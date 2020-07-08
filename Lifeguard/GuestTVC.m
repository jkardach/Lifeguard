//
//  GuestTVC.m
//
//  Created by jim kardach on 5/5/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//

#import "GuestTVC.h"
#import "Constants.h"
#import "FamilyRec.h"
#import "FileRoutines.h"
#import "ShowCheckedInTVC.h"
#import "getTemps.h"
#import "AppDelegate.h"
#import "calObj.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-w documentation"
#import "GTLRSheets.h"
#pragma clang diagnostic pop

@interface GuestTVC () <getTempsDelegate>  // post 5.0 google sign-in
@property (nonatomic, strong) GTLRSheetsService *sheetService;  // to contain the shared auth
@property (nonatomic, strong) GTLRCalendarService *calendarService;  // to contain the shared auth
@property (nonatomic, strong) GIDGoogleUser *theUser;   // to contain the shared user var
@property (nonatomic, strong) AppDelegate *appDelegate;  // var for appDelegate

@property (nonatomic, strong) NSMutableArray *families;
@property (nonatomic, strong) NSMutableArray *checkedInToday;
@property (nonatomic) int guestRow;
@property (nonatomic) int guestValue;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSMutableArray *todayCalEvents;
@property (nonatomic, strong) NSMutableArray *calArray;

@property (nonatomic, strong) FileRoutines *tools;
@property (nonatomic, strong) FamilyRec *recToDelete;
@property (nonatomic) int maxSections;
@property (nonatomic, strong) getTemps *temps;
@property (nonatomic, strong) FamilyRec *recToUpdate;
@end

@implementation GuestTVC

#pragma mark setters/getters
// array of all members (PM, Lease, Trial)
- (NSMutableArray *)families {
    if (!_families) {
        _families = [[NSMutableArray alloc] init];
    }
    return _families;
}

// array of members checked in today
- (NSMutableArray *)checkedInToday {
    if (!_checkedInToday) {
        _checkedInToday = [[NSMutableArray alloc] init];
    }
    return _checkedInToday;
}

// array of today's calendar events
- (NSMutableArray *)calArray {
    if (!_calArray) {
        _calArray = [[NSMutableArray alloc] init];
    }
    return _calArray;
}

- (FileRoutines *)tools {
    if (!_tools) {
        _tools = [[FileRoutines alloc] init];
    }
    return _tools;
}

- (NSDate *)currentDate {
    if (!_currentDate) {
        _currentDate = [NSDate date];
    }
    return _currentDate;
}

- (getTemps *) temps {
    if (!_temps) {
        _temps = [[getTemps alloc] init];
    }
    return _temps;
}

#pragma mark viewcontroller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.sheetService = self.appDelegate.sheetService;
    self.calendarService = self.appDelegate.calendarService;
    
    self.theUser = self.appDelegate.theUser;  // added post 5.0 google sign-in to have user data
    
    // observe orientation change notification, to reload table view when device rotated
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveGuestAuthUINotification:)
     name:@"authUINotification"
     object:nil];
    
    // add refresh control to allow sheets/devices to reload when pulled down
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"]; //to give the attributedTitle
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Saratoga Swim Club - SignIn, V%@", appVersionString]];
}

// When the view appears, ensure that the Google Sheets API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    // get shared instance of getTemps which has the particle.io devices
    self.temps = [getTemps sharedInstance];
    self.temps.delegate = self;
    [self.temps getDevices];
    
    [self.appDelegate signInToGoogle:self];
}

// removes the record (FamilyRec) from the Accounts.SignIn spreadsheet
- (void) removeRecFromSignIn:(FamilyRec *)rec
{
    // find the row of the record in SignIn
    self.recToDelete = rec;
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"SignIn!A2:N"];
    
    [self.sheetService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        int rowOfRec = 0;
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                for (NSArray *row in rows) {
                    if (row.count > 1) {
                        FamilyRec *rec = [self convertToSignIn:row];
                        if ((rec.memberID == self.recToDelete.memberID) && (rec.lastName == self.recToDelete.lastName)) {
                            break;
                        }
                    } else {
                        break;
                    }
                    rowOfRec++;
                }
            }
            [self deleteRow:rowOfRec+1];  // increment row as spreadsheet starts at 1, not 0
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting display result Signin sheet data: %@\n", error.localizedDescription];
            [self showAlert:@"Error" message:message];
        }
    }];
}

