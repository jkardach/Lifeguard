//
//  FamilyRec.m
//  Lifeguard
//
//  Created by jim kardach on 6/28/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "FamilyRec.h"
@import MessageUI;

@interface FamilyRec() <MFMessageComposeViewControllerDelegate,
MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) id viewController;
@end

@implementation FamilyRec
- (id)init
{
    if (self = [super init]) {
        _date = @"";
        _lastName = @"";
        _memberID = @"";
        _memType = @"";
        _members = 0;
        _familyMembers = @"2";
        _guests = 0;
        _kidsDroppedOff = @"";
        _email = @"";
        _phone = @"";
        _email2 = @"";
        _phone2 = @"";
        _signOut = @"";
        _optPhone = @"";
        _signInRow = 0;
        _eligable = NO;
        _checked = NO;
        _droppedOff = NO;
        _updated = NO;      // determines if the record was updated and needs to be written back
    }
    return self;
}

- (void)sendSMS:(id)viewController phone1:(int)phone1
{
    // make an SMS
    self.viewController = viewController;
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    NSString *phoneNum;
    if (phone1 == 1) {
        phoneNum = [self.phone
                    stringByReplacingOccurrencesOfString:@" "
                    withString:@""];
    } else if (phone1 == 2){
        phoneNum = [self.phone2
                    stringByReplacingOccurrencesOfString:@" "
                    withString:@""];
    } else {
        phoneNum = [self.optPhone
                    stringByReplacingOccurrencesOfString:@" "
                    withString:@""];
    }
    if([MFMessageComposeViewController canSendText]) {
        controller.body = @"Important message from the Saratoga Swim Club!  ";
        controller.recipients = [NSArray arrayWithObjects:phoneNum, nil];
        controller.messageComposeDelegate = self;
        [viewController presentViewController:controller animated:YES completion:nil];
        
    }
}

// if supports phone call make phone call, else SMS
- (void)call:(id)viewController phone1:(BOOL)phone1
{
    self.viewController = viewController;
    // remove spaces from phone number
    NSString *phoneNum;
    if (phone1) {
        phoneNum = [self.phone
                    stringByReplacingOccurrencesOfString:@" "
                    withString:@""];
    } else {
        phoneNum = [self.phone2
                    stringByReplacingOccurrencesOfString:@" "
                    withString:@""];
    }
    // make a phone call, if you can't then make SMS
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        // can make a phone call, make it
        NSString *phoneURL = [NSString stringWithFormat:@"telprompt://%@", phoneNum];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL] options:@{} completionHandler:^(BOOL success) {
            NSLog(@"Open %@: %d", phoneNum, success);
        }];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
    } else if([MFMessageComposeViewController canSendText]) { // else do SMS
        controller.body = @"";
        controller.recipients = [NSArray arrayWithObjects:phoneNum, nil];
        controller.messageComposeDelegate = self;
        [viewController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendEmail:(id)viewController subject:(NSString *)subject email1:(BOOL)email1
{
    self.viewController = viewController;
    // send an email
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        MFMailComposeViewController * mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        NSString *email = @"";
        if (email1) {
            email = self.email;
        } else {
            email = self.email2;
        }
        NSArray *toList = @[email];
        [mailView setToRecipients:toList];
        [mailView setSubject:subject];      //Set the subject
        [mailView setMessageBody:@"" isHTML:YES];   //Set the mail body
        
        
        //Display Email Composer
        if([mailClass canSendMail]) {
            [viewController presentViewController:mailView animated:YES completion:nil];
        }
    }
}


// delegate routine for MFMessageComposeViewController, dismisses view controller
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}


@end
