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
#import "Reservations.h"
#import "Alert.h"

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
@property (nonatomic, strong) NSMutableArray *missedResToday;
@property (nonatomic, strong) NSMutableArray *reservationsToday;
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
@property (nonatomic, strong) Reservations *resSummary;
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

// array of members with reservations today
- (NSMutableArray *)reservationsToday {
    if (!_reservationsToday) {
        _reservationsToday = [[NSMutableArray alloc] init];
    }
    return _reservationsToday;
}

// array of members who missed their today's reservation
- (NSMutableArray *)missedResToday {
    if (!_missedResToday) {
        _missedResToday = [[NSMutableArray alloc] init];
    }
    return _missedResToday;
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

- (Reservations *)resSummary {
    if (!_resSummary) {
        _resSummary = [[Reservations alloc] init];
    }
    return _resSummary;
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
                                                            range:@"SignIn!A2:V"];
    
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
                        FamilyRec *rec = [FamilyRec convertToSignIn:row];
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
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
}

// this writes family record to the signIn
- (void)writeGuest:(FamilyRec *)member
            values:(NSArray *)values
           sheetID:(NSString *)sheetID
        sheetRange:(NSString *)sheetRange
{
    GTLRSheets_ValueRange *value = [[GTLRSheets_ValueRange alloc] init];

    value.values = values;

    GTLRSheetsQuery_SpreadsheetsValuesAppend *query =
    [GTLRSheetsQuery_SpreadsheetsValuesAppend queryWithObject:value
                                                spreadsheetId:sheetID
                                                        range:sheetRange];
    query.valueInputOption = @"USER_ENTERED";

    [self.sheetService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        if (error == nil) {
            [self readLog];
    
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting update sheet data: %@\n", error.localizedDescription];
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
}


// this reads the record from the SignIn sheet on the account spreadsheet
- (void)readLog {
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"SignIn!A2:V"];
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
                        FamilyRec *rec = [FamilyRec convertToSignIn:row];
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
            [Alert showAlert:@"Error" message:message viewController:self];
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
    [self.sheetService executeQuery:query
                      completionHandler:^(GTLRServiceTicket *ticket,
                                          GTLRSheets_ValueRange *result,
                                          NSError *error) {
            if (error == nil) {
                [self readLog];
        
            } else {
                NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
                [Alert showAlert:@"Error" message:message viewController:self];
            }
        }];
}

// defined in Constants.h: ACT_SSHEET_ID = 1AE2j_p2O5e9K_x1-WLiUsZu-SOq5oi5QYsKD6OGMvCQ
// get values from Members sheet (PM, Lease, Trial)
- (void)readbatchSheet {
    GTLRSheetsQuery_SpreadsheetsValuesGet *query1 =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Members!A2:V86"];  // PM
    GTLRSheetsQuery_SpreadsheetsValuesGet *query2 =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Members!A89:V99"];  // Lease
    GTLRSheetsQuery_SpreadsheetsValuesGet *query3 =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Members!A127:V139"];  // Trial
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
                                FamilyRec *rec = [FamilyRec convertToFamObj: row];
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
                [Alert showAlert:@"Error" message:message viewController:self];
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
                        FamilyRec *rec = [FamilyRec convertToFamObj: row];  // converts to family object
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
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
}


- (void)readTodaysResCal {
    NSString *calId = @"lssmnscr8a49bcg51knvtgo234@group.calendar.google.com";  // the reservation calendar
    //NSString *calId = @"45hmspi6f6ur1i6h62et9tet08@group.calendar.google.com";   // the test calendar
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
                    cal.resDate = self.resSummary.dateString;
                    cal.memberId = [item.summary stringByReplacingOccurrencesOfString:@"#" withString:(@"")];
                    cal.end = [self stringFromDateTime: [item.end valueForKey:@"dateTime"]];
                    NSString *start = [self stringFromDateTime: [item.start valueForKey:@"dateTime"]];
                    start = [start stringByReplacingOccurrencesOfString:@"^0+"
                                                                       withString:@""
                                                                          options:NSRegularExpressionSearch
                                                                            range:NSMakeRange(0, start.length)];
                    NSString *minutes = [start componentsSeparatedByString:@":"][1];
                    
                    if ([minutes isEqualToString:@"30"]) {
                        cal.lapSwimmer = YES;
                        cal.lapStart = start;
                    } else {
                        cal.start = start;
                    }
                    [self.calArray addObject:cal];
                }
                [self addResToFamiles];  // this guy needs to remove the signed-in ones, as they now have time info

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
            [Alert showAlert:@"Error" message:message viewController:self];
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
    NSString *dateString = [dateFormatter stringFromDate:self.resSummary.date];
    
    NSString *startDate = [NSString stringWithFormat:@"%@T00:00:00-07:00", dateString];
    NSString *stopDate = [NSString stringWithFormat:@"%@T23:00:00-07:00", dateString];
    
    GTLRDateTime *startDateTime = [GTLRDateTime dateTimeWithRFC3339String:startDate];
    GTLRDateTime *endDateTime = [GTLRDateTime dateTimeWithRFC3339String:stopDate];
    return @[startDateTime, endDateTime];
}