// this writes family record to the signIn
- (void)writeGuest:(FamilyRec *)member
{
    GTLRSheets_ValueRange *value = [[GTLRSheets_ValueRange alloc] init];
    NSNumber *guestNum = [NSNumber numberWithInt:member.guests];
    NSNumber *memberNum = [NSNumber numberWithInt:member.members];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    NSString *elg = @"NO";
    if (member.eligable) {
        elg = @"YES";
    }
    NSArray *valueArray = @[@[dateString, member.lastName, member.memberID,
                              memberNum, guestNum, member.kidsDroppedOff,
                              member.familyMembers, member.memType, member.phone,
                              member.email, member.phone2, member.email2,
                              member.optPhone, elg]];
    value.values = valueArray;

    GTLRSheetsQuery_SpreadsheetsValuesAppend *query =
    [GTLRSheetsQuery_SpreadsheetsValuesAppend queryWithObject:value
                                                spreadsheetId:ACT_SSHEET_ID
                                                        range:@"SignIn!A1"];
    query.valueInputOption = @"USER_ENTERED";

    [self.sheetService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        if (error == nil) {
            [self readLog];
    
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting update sheet data: %@\n", error.localizedDescription];
            [self showAlert:@"Error" message:message];
        }
    }];
}


// this reads the record from the SignIn sheet on the account spreadsheet
- (void)readLog {
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"SignIn!A2:N"];
    [self.sheetService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                self.checkedInToday = nil;
                int arrayRow = 0;
                for (NSArray *row in rows) {
                    if (row.count > 1) {
                        FamilyRec *rec = [self convertToSignIn:row];
                        if (rec) {
                            rec.signInRow = arrayRow+2;                 // zero based row
                            [self.checkedInToday addObject:rec];  // add to checkedInToday Array
                        }
                    }
                    arrayRow++;
                }
            }
            [self readbatchSheet];
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting display result Signin sheet data: %@\n", error.localizedDescription];
            [self showAlert:@"Error" message:message];
        }
    }];
}

// deletes the row in the spreadsheet.  row is the spreadsheet row (starts at 1)
- (void)deleteRow:(int) row {
    // sign-in tab of accounts sheet is edit#gid=744046825
    [self delRow:row spreadSheetId:ACT_SSHEET_ID sheetId:@(744046825)];
}


- (void)delRow:(int) row  spreadSheetId:(NSString *)spreadsheetId sheetId:(NSNumber *)sheetId {
    GTLRSheets_DeleteDimensionRequest *delDimReq = [[GTLRSheets_DeleteDimensionRequest alloc] init];
    GTLRSheets_Request *sheetsRequest = [[GTLRSheets_Request alloc] init];
    sheetsRequest.deleteDimension = delDimReq;
    
    GTLRSheets_DimensionRange *range = [[GTLRSheets_DimensionRange alloc] init];
    range.dimension = @"ROWS";
    range.sheetId = sheetId;
    range.startIndex = @(row);  // row to delete inclusive
    range.endIndex = @(row + 1);    // row to delete exclusive
    
    delDimReq.range = range;
    
    GTLRSheets_BatchUpdateSpreadsheetRequest *request = [[GTLRSheets_BatchUpdateSpreadsheetRequest alloc] init];
    request.includeSpreadsheetInResponse = 0;
    request.responseIncludeGridData = 0;
    request.requests = @[sheetsRequest];

    GTLRSheetsQuery_SpreadsheetsBatchUpdate *query = [GTLRSheetsQuery_SpreadsheetsBatchUpdate
                                                      queryWithObject:(GTLRSheets_BatchUpdateSpreadsheetRequest *) request
                                                      spreadsheetId: spreadsheetId];
    NSLog(@"Deleting Row: %D", row);
    [self.sheetService executeQuery:query
                      completionHandler:^(GTLRServiceTicket *ticket,
                                          GTLRSheets_ValueRange *result,
                                          NSError *error) {
            if (error == nil) {
                [self readLog];
        
            } else {
                NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
                [self showAlert:@"Error" message:message];
            }
        }];
}

