//
//  CalDetailTVCTableViewController.m
//  Lifeguard
//
//  Created by jim kardach on 7/9/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "CalDetailTVCTableViewController.h"
#import "FamilyRec.h"
#import "CancelTVC.h"
#import "ShowFamiliesTVC.h"

@interface CalDetailTVCTableViewController ()

@end

@implementation CalDetailTVCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 1;
    } else {
        return self.recArray.count;
    }
}


- (IBAction)CancelButton:(UIButton *)sender {
    __block NSMutableArray *emails = [[NSMutableArray alloc] init];
    __block NSMutableArray *smss = [[NSMutableArray alloc] init];
    __block FamilyRec *emailMember;
    
    // collect phone numbers and emails
    for (FamilyRec *member in self.recArray) {
        if(![member didTheyMissReservation]) {
            emails = [member addEmails:emails];
            emailMember = member;  // just a member to call class function
            smss = [member addSMSs:smss];
        }
    }
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:[NSString stringWithFormat:@"Email or SMS Members"]
                                message:[NSString stringWithFormat:@"Do you wish to email or SMS members about cancelled reservations"]
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *body = @"Hello, <br><br>The swim club has had to cancel reservations today. Please contact us for more information.<br><br>Saratoga Swim Club";
        [emailMember sendEmail:self
                      subject:@"Reservations have been cancelled"
                         body:body
                     ToEmails:emails];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *body = @"Hello, \n\nThe swim club has had to cancel reservations today. Please contact us for more information.\n\nSaratoga Swim Club";
        [emailMember sendSMS:self
                          to:smss
                    withBody:body];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        CancelTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"Cancel" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor systemBlueColor];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        FamilyRec *rec = self.recArray[indexPath.row];
        if (rec.lapSwimmerRes) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@, %@), %ld Swimmers",
                                   rec.lastName, rec.memberID, rec.memType, rec.lapSwimmers];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@(%@, %@), %@ Swimmers",
                                   rec.lastName, rec.memberID, rec.memType, rec.familyMembers];
        }
        return cell;
    }
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowFamily"]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        FamilyRec *rec = self.recArray[path.row];   // get the family
        
        ShowFamiliesTVC *sFTVC = [segue destinationViewController];  // get the TVC
        sFTVC.family = rec;  // set the record 
        
        sFTVC.title = rec.lastName;
    }
}


@end
