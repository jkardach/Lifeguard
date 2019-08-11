//
//  MemberTVC.m
//  googleSheetsTest
//
//  Created by jim kardach on 5/5/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//

#import "MemberTVC.h"
#import "Constants.h"
#import "AppDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-w documentation"
#import "GTLRSheets.h"
#pragma clang diagnostic pop

// NSString *const kKeychainItemName = @"Google Sheets API";
//static NSString *const kClientID = @"488077888352-kn6td47na6g1lkf2epr7clu9tcbmv4vs.apps.googleusercontent.com";

@interface MemberTVC ()
@property (nonatomic, strong) GTLRSheetsService *service;
@property (nonatomic, strong) NSMutableArray *members;

@end

@implementation MemberTVC

#pragma mark = setters/getters

- (NSMutableArray *)members {
    if (!_members) {
        _members = [[NSMutableArray alloc] init];
    }
    return _members;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.service = appDelegate.service;
    
    // work around, allows you to manually login to the google account
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    // end workaround
}

// When the view appears, ensure that the Google Sheets API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    [self readSheet];  // go read spreadsheet
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Display (in the UITextView) the Over-Due tab
// spreadsheet: 1AE2j_p2O5e9K_x1-WLiUsZu-SOq5oi5QYsKD6OGMvCQ
// defined in Constants.h: ACT_SHEET_ID = 1AE2j_p2O5e9K_x1-WLiUsZu-SOq5oi5QYsKD6OGMvCQ

- (void)readSheet {
    // get the over-due tab of the SSC budget sheet;
    NSString *spreadsheetId = ACT_SHEET_ID;
    NSString *range = @"Members!A1:Q";
    
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
                          error:(NSError *)error {
    if (error == nil) {
        NSArray *rows = result.values;
        if (rows.count > 0) {
            self.members = nil;
            for (NSArray *row in rows) {
                if (row.count > 1) {
                    [self.members addObject:row];  // add to members Array
                } else {
                    break;
                }
            }
        }
        [self.tableView reloadData];
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

// Creates the auth controller for authorizing access to Google Sheets API.

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (self.members.count != 0) {
        NSArray *header = self.members[0];
        NSString *headerString = [NSString stringWithFormat:@"%@ (ID)/%@", header[0], header[16]];

        return headerString;
    } else {
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count - 1;  // don't want to display the header row
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *member = self.members[indexPath.row + 1];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (#%@)", member[0], member[1]];
    if (member.count >= 16) {
        cell.detailTextLabel.text = member[16];
    } else {
        cell.detailTextLabel.text = @"2";
    }
    cell.imageView.image = [UIImage imageNamed:@"SwimClub10mm"];
    
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

- (BOOL)even:(int)value
{
    return (value%2) ? YES : NO;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