// defined in Constants.h: ACT_SSHEET_ID = 1AE2j_p2O5e9K_x1-WLiUsZu-SOq5oi5QYsKD6OGMvCQ
// get values from Members sheet (PM, Lease, Trial)
- (void)readbatchSheet {
    GTLRSheetsQuery_SpreadsheetsValuesGet *query1 =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Members!A2:R86"];  // PM
    GTLRSheetsQuery_SpreadsheetsValuesGet *query2 =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Members!A89:R99"];  // Lease
    GTLRSheetsQuery_SpreadsheetsValuesGet *query3 =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Members!A127:R139"];  // Trial
    GTLRBatchQuery *batchQuery = [GTLRBatchQuery batchQuery];
    [batchQuery addQuery:query1];
    [batchQuery addQuery:query2];
    [batchQuery addQuery:query3];
    
    [self.sheetService executeQuery:batchQuery
        completionHandler:^(GTLRServiceTicket *callbackTicket,
                            GTLRBatchResult *batchResult,
                            NSError *error) {
            if (error == nil) {
                NSDictionary *successes = batchResult.successes;
                self.families = nil;  // clear out array
                for (NSString *requestID in successes) {
                    GTLRSheets_ValueRange  *result = [successes objectForKey:requestID];
                    NSArray *rows = result.values;
                    if (rows.count > 0) {
                        
                        for (NSArray *row in rows) {
                            if (row.count > 1) {
                                FamilyRec *rec = [self convertToFamObj: row];
                                if (rec)
                                    [self.families addObject:rec];  // add to famalies Array
                            } else {
                                break;
                            }
                        }
                    }
                }
                [self readTodaysResCal];

            } else {
                NSString *message = [NSString stringWithFormat:@"Error getting display result Signin sheet data: %@\n", error.localizedDescription];
                [self showAlert:@"Error" message:message];
            }
        }];
}

- (void)readSheet {
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Accounts!A3:AQ"];
    [self.sheetService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                self.families = nil;
                for (NSArray *row in rows) {
                    if (row.count > 1) {
                        FamilyRec *rec = [self convertToFamObj: row];  // converts to family object
                        if (rec)
                            [self.families addObject:rec];  // add to famalies Array
                    } else {
                        break;
                    }
                }
            }

            [self readTodaysResCal];
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting display result sheet data: %@\n", error.localizedDescription];
            [self showAlert:@"Error" message:message];
        }
    }];
}