// add reservation values to Family array
// if lapSwimmer, create a new record
- (void)addResToFamiles {
    [self.resSummary reset];
    [self.reservationsToday removeAllObjects];
    [self.missedResToday removeAllObjects];
    NSMutableArray *lapArray = [[NSMutableArray alloc] init];
    // add reservation data to family records
    for (int i = 0; i < self.families.count; i++) {
        FamilyRec *rec = self.families[i];
        for (calObj *cal in self.calArray) {
            if ([cal.memberId isEqualToString:rec.memberID]) {

                if (cal.lapSwimmer) {
                    FamilyRec *lapRec = [rec copy];
                    lapRec.hasRes = YES;  // member matches reservation, hasRes
                    lapRec.resStart = @"";  // blank out normal reservations from copy
                    lapRec.resStop = @"";   // blank out normal reservations from copy
                    lapRec.resDate = cal.resDate;
                    lapRec.lapStart = cal.lapStart;
                    lapRec.lapSwimmerRes = YES;
                    lapRec.lapSwimmers = 1;
                    [lapArray addObject:lapRec];  // add them to seperate array
                } else {
                    rec.hasRes = YES;  // member matches reservation, hasRes
                    rec.resDate = cal.resDate;
                    rec.resStop = cal.end;
                    rec.resStart = cal.start;
                }
                [self.reservationsToday addObject: rec];
                if ([rec didTheyMissReservation]) {
                    [self.missedResToday addObject:rec];
                }
            }
        }
    }
    // add the lap swimmers back into the family array, if duplicate combine into single record
    // has to have two or more records to have a duplicate
    NSMutableArray *dupArray = [[NSMutableArray alloc] init];
    if (lapArray.count>=2) {
        FamilyRec *lastRec = lapArray[0];
        for (int i = 1; i < lapArray.count; i++) {
            FamilyRec *rec = lapArray[i];
            if (([lastRec.memberID isEqualToString:rec.memberID])&&
                ([lastRec.lapStart isEqualToString:rec.lapStart])) {
                // duplicate record
                lastRec.lapSwimmers = 2;
                [dupArray addObject:rec];
            }
            lastRec = rec;
        }
    }
    [lapArray removeObjectsInArray:dupArray];  // remove these objects
    [self.families addObjectsFromArray:lapArray];

    // go through the checked in families, and update cal reservation if needed
//    for (int i = 0; i < self.checkedInToday.count; i++) {
//        FamilyRec *rec = self.checkedInToday[i];
//        for (calObj *cal in self.calArray) {
//            if ([cal.memberId isEqualToString:rec.memberID]) {
//                //rec.hasRes = YES;  // check-in already, so update hasRes in case
//                rec.resDate = cal.resDate;
//                if (cal.lapSwimmer) {
//                    rec.lapStart = cal.lapStart;
//                    rec.lapSwimmers = cal.numberLapSwimmers;
//                    rec.lapSwimmerRes = cal.lapSwimmer;
//                } else {
//                    rec.resStart = cal.start;
//                    rec.resStop = cal.end;
//                }
//            }
//        }
//    }
    
    // need to remove checked-In members from Family Array, but only exact matches
    [self removeResFromFamilies];
    
    self.calArray = nil;
}

