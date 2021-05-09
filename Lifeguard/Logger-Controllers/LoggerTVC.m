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
#import "Alert.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-w documentation"
#import "GTLRSheets.h"
#import "poolRecord.h"
#import "showRecordTVC.h"
#import "editRecordTVC.h"
#import "ConfigTVC.h"
#import "FileRoutines.h"
//@import PurpleSensor;

#pragma clang diagnostic pop

@interface LoggerTVC () <UISearchBarDelegate, UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *configButton;

@property (nonatomic, strong) NSMutableArray *poolLogArray;
@property (nonatomic, strong) NSMutableArray *filteredPoolLogArray;
@property (nonatomic, weak) NSMutableArray *displayedPoolLogArray;
@property (nonatomic, strong) FileRoutines *tools;
@property (nonatomic, strong) GTLRSheetsService *service;
@property (nonatomic, strong) AppDelegate *appDelegate;

// 
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) getTemps *particle;
//@property (nonatomic, strong) PurpleModel *purple;
@end

@implementation LoggerTVC


@synthesize searchController;
@synthesize displayedPoolLogArray;


#pragma mark setters/getters

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
    
    
    
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.service = self.appDelegate.sheetService;
    //self.purple = self.appDelegate.purple;
    //self.particle = self.appDelegate.particle;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.obscuresBackgroundDuringPresentation = YES;
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
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveLoggerAuthUINotification:)
     name:@"tempsUpdated"
     object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing"]; //to give the attributedTitle
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    

}