- (void)readTodaysResCal {
    // get the Accounts tab of the SSC sheet;
    //NSString *calId = @"lssmnscr8a49bcg51knvtgo234@group.calendar.google.com";  // the reservation calendar
    NSString *calId = @"45hmspi6f6ur1i6h62et9tet08@group.calendar.google.com";   // the test calendar
    // create events list query
    GTLRCalendarQuery_EventsList *query = [GTLRCalendarQuery_EventsList queryWithCalendarId:calId];
    query.maxResults = 40;
    NSArray *times = [self getDateTime];
    query.timeMin = times[0];   // add today at 8AM
    query.timeMax = times[1];  // to today at 11PM
    
    query.executionParameters.shouldFetchNextPages = @YES;
    query.executionParameters.retryEnabled = @YES;
    query.executionParameters.maxRetryInterval = @15;
    query.singleEvents = YES;
    query.orderBy = kGTLRCalendarOrderByStartTime;
    
    [self.calendarService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                                 GTLRCalendar_Events *events,
                                                                 NSError *error) {
        if (error == nil) {
            if (events.items.count > 0) {
                self.calArray = nil;
                calObj *cal;
                for (GTLRCalendar_Event *item in events) {
                    cal = [[calObj alloc] init];
                    cal.memberId = [item.summary stringByReplacingOccurrencesOfString:@"#" withString:(@"")];
                    cal.end = [self stringFromDateTime: [item.end valueForKey:@"dateTime"]];
                    cal.start = [self stringFromDateTime: [item.start valueForKey:@"dateTime"]];
                    NSString *tempStr = [cal.start substringFromIndex:2];
                    if ([tempStr isEqualToString:@":30"]) {
                        cal.lapSwimmer = YES;
                    }
                    [self.calArray addObject:cal];
                }
                [self addResToFamiles];
                
                // sort the families array such that (checked in on top and alphabetical, then rest alphabetical)
                // Set ascending:NO so that "YES" would appear ahead of "NO"
                NSSortDescriptor *checkedBool = [[NSSortDescriptor alloc] initWithKey:@"checked" ascending:NO];
                
                NSSortDescriptor *resStart = [[NSSortDescriptor alloc] initWithKey:@"resStart" ascending:YES];
                // String are alphabetized in ascending order
                NSSortDescriptor *lastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
                // set assending:No so that "YES" would appear ahead of "NO"
                NSSortDescriptor *hasResBool = [[NSSortDescriptor alloc] initWithKey:@"hasRes" ascending:NO];
                // Combine the two
                NSArray *sortDescriptors = @[hasResBool, resStart, checkedBool, lastName];
                // Sort your array
                self.families = [NSMutableArray arrayWithArray:[self.families sortedArrayUsingDescriptors:sortDescriptors]];
                self.checkedInToday = [NSMutableArray arrayWithArray:[self.checkedInToday sortedArrayUsingDescriptors:sortDescriptors]];
                
                [self.tableView reloadData];
                [self.tableView.refreshControl endRefreshing];
                
                // scroll to top of tableview
                if (@available(iOS 11.0, *)) {
                    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.adjustedContentInset.top) animated:YES];
                } else {
                    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
                }
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting display result sheet data: %@\n", error.localizedDescription];
            [self showAlert:@"Error" message:message];
        }
    }];
}

- (NSString *) stringFromDateTime:(GTLRDateTime *) date {
    NSDate *today = date.date;
    NSDateFormatter* pstDf = [[NSDateFormatter alloc] init];
    [pstDf setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
    [pstDf setDateFormat:@"HH:mm"];
    NSString *dateStr = [pstDf stringFromDate:today];
    

    return dateStr;
}

// helper function to add time to date and put in GTLRDateTime format
// Utility routine to make a GTLRDateTime object for sometime today
- (NSArray *)getDateTime {
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *startDate = [NSString stringWithFormat:@"%@T00:00:00-07:00", dateString];
    NSString *stopDate = [NSString stringWithFormat:@"%@T23:00:00-07:00", dateString];
    
    GTLRDateTime *startDateTime = [GTLRDateTime dateTimeWithRFC3339String:startDate];
    GTLRDateTime *endDateTime = [GTLRDateTime dateTimeWithRFC3339String:stopDate];
    return @[startDateTime, endDateTime];
}

// add reservation values to Family and checked-in arrays
- (void)addResToFamiles {
    for (int i = 0; i < self.families.count; i++) {
        FamilyRec *rec = self.families[i];
        for (calObj *cal in self.calArray) {
            if ([cal.memberId isEqualToString:rec.memberID]) {
                rec.hasRes = YES;
                rec.resStart = cal.start;
                rec.resStop = cal.end;
                rec.lapSwimmerRes = cal.lapSwimmer;
                if (rec.lapSwimmerRes) {
                    rec.lapSwimmers++;  // if this is a lapswimmer res, inc lap swimmers
                }
            }
        }
    }
    for (int i = 0; i < self.checkedInToday.count; i++) {
        FamilyRec *rec = self.checkedInToday[i];
        for (calObj *cal in self.calArray) {
            if ([cal.memberId isEqualToString:rec.memberID]) {
                rec.hasRes = YES;
                rec.resStart = cal.start;
                rec.resStop = cal.end;
            }
        }
    }
    self.calArray = nil;
}

// this creates an array which updates the specified row
- (void)updateRecord:(FamilyRec *)recordToUpdate
{
    GTLRSheets_ValueRange *value = [[GTLRSheets_ValueRange alloc] init];
    value.values = [self createValueArrayFromFamilyRecord:recordToUpdate];
    
    GTLRSheetsQuery_SpreadsheetsValuesUpdate *query =
    [GTLRSheetsQuery_SpreadsheetsValuesUpdate queryWithObject:value
                                                spreadsheetId:ACT_SSHEET_ID
                                                        range:[NSString stringWithFormat:@"SignIn!A%d", recordToUpdate.signInRow]];
    query.valueInputOption = @"USER_ENTERED";
    [self.sheetService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        if (error == nil) {
            [self readSheet];
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting update sheet data: %@\n", error.localizedDescription];
            [self showAlert:@"Error" message:message];
        }
    }];
}

