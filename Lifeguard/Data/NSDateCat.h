//
//  NSDateCat.h
//  TestMacOS
//
//  Created by jim kardach on 6/28/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate(Myadditions)
+(NSDateComponents *)getComponentsOfDate:(NSDate *)date;
+(int)weekOfDate:(NSDate*)aDate;
+(BOOL)isThisYear:(NSDate *)aDate;
+(BOOL)isThisMonth:(NSDate *)aDate;
+(BOOL)isThisWeek:(NSDate *)aDate;
+(BOOL)isToday:(NSDate *)aDate;
+(NSDate *)stringToDate:(NSString *)dateStr;
@end

NS_ASSUME_NONNULL_END