// When the view appears, ensure that the Google Sheets API service is authorized, and perform API calls.
// this could be the initial viewing, or comming back from edit or add record (where it is added)
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (!self.poolLogArray) return;
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
    
    [self removeBadRecord];     // removes any aborted new record
    
    int i = 0;
    for (poolRecord *record in self.poolLogArray) {
        if (record.updated && !record.newRecord) {  //
            [self updateRec: record];  // replace old record with updated record in spreadsheet
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
    
    [self.poolLogArray sortUsingSelector:@selector(compareDates:)];  // sort array
    [self.tableView reloadData];
}

// check to see if an add record, or edit record was aborted, remove record
-(void)removeBadRecord
{
    if (self.poolLogArray.count > 0) {
        poolRecord *record = [self.poolLogArray lastObject];
        if ([record.poolPh isEqualToString:@"-"]) {
            [self.poolLogArray removeLastObject];
        }
    }
}

// reads the google sheet pointed to by the sheet object
- (void)readSheet
{
    NSString *range;
    if(self.sheet.service) {
        range = [NSString stringWithFormat:@"%@!A2:S", self.sheet.tabName];
    } else {
        range = [NSString stringWithFormat:@"%@!A2:I", self.sheet.tabName];
    }
    
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:self.sheet.spreadSheetID
                                                            range:range];
    
    [self.service executeQuery:query
             completionHandler:^(GTLRServiceTicket *ticket,
                                 GTLRSheets_ValueRange *result,
                                 NSError *error) {
        if (error == nil) {
            [self createRecord:result];
        } else {
            NSString *message = [NSString stringWithFormat:@"Error getting display result sheet data: %@\n", error.localizedDescription];
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];

}

// creates records from result array
- (void)createRecord:(GTLRSheets_ValueRange *) result {
    
    NSArray *rows = result.values;
    if (rows.count > 0) {
        [self.poolLogArray removeAllObjects];
        poolRecord *rec;
        for (NSArray *row in rows) {
            rec = [[poolRecord alloc] init];
            rec.service = self.sheet.service;
            for(int i = 0; i < row.count; i++) {
                if ((i <= 6) ||
                    (rec.service&&((i==7)||((i>=9)&&(i<=14))||(i==16)))) {
                    [rec setValue:row[i] forKey:rec.keys[i]];
                } else {
                    NSString *value = row[i];
                    if([value isEqualToString:@"TRUE"]) {
                        [rec setValue:@YES forKey:rec.keys[i]];
                    } else {
                        [rec setValue:@NO forKey:rec.keys[i]];
                    }
                }
                
            }
            rec.newRecord = false;
            rec.updated = false;
            rec.service = self.sheet.service;
            [self.poolLogArray addObject:rec];
        }
    }
    
    [self.poolLogArray sortUsingSelector:@selector(compareDates:)];  // sort array
    self.displayedPoolLogArray = self.poolLogArray;
    [self.tableView.refreshControl endRefreshing];
    [self.tableView reloadData];
}

// creates records from result array
- (void)create2Record:(GTLRSheets_ValueRange *) result {
   
    NSArray *rows = result.values;
    if (rows.count > 0) {
        [self.poolLogArray removeAllObjects];
        
        
        for (NSArray *row in rows) {
            if (row.count > 1) {
                // create the object here
                poolRecord *record = [[poolRecord alloc] init];
                record.date = row[0];
                record.time = row[1];
                if (row.count > 2)
                    record.poolPh = row[2];
                if (row.count > 3)
                    record.poolCl = row[3];
                if (self.sheet.service) {
                    if (row.count > 4)
                        record.poolSensorPh = row[4];
                    if (row.count > 5)
                        record.poolSensorCl = row[5];
                    if (row.count > 6)
                        record.poolGalAcid = row[6];
                    if (row.count > 7)
                        record.poolGalCl = row[7];
                    if (row.count > 8) {
                        if ([row[8] isEqualToString:@"TRUE"]) {
                            record.poolfilterBackwash = true;
                        } else {
                            record.poolfilterBackwash = false;
                        }
                    }
                    if (row.count > 9)
                        record.spaPh = row[9];
                    
                    if (row.count > 10)
                        record.spaCl = row[10];
                    
                    if (row.count > 11)
                        record.spaSensorPh = row[11];
                    
                    if (row.count > 12)
                        record.spaSensorCl = row[12];
                    
                    if (row.count > 13)
                        record.spaGalAcid = row[13];
                    
                    if (row.count > 14)
                        record.spaGalCl = row[14];
                    
                    if (row.count > 15) {
                        if ([row[15] isEqualToString:@"TRUE"]) {
                            record.spafilterBackwash = true;
                        } else {
                            record.spafilterBackwash = false;
                        }
                    }
                    if(row.count > 16) {
                        record.note = row[16];
                    }
                    if(row.count > 17) {
                        if ([row[17] isEqualToString:@"TRUE"]) {
                            record.poolWaterLevel = true;
                        } else {
                            record.poolWaterLevel = false;
                        }
                    }
                    if(row.count > 18) {
                        if ([row[18] isEqualToString:@"TRUE"]) {
                            record.spaWaterLevel = true;
                        } else {
                            record.spaWaterLevel = false;
                        }
                    }
                } else {
                    if (row.count > 4)
                        record.spaPh = row[4];
                    if (row.count > 5)
                        record.spaCl = row[5];
                    if(row.count > 6) {
                        record.note = row[6];
                    }
                    if(row.count > 7) {
                        if ([row[7] isEqualToString:@"TRUE"]) {
                            record.poolWaterLevel = true;
                        } else {
                            record.poolWaterLevel = false;
                        }
                    }
                    if(row.count > 8) {
                        if ([row[8] isEqualToString:@"TRUE"]) {
                            record.spaWaterLevel = true;
                        } else {
                            record.spaWaterLevel = false;
                        }
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
}

//****************
- (void) updateRec: (poolRecord *)poolRecToUpdate
{
    // first find the row of the record to update
    NSString *range;
    if(self.sheet.service) {
        range = [NSString stringWithFormat:@"%@!A1:S", self.sheet.tabName];
    } else {
        range = [NSString stringWithFormat:@"%@!A1:I", self.sheet.tabName];
    }
    
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:self.sheet.spreadSheetID
                                                            range:range];
    [self.service executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        int rowOfRec = 0;
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                for (NSArray *row in rows) {
                    if (row.count > 1) {
                        if (([poolRecToUpdate.date isEqualToString:row[0]])&&([poolRecToUpdate.time isEqualToString:row[1]])) {
                            break;  // this is the record with the date and time stamps
                        }
                    } else {
                        break;
                    }
                    rowOfRec++;
                }
            }
            rowOfRec -= 1;  // array starts at zero, spreadsheet row starts at 1
            [self updateRecordAtRow:rowOfRec poolRecord:poolRecToUpdate];  // update spreadsheet row
        } else {
            NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
}


// this creates an array which updates/replaces the specified row
- (void)updateRecordAtRow: (int)row poolRecord:(poolRecord *)poolRecord
{
    NSString *range;
    if(self.sheet.service) {
        range = [NSString stringWithFormat:@"%@!A%d", self.sheet.tabName, row+2];
    } else {
        range = [NSString stringWithFormat:@"%@!A%d", self.sheet.tabName, row+2];
    }
    
    GTLRSheets_ValueRange *value = [[GTLRSheets_ValueRange alloc] init];
    value.values = poolRecord.valueArray;
    
    GTLRSheetsQuery_SpreadsheetsValuesUpdate *query =
    [GTLRSheetsQuery_SpreadsheetsValuesUpdate queryWithObject:value
                                                spreadsheetId:self.sheet.spreadSheetID
                                                        range:range];
    query.valueInputOption = @"USER_ENTERED";
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket,
                                                         GTLRSheets_ValueRange *result,
                                                         NSError *error) {
        if (error == nil) {
            [self readSheet];
        } else {
            NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
}

// this creates an array to append a row to end of sheet.
- (void)appendRowToSheetWith: (poolRecord *)poolRecord
{
    NSString *range;
    if(self.sheet.service) {
        range = [NSString stringWithFormat:@"%@!A2:S", self.sheet.tabName];
    } else {
        range = [NSString stringWithFormat:@"%@!A2:I", self.sheet.tabName];
    }
    GTLRSheets_ValueRange *valueRange = [[GTLRSheets_ValueRange alloc] init];
    valueRange.values = poolRecord.valueArray;
    
    GTLRSheetsQuery_SpreadsheetsValuesAppend *query =
    [GTLRSheetsQuery_SpreadsheetsValuesAppend queryWithObject:valueRange
                                                spreadsheetId:self.sheet.spreadSheetID
                                                        range:range];
    query.valueInputOption = @"USER_ENTERED";

    [self.service executeQuery:query
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

// removes the record (poolRecord) at row from the Logger spreadsheet
- (void) removeRecAtRow: (poolRecord *)poolRecToDel
{
    // first find the row of the record to delete
    NSString *range;
    if(self.sheet.service) {
        range = [NSString stringWithFormat:@"%@!A1:S", self.sheet.tabName];
    } else {
        range = [NSString stringWithFormat:@"%@!A1:I", self.sheet.tabName];
    }
    
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:self.sheet.spreadSheetID
                                                            range:range];
    
    [self.service executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        int rowOfRec = 0;
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                for (NSArray *row in rows) {
                    if (row.count > 1) {
                        if (([poolRecToDel.date isEqualToString:row[0]])&&([poolRecToDel.time isEqualToString:row[1]])) {
                            break;  // this is the record with the date and time stamps
                        }
                    } else {
                        break;
                    }
                    rowOfRec++;
                }
            }
            //rowOfRec += 1;  // array starts at zero, spreadsheet row starts at 1
            [self delRow:rowOfRec spreadSheetId:self.sheet.spreadSheetID sheetId:@(744046825)];  // del spreadsheet row

        } else {
            NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
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
                cell.textLabel.text = @"Ambient:";
//                if(self.purple) {
//                    // 87F, 22% hum, AQ 15 (Good)
//                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@F, %@ hum, AQ %d(%@)",
//                                                 self.purple.temp,
//                                                 self.purple.humidity,
//                                                 (int) self.purple.AQ,
//                                                 self.purple.AQDescription];
//                } else {
//                cell.detailTextLabel.text = @"";
//                }
//                break;
            case 1:
                cell.textLabel.text = @"Pool Temperature:";
                cell.detailTextLabel.text = self.particle.poolTemp;
                break;
            case 2:
                cell.textLabel.text = @"Spa Temperature:";
                cell.detailTextLabel.text = self.particle.spaTemp;
                break;
            default:
                cell.textLabel.text = @"";
                cell.detailTextLabel.text = @"";
                break;
        }
        return cell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        poolRecord *record = self.displayedPoolLogArray[indexPath.row];
        NSString *poolTxt;
        NSString *spaTxt;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", record.date, record.time];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
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
 return YES;
 }

// allow deleting of log records
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        poolRecord *record = self.displayedPoolLogArray[indexPath.row];  // get record to delete
        [self.displayedPoolLogArray removeObjectAtIndex:indexPath.row];  // remove the record from tableview datasource
        [self removeRecAtRow:record];                                    // remove record from spreadsheet
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)delRow:(int) row  spreadSheetId:(NSString *)spreadsheetId sheetId:(NSNumber *)sheetId {
    GTLRSheets_DeleteDimensionRequest *delDimReq = [[GTLRSheets_DeleteDimensionRequest alloc] init];
    GTLRSheets_Request *sheetsRequest = [[GTLRSheets_Request alloc] init];
    sheetsRequest.deleteDimension = delDimReq;
    
    // Create range property
    GTLRSheets_DimensionRange *range = [[GTLRSheets_DimensionRange alloc] init];
    range.dimension = @"ROWS";
    range.sheetId = sheetId;
    range.startIndex = @(row);  // row to delete inclusive
    range.endIndex = @(row + 1);    // row to delete exclusive
    delDimReq.range = range;  // add range property to delDimReq

    GTLRSheets_BatchUpdateSpreadsheetRequest *request = [[GTLRSheets_BatchUpdateSpreadsheetRequest alloc] init];
    request.includeSpreadsheetInResponse = 0;
    request.responseIncludeGridData = 0;
    request.requests = @[sheetsRequest];
    NSLog(@"Deleting Row: %D", row);

    GTLRSheetsQuery_SpreadsheetsBatchUpdate *query = [GTLRSheetsQuery_SpreadsheetsBatchUpdate
                                                      queryWithObject:(GTLRSheets_BatchUpdateSpreadsheetRequest *) request
                                                      spreadsheetId: spreadsheetId];
    
    [self.service executeQuery:query
                      completionHandler:^(GTLRServiceTicket *ticket,
                                          GTLRSheets_ValueRange *result,
                                          NSError *error) {
            if (error == nil) {
                [self readSheet];
        
            } else {
                NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
                [Alert showAlert:@"Error" message:message viewController:self];
            }
        }];
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


// This is a notification executed after successful signIn, or temp update
- (void) receiveLoggerAuthUINotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"authUINotification"]) {
        [self readSheet];
    } else if ([notification.name isEqualToString:@"updateTemp"]) {
        [self.tableView reloadData];  // refresh the dataview
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl
{
    //[self.appDelegate refreshTemps];
    //[self.appDelegate refreshPurple];   // refresh
    [self readSheet]; //call function you want
}


@end
