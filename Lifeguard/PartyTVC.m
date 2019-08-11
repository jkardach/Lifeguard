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

//static NSString *const kKeychainItemName = @"Google Sheets API";
//static NSString *const kClientID = @"488077888352-kn6td47na6g1lkf2epr7clu9tcbmv4vs.apps.googleusercontent.com";

@interface PartyTVC ()
@property (nonatomic, strong) GTLRSheetsService *service;
@property (nonatomic, strong) NSMutableArray *partySheetArray;
@property (nonatomic, strong) NSMutableArray *parties;
@property (nonatomic, strong) NSMutableArray *upcomingParties;

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
    
    // work around, allows you to manually login to the google account
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    // end workaround
    
    // Initialize the Google Sheets API service & load existing credentials from the keychain if available.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.service = appDelegate.service;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Display (in the UITextView) the Parties tab
// defined in Constants.h: ACT_SHEET_ID = 1AE2j_p2O5e9K_x1-WLiUsZu-SOq5oi5QYsKD6OGMvCQ
- (void)readSheet {
    NSString *spreadsheetId = ACT_SHEET_ID;
    NSString *range = @"Parties!A2:O";  // get the parties sheet, range A2:J
    
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:spreadsheetId
                                                            range:range];
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// take the sheet cells and put them into an array
- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRSheets_ValueRange *)result
                          error:(NSError *)error
{
    if (error == nil) {
        NSArray *rows = result.values;
        if (rows.count > 0) {
            self.partySheetArray = nil;
            for (NSArray *row in rows) {
                if (row.count > 1) {
                    [self.partySheetArray addObject:row];  // add to membersOverDue Array
                } else {
                    break;
                }
            }
        }
        [self convertToPartyObjects];
        [self.parties sortUsingSelector:@selector(compareDates:)];  // sort array by start Date
        [self seperateParties];    // seperates into upcoming and past parties
        [self.tableView reloadData];
        //self.output.text = output;
    } else {
        NSString *message = [NSString stringWithFormat:@"Error getting sheet data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
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

- (void)convertToPartyObjects {
    self.parties = nil; // clear out parties array records
    for (NSArray *member in self.partySheetArray) {
        if ([member[0] isEqualToString: @"Name"]) {
            continue;      // this is the header, remove
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
            rec.fees = member[11];
        }
        
        if (member.count > 12) {     // email
            rec.email = member[12];
        }
        
        if (member.count > 13) {     // phone
            rec.phone = member[13];
        }
        
        if (member.count > 14) {     // payment
            rec.payment = member[14];
            if ([rec.payment isEqualToString: @""]) {
                rec.payment = @"$0.00";
            }
        }
        [self.parties addObject:rec];
    }
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
    formatter.dateFormat = @"yyyy/MM/dd HH:mm";
    NSDate *partyNSDate = [formatter dateFromString:partyDate];
    
    NSDate *now = [NSDate date];
    
    if ([now compare: partyNSDate] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


 #pragma mark - Navigation
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"partyDetail" sender:cell];
    }
}
 */
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
