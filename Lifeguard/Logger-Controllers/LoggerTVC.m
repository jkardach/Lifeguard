//
//  LoggerTVC.m
//  PoolLogger
//
//  Created by jim kardach on 5/21/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
/*
//  Basic structure works, to do:

*/

#import "LoggerTVC.h"
//#import "Constants.h"
#import "FileRoutines.h"
#import "getTemps.h"
#import "AppDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-w documentation"
#import "GTLRSheets.h"
#import "poolRecord.h"
#import "showRecordTVC.h"
#import "editRecordTVC.h"
#import "ConfigTVC.h"
#import "FileRoutines.h"

#pragma clang diagnostic pop

@interface LoggerTVC () <UISearchBarDelegate, UISearchResultsUpdating, getTempsDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *configButton;

@property (nonatomic, strong) NSMutableArray *poolLogArray;
@property (nonatomic, strong) NSMutableArray *filteredPoolLogArray;
@property (nonatomic, weak) NSMutableArray *displayedPoolLogArray;
@property (nonatomic, strong) FileRoutines *tools;
@property (nonatomic, strong) GTLRSheetsService *service;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) getTemps *temps;
@end

@implementation LoggerTVC


@synthesize searchController;
@synthesize displayedPoolLogArray;


#pragma mark setters/getters
-(getTemps *)temps {
    if (!_temps) {
        _temps = [[getTemps alloc] init];
    }
    return _temps;
}

- (FileRoutines *)tools {
    if (!_tools) {
        _tools = [[FileRoutines alloc] init];
    }
    return _tools;
}

- (NSMutableArray *) poolLogArray {
    if (!_poolLogArray) {
        _poolLogArray = [[NSMutableArray alloc] init];
    }
    return _poolLogArray;
}

- (NSMutableArray *) filteredPoolLogArray {
    if (!_filteredPoolLogArray) {
        _filteredPoolLogArray = [[NSMutableArray alloc] init];
    }
    return _filteredPoolLogArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pool Logger";
    
    self.temps = [getTemps sharedInstance];
    self.temps.delegate = self;
    [self.temps getDevices];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.service = appDelegate.service;

    // work around, allows you to manually login to the google account
   //NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36", @"UserAgent", nil];
    //[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    // end workaround
    
    // Initialize the Google Sheets API service & load existing credentials from the keychain if available.
//    [GIDSignIn sharedInstance].uiDelegate = (id<GIDSignInUIDelegate>) self;
//    if ([GIDSignIn sharedInstance].currentUser == nil) {
//        [[GIDSignIn sharedInstance] signIn];
//    } else {
//        [[GIDSignIn sharedInstance] signInSilently];
//    }
    
    // initialize the UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView setContentOffset:CGPointMake(0,
                                                 self.searchController.searchBar.frame.size.height)];
    self.definesPresentationContext = YES;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveLoggerAuthUINotification:)
     name:@"authUINotification"
     object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"]; //to give the attributedTitle
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
}

// When the view appears, ensure that the Google Sheets API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (!self.poolLogArray) return;
    [self removeBadRecord];     // removes any partial record
    
    int i = 0;
    for (poolRecord *record in self.poolLogArray) {
        if (record.updated && !record.newRecord) {
            [self updateRecordAtRow:i poolRecord:record];
            record.updated = false;
        } else if (record.newRecord && ![record.poolPh isEqualToString:@" "]) {
            [self appendRowToSheetWith:record];
            record.newRecord = false;
        }
        i++;
    }
    
    [self.poolLogArray sortUsingSelector:@selector(compareDates:)];  // sort array
    [self readSheet];
    [self.tableView reloadData];
}