-(void)removeResFromFamilies {
    NSMutableArray *recsToDel = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.checkedInToday.count; i++) {
        FamilyRec *checkInRec = self.checkedInToday[i];
        for (FamilyRec *famRec in self.families) {
            if([checkInRec.memberID isEqualToString:famRec.memberID]) {
                if(checkInRec.hasRes && [checkInRec.resStart isEqualToString:famRec.resStart]) {
                    // this is a normal reservation that is checked in
                    [recsToDel addObject:famRec];
                } else if (checkInRec.lapSwimmerRes && [checkInRec.lapStart isEqualToString:famRec.lapStart]) {
                    [recsToDel addObject:famRec];
                }
            }
        }
    }
    [self.families removeObjectsInArray:recsToDel];
}

// this creates an array which updates the specified row
- (void)updateRecord:(FamilyRec *)recordToUpdate
{
    GTLRSheets_ValueRange *value = [[GTLRSheets_ValueRange alloc] init];
    value.values = recordToUpdate.getFamilyValueArray;
    
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
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
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
        headerTxt.textColor = [UIColor labelColor];
        famMem.text = @"# Fam Members ";
        famMem.textColor = [UIColor labelColor];
    } else {
        headerTxt.text = @" Signed-In Family(type,ID):";
        headerTxt.textColor = [UIColor labelColor];
        famMem.text = @"# Signed-In";
        famMem.textColor = [UIColor labelColor];
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
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    } else {  // families
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        member = self.families[indexPath.row];
        cell.detailTextLabel.text = member.familyMembers;
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    }
    // default

    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    [cell.textLabel setFont:[UIFont fontWithName:@"System" size:17]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"System" size:17]];
    if (![self sameDay:self.currentDate]) {
        [self clearCheckmarks];
    }
    if (indexPath.section == 0) {
        cell.backgroundColor = [UIColor systemYellowColor];
        cell.imageView.image = nil;
        cell.accessoryType = 0;
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
        cell.imageView.image = [member getLogo];
        cell.accessoryType = member.checked ?UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;

        if (member.droppedOff) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@,%@): Dropped Off: %@",
                                   member.lastName, member.memType,
                                   member.memberID, member.kidsDroppedOff];
        } else if (member.hasRes){
            if (member.lapSwimmerRes) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@(%@,%@), R:%@",
                                       member.lastName, member.memType,
                                       member.memberID, member.lapStart];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)member.lapSwimmers];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@(%@,%@), R:%@",
                                       member.lastName, member.memType,
                                       member.memberID, member.resStart];
            }
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@,%@)",
                                   member.lastName, member.memType,
                                   member.memberID];
        }
        
        // make odd rows light blue
        UIColor *lightBlue = [UIColor colorWithRed: 131.0/255.0 green: 241.0/255.0 blue:255.0/255.0 alpha: 1.0];
        
        if (member.droppedOff) {
            cell.backgroundColor = [self.tools getUIColorObjectFromHexString:@"#74b9ff" alpha:0.9];
        } else if (![FamilyRec even:(int)indexPath.row]) {
            cell.backgroundColor = lightBlue;
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if(member.didTheyMissReservation || member.noShow) {
            cell.backgroundColor = [UIColor systemOrangeColor];
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

// takes a string time in, and compares it to the current time.
// if current time is two hours past resTime, then return YES, else NO
-(BOOL)missedReservation:(NSString *) resTime {
    BOOL missedRes = NO;
    
    return missedRes;
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
        if (self.checkedInToday.count == 0) {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self removeRecFromSignIn: rec];
    }
}

// this picks the family member which will be checked in, which is either section 2&&max3 or section 1 max2
// but not section 0 or section 1 max 3 (which returns)
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) || ((indexPath.section == 1)&&(self.maxSections==3)))
        return;
    FamilyRec *member = self.families[indexPath.row];
    //member.missedReservation = NO;
    if(!(member.lapSwimmerRes && !member.didTheyMissReservation)) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@(%@) Family", member.lastName, member.memberID]
                     message:[NSString stringWithFormat:@"How many members and guests are you checking in?\n\nNames(%@): %@", member.familyMembers, member.getNames]
              preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"(number of) members";
            textField.textColor = [UIColor systemBlueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            [textField setKeyboardType:UIKeyboardTypeNumberPad ];
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"(number of) guests";
            textField.textColor = [UIColor systemBlueColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
            [textField setKeyboardType:UIKeyboardTypeNumberPad ];
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray *textfields = alert.textFields;
            UITextField *members = textfields[0];
            UITextField *guests = textfields[1];
            member.checked = YES;
            member.members = [members.text intValue];
            member.guests = [guests.text intValue];

            [self writeGuest:member values:member.getSignInValueArray sheetID:ACT_SSHEET_ID sheetRange:@"SignIn!A1"];

        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Drop Off Children" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray *textfields = alert.textFields;
            UITextField *members = textfields[0];
            UITextField *guests = textfields[1];
            member.checked = YES;
            member.members = [members.text intValue];
            member.guests = [guests.text intValue];
            [self getNamesOfKids:(FamilyRec *) member];
        }]];
        if (member.didTheyMissReservation) {
            [alert addAction:[UIAlertAction actionWithTitle:@"No Show" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSArray *textfields = alert.textFields;
                UITextField *members = textfields[0];
                UITextField *guests = textfields[1];
                member.checked = YES;
                member.members = [members.text intValue];
                member.guests = [guests.text intValue];
                member.noShow = YES;
                [self writeGuest:member values:member.getSignInValueArray sheetID:ACT_SSHEET_ID sheetRange:@"SignIn!A1"];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // this is a lapswimmer with reservation
        member.members = (int)member.lapSwimmers;
        member.checked = YES;
        [self writeGuest:member values:member.getSignInValueArray sheetID:ACT_SSHEET_ID sheetRange:@"SignIn!A1"];
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
        textField.textColor = [UIColor systemBlueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [textField setKeyboardType:UIKeyboardTypeDefault];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"(xxx) ttt-tttt";
        textField.textColor = [UIColor systemBlueColor];
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

        [self writeGuest:member values:member.getSignInValueArray sheetID:ACT_SSHEET_ID sheetRange:@"SignIn!A1"];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self writeGuest:member values:member.getSignInValueArray sheetID:ACT_SSHEET_ID sheetRange:@"SignIn!A1"];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

//// converts record from sign-in sheet to familyRec
//- (FamilyRec *)convertToSignIn: (NSArray *)input {
//    if([input[0] isEqualToString:@""] ||
//       [input[0] isEqualToString:@"Date Time"]) {
//        return nil;
//    }
//    if (input.count > 0) {     // date
//        if (![self isToday:[self stringToDate:input[0]]]) {
//            return nil;   // if not today, return empty
//        }
//    }
//    
//    FamilyRec *rec = [[FamilyRec alloc] init];
//    for (int i = 0; i < input.count; i++) {
//        if ([(NSString *)rec.signinKeys[i] isEqualToString: @""]) {
//            //NSLog(@"blank key in convertToSignIn");
//            continue;  // skip if key is blank
//        }
////        if (((i >= 0) && (i <= 2)) || ((i >= 5) && (i <= 12)) || (i > 14)) {
////            [rec setValue:input[i] forKey:rec.signinKeys[i]];
////        } else
//        
//        if (i == 3) {
//            rec.members = [(NSString *)input[3] intValue];
//        } else if (i == 4) {
//            rec.guests = [(NSString *)input[4] intValue];
//        } else if ((i == 13)||(i == 14)) {
//            if ([input[i] isEqualToString:@"YES"]) {
//                [rec setValue:@YES forKey:rec.signinKeys[i]];
//            } else {
//                [rec setValue:@NO forKey:rec.signinKeys[i]];
//            }
//        } else {  // the rest of the values are NSStrings
//            [rec setValue:input[i] forKey:rec.signinKeys[i]];
//        }
//    }
//    rec.checked = YES;
//    if (![rec.kidsDroppedOff isEqualToString:@""]) {  // kids dropped off?
//        rec.droppedOff = YES;
//    }
//    rec.hasRes = YES;  // these are records from signedin array, so have reservation
//    // figure out if normal reservation or lap reservation (lapSwimmerRes YES or NO)
//    if ([rec.lapStart isEqualToString:@""]) {
//        rec.lapSwimmerRes = NO;
//    } else {
//        rec.lapSwimmerRes = YES;
//    }
//
//    return rec;
//}

//// indicates if this record is from today (current date)
//-(BOOL) isToday:(NSDate *)aDate {
//    
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
//                                          fromDate:self.currentDate];
//    NSDate *today = [cal dateFromComponents:components];
//    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
//                        fromDate:aDate];
//    NSDate *otherDate = [cal dateFromComponents:components];
//    BOOL isToday = [today isEqualToDate:otherDate];
//    return isToday;
//}

//// converts a string date to the yyyy-MM-dd HH:mm format
//- (NSDate *)stringToDate:(NSString *)dateStr {
//    // Convert string to date object
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
//    return [dateFormat dateFromString:dateStr];
//}

// clear the checked-in checkmarks fromthe records
- (void) clearCheckmarks {
    for (FamilyRec *rec in self.families) {
        rec.checked = NO;
        rec.droppedOff = NO;
        rec.kidsDroppedOff = @"";
    }
}

//// converts memberSheet record to family object, remove CL, PL records
//// added 18 - landline phone, 19- firstName, 20-firstName2 on 9/17/2020
//- (FamilyRec *) convertToFamObj: (NSArray *)member {
//    if (([member[1] isEqualToString: @"Certificate Number"]) ||
//        [member[2] isEqualToString:@"CL"] || [member[2] isEqualToString:@"PL"] ||
//        [member[0] isEqualToString:@""]) {
//        return nil;      // this is the header, blank last name, or CL or PL remove
//    }
//    FamilyRec *rec = [[FamilyRec alloc] init];
//    for(int i = 0; i < member.count; i++) {
//        if ([(NSString *)rec.famKeys[i] isEqualToString: @""]) {
//            //NSLog(@"blank key in convertToSignIn");
//            continue;  // skip if key is blank
//        }
//
//        rec.eligable = YES;
//        if (i == 17) {
//            NSString *owesMoney = member[17];
//            if ([owesMoney isEqualToString:@"x"] ||
//                [rec.memType isEqualToString:@"PL"]) {
//                rec.eligable = NO;
//            }
//            if ([rec.memType isEqualToString:@"BD"] ||
//                [rec.memType isEqualToString:@"BE"] ) {
//                rec.eligable = YES;
//            }
//        } else {
//            [rec setValue:member[i] forKey:rec.famKeys[i]];
//        }
//
//    }
//    // if record is in checkedInToday, then use this record
//    return rec; //[self isCheckedInToday: rec];  // can have multiple reservations, can't do it here
//}

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
