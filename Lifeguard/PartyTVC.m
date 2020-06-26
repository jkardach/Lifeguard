//
//  PartyTVC.m
//  googleSheetsTest
//
//  Created by jim kardach on 5/5/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//

#import "PartyTVC.h"
#import "PartyDetailTVC.h"
#import "Constants.h"
#import "FCell.h"
#import "PartyRec.h"
#import "AppDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-w documentation"
#import "GTLRSheets.h"
#pragma clang diagnostic pop

@interface PartyTVC ()
@property (nonatomic, strong) GTLRSheetsService *service;
@property (nonatomic, strong) NSMutableArray *partySheetArray;
@property (nonatomic, strong) NSMutableArray *parties;
@property (nonatomic, strong) NSMutableArray *upcomingParties;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation PartyTVC

- (NSMutableArray *)parties {
    if (!_parties) {
        _parties = [[NSMutableArray alloc] init];
    }
    return _parties;
}

- (NSMutableArray *)upcomingParties {
    if (!_upcomingParties) {
        _upcomingParties = [[NSMutableArray alloc] init];
    }
    return _upcomingParties;
}

- (NSMutableArray *)partySheetArray {
    if (!_partySheetArray) {
        _partySheetArray = [[NSMutableArray alloc] init];
    }
    return _partySheetArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Parties";

    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.service = self.appDelegate.sheetService;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

// When the view appears, ensure that the Google Sheets API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self readSheet];  // go read spreadsheet
}

