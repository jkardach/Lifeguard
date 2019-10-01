//
//  PoolPickerTVC.m
//  PoolLogger
//
//  Created by jim kardach on 5/24/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import "PoolPickerTVC.h"
#import "ConfigTVC.h"
#import "LoggerTVC.h"
#import "GoogleSheet.h"
#import "AppDelegate.h"

@interface PoolPickerTVC ()
@property (nonatomic, strong) NSMutableArray *poolSheets;
@property (nonatomic)  BOOL isFirstAppearance;

@end

@implementation PoolPickerTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.poolSheets = appDelegate.poolSheets;
    self.isFirstAppearance = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // check to see if a sheet was aborted, and remove if so
    if (self.poolSheets.count > 0) {
        GoogleSheet *sheet = [self.poolSheets lastObject];
        if ([sheet.name isEqualToString:@""]) {
            [self.poolSheets removeLastObject];
            
        }

    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if just one sheet, then go directly to it.
    if ((self.poolSheets.count == 1) && self.isFirstAppearance) {
        [self performSegueWithIdentifier:@"SelectPool" sender:nil];
    }
    self.isFirstAppearance = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poolSheets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    GoogleSheet *sheet = self.poolSheets[indexPath.row];
    cell.textLabel.text = sheet.name;
    cell.textLabel.textColor = [UIColor blackColor];
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.poolSheets removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (BOOL)even:(int)value
{
    return (value%2) ? YES : NO;
}

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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectPool"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        GoogleSheet *sheet = (GoogleSheet *)self.poolSheets[path.row];
        
        LoggerTVC *lTVC = [segue destinationViewController];
        lTVC.title = sheet.name;
        lTVC.sheet = sheet;
    } else if ([segue.identifier isEqualToString:@"NewSheet"]) {
        GoogleSheet *sheet = [[GoogleSheet alloc] init];
        [self.poolSheets addObject:sheet];
        ConfigTVC *cTVC = [segue destinationViewController];
        cTVC.sheet = sheet;
        cTVC.title = @"Edit Pool Sheet";
    }
}

@end