- (NSArray *) createValueArrayFromFamilyRecord:(FamilyRec *)record
{
    NSArray *valueArray = @[
                       @[record.date, record.lastName,
                         record.memberID,
                         [NSString stringWithFormat:@"%D", record.members],
                         [NSString stringWithFormat:@"%D", record.guests],
                         record.kidsDroppedOff,record.familyMembers,
                         record.memType, record.phone, record.email,
                         record.phone2, record.email2, record.optPhone]
                       ];

    return valueArray;
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source
// 1st section is for temperatures
// 2nd section is form members checked-in
// 3rd section is for members not signed-in
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.checkedInToday.count > 0) {
        self.maxSections = 3;
    } else {
        self.maxSections = 2;
    }
    return self.maxSections;
}

// section 0 is always 3
// if three sections, sec 1 is checkedInToday.count, and sec 2 is families.count
// if two sections, sec 1 is famlies.count
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (((section == 2)&&(self.maxSections==3)) || ((section == 1)&&(self.maxSections==2))) {
        return self.families.count;
    } else {
        return self.checkedInToday.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    int tvWidth = tableView.frame.size.width - 10;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0,tvWidth, 50)];
    headerView.backgroundColor = [self.tools getUIColorObjectFromHexString:@"#b2bec3" alpha:1];;
    
    UILabel *headerTxt = [[UILabel alloc] initWithFrame:CGRectMake(5, 15,tvWidth, 22)];
    headerTxt.textAlignment = NSTextAlignmentLeft;
    [headerTxt setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    
    UILabel *famMem = [[UILabel alloc] initWithFrame:CGRectMake(5, 15,tvWidth, 22)];
    famMem.textAlignment = NSTextAlignmentRight;
    
    [famMem setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    
    if (section == 0) {
        headerTxt.text = @"CL Spa:3-10ppm Pool:2-10ppm";
        headerTxt.textColor = [self.tools getUIColorObjectFromHexString:@"#e17055" alpha:1];
        famMem.text = @"pH:7.2-7.8";
        famMem.textColor = [self.tools getUIColorObjectFromHexString:@"#0984e3" alpha:1];
    } else if (((section == 2)&&(self.maxSections==3)) || ((section == 1)&&(self.maxSections==2))) {
        UILabel *center = [[UILabel alloc] initWithFrame:CGRectMake(5, 15,tvWidth, 22)];
        center.textAlignment = NSTextAlignmentCenter;
        [center setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
        center.text = @"Click to sign-in";
        center.textColor = [self.tools getUIColorObjectFromHexString:@"#0097e6" alpha:1];
        [headerView addSubview:center];
        
        headerTxt.text = @" Family(type,ID):";
        headerTxt.textColor = [UIColor blackColor];
        famMem.text = @"# Fam Members ";
        famMem.textColor = [UIColor blackColor];
    } else {
        headerTxt.text = @" Signed-In Family(type,ID):";
        headerTxt.textColor = [UIColor blackColor];
        famMem.text = @"# Signed-In";
        famMem.textColor = [UIColor blackColor];
    }
    [headerView addSubview:famMem];
    [headerView addSubview:headerTxt];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyRec *member;
    int section = (int)indexPath.section;
    UITableViewCell *cell;
    if (section == 0) {  // temperatures
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    } else if ((section == 1)&&(self.maxSections==3)) {  // checked-in
        cell = [tableView dequeueReusableCellWithIdentifier:@"Celld" forIndexPath:indexPath];
        member = self.checkedInToday[indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%D",member.guests + member.members];
    } else {  // families
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        member = self.families[indexPath.row];
        cell.detailTextLabel.text = member.familyMembers;
    }
    // default
    cell.imageView.image = nil;  // default
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    [cell.textLabel setFont:[UIFont fontWithName:@"System" size:17]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"System" size:17]];
    if (![self sameDay:self.currentDate]) {
        [self clearCheckmarks];
    }
    if (indexPath.section == 0) {
        cell.backgroundColor = [UIColor yellowColor];
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"Ambient Temperature:";
                cell.detailTextLabel.text = self.temps.ambTemp;
                break;
            case 1:
                cell.textLabel.text = @"Pool Temperature:";
                cell.detailTextLabel.text = self.temps.poolTemp;
                break;
             case 2:
                cell.textLabel.text = @"Spa Temperature:";
                cell.detailTextLabel.text = self.temps.spaTemp;
                break;
            default:
                cell.textLabel.text = @"";
                cell.detailTextLabel.text = @"";
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // make odd rows light blue

    } else {
        if (!member.eligable) {
            cell.imageView.image = [UIImage imageNamed:@"xSwimClub10mm"];
        } else {
            if (member.hasRes) {
                cell.imageView.image = [UIImage imageNamed:@"gSwimClub10mm"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"SwimClub10mm"];
            }
        }
        
        if (member.checked) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (member.droppedOff) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@,%@): Dropped Off: %@", member.lastName, member.memType, member.memberID, member.kidsDroppedOff];
        } else if (member.hasRes){
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@,%@), R:%@", member.lastName, member.memType,
                                   member.memberID, member.resStart];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@,%@)", member.lastName, member.memType, member.memberID];
        }
        
        // make odd rows light blue
        UIColor *lightBlue = [UIColor colorWithRed: 131.0/255.0 green: 241.0/255.0 blue:255.0/255.0 alpha: 1.0];
        
        if (member.droppedOff) {
            cell.backgroundColor = [self.tools getUIColorObjectFromHexString:@"#74b9ff" alpha:0.9];
        } else if (![self even:(int)indexPath.row]) {
            // light blue color
            cell.backgroundColor = lightBlue;
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

- (NSString *)formatRes:(NSString *) start {
    NSArray *strings = [start componentsSeparatedByString:@" "];
    NSString *tempString = strings[1];
    tempString = [tempString substringToIndex:tempString.length-2];
    tempString = [NSString stringWithFormat: @"%@0", tempString];
    return tempString;
}

- (BOOL)sameDay:(NSDate *) currentDate {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    unsigned unitFlags = NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:currentDate];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:now];
    
    return [comp1 day] == [comp2 day];
}
         
