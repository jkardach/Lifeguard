//
//  Reservations.h
//  Lifeguard
//
//  Created by jim kardach on 7/9/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

@import Foundation;
#import "FamilyRec.h"

NS_ASSUME_NONNULL_BEGIN

@interface Reservations : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong, readonly) NSString *dateString;
@property (nonatomic, strong) NSString *title;

-(void)updateCount:(NSArray *)families;
-(void)reset;
// returns an array of reservation associated with the timeslot row
-(NSArray *)getReservationsFromFamilies:(NSArray *)families fromTitleRow:(NSInteger)TitleRow;
// returns the count of the reservations for the timeslot row
-(NSInteger)getCountFromTitleRow:(NSInteger)Titlerow;
// returns the row of the reservation based on the startTime string
-(NSInteger)getRowFromStartTime:(NSString *)startTime;
+(NSArray *)compareFullArray;
+(NSArray *)compareArray;
@end

NS_ASSUME_NONNULL_END
