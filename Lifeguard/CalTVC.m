//
//  CalTVC.m
//  Lifeguard
//
//  Created by jim kardach on 7/9/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "CalTVC.h"
#import "Constants.h"
#import "FamilyRec.h"
#import "AppDelegate.h"
#import "calObj.h"
#import "Reservations.h"
#import "CalDetailTVCTableViewController.h"
#import "DateSelTVCell.h"
#import "GoToTodayTVCell.h"

@interface CalTVC ()

@property (nonatomic, strong) GTLRSheetsService *sheetService;  // to contain the shared auth
@property (nonatomic, strong) GTLRCalendarService *calendarService;  // to contain the shared auth
@property (nonatomic, strong) GIDGoogleUser *theUser;   // to contain the shared user var
@property (nonatomic, strong) AppDelegate *appDelegate;  // var for appDelegate
@property (nonatomic, strong) NSMutableArray *todayCalEvents;
@property (nonatomic, strong) NSMutableArray *calArray;
@property (nonatomic, strong) NSMutableArray *families;
@property (nonatomic, strong) NSMutableArray *familiesWithReservations;
@property (nonatomic, strong) Reservations *resSummary;
@end

@implementation CalTVC
- (Reservations *)resSummary {
    if (!_resSummary) {
        _resSummary = [[Reservations alloc] init];
    }
    return _resSummary;
}

// array of today's calendar events
- (NSMutableArray *)calArray {
    if (!_calArray) {
        _calArray = [[NSMutableArray alloc] init];
    }
    return _calArray;
}

// array of all members (PM, Lease, Trial)
- (NSMutableArray *)families {
    if (!_families) {
        _families = [[NSMutableArray alloc] init];
    }
    return _families;
}

// array of all members (PM, Lease, Trial)
- (NSMutableArray *)familiesWithReservations {
    if (!_familiesWithReservations) {
        _familiesWithReservations = [[NSMutableArray alloc] init];
    }
    return _familiesWithReservations;
}

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
    
    // add refresh control to allow sheets/devices to reload when pulled down
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"]; //to give the attributedTitle
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    self.resSummary.date = [NSDate now];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];

    [self readbatchSheet];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    else
        return [Reservations compareFullArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            DateSelTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
            cell.date.text = self.resSummary.dateString;
            cell.backgroundColor = [UIColor systemBlueColor];
            return cell;
        } else {
            GoToTodayTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor systemBlueColor];
            return cell;
        }
    } else { // section == 1
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell3" forIndexPath:indexPath];
        NSInteger count = [self.resSummary getCountFromTitleRow:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@: (Swimmers-%ld)",
                               [Reservations compareFullArray][indexPath.row],
                               count];
        if (![self even:indexPath.row]) {
            // light blue color
            cell.backgroundColor = [UIColor systemTealColor];
        } else {
            cell.backgroundColor = [UIColor systemGreenColor];
        }
        return cell;
    }
}

- (BOOL)even:(NSInteger)value
{
    return (value%2) ? YES : NO;
}

#pragma mark - Navigation Buttons

- (IBAction)previousDay:(UIButton *)sender {
    self.resSummary.date = [self decDay:self.resSummary.date];
    [self readbatchSheet];
}

- (IBAction)nextDay:(UIButton *)sender {
     self.resSummary.date = [self incDay:self.resSummary.date];
    [self readbatchSheet];
}

- (IBAction)goToToday:(UIButton *)sender {
    self.resSummary.date = [NSDate now];
    [self readbatchSheet];
}


#pragma mark - sheet methods
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
                [self readResCalDate];  // read reservation calendar for date in self.resSummary

            } else {
                NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
                [self showAlert:@"Error" message:message];
            }
        }];
}


#pragma mark - calendar methods
- (void)readResCalDate {
    // get the Accounts tab of the SSC sheet;
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
                    NSString *tempStr = [start substringFromIndex:2];
                    if ([tempStr isEqualToString:@":30"]) {
                        cal.lapSwimmer = YES;
                        cal.lapStart = start;
                    } else {
                        cal.start = start;
                    }
                    [self.calArray addObject:cal];
                }
                [self addResToFamiles];  // fills in the self.familiesWithReservationsArray
                
                
                
                // scroll to top of tableview
                if (@available(iOS 11.0, *)) {
                    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.adjustedContentInset.top) animated:YES];
                } else {
                    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
                }
            }
            [self.tableView.refreshControl endRefreshing];
            [self updateDisplay];
        } else {
            NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
            [self showAlert:@"Error" message:message];
        }
    }];
}

// add reservation values to Family and checked-in arrays
- (void)addResToFamiles {
    [self.resSummary reset];  // reset reservation counts to zero
    [self.familiesWithReservations removeAllObjects];
    for (int i = 0; i < self.families.count; i++) {
        FamilyRec *rec = self.families[i];
        for (calObj *cal in self.calArray) {
            if ([cal.memberId isEqualToString:rec.memberID]) {
                if ([rec.lastName isEqualToString:@"Bannon"]) {
                    printf("Bannon record");
                }
                if ([cal.memberId isEqualToString:@"62"]) {
                    printf("Bannon Cal for %s", [cal.start UTF8String]);
                }
                rec.hasRes = YES;
                rec.resDate = cal.resDate;
                
                if (cal.lapSwimmer) {
                    rec.lapStart = cal.lapStart;
                } else {
                    rec.resStop = cal.end;
                    rec.resStart = cal.start;
                }
                
                rec.lapSwimmerRes = cal.lapSwimmer;
                if (rec.lapSwimmerRes) {
                    rec.lapSwimmers++;  // if this is a lapswimmer res, inc lap swimmers
                }
                //[self.resSummary updateCount:rec.resStart];  // update the reservation count
                if (!rec.added) {
                    [self.familiesWithReservations addObject:rec];  // only add object once
                    rec.added = YES;
                }
            }
        }
    }
    [self.resSummary updateCount:self.familiesWithReservations];
    self.calArray = nil;
}

- (NSString *) stringFromDateTime:(GTLRDateTime *) date {
    NSDate *today = date.date;
    NSDateFormatter* pstDf = [[NSDateFormatter alloc] init];
    [pstDf setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
    [pstDf setDateFormat:@"HH:mm"];
    NSString *dateStr = [pstDf stringFromDate:today];
    return dateStr;
}

// updates the display after doing a new date
- (void)updateDisplay {
    [self.tableView reloadData];
}

- (NSDate *)incDay:(NSDate *)date {
    NSDate *nextDay = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:date];
    return nextDay;
}

- (NSDate *)decDay:(NSDate *)date {
    NSDate *prevDay = [NSDate dateWithTimeInterval:(-24*60*60) sinceDate:date];
    return prevDay;
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
    return rec;
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
    [self readbatchSheet]; //call function you want
    [refreshControl endRefreshing];
}

 #pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CalDetail"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        CalDetailTVCTableViewController *cDTVC = [segue destinationViewController];
        if (path.section == 0) {
            NSLog(@"Error, something pressed in section 0");
        } else {
            cDTVC.recArray = [self.resSummary getReservationsFromFamilies:self.familiesWithReservations
                                                             fromTitleRow:path.row];
            cDTVC.title = self.resSummary.title;
        }
    }
}

@end