- (BOOL)even:(int)value
{
    return (value%2) ? YES : NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL edit = NO;
    if((indexPath.section == 1)&& (self.maxSections==3)) {
        edit = YES;
    }
 return edit;
 }

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FamilyRec *rec = self.checkedInToday[indexPath.row];
        [self.checkedInToday removeObjectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self removeRecFromSignIn: rec];
    }
}

// this picks the family member which will be checked in, which is either section 2&&max3 or sectoin 1 max2
// but not section 0 or section 1 max 3 (which returns)
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) || ((indexPath.section == 1)&&(self.maxSections==3)))
        return;
    FamilyRec *member = self.families[indexPath.row];
    if(!member.lapSwimmerRes) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@(%@) Family",
                                                                                member.lastName, member.memberID]
                                                                       message:@"How many members and guests are you checking in?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"(number of) members";
            textField.textColor = [UIColor blueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            [textField setKeyboardType:UIKeyboardTypeNumberPad ];
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"(number of) guests";
            textField.textColor = [UIColor blueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            [textField setKeyboardType:UIKeyboardTypeNumberPad ];
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray *textfields = alert.textFields;
            UITextField *members = textfields[0];
            UITextField *guests = textfields[1];
            member.checked = YES;
            //NSLog(@"%@",guests.text);
            member.members = [members.text intValue];
            member.guests = [guests.text intValue];
            [self.checkedInToday addObject:member];
            [tableView reloadData];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            
            [self writeGuest:(FamilyRec *)member];   // update database
            [tableView reloadData];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Drop Off Children" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray *textfields = alert.textFields;
            UITextField *members = textfields[0];
            UITextField *guests = textfields[1];
            member.checked = YES;
            //NSLog(@"%@",guests.text);
            member.members = [members.text intValue];
            member.guests = [guests.text intValue];
            [self getNamesOfKids:(FamilyRec *) member];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // this is a lapswimmer with reservation
        member.members = (int)member.lapSwimmers;
        member.checked = YES;
        [self writeGuest: member];
        [self.tableView reloadData];
    }
}

