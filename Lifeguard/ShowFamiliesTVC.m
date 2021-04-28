//
//  ShowFamiliesTVC.m
//  Lifeguard
//
//  Created by jim kardach on 9/18/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "ShowFamiliesTVC.h"
#import "FamilyRec.h"

@interface ShowFamiliesTVC ()

@end

@implementation ShowFamiliesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

// Parent1 Cell:
// Parent1 Email:
// Parent2 Cell:
// Parent2 Email:
// Children:

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIColor *lightBlue = [UIColor colorWithRed: 131.0/255.0 green: 241.0/255.0 blue:255.0/255.0 alpha: 1.0];
    if (![FamilyRec even:(int)indexPath.row]) {
        cell.backgroundColor = lightBlue;
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if(indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat: @"%@ %@: %@", self.family.firstName,
                               self.family.lastName, self.family.phone];
    }
    if(indexPath.row == 1) {
        cell.textLabel.text = [NSString stringWithFormat: @"%@ %@: %@", self.family.firstName,
                               self.family.lastName, self.family.email];
    }
    if(indexPath.row == 2) {
        if(![self.family.firstName2 isEqualToString:@""]) {
            cell.textLabel.text = [NSString stringWithFormat: @"%@ %@: %@", self.family.firstName2,
                                   self.family.lastName, self.family.phone2];
        } else {
            cell.textLabel.text =  @"";
        }
    }
    if(indexPath.row == 3) {
        if(![self.family.firstName2 isEqualToString:@""]) {
            cell.textLabel.text = [NSString stringWithFormat: @"%@ %@: %@", self.family.firstName2,
                                   self.family.lastName, self.family.email2];
        } else {
            cell.textLabel.text =  @"";
        }
    }
    
    if(indexPath.row == 4) {
        if(![self.family.firstName2 isEqualToString:@""]) {
            cell.textLabel.text = [NSString stringWithFormat: @"Children: %@", self.family.kidsNames];
        } else {
            cell.textLabel.text =  @"";
        }
    }

    return cell;
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
