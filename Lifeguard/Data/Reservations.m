//
//  Reservations.m
//  Lifeguard
//
//  Created by jim kardach on 7/9/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "Reservations.h"

@interface Reservations ()

@property (nonatomic, strong) NSMutableArray *resCounts;

@end


@implementation Reservations

- (NSMutableArray *)resCounts {
    if (!_resCounts) {
        _resCounts = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < 9; i++) {
            [_resCounts addObject:[NSNumber numberWithInteger:0]];
        }
    }
    return _resCounts;
}

- (id)init {
    if (self = [super init]) {
        _date = [NSDate now];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"MM-dd-yyyy"];
        _dateString = [dateFormatter stringFromDate:_date];
        _title = @"";
        _resCounts = nil;  // this will cause all counts to go to zero
    }
    return self;
}

// go through families and update reservation counts (resStart, or lapStart)
- (void)updateCount:(NSArray *)families {
    for(NSInteger i=0; i<families.count; i++) {
        FamilyRec *rec = families[i];
        NSArray *startLabels = [Reservations compareArray];
        for (NSInteger row = 0; row < startLabels.count; row++) {
            if([rec.resStart isEqualToString:startLabels[row]]) {  // for normal reservations
                NSInteger count = [self.resCounts[row] integerValue];
                count += [rec.familyMembers intValue];
                [self.resCounts replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:count]];
            }
            if([rec.lapStart isEqualToString:startLabels[row]]) {  // for lap reservations
                NSInteger count = [self.resCounts[row] integerValue];
                count += rec.lapSwimmers;
                [self.resCounts replaceObjectAtIndex:row withObject:[NSNumber numberWithInteger:count]];
            }
        }
    }
}


- (void)reset {
    self.resCounts = nil;
}

// returns an array of reservation associated with the timeslot row
- (NSArray *)getReservationsFromFamilies:(NSArray *)families fromTitleRow:(NSInteger)titleRow {
    self.title = [Reservations compareFullArray][titleRow];
    NSMutableArray *resSlot = [[NSMutableArray alloc] init];
    for (FamilyRec *fam in families) {
        if ([fam.resStart isEqualToString:[Reservations compareArray][titleRow]] ||
            [fam.lapStart isEqualToString:[Reservations compareArray][titleRow]]) {
            [resSlot addObject:fam];
        }
    }
    return [NSArray arrayWithArray:resSlot];

}

// once a date is entered, create the NSString in the MM-dd-yyyy format
- (NSDate *)date {
    if (!_date) {
        _date = [NSDate now];
    }
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"MM-dd-yyyy"];
    _dateString = [dateFormatter stringFromDate:_date];
    return _date;
}

// returns the reservation count from the title row
- (NSInteger)getCountFromTitleRow:(NSInteger)Titlerow {
    return [[self.resCounts objectAtIndex:Titlerow] integerValue];
}

- (NSInteger)getRowFromStartTime:(NSString *)startTime {
    NSArray *startTimes = [Reservations compareArray];
    for (NSInteger i = 0; i < startTimes.count; i++) {
        if ([startTimes[i] isEqualToString: startTime]) {
            return i;
        }
    }
    NSException *myException = [NSException
                                exceptionWithName:@"Reservations Class"
                                reason:@"getRowFromStartTime: did not fine a value"
                                userInfo:nil];
    [myException raise];
    return 0;
}


+(NSArray *)compareFullArray {
    NSArray *compareFullArray = @[@"11:00am to 12:30pm", @"12:30pm to 1:00pm", @"1:00pm to 2:30pm",
                                  @"2:30pm to 3:00pm", @"3:00pm to 4:30pm", @"4:30pm to 5:00pm",
                                  @"5:00pm to 6:30pm", @"6:30pm to 7:00pm", @"7:00pm to 8:30pm"];
    return compareFullArray;
}

+(NSArray *)compareArray {
    NSArray *compareArray = @[@"11:00", @"12:30", @"13:00",
                              @"14:30", @"15:00", @"16:30",
                              @"17:00", @"18:30", @"19:00"];
    return compareArray;
}

+(NSString *)getStartLabelByRow:(int)row {
    NSString *startLabel = [Reservations compareArray][row];
    return startLabel;
}

+(NSInteger)getRowFromStartTime:(NSString *)startTime {
    NSArray *compArray = [Reservations compareArray];
    for(NSInteger i = 0; i < compArray.count; i++) {
        if ([startTime isEqualToString:compArray[i]]) {
            return i;
        }
    }
    NSException *myException = [NSException
                                exceptionWithName:@"Reservations Class"
                                reason:@"getRowFromStartLabel: did not fine a value"
                                userInfo:nil];
    [myException raise];
    return 0;
}

@end