- (void)getNamesOfKids:(FamilyRec *)member {
    NSString *message;
    if ([member.phone2 isEqualToString:@""]) {
        message = [NSString stringWithFormat:@"Please enter the names of the children being dropped off, each name seperated by a comma.\nPhone: %@\nIn the 2nd Row enter an emergency cell number if number is not in current database", member.phone];
    } else {
        message = [NSString stringWithFormat:@"Please enter the names of the children being dropped off, each name seperated by a comma.\nPhone: %@\nPhone2:%@\nIn the 2nd Row enter an emergency cell number if number is not in current database", member.phone, member.phone2];
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@(%@) Family Children Drop Off", member.lastName, member.memberID]
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"name(age), name(age), name(age), ...";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [textField setKeyboardType:UIKeyboardTypeDefault];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"(xxx) ttt-tttt";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [textField setKeyboardType:UIKeyboardTypeDefault];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray *textfields = alert.textFields;
        UITextField *kids = textfields[0];
        UITextField *optPhone = textfields[1];
        member.kidsDroppedOff = kids.text;
        member.optPhone = optPhone.text;
        member.checked = YES;
        member.droppedOff = YES;
        //NSLog(@"%@",kids.text);
        [self writeGuest: member];
        [self.tableView reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self writeGuest:member];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// converts record from sign-in sheet to familyRec
- (FamilyRec *)convertToSignIn: (NSArray *)input {
    if (input.count > 0) {     // date
        NSString *recDateStr = input[0];
        if (![self isToday:[self stringToDate:recDateStr]] || ([input[0] isEqualToString:@"Date Time"])) {
            return nil;   // if not today, return empty
        }
    }
    FamilyRec *rec = [[FamilyRec alloc] init];  // create a record
    if (input.count > 0) {      // date
        rec.date = input[0];
    }
    if (input.count > 1) {     // lastname
        rec.lastName = input[1];
    }
    if (input.count > 2) {     // member id
        rec.memberID = input[2];
    }
    if (input.count > 3) {      //
        rec.members = [(NSString *)input[3] intValue];
    }
    if (input.count > 4) {     // number of guests
        rec.guests = [(NSString *)input[4] intValue];
    }
    if (input.count > 5) {     // number of kids dropped off
        rec.kidsDroppedOff = input[5];
    }
    if (input.count > 6) {     // number of family members
        rec.familyMembers = input[6];
    }
    if (input.count > 7) {     // membership type
        rec.memType = input[7];
    }
    if (input.count > 8) {     // member phone number
        rec.phone = input[8];
    }
    if (input.count > 9) {     // member email
        rec.email = input[9];
    }
    if (input.count > 10) {     // member phone number 2
        rec.phone2 = input[10];
    }
    if (input.count > 11) {     // member email 2
        rec.email2 = input[11];
    }
    if (input.count > 12) {     // member optional phone
        rec.optPhone = input[12];
    }
    if (input.count > 13) {     // member eligible for reservations
        
        if ([input[13] isEqualToString:@"YES"]) {
            rec.eligable = YES;
        } else {
            rec.eligable = NO;
        }
    }
    rec.checked = YES;
    if (![rec.kidsDroppedOff isEqualToString:@""]) {  // kids dropped off?
        rec.droppedOff = YES;
    }
    return rec;
}

// indicates if this record is from today (current date)
-(BOOL) isToday:(NSDate *)aDate {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
                                          fromDate:self.currentDate];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:aDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    BOOL isToday = [today isEqualToDate:otherDate];
    return isToday;
}

// converts a string date to the yyyy-MM-dd HH:mm format
- (NSDate *)stringToDate:(NSString *)dateStr {
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormat dateFromString:dateStr];
}