// check to see if a sheet was aborted, and remove if so
-(void)removeBadRecord
{
    if (self.poolLogArray.count > 0) {
        poolRecord *record = [self.poolLogArray lastObject];
        if ([record.poolPh isEqualToString:@" "]) {
            [self.poolLogArray removeLastObject];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // setup the configuration button
    self.configButton.title = @"\u2699";
    UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          f1, NSFontAttributeName, nil];
    [self.configButton setTitleTextAttributes:dict forState:UIControlStateNormal];
    [self.poolLogArray sortUsingSelector:@selector(compareDates:)];  // sort array
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// reads the google sheet pointed to by the sheet object
- (void)readSheet
{
    NSString *range = [NSString stringWithFormat:@"%@!A2:Z", self.sheet.range];
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:self.sheet.spreadSheetID
                                                            range:range];
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// callback from readsheet, takes row and puts them into a poolRecord object and adds
// objects to poolLogArray
- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRSheets_ValueRange *)result
                          error:(NSError *)error {
    if (error == nil) {
        NSArray *rows = result.values;
        if (rows.count > 0) {
            [self.poolLogArray removeAllObjects];
            for (NSArray *row in rows) {
                if (row.count > 1) {
                    // create the object here
                    poolRecord *record = [[poolRecord alloc] init];
                    record.date = row[0];
                    record.time = row[1];
                    record.poolPh = row[2];
                    record.poolCl = row[3];
                    if (self.sheet.service) {
                        record.poolSensorPh = row[4];
                        record.poolSensorCl = row[5];
                        record.poolGalAcid = row[6];
                        record.poolGalCl = row[7];
                        if ([row[8] isEqualToString:@"TRUE"]) {
                            record.poolfilterBackwash = true;
                        } else {
                            record.poolfilterBackwash = false;
                        }
                        record.spaPh = row[9];
                        record.spaCl = row[10];
                        record.spaSensorPh = row[11];
                        record.spaSensorCl = row[12];
                        record.spaGalAcid = row[13];
                        record.spaGalCl = row[14];
                        if ([row[15] isEqualToString:@"TRUE"]) {
                            record.spafilterBackwash = true;
                        } else {
                            record.spafilterBackwash = false;
                        }
                        if(row.count>=17) {
                            record.note = row[16];
                        }
                    } else {
                        record.spaPh = row[4];
                        record.spaCl = row[5];
                        if(row.count >= 7) {
                            record.note = row[6];
                        }
                    }
                    record.newRecord = false;
                    record.updated = false;
                    record.service = self.sheet.service;
                    
                    [self.poolLogArray addObject:record];  // add to poolLogArray
                } else {
                    break;
                }
            }
        }
        [self.poolLogArray sortUsingSelector:@selector(compareDates:)];  // sort array
        self.displayedPoolLogArray = self.poolLogArray;
        [self.tableView.refreshControl endRefreshing];
        [self.tableView reloadData];
    } else {
        //*** put in relogin here
        //[self presentViewController:[self createAuthController] animated:YES completion:nil];
        NSString *message = [NSString stringWithFormat:@"Error getting sheet data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
        // Google sign-in; if not signed in, sign-in, else silently signin.
        [GIDSignIn sharedInstance].uiDelegate = (id<GIDSignInUIDelegate>) self;
        if ([GIDSignIn sharedInstance].currentUser == nil) {
            [[GIDSignIn sharedInstance] signIn];
        } else {
            [[GIDSignIn sharedInstance] signInSilently];
        }
    }
    
}

// this creates an array which updates the specified row
- (void)updateRecordAtRow: (int)row poolRecord:(poolRecord *)poolRecord
{
    NSString *range = [NSString stringWithFormat:@"%@!A%d", self.sheet.range, row+2];
    GTLRSheets_ValueRange *value = [[GTLRSheets_ValueRange alloc] init];
    value.values = [self createValueArrayFromPoolRecord:poolRecord];
    
    GTLRSheetsQuery_SpreadsheetsValuesUpdate *query =
    [GTLRSheetsQuery_SpreadsheetsValuesUpdate queryWithObject:value
                                                spreadsheetId:self.sheet.spreadSheetID
                                                        range:range];
    query.valueInputOption = @"USER_ENTERED";
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayUpdateResultWithTicket:finishedWithObject:error:)];
}



// callback routine for writing the value to the given row, indicates an error (if one)
- (void)displayUpdateResultWithTicket:(GTLRServiceTicket *)ticket
                   finishedWithObject:(GTLRSheets_ValueRange *)result
                                error:(NSError *)error {
    if (error != nil) {
        NSString *message = [NSString stringWithFormat:@"Error getting update sheet data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    } else {
        [self readSheet];
    }
}


// this creates an array to append a row to end of sheet.
- (void)appendRowToSheetWith: (poolRecord *)poolRecord
{
    NSString *range = [NSString stringWithFormat:@"%@!A2:Z", self.sheet.range];
    GTLRSheets_ValueRange *valueRange = [[GTLRSheets_ValueRange alloc] init];
    valueRange.values = [self createValueArrayFromPoolRecord:poolRecord];
    
    GTLRSheetsQuery_SpreadsheetsValuesAppend *query =
    [GTLRSheetsQuery_SpreadsheetsValuesAppend queryWithObject:valueRange
                                                spreadsheetId:self.sheet.spreadSheetID
                                                        range:range];
    query.valueInputOption = @"USER_ENTERED";

    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayAppendResultWithTicket:finishedWithObject:error:)];
}

