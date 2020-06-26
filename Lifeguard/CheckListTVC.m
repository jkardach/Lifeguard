//
//  CheckListTVC.m
//  Lifeguard
//
//  Created by jim kardach on 6/17/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "CheckListTVC.h"

@interface CheckListTVC ()
@property (nonatomic, strong) NSArray *itemArray;


@end

@implementation CheckListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.itemArray = [NSArray arrayWithObjects:
                      @"Check Pool Water Level, Fill If Needed",
                      @"Check Spa Water Level, Fill If Needed",
                      @"Check Pool CL and PH levels, record",
                      @"Check Spa CL and PH levels, record",
                      @"Check Pool Filter baskets, empty if needed",
                      @"Check Spa Filter baskets, empty if needed",
                      nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.itemArray[indexPath.row];
    return cell;
}

@end
