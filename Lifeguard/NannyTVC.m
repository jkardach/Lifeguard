//
//  NannyTVC.m
//  googleSheetsTest
//
//  Created by jim kardach on 5/22/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//

#import "NannyTVC.h"
#import "Constants.h"
#import "FCell.h"
#import "AppDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-w documentation"
#import "GTLRSheets.h"
#pragma clang diagnostic pop

@interface NannyTVC ()
@property (nonatomic, strong) GTLRSheetsService *service;
@property (nonatomic, strong) NSMutableArray *nanny;
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation NannyTVC

- (NSMutableArray *)nanny {
    if (!_nanny) {
        _nanny = [[NSMutableArray alloc] init];
    }
    return _nanny;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Nanny";
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

// Get the id for the SSC budget sheet
- (void)readSheet {
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:ACT_SSHEET_ID
                                                            range:@"Accounts!A4:AQ130"];
    [self.service executeQuery:query
             completionHandler:^(GTLRServiceTicket *ticket,
                                 GTLRSheets_ValueRange *result,
                                 NSError *error) {
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                self.nanny = nil;
                for (NSArray *row in rows) {
                    if (row.count < 29)
                        continue;
                    if (![row[27] isEqualToString: @""]) {
                       
                        [self.nanny addObject:row];
                    }
                }
            }
            [self.tableView reloadData];
        } else {
            [self.appDelegate signInToGoogle:self];
        }
    }];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nanny.count;
}

-(CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int tvWidth = tableView.frame.size.width - 10;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(5, 0,tvWidth, 50)];
    headerView.backgroundColor = [UIColor grayColor];
    
    UILabel *famTxt = [[UILabel alloc] initWithFrame:CGRectMake(5, 15,tvWidth, 22)];
    famTxt.textAlignment = NSTextAlignmentLeft;
    famTxt.text = @" Family Name(Member ID):";
    [famTxt setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    famTxt.textColor = [UIColor whiteColor];
    
    UILabel *fee = [[UILabel alloc] initWithFrame:CGRectMake(5, 0,tvWidth, 22)];
    fee.textAlignment = NSTextAlignmentRight;
    fee.text = @"Nanny Fee ($75)";
    [fee setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    fee.textColor = [UIColor redColor];
    
    UILabel *payment = [[UILabel alloc] initWithFrame:CGRectMake(5, 25,tvWidth, 22)];
    payment.textAlignment = NSTextAlignmentRight;
    payment.text = @"Nanny Fee Payments ";
    [payment setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    payment.textColor = [UIColor greenColor];
    
    [headerView addSubview:famTxt];
    [headerView addSubview:fee];
    [headerView addSubview:payment];
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FCell" forIndexPath:indexPath];
    NSArray *nannyItem = self.nanny[indexPath.row];
    cell.icon.image = [UIImage imageNamed:@"SwimClub10mm"];    // logo

    cell.title.textColor = [UIColor blackColor];
    cell.title.text = [NSString stringWithFormat:@"%@(%@)",nannyItem[1], nannyItem[0]];
    NSString *nannyFeePaid = @"$0.00";
    if (nannyItem.count >=29) {
        nannyFeePaid = nannyItem[28];
    }
    cell.top.text = nannyItem[27];
    cell.bottom.text = nannyFeePaid;
    
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
- (void) orientationChanged:(NSNotification *)note
{
    [self.tableView reloadData];
}
@end
