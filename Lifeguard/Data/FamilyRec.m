//
//  FamilyRec.m
//  Lifeguard
//
//  Created by jim kardach on 6/28/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "FamilyRec.h"
#import "GuestFees.h"
#import "NSDateCat.h"
@import MessageUI;

@interface FamilyRec() <MFMessageComposeViewControllerDelegate,
MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) id viewController;
@property(nonatomic, strong) GuestFees *guestFees;


@end

@implementation FamilyRec
- (id)init
{
    if (self = [super init]) {
        _resDate = @"";
        _date = @"";
        _firstName = @"";
        _firstName2 = @"";
        _kidsNames = @"";
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
        _row = @"0";  // real record will be 2 or greater
        _landLine = @"";
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
        //_missedReservation = NO;
        _missedReservationSaved = NO;
        _noShow = NO;
    }
    return self;
}

-(GuestFees *)guestFees {
    if (!_guestFees) {
        _guestFees = [[GuestFees alloc] init];
    }
    return _guestFees;
}

-(void)sendSMS:(id)viewController to:(NSArray *)phones withBody:(NSString *)body {
    // make an SMS
    self.viewController = viewController;
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if([MFMessageComposeViewController canSendText]) {
        controller.body = body;
        controller.recipients = phones;
        controller.messageComposeDelegate = self;
        [viewController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendSMS:(id)viewController phone1:(int)phone1
{
    // make an SMS
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
    [self sendSMS:viewController to:[NSArray arrayWithObjects:phoneNum, nil] withBody:@"Important message from the Saratoga Swim Club!  "];
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

// send an email to the array of emails with subject and HTML body
-(void)sendEmail:(id)viewController
         subject:(NSString *)subject
            body:(NSString *)body
        ToEmails:(NSArray *)emails {
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = viewController;
        
        [mailCont setSubject:subject];
        [mailCont setBccRecipients:emails];
        [mailCont setMessageBody:body isHTML:true];
        [viewController presentViewController:mailCont animated:YES completion:nil];
    }
    
//    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
//    if (mailClass != nil) {
//        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
//        mailView.mailComposeDelegate = self;  // return to this object to complete delegate methods
//        [mailView setToRecipients:emails];
//        [mailView setSubject:subject];      //Set the subject
//        [mailView setMessageBody:body isHTML:YES];   //Set the mail body
//        //Display Email Composer
//        if([mailClass canSendMail]) {
//            [viewController presentViewController:mailView animated:YES completion:nil];
//        }
//    }
}

-(void)sendEmail:(id)viewController
         subject:(NSString *)subject
          email1:(BOOL)email1
{
    NSString *email = @"";
    if(email1) {
        email = self.email;
    } else {
        email = self.email2;
    }
    [self sendEmail:viewController subject:subject body:@"" ToEmails:@[email]];
}


// delegate routine for MFMessageComposeViewController, dismisses view controller
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

+(BOOL)even:(int)value
{
    return (value%2) ? YES : NO;
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
    BOOL missedReservation = NO;
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
            missedReservation = YES;
        }
    }
    if (self.hasRes && !self.lapSwimmerRes) {
        resTimeLimit = [self convertTimeToFloat:self.resStart];
        if ((resTimeLimit - currentTime) < 0) {
            missedReservation = YES;
        }
    }
    return missedReservation;
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
               self.resStart, self.lapStart, @"", self.kidsNames,
               self.firstName, self.firstName2]];
}

-(NSArray *)signinKeys {
    return @[@"date", @"lastName", @"memberID", @"members", @"guests",
             @"kidsDroppedOff", @"familyMembers", @"memType", @"phone",
             @"email", @"phone2", @"email2", @"optPhone", @"eligable",
             @"noShow", @"resDate", @"resStart", @"lapStart", @"",
             @"kidsNames", @"firstName", @"firstName2"];
}

-(NSArray *)famKeys {
    return @[@"lastName", @"memberID", @"memType", @"", @"",
             @"", @"", @"phone", @"phone2",
             @"email", @"email2", @"", @"", @"", @"",
             @"kidsNames", @"familyMembers", @"eligable", @"row", @"landLine",
             @"firstName", @"firstName2"];
}

-(NSArray *)getMissedResValueArray {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
//    NSString *elg = @"NO";
//    if (self.eligable) {
//        elg = @"YES";
//    }
    return @[@[dateString, self.lastName, self.memberID, self.memType, 
               self.phone, self.email, self.email2, self.phone2,
               self.resDate, self.resStart, self.lapStart]];
}

-(UIImage *)getLogo {
    if (self.checked) {
        return [UIImage imageNamed:@"gSwimClub10mm"];
    } else {
        if (self.eligable) {
            return [UIImage imageNamed:@"SwimClub10mm"];
        } else {
            return [UIImage imageNamed:@"xSwimClub10mm"];
        }
    }
}

