//
//  PartyDetailTVC.m
//  Lifeguard
//
//  Created by jim kardach on 7/2/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "PartyDetailTVC.h"

@interface PartyDetailTVC ()

@end

@implementation PartyDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"Name(memberID): %@(%@)", self.rec.name, self.rec.memberID];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"Date Time: %@", self.rec.start];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"Email: %@", self.rec.email];
            break;
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"Phone: %@", self.rec.phone];
            break;
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"MemberType: %@", self.rec.memberType];
            break;
        case 5:
            cell.textLabel.text = [NSString stringWithFormat:@"Duration: %@ hrs", self.rec.duration];
            break;
            
        default:
            break;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"Name(memberID): %@(%@)", self.rec.name, self.rec.memberID];
    }
    // Configure the cell...
    
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
