//
//  NSDateCat.m
//  TestMacOS
//
//  Created by jim kardach on 6/28/21.
//

#import "NSDateCat.h"
@implementation NSDate(Myadditions)

// indicates if this record is from today (current date)
+(BOOL)isDay:(NSDate *)aDate {
    NSDate *today = [NSDate date];
    NSInteger day = [[NSDate getComponentsOfDate: today] day];
    NSInteger dayRecord = [[NSDate getComponentsOfDate: aDate] day];
    return dayRecord == day;
}

// indicates if this record is from today (current date)
+(BOOL)isToday:(NSDate *)aDate {
    return [self isDay:aDate] && [self isThisMonth:aDate] && [self isThisYear:aDate];
}

// compares the passed date to the current date's workweek.  returns true if equal
+(BOOL)isThisWeek:(NSDate *)aDate {
    NSDate *today = [NSDate date];
    NSInteger week = [[NSDate getComponentsOfDate: today] weekOfYear];
    NSInteger weekRecord = [[NSDate getComponentsOfDate: aDate] weekOfYear];
    return weekRecord == week;
}

+(BOOL)isThisMonth:(NSDate *)aDate {
    NSInteger monthToday = [[NSDate getComponentsOfDate: [NSDate date]] month];
    NSInteger monthRecord = [[NSDate getComponentsOfDate: aDate] month];
    return (monthToday == monthRecord) && [self isThisYear: aDate];
}

// indicates if this record is from this year (year from current date)
+(BOOL)isThisYear:(NSDate *)aDate {
    NSInteger yearToday = [[NSDate getComponentsOfDate: [NSDate date]] year];
    NSInteger yearRecord = [[NSDate getComponentsOfDate: aDate] year];
    return yearToday == yearRecord;
}


// returns the week of the date
+(int)weekOfDate:(NSDate*)aDate {
    NSInteger weekRecord = [[NSDate getComponentsOfDate: aDate] weekOfYear];
    return (int) weekRecord;
}

// helper method gets calendar components for a date
+(NSDateComponents *)getComponentsOfDate:(NSDate *)date {
    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
            kCFCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: date];
}

// Convert string to date object
+(NSDate *)stringToDate:(NSString *)dateStr {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate* returnDate = [dateFormat dateFromString:dateStr];
    if(!returnDate) {
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        returnDate = [dateFormat dateFromString:dateStr];
    }
    return returnDate;
}

@end