// callback routine for writing the value to the guest column, indicates an error (if one)
- (void)displayAppendResultWithTicket:(GTLRServiceTicket *)ticket
                   finishedWithObject:(GTLRSheets_ValueRange *)result
                                error:(NSError *)error {
    if (error != nil) {
        NSString *message = [NSString stringWithFormat:@"Error getting append sheet data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    } else {
        [self readSheet];
    }
}

- (NSArray *) createValueArrayFromPoolRecord:(poolRecord *)poolRecord
{
    NSString *poolBackwash = @"FALSE";
    NSString *spaBackwash = @"FALSE";
    if (poolRecord.poolfilterBackwash) {
        poolBackwash = @"TRUE";
    }
    if (poolRecord.spafilterBackwash) {
        spaBackwash = @"TRUE";
    }
    NSArray *valueArray;
    if(self.sheet.service) {
        valueArray = @[
                       @[poolRecord.date, poolRecord.time,
                         poolRecord.poolPh, poolRecord.poolCl,
                         poolRecord.poolSensorPh, poolRecord.poolSensorCl,
                         poolRecord.poolGalAcid, poolRecord.poolGalCl, poolBackwash,
                         poolRecord.spaPh, poolRecord.spaCl,
                         poolRecord.spaSensorPh, poolRecord.spaSensorCl,
                         poolRecord.spaGalAcid, poolRecord.spaGalCl, spaBackwash,
                         poolRecord.note]
                       ];
    } else {
        valueArray = @[
                       @[poolRecord.date, poolRecord.time, poolRecord.poolPh,
                         poolRecord.poolCl, poolRecord.spaPh, poolRecord.spaCl,
                         poolRecord.note]
                       ];
    }
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

#pragma mark - Table view data source#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
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
    headerTxt.textColor = [self.tools getUIColorObjectFromHexString:@"#e17055" alpha:1];
    
    UILabel *famMem = [[UILabel alloc] initWithFrame:CGRectMake(5, 15,tvWidth, 22)];
    famMem.textAlignment = NSTextAlignmentRight;
    [famMem setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    famMem.textColor = [self.tools getUIColorObjectFromHexString:@"#0984e3" alpha:1];
    
    if (section == 0) {
        headerTxt.text = @"CL Spa:3-10ppm Pool:2-10ppm";
        famMem.text = @"pH:7.2-7.8";
    } else if (section == 1) {
        
        NSString *poolTxt = @"Pool pH/CL";
        NSString *spaTxt = @"Spa pH/CL";
        famMem.attributedText = [self createAttrTxt:famMem.textColor
                                               font:famMem.font
                                            poolTxt:poolTxt
                                             spaTxt:spaTxt];
        headerTxt.text = @"Meas Date (Time)";
        //famMem.text = @"Pool pH/CL, Spa pH/CL";
    }
    [headerView addSubview:famMem];
    [headerView addSubview:headerTxt];
    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else {
        return self.displayedPoolLogArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor yellowColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        poolRecord *record = self.displayedPoolLogArray[indexPath.row];
        NSString *poolTxt;
        NSString *spaTxt;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", record.date, record.time];
        cell.textLabel.textColor = [UIColor blackColor];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            poolTxt = [NSString stringWithFormat:@"pH:%@/CL:%@ppm", record.poolPh, record.poolCl];
            spaTxt = [NSString stringWithFormat:@"pH:%@/CL:%@ppm", record.spaPh, record.spaCl];
        } else {
            poolTxt = [NSString stringWithFormat:@"pH:%@/CL:%@", record.poolPh, record.poolCl];
            spaTxt = [NSString stringWithFormat:@"pH:%@/CL:%@", record.spaPh, record.spaCl];
        }
        cell.detailTextLabel.attributedText = [self createAttrTxt:cell.detailTextLabel.textColor
                                                             font:cell.detailTextLabel.font
                                                          poolTxt:poolTxt
                                                           spaTxt:spaTxt];

        // make odd rows light blue
        UIColor *lightBlue = [UIColor colorWithRed: 131.0/255.0 green: 241.0/255.0 blue:255.0/255.0 alpha: 1.0];
        if (![self even:(int)indexPath.row]) {
            // light blue color
            cell.backgroundColor = lightBlue;
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}


- (NSMutableAttributedString *) createAttrTxt:(UIColor *)labelColor
                                         font:(UIFont *)labelFont
                                        poolTxt:(NSString *)poolTxt
                                        spaTxt:(NSString *)spaTxt
{
    NSString *text = [NSString stringWithFormat:@"%@, %@", poolTxt, spaTxt];
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: labelColor,
                              NSFontAttributeName: labelFont
                              };
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    // CL color text attribute
    UIColor *spaColor = [self.tools getUIColorObjectFromHexString:@"#e17055" alpha:1];
    UIColor *poolColor = [self.tools getUIColorObjectFromHexString:@"#0984e3" alpha:1];
    
    
    NSRange poolTextRange = NSMakeRange(0, poolTxt.length+1);
    NSRange spaTextRange =  NSMakeRange(poolTxt.length+1, spaTxt.length+1);
    [attributedText setAttributes:@{NSForegroundColorAttributeName:poolColor}
                            range:poolTextRange];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:spaColor}
                            range:spaTextRange];
    return attributedText;
}