// clear the checked-in checkmarks fromthe records
- (void) clearCheckmarks {
    for (FamilyRec *rec in self.families) {
        rec.checked = NO;
        rec.droppedOff = NO;
        rec.kidsDroppedOff = @"";
    }
}

// converts memberSheet record to family object, remove CL, PL records
- (FamilyRec *) convertToFamObj: (NSArray *)member {
    FamilyRec *rec;
    if (member[0]) {
        if (([member[0] isEqualToString: @"Certificate Number"]) ||
            [member[2] isEqualToString:@"CL"] || [member[2] isEqualToString:@"PL"]) {
            return nil;      // this is the header, remove
        } else {
            rec = [[FamilyRec alloc] init];
        }
    }
    
    if (member.count > 1) {     // member ID
        rec.memberID = member[1];
    }
    if (member.count > 0) {     // member last name
        rec.lastName = member[0];
        if ([rec.lastName isEqualToString:@""]) {
            return nil;
        }
    }
    if (member.count > 2) {     // membership type
        rec.memType = member[2];
    }
    if (member.count > 7) {     // member phone
        rec.phone = member[7];
    }
    if (member.count > 9) {     // member email
        rec.email = member[9];
    }
    if (member.count > 8) {     // member phone 2
        rec.phone2 = member[8];
    }
    if (member.count > 10) {     // member email 2
        rec.email2 = member[10];
    }
    if (member.count > 16) {
        rec.familyMembers = member[16];
    }
    // indicates if member is eligable to swim
    rec.eligable = YES;
    if (member.count > 17) {
        NSString *owesMoney = member[17];
        if ([owesMoney isEqualToString:@"x"] ||
            [rec.memType isEqualToString:@"PL"]) {
            rec.eligable = NO;
        }
        if ([rec.memType isEqualToString:@"BD"] ||
            [rec.memType isEqualToString:@"BE"] ) {
            rec.eligable = YES;
        }

    }
    // if record is in checkedInToday, then use this record
    return [self isCheckedInToday: rec];  // if checked in today, then replaces record
}

- (FamilyRec *) isCheckedInToday: (FamilyRec *)rec {
    for (FamilyRec *checkedInRec in self.checkedInToday) {
        if ([rec.memberID isEqualToString:checkedInRec.memberID] && [rec.lastName isEqualToString:checkedInRec.lastName]) {
            return nil;  // if checked in, remove from member array
        }
    }
    return rec;
}

 #pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowCheckedIn"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        self.recToUpdate = (FamilyRec *) self.checkedInToday[path.row];  // grab the record being updated
        
        ShowCheckedInTVC *sciTVC = [segue destinationViewController];
        sciTVC.title = [NSString stringWithFormat:@"%@(%@, %@)", self.recToUpdate.lastName, self.recToUpdate.memType, self.recToUpdate.memberID];
        sciTVC.member = self.recToUpdate;
    }
}

// This is a notification executed after successful signIn
- (void) receiveGuestAuthUINotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"authUINotification"]) {
        if (self.recToUpdate) {
            if (self.recToUpdate.updated) {
                [self updateRecord:self.recToUpdate];
                self.recToUpdate = nil;
            }
        } else {
            [self readLog];  // already logged in, go read spreadsheet
        }
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    [self.tableView reloadData];
}

-(void) refreshData {
    [self.tableView reloadData];
}

- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self.temps refreshTemps];  // refresh the particle.io temperatures
    [self readLog]; //call function you want
    [refreshControl endRefreshing];
}

- (IBAction)reLogin:(UIBarButtonItem *)sender
{
    [self.appDelegate reSignInToGoogle:self];
}
@end
