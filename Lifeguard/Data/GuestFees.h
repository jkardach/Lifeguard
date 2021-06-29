//
//  GuestFees.h
//  Lifeguard
//
//  Created by jim kardach on 6/26/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuestFees : NSObject

-(void)addGuests:(int)guests fromDate:(NSDate *)date;  // adds guests to correct week in date
-(int)getGuestsForWeekFromDate:(NSDate *)date;    // returns guests for week in date
-(int)getPaidGuestsForWeekFromDate:(NSDate *)date; // returns paid guests for week in date
-(int)getTotalGuests;                       // gets the total guests for year
-(int)getTotalPaidGuests;                   // get total paid guests for year
-(NSArray *)getGuests;                      // this returns an array of nonezero weeks
-(NSArray *)getPaidGuests;

@end


NS_ASSUME_NONNULL_END
