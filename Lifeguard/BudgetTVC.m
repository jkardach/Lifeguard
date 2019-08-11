//
//  BudgetTVC.m
//  googleSheetsTest
//
//  Created by jim kardach on 5/6/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//

#import "BudgetTVC.h"
#import "Constants.h"
#import "AppDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-w documentation"
#import "GTLRSheets.h"
#pragma clang diagnostic pop

//static NSString *const kKeychainItemName = @"Google Sheets API";
//static NSString *const kClientID = @"488077888352-kn6td47na6g1lkf2epr7clu9tcbmv4vs.apps.googleusercontent.com";

@interface BudgetTVC ()
@property (nonatomic, strong) GTLRSheetsService *service;
@property (nonatomic, strong) NSMutableArray *budget;
@end

@implementation BudgetTVC
- (NSMutableArray *)budget {
    if (!_budget) {
        _budget = [[NSMutableArray alloc] init];
    }
    return _budget;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.service = appDelegate.service;
    
    //self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    // work around, allows you to manually login to the google account
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    // end workaround
    
    // Initialize the Google Sheets API service & load existing credentials from the keychain if available.
    
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

// Get the id for the SSC budget sheet
- (void)readSheet {
    // get the over-due field of the SSC 2017 budget sheet;
    NSString *spreadsheetId = ACT_SHEET_ID;
    NSString *range = @"Budget!A1:D";
    
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
        //        NSString *output = @"";
        NSArray *rows = result.values;
        //        printf("Rows: %lu", (unsigned long)rows.count);
        //        NSInteger rowIndex = 0;
        if (rows.count > 0) {
            self.budget = nil;
            int i = 0;
            for (NSArray *row in rows) {
                i++;
                // 13: income
                // 14: member dues
                // 24: member fees
                // 37: Expenses
                // 38: Facilities
                // 46: Social & Supplies
                // 49: Insurance
                // 53: Payroll Costs
                // 59: Pool
                // 62: Lifeguard
                // 65: Operating/Admin Costs
                // 72: Property Taxes
                // 73: Utilities
                // 78: Re-model Loan
                // 79: Unknown
                if ((i==13)||(i==14)||(i==24)||(i==37)||(i==38)||(i==46)||(i==49)||(i==53)||(i==59)||(i==62)||
                    (i==65)||(i==72)||(i==73)||(i==78)) {
                [self.budget addObject:row];  // add to membersOverDue Array
                }
            }
        }
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

//- (NSString *)tableView:(UITableView *)tableView
//titleForHeaderInSection:(NSInteger)section
//{
//    if (self.budget.count != 0) {
//        NSString *headerString = @"Item   Budgeted    Actual";
//        
//        return headerString;
//    } else {
//        return @"";
//    }
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.budget.count;  // 16 sections
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *budgetItem = self.budget[indexPath.row];
    
    if (indexPath.row < 3) {
        UIColor *darkGreen = [UIColor colorWithRed: 0 green: .5 blue:0 alpha: 1];
        cell.detailTextLabel.textColor = darkGreen;
    } else {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    cell.textLabel.text = budgetItem[0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",budgetItem[1], budgetItem[3]];
    
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
