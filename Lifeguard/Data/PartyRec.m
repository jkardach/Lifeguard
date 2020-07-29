//
//  PartyRec.m
//  Lifeguard
//
//  Created by jim kardach on 6/28/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "PartyRec.h"

@implementation PartyRec
- (id)init
{
    if (self = [super init]) {
        _name = @"";
        _memberID = @"";
        _invoiceDate = @"";
        _partyOccassion = @"";
        _partyDate = @"";
        _start = @"";
        _stop = @"";
        _partyTime = @"";
        _duration = @"";
        _partyType = @"";
        _memberType = @"";
        _fees = @"";
        _partyFee = @"";
        _lateFee = @"";
        _email = @"";
        _phone = @"";
        _payment = @"";
        _check = @"";
        _received = @"";
        _deposited = @"";
        _refund = @"";
    }
    return self;
}

// used to compare dates in an array, sorts by date
- (NSComparisonResult)compareDates:(PartyRec *)record
{
    NSDateFormatter *recDateFormat = [[NSDateFormatter alloc] init];
    [recDateFormat setDateFormat:@"yyyy/MM/dd"];
    
    NSDate *recDate = [recDateFormat dateFromString:record.partyDate];
    NSDate *thisDate = [recDateFormat dateFromString:self.partyDate];
    
    return [thisDate compare:recDate];
}

-(NSArray *)keys {
    
    return @[@"name", @"memberID",
             @"invoiceDate", @"partyOccassion",@"partyDate", @"start",
             @"stop", @"partyTime", @"duration", @"partyType", @"memberType",
             @"fees", @"partyFee", @"lateFee", @"email", @"phone", @"payment",
             @"check", @"received", @"deposited", @"refund", @"checked"];
}


@end