- (BOOL)even:(int)value
{
    return (value%2) ? YES : NO;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)SearchController
{
\
    NSLog(@"updateSearchResultsForSearchController");
    
    NSString *searchString = self.searchController.searchBar.text;
    NSLog(@"searchString=%@", searchString);
    
    // Check if the user cancelled or deleted the search term so we can display the full list instead.
    if ([self isFiltering]) {
        [self.filteredPoolLogArray removeAllObjects];
        for (poolRecord *rec in self.poolLogArray) {
            NSString *str = [NSString stringWithFormat:@"%@ %@", rec.date, rec.time];
            if ([searchString isEqualToString:@""] || [str localizedCaseInsensitiveContainsString:searchString] == YES) {
                NSLog(@"str=%@", str);
                [self.filteredPoolLogArray addObject:rec];
            }
        }
        self.displayedPoolLogArray = self.filteredPoolLogArray;
    }
    else {
        self.displayedPoolLogArray = self.poolLogArray;
    }
    [self.tableView reloadData];
}

- (BOOL)isFiltering
{
    return searchController.isActive && ![self searchBarIsEmpty];
}

- (BOOL)searchBarIsEmpty
{
    if([self.searchController.searchBar.text isEqualToString:@""]) {
        return true;
    } else {
        return false;
    }
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"ShowRecord"]) {
        poolRecord *record = (poolRecord *)self.displayedPoolLogArray[path.row];
        record.newRecord = false;
        record.updated = false;
        
        showRecordTVC *srTVC = [segue destinationViewController];
        srTVC.title = @"Show Record";
        srTVC.precord = record;
    } else if ([segue.identifier isEqualToString:@"NewRecord"]) {
        poolRecord *record = (poolRecord *)[[poolRecord alloc] init];
        record.service = self.sheet.service;
        record.newRecord = true;
        record.updated = false;
        
        [self.poolLogArray addObject:record];
        editRecordTVC *erTVC = [segue destinationViewController];
        erTVC.precord = record;
        erTVC.title = @"Edit Record";
    } else if ([segue.identifier isEqualToString:@"EditPool"]) {
        ConfigTVC *cTVC = [segue destinationViewController];
        cTVC.sheet = self.sheet;
    }
}

- (void) refreshData {
    [self.tableView reloadData];
}

- (void) orientationChanged:(NSNotification *)note
{
    [self.tableView reloadData];
}

- (void) receiveLoggerAuthUINotification:(NSNotification *) notification {
    NSLog(@"-Logger- AuthUINotification");
    if ([notification.name isEqualToString:@"authUINotification"]) {
        [self readSheet];
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self.temps refreshTemps];
    [self readSheet]; //call function you want
}
@end