// returns a comma delimited string of all first names
-(NSString *)getNames {
    NSString *names = self.firstName;
    if(![self.firstName2 isEqualToString:@""]) {
        names = [names stringByAppendingFormat:@", %@", self.firstName2];
    }
    if(![self.kidsNames isEqualToString:@""]) {
        names = [names stringByAppendingFormat:@", %@", self.kidsNames];
    }
    return names;
}

// this appends this users emails to the email list
-(NSMutableArray *)addEmails:(NSMutableArray *)emails {
    [emails addObject:self.email];
    if (![self.email2 isEqualToString:@""]) {
        [emails addObject:self.email2];
    }
    return emails;
}

// this appends this users cellphone to the sms list
-(NSMutableArray *)addSMSs:(NSMutableArray *)smss {
    [smss addObject:self.phone];
    if (![self.phone2 isEqualToString:@""]) {
        [smss addObject:self.phone2];
    }
    return smss;
}

// converts memberSheet record to family object, remove CL, PL records
// added 18 - landline phone, 19- firstName, 20-firstName2 on 9/17/2020
+(FamilyRec *) convertToFamObj: (NSArray *)member {
    if ([member[0] isEqualToString: @"Last Name"] ||
        [member[0] isEqualToString: @"Test"] ||
        [member[0] isEqualToString: @"Test row"] ||
        [member[0] isEqualToString: @"Test Row"] ||
        [member[1] isEqualToString:@"#"] ||
        [member[2] isEqualToString:@"CL"] ||
        [member[2] isEqualToString:@"PL"] ||
        [member[2] isEqualToString:@"CO"] ||
        [member[2] isEqualToString:@"SL"] ||
        [member[2] isEqualToString:@""]) {
        return nil;      // this is the header, blank last name, or CL or PL remove
    }
    FamilyRec *rec = [[FamilyRec alloc] init];
    for(int i = 0; i < member.count; i++) {
        if ([(NSString *)rec.famKeys[i] isEqualToString: @""]) {
            //NSLog(@"blank key in convertToSignIn");
            continue;  // skip if key is blank
        }

        rec.eligable = YES;
        if (i == 17) {
            NSString *owesMoney = member[17];
            if ([owesMoney isEqualToString:@"x"] ||
                [rec.memType isEqualToString:@"PL"]) {
                rec.eligable = NO;
            }
            if ([rec.memType isEqualToString:@"BD"] ||
                [rec.memType isEqualToString:@"BE"] ) {
                rec.eligable = YES;
            }
        } else {
            [rec setValue:member[i] forKey:rec.famKeys[i]];
        }
        
    }
    // if record is in checkedInToday, then use this record
    return rec; //[self isCheckedInToday: rec];  // can have multiple reservations, can't do it here
}
// 5/29/21 -- looking to check how many guests in a work week, and put that
// in a new family int property "guestsInWeek"
// converts record from sign-in sheet to familyRec
+(FamilyRec *)convertToSignIn: (NSArray *)input {
    if([input[0] isEqualToString:@""] ||
       [input[0] isEqualToString:@"Date Time"]) {
        return nil;
    }
    //
    
    if (input.count > 0) {     // date
        NSDate *date = [NSDate stringToDate:input[0]];  // convert date
        if (![NSDate isToday:date]) {
            return nil;   // if not today, return empty
        }
    }
    
    FamilyRec *rec = [[FamilyRec alloc] init];
    for (int i = 0; i < input.count; i++) {
        if ([(NSString *)rec.signinKeys[i] isEqualToString: @""]) {
            //NSLog(@"blank key in convertToSignIn");
            continue;  // skip if key is blank
        }
        if (i == 3) {
            rec.members = [(NSString *)input[3] intValue];
        } else if (i == 4) {
            rec.guests = [(NSString *)input[4] intValue];
        } else if ((i == 13)||(i == 14)) {
            if ([input[i] isEqualToString:@"YES"]) {
                [rec setValue:@YES forKey:rec.signinKeys[i]];
            } else {
                [rec setValue:@NO forKey:rec.signinKeys[i]];
            }
        } else {  // the rest of the values are NSStrings
            [rec setValue:input[i] forKey:rec.signinKeys[i]];
        }
    }
    rec.checked = YES;
    if (![rec.kidsDroppedOff isEqualToString:@""]) {  // kids dropped off?
        rec.droppedOff = YES;
    }
    //rec.hasRes = YES;  // these are records from signedin array, so have reservation
    // figure out if normal reservation or lap reservation (lapSwimmerRes YES or NO)
    if ([rec.lapStart isEqualToString:@""]) {
        rec.lapSwimmerRes = NO;
    } else {
        rec.lapSwimmerRes = YES;
    }

    return rec;
}

