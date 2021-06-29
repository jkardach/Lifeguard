//
//  GuestFees.m
//  Lifeguard
//
//  Created by jim kardach on 6/26/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//
/*
 This class holds a private date and the n
 */

#import "GuestFees.h"
#import "GuestWeek.h"  // this class has a weekDate and a guests property
#import "NSDateCat.h"
#import "Constants.h"

@interface GuestFees()

// private properties
@property(nonatomic, strong)NSMutableArray *weeksInYear;
//@property(nonatomic, strong)NSDate *today = [NSDate date]; // week for year
//@property(nonatomic)int guests;
    
@end

@implementation GuestFees

- (id)init
{
    if (self = [super init]) {
        // init code here
        _weeksInYear = [[NSMutableArray alloc] init];
        // creates an array of all workweeks
        for(int i = 0; i < 53; i++) {
            GuestWeek *guestWeek = [[GuestWeek alloc] init];
            guestWeek.workWeek = i;
            guestWeek.guests = 0;
            [_weeksInYear addObject:guestWeek];
        }
        
    }
    return self;
}

// adds guests to the date if in the same year
-(void)addGuests:(int)guests fromDate:(NSDate *)date {
    if([NSDate isThisYear:date]) {
        int week = [NSDate weekOfDate: date];
        GuestWeek *rec = [self getGuestRecFromWeek: week];
        rec.guests += guests;
    } else {
        printf("**");
    }
}

// returns the guests for date
-(int)getGuestsForWeekFromDate:(NSDate *)date {
    int guests = 0;
    if([NSDate isThisYear:date]) {
        int week = [NSDate weekOfDate: date];
        GuestWeek *rec = [self getGuestRecFromWeek: week];
        guests = rec.guests;
    }
    return guests;
}

// returns the paid guests for date
-(int)getPaidGuestsForWeekFromDate:(NSDate *)date {
    int guests = 0;
    if([NSDate isThisYear:date]) {
        int week = [NSDate weekOfDate: date];
        GuestWeek *rec = [self getGuestRecFromWeek: week];
        guests = rec.guests - GUESTS_PER_WEEK;
        if(guests < 0) {
            guests = 0;
        }
    }
    return guests;
}

// returns an array of guest non-empty guests
-(NSArray *)getGuests {
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for(GuestWeek *rec in self.weeksInYear) {
        if(rec.guests != 0) {
            [values addObject:rec];
        }
    }
    return values;
}

// returns the total guests for the year to date
-(int)getTotalGuests {
    int total = 0;
    NSArray *guestArray = [self getGuests];
    for(GuestWeek *rec in guestArray) {
        total += rec.guests;
    }
    return total;
}

// returns the total number of Paid guests for the year to date
-(int)getTotalPaidGuests {
    int total = 0;
    NSArray *paidGuestArray = [self getPaidGuests];
    for(GuestWeek *rec in paidGuestArray) {
        total += rec.guests;
    }
    return total;
}

// returns an array of Paid guest non-empty guests
-(NSArray *)getPaidGuests {
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for(GuestWeek *rec in self.weeksInYear) {
        if(rec.guests != 0) {
            GuestWeek *newRec = [[GuestWeek alloc] init];  // create new record
            newRec.guests = rec.guests - GUESTS_PER_WEEK;
            newRec.workWeek = rec.workWeek;
            if(newRec.guests <= 0) {
                continue;  // if result is zero or less, continue
            }
            [values addObject:newRec];
        }
    }
    return values;
}

// private returns the guestFees record based on week
-(GuestWeek *)getGuestRecFromWeek:(int)week {
    GuestWeek *rec;
    for(GuestWeek *guestWeek in self.weeksInYear) {
        if(guestWeek.workWeek == week) {
            rec = guestWeek;
            break;
        }
    }
    return rec;
}



@end



