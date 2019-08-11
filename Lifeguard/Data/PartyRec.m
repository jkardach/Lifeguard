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
        _email = @"";
        _phone = @"";
        _payment = @"";
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



@end