// new method that will update the guests for yearly and weekly
// rows is an array of Signin records
-(void)updateGuests: (NSArray *)rows {
    int guests = 0;
    self.guestFees = nil;       // destroy old object if exists
    for(NSArray *row in rows) {
        // if not a record, or not the lastName or not the memberID then continue to next record
        int rowCount = 0;
        if(row.count > 2) {
            if(row.count == 3) {
                NSLog(@"3");
            }
            if([row[0] isEqualToString:@""] ||
               [row[0] isEqualToString:@"Date Time"] ||
               [row[0] isEqualToString:@""] ||
               [row[0] isEqualToString:@"Tester"] ||
               [row[0] isEqualToString:@"Sold"] ||
               ![row[1] isEqualToString: self.lastName] ||
               ![row[2] isEqualToString:self.memberID]) {
                continue;
            }
        } else {        // 7/30/2023 evict record if less than 2
            continue;
        }
        printf("rowCount: %i", rowCount);
        if(row.count > 0) {     // date
            // if the name and memberID, then applies to this object
            if([row[1] isEqualToString: self.lastName] &&
               [row[2] isEqualToString:self.memberID]) {
                if(row.count > 4) {
                    guests = [(NSString *)row[4] intValue]; // get the guest count
                }
                NSDate *date = [NSDate stringToDate:row[0]];  // convert date
                [self.guestFees addGuests:guests fromDate:date];
            }
        }
    }
}

-(void)addGuests:(int)guests {
    [self.guestFees addGuests:guests fromDate:[NSDate date]];
}

-(int)getGuestsForWeek:(NSDate *)date {
    return [self.guestFees getGuestsForWeekFromDate:date];
    
}
-(int)getPaidGuestsForWeek:(NSDate *)date {
    return [self.guestFees getPaidGuestsForWeekFromDate:date];
}
-(int)getGuestsForYear {
    return [self.guestFees getTotalGuests];
}
-(int)getPaidGuestsForYear {
    return [self.guestFees getTotalPaidGuests];
}

//// indicates if this record is from today (current date)
//+(BOOL)isToday:(NSDate *)aDate {
//
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
//                                          fromDate:[NSDate date]];
//    NSDate *today = [cal dateFromComponents:components];
//    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
//                        fromDate:aDate];
//    NSDate *otherDate = [cal dateFromComponents:components];
//    BOOL isToday = [today isEqualToDate:otherDate];
//    return isToday;
//}
//// indicates if this record is from this year (year from current date)
//+(BOOL)isThisYear:(NSDate *)aDate {
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
//                                    NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
//    NSInteger yearToday = [components year];
//    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
//                  NSCalendarUnitMonth | NSCalendarUnitYear fromDate: aDate];
//    NSInteger yearRecord = [components year];
//
//    return yearToday == yearRecord;
//}
//
//// compares the passed date to the current date's workweek.  returns true if equal
//+(BOOL)isThisWeek:(NSDate *)aDate {
//    NSDate *today = [NSDate date];
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
//                                    kCFCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
//    NSInteger week = [components weekOfYear];
//    components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
//                  kCFCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: aDate];
//    NSInteger weekRecord = [components weekOfYear];
//    return weekRecord == week;
//}
//
//// returns the week of the date
//+(int)weekOfYear:(NSDate*)aDate {
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
//                  kCFCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: aDate];
//    NSInteger weekRecord = [components weekOfYear];
//    return (int) weekRecord;
//}


// converts a string date to the yyyy-MM-dd HH:mm format
//+(NSDate *)stringToDate:(NSString *)dateStr {
//    // Convert string to date object
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
//    return [dateFormat dateFromString:dateStr];
//}

-(id) copyWithZone: (NSZone *) zone
{
    FamilyRec *copy = [[FamilyRec allocWithZone: zone] init];
    copy.date = self.date;
    copy.firstName = self.firstName;
    copy.firstName2 = self.firstName2;
    copy.kidsNames = self.kidsNames;
    copy.lastName = self.lastName;
    copy.memberID = self.memberID;
    copy.memType = self.memType;
    copy.familyMembers = self.familyMembers;
    copy.members = self.members;
    copy.guests = self.guests;
    copy.kidsDroppedOff = self.kidsDroppedOff;
    copy.email = self.email;
    copy.phone = self.phone;
    copy.email2 = self.email2;
    copy.phone2 = self.phone2;
    copy.signOut = self.signOut;
    copy.optPhone = self.optPhone;
    copy.landLine = self.landLine;
    copy.signInRow = self.signInRow;
    copy.eligable = self.eligable;
    copy.droppedOff = self.droppedOff;
    copy.checked = self.checked;
    copy.updated = self.updated;
    copy.added = self.added;
    copy.hasRes = self.hasRes;
    copy.resDate = self.resDate;
    copy.resStart = self.resStart;
    copy.resStop = self.resStop;
    copy.lapStart = self.lapStart;
    copy.lapSwimmerRes = self.lapSwimmerRes;
    copy.lapSwimmers = self.lapSwimmers;
    copy.missedReservationSaved = self.missedReservationSaved;
    copy.noShow = self.noShow;
    copy.guestFees = self.guestFees;
    copy.row = self.row;
    
    return copy;
}

@end
