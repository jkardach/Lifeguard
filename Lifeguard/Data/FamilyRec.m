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
        _resDate = @"";
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
        _hasRes = NO;
        _resStart = @"";
        _resStop = @"";
        _lapSwimmers = 0;
        _lapSwimmerRes = NO;
        _added = NO;
        _lapStart = @"";
        _missedReservation = NO;
        _missedReservationSaved = NO;
        _noShow = NO;
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

// returns true if more than 2 hours after reservation and not checked in
-(BOOL)timeToSaveMissedReservation {
    return [self missReservation:2.0];
}

// returns true if past the reservation starttime
-(BOOL)didTheyMissReservation {
    return [self missReservation:0];
}

// assumes only called on same day as reservation, checks current time vs. res times
// sets reservationMissed if if more than 2 hours after reservation and returns true
-(BOOL)missReservation:(float)deltaHour {
    if(self.missedReservationSaved || self.checked || !self.hasRes) {
        return NO;          // they missed the reservation, but have already been saved
    }
    // if two hours beyond start time then YES and set self.missedReservation
    float lapResTimeLimit = 0.0 + deltaHour;
    float resTimeLimit = 0.0 + deltaHour;
    float currentTime = [self currentTimeAsFloat];
    // see if laptime
    if (self.hasRes && self.lapSwimmerRes) {
        lapResTimeLimit = [self convertTimeToFloat:self.lapStart];
        if ((lapResTimeLimit - currentTime) < 0) {
            self.missedReservation = YES;
        }
    }
    if (self.hasRes && !self.lapSwimmerRes) {
        resTimeLimit = [self convertTimeToFloat:self.resStart];
        if ((resTimeLimit - currentTime) < 0) {
            self.missedReservation = YES;
        }
    }
    return self.missedReservation;
}

// converts @"11:00" to 11, or @"11:30" to 11.5
-(float)convertTimeToFloat:(NSString *)time {
    float value = 0.0;
    NSArray *strings = [time componentsSeparatedByString:@":"];
    value = [strings[0] floatValue];  // get hours
    if (strings.count > 1) {
        float value2 = [strings[1] floatValue];  // get minutes
        value += value2/60.0;  // convert to house, add to value
    }
    return value;
}

-(float)currentTimeAsFloat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];

    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    return [self convertTimeToFloat:timeString];
}

- (NSArray *)getFamilyValueArray
{
    return @[
        @[self.date, self.lastName,
          self.memberID,
          [NSString stringWithFormat:@"%D", self.members],
          [NSString stringWithFormat:@"%D", self.guests],
          self.kidsDroppedOff,self.familyMembers,
          self.memType, self.phone, self.email,
          self.phone2, self.email2, self.optPhone]
    ];
}

-(NSArray *)getSignInValueArray {
    
    NSNumber *guestNum = [NSNumber numberWithInt:self.guests];
    NSNumber *memberNum = [NSNumber numberWithInt:self.members];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    NSString *elg = @"NO";
    if (self.eligable) {
        elg = @"YES";
    }
    NSString *noShow = @"NO";
    if(self.noShow) {
        noShow = @"YES";
    }
    return @[@[dateString, self.lastName, self.memberID,
               memberNum, guestNum, self.kidsDroppedOff,
               self.familyMembers, self.memType, self.phone,
               self.email, self.phone2, self.email2,
               self.optPhone, elg, noShow, self.resDate,
               self.resStart, self.lapStart]];
}

-(NSArray *)signinKeys {
    return @[@"date", @"lastName", @"memberID", @"members", @"guests",
             @"kidsDroppedOff", @"familyMembers", @"memType", @"phone",
             @"email", @"phone2", @"email2", @"optPhone", @"eligable",
             @"noShow", @"resDate", @"resStart", @"lapStart"];
}

-(NSArray *)famKeys {
    return @[@"lastName", @"memberID", @"memType", @"", @"",
             @"", @"", @"phone", @"phone2",
             @"email", @"email2", @"", @"", @"", @"", @"",
             @"familyMembers", ];
}

-(NSArray *)getMissedResValueArray {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    NSString *elg = @"NO";
    if (self.eligable) {
        elg = @"YES";
    }
    return @[@[dateString, self.lastName, self.memberID, self.memType, 
               self.phone, self.email, self.email2, self.phone2,
               self.resDate, self.resStart, self.lapStart]];
}
@end