- (void)readSheet {
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SHEET_ID
                                                            range:@"Parties!A2:V"];
    [self.service executeQuery:query
             completionHandler:^(GTLRServiceTicket *ticket,
                                 GTLRSheets_ValueRange *result,
                                 NSError *error) {
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                self.parties = nil;
                for (NSArray *row in rows) {
                    if ((row.count > 1)) {
                        PartyRec *member = [self convertToPartyObjects:row];
                        if (member) {
                            [self.parties addObject:member];
                        }
                    } else {
                        break;
                    }
                }
            }
            [self.parties sortUsingSelector:@selector(compareDates:)];
            [self seperateParties];    // seperates into
            [self.tableView reloadData];
        } else {
            [self.appDelegate signInToGoogle:self];
        }
    }];
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

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (self.parties.count != 0) {
        NSArray *header = self.parties[0];
        NSString *headerString = [NSString stringWithFormat:@"%@:%@/%@/%@", header[0], header[4], header[8], header[9]];
        
        return headerString;
    } else {
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.upcomingParties.count;
    } else {
        return self.parties.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int tvWidth = tableView.frame.size.width;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0,tvWidth-10, 50)];
    headerView.backgroundColor = [UIColor grayColor];
    
    UILabel *famTxt = [[UILabel alloc] initWithFrame:CGRectMake(5, 15,tvWidth-10, 22)];
    famTxt.textAlignment = NSTextAlignmentLeft;
    if (section == 0) {
        famTxt.text = @"Upcoming Parties";
    } else {
        famTxt.text = @"Past Parties";
    }
    [famTxt setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    famTxt.textColor = [UIColor whiteColor];
    
    UILabel *fee = [[UILabel alloc] initWithFrame:CGRectMake(5, 0,tvWidth-10, 22)];
    fee.textAlignment = NSTextAlignmentRight;
    fee.text = @"Party Fee";
    [fee setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    fee.textColor = [UIColor redColor];
    
    UILabel *payment = [[UILabel alloc] initWithFrame:CGRectMake(5, 25,tvWidth-10, 22)];
    payment.textAlignment = NSTextAlignmentRight;
    payment.text = @"Party Payment";
    [payment setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    payment.textColor = [UIColor greenColor];
    
    
    [headerView addSubview:famTxt];
    [headerView addSubview:fee];
    [headerView addSubview:payment];
    //[self.tableView updateConstraintsIfNeeded];
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCell *cell = (FCell *)[tableView dequeueReusableCellWithIdentifier:@"FCell"
                                                           forIndexPath:indexPath];
    PartyRec *party;
    if (indexPath.section == 0) {
        party = self.upcomingParties[indexPath.row];
    } else {
        party = self.parties[indexPath.row];
    }
    //cell.icon.image = [UIImage imageNamed:@"SwimClub10mm"];    // logo

    cell.title.textColor = [UIColor blackColor];
    cell.title.text = [NSString stringWithFormat:@"%@: %@/%@ hrs/%@", party.name, party.start, party.duration, party.partyType];
    cell.top.text = party.fees;
    cell.bottom.text = party.payment;
    
    // make odd rows light blue
    UIColor *lightBlue = [UIColor colorWithRed: 131.0/255.0 green: 241.0/255.0 blue:255.0/255.0 alpha: 1.0];
    if (![self even:(int)indexPath.row]) {
        // light blue color
        cell.backgroundColor = lightBlue;
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (PartyRec *)convertToPartyObjects:(NSArray *) member {

    if ([member[0] isEqualToString: @"Name"] || [member[0] isEqualToString:@""]) {
        return nil;      // this is the header, remove
    }
    
    PartyRec *rec = [[PartyRec alloc] init];
    if (member.count > 0) {     // date
        rec.name = member[0];
    }

    if (member.count > 1) {     // member number
        rec.memberID = member[1];
        if ([rec.memberID isEqualToString:@""] || [rec.memberID isEqualToString:@"0"]) {
            rec.memberID = @"NM";
        } else {
            rec.memberID = [NSString stringWithFormat:@"%@", rec.memberID];
        }
    }
    if (member.count > 2) {
        rec.invoiceDate = member[2];
    }
    if (member.count > 3) {
        rec.partyOccassion = member[3];
    }
    if (member.count > 4) {
        rec.partyDate = member[4];
    }
    if (member.count > 5) {     // date
        rec.start = member[5];
    }
    if (member.count > 6) {     // date
        rec.stop = member[6];
    }
    if (member.count > 7) {     // date
        rec.partyTime = member[7];
    }

    if (member.count > 8) {
        rec.duration = member[8];
    }
    if (member.count > 9) {
        rec.partyType = member[9];
    }
    if (member.count > 10) {     // type
        rec.memberType = member[10];
    }

    if (member.count > 11) {     // fees
        
        if ([member[11] isEqualToString: @""]) {
          rec.fees = @"$0.00";
        } else {
            rec.fees = [NSString stringWithFormat:@"$%@", member[11]];
        }
    }
    if (member.count > 12) {     // fees
        if ([member[12] isEqualToString: @""]) {
            rec.partyFee = @"$0.00";
        } else {
            rec.partyFee = [NSString stringWithFormat:@"$%@", member[12]];
        }
    }
    if (member.count > 13) {     // fees
        
        if ([member[13] isEqualToString: @""]) {
            rec.lateFee = @"$0.00";
        } else {
            rec.lateFee = [NSString stringWithFormat:@"$%@", member[13]];
        }
    }


    if (member.count > 14) {     // email
        rec.email = member[14];
    }

    if (member.count > 15) {     // phone
        rec.phone = member[15];
    }

    if (member.count > 16) {     // payment
        if ([member[16] isEqualToString: @""]) {
            rec.payment = @"$0.00";
        } else {
            rec.payment = [NSString stringWithFormat:@"$%@", member[16]];
        }
    }

    if (member.count > 17) {     // phone
        rec.check = member[17];
    }
    if (member.count > 18) {     // phone
        rec.received = member[18];
    }
    if (member.count > 19) {     // phone
        rec.deposited = member[19];
    }
    if (member.count > 20) {     // phone
        
        if ([member[20] isEqualToString: @""]) {
            rec.refund = @"$0.00";
        } else {
            rec.refund = member[20];
        }
    }
    return rec;
}

- (BOOL)even:(int)value
{
    return (value%2) ? YES : NO;
}

- (void) seperateParties
{
    self.upcomingParties = nil;
    for (PartyRec *rec in self.parties) {
        if ([self isInFuture: rec.start]) {
            [self.upcomingParties addObject:rec];
        }
    }
    [self.parties removeObjectsInArray:self.upcomingParties];
}

- (BOOL) isInFuture:(NSString *)partyDate {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    NSDate *partyNSDate = [formatter dateFromString:partyDate];
    
    NSDate *now = [NSDate date];
    
    if ([now compare: partyNSDate] == NSOrderedAscending) {
        return YES;
    } else {
        return NO;
    }
}

 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"partyDetail"]) {
         NSIndexPath *path = [self.tableView indexPathForSelectedRow];
         PartyDetailTVC *pdTVC = [segue destinationViewController];
         if (path.section == 0) {
             pdTVC.rec = self.upcomingParties[path.row];
         } else if (path.section == 1) {
             pdTVC.rec = self.parties[path.row];
         }
     }
 }

- (void) orientationChanged:(NSNotification *)note
{
    [self.tableView reloadData];
}
@end
