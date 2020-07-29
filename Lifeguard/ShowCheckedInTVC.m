//
//  ShowCheckedInTVC.m
//  Lifeguard
//
//  Created by jim kardach on 7/21/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "ShowCheckedInTVC.h"
#import "CheckInTVCellTableViewCell.h"

@interface ShowCheckedInTVC () <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *nameArray;

// user interface
@property (weak, nonatomic) IBOutlet UITableViewCell *dateTimeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *familyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *totalFamilyMembersCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *guestsAttendingCell;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeCheckedIn;
@property (weak, nonatomic) IBOutlet UILabel *familyTypeId;
@property (weak, nonatomic) IBOutlet UILabel *totalFamilyMembers;
@property (weak, nonatomic) IBOutlet UITextField *membersAttending;
@property (weak, nonatomic) IBOutlet UITextField *guestsAttending;
@property (weak, nonatomic) IBOutlet UITextField *kidsDroppedOffTF;

@property (weak, nonatomic) IBOutlet UITableViewCell *buttonCell1;
@property (weak, nonatomic) IBOutlet UITableViewCell *buttonCell2;
@property (weak, nonatomic) IBOutlet UITableViewCell *buttonCell3;
@property (weak, nonatomic) IBOutlet UITableViewCell *buttonCell4;
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *title3;
@property (weak, nonatomic) IBOutlet UILabel *title4;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UILabel *famOrRes;
@end

@implementation ShowCheckedInTVC

- (NSMutableArray *)itemArray {
    if (!_itemArray) {
        _itemArray = [[NSMutableArray alloc] init];
    }
    return _itemArray;
}

- (NSMutableArray *)nameArray {
    if (!_nameArray) {
        _nameArray = [[NSMutableArray alloc] init];
    }
    return _nameArray;
}

- (void)viewDidLoad {
    
    if (![self.member.phone isEqualToString:@""]) {
        [self.itemArray addObject:self.member.phone];
        [self.nameArray addObject:@"SMS"];
    }
    if (![self.member.phone2 isEqualToString:@""]) {
        [self.itemArray addObject:self.member.phone2];
        [self.nameArray addObject:@"SMS2"];
    }
    if (![self.member.optPhone isEqualToString:@""]) {
        [self.itemArray addObject:self.member.optPhone];
        [self.nameArray addObject:@"OptSMS"];
    }
    if (![self.member.email isEqualToString:@""]) {
        [self.itemArray addObject:self.member.email];
        [self.nameArray addObject:@"Email"];
    }
    if (![self.member.email2 isEqualToString:@""]) {
        [self.itemArray addObject:self.member.email2];
        [self.nameArray addObject:@"Email2"];
    }
    
    self.membersAttending.text = [NSString stringWithFormat:@"%d", self.member.members];
    self.guestsAttending.text = [NSString stringWithFormat:@"%d", self.member.guests];
    self.kidsDroppedOffTF.text = self.member.kidsDroppedOff;
    
    self.dateTimeCheckedIn.text = self.member.date;
    if (self.member.hasRes) {
        self.familyTypeId.text = [NSString stringWithFormat:@"%@",
                                  self.member.resStart];
        self.famOrRes.text = @"Reservation";
    } else {
        self.familyTypeId.text = [NSString stringWithFormat:@"%@(%@, %@)",
                                  self.member.resStart,
                                  self.member.memType,
                                  self.member.memberID];
        self.famOrRes.text = @"Family(memType, id)";
    }
    self.totalFamilyMembers.text = self.member.familyMembers;
    self.membersAttending.delegate = self;
    self.guestsAttending.delegate = self;
    self.kidsDroppedOffTF.delegate = self;
    
    NSString *item = @"";
    NSString *name = @"";
    self.buttonCell1.hidden = YES;
    self.buttonCell2.hidden = YES;
    self.buttonCell3.hidden = YES;
    self.buttonCell4.hidden = YES;
    
    for (int i = 0; i < self.itemArray.count; i++) {
        item = self.itemArray[i];
        name = self.nameArray[i];
        switch (i) {
            case 0:
                self.buttonCell1.hidden = NO;
                [self.button1 setTitle:name forState:UIControlStateNormal];
                self.title1.text = [NSString stringWithFormat:@"%@: %@",
                                   name, item];
                break;
            case 1:
                self.buttonCell2.hidden = NO;
                [self.button2 setTitle:name forState:UIControlStateNormal];
                self.title2.text = [NSString stringWithFormat:@"%@: %@",
                                    name, item];
                break;
            case 2:
                self.buttonCell3.hidden = NO;
                [self.button3 setTitle:name forState:UIControlStateNormal];
                self.title3.text = [NSString stringWithFormat:@"%@: %@",
                                    name, item];
                break;
            case 3:
                self.buttonCell4.hidden = NO;
                [self.button4 setTitle:name forState:UIControlStateNormal];
                self.title4.text = [NSString stringWithFormat:@"%@: %@",
                                    name, item];
                break;
                
            default:
                break;
        }
        
        // add gesture recognizer to the view
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapRecognizer];
        self.navigationController.toolbarHidden = NO;
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count + 6;
}

#pragma mark - textfield delegate method

- (void)backgroundTapped:(UITapGestureRecognizer*)recognizer {
    [self.membersAttending  resignFirstResponder];
    [self.guestsAttending resignFirstResponder];
    [self.kidsDroppedOffTF resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)membersTF:(UITextField *)sender {
    self.member.updated = YES;
    self.member.members = [sender.text intValue];
}

- (IBAction)guestsTF:(UITextField *)sender {
    self.member.updated = YES;
    self.member.guests = [sender.text intValue];
}

- (IBAction)kidsDroppedOffTF:(UITextField *)sender {
    self.member.updated = YES;
    self.member.droppedOff = YES;
    self.member.kidsDroppedOff = sender.text;
}
#pragma mark - CheckInTVCellTableViewCell delegate

- (IBAction)buttonClick:(UIButton *)sender {
    
    if([sender.titleLabel.text isEqualToString:@"SMS"]) {
        [self.member sendSMS:self phone1:1];
    } else if([sender.titleLabel.text isEqualToString:@"SMS2"]) {
        [self.member sendSMS:self phone1:2];
    } else if([sender.titleLabel.text isEqualToString:@"Email"]) {
        [self.member sendEmail:self subject:@"Important message from Saratoga Swim Club" email1:YES];
    } else if ([sender.titleLabel.text isEqualToString:@"Email2"]) {
        [self.member sendEmail:self subject:@"Important message from Saratoga Swim Club" email1:NO];
    }else  {
        [self.member sendSMS:self phone1:3];
    }
}
@end
