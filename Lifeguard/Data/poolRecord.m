//
//  poolRecord.m
//  PoolLogger
//
//  Created by jim kardach on 5/21/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import "poolRecord.h"

@implementation poolRecord
- (id)init
{
    if (self = [super init]) {
        NSDate *today = [NSDate date];  // get current date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        
        _date = [dateFormatter stringFromDate:today];
        _time = [timeFormatter stringFromDate:today];
        _note = @" ";
        _poolPh = @" ";
        _poolCl = @" ";
        _poolSensorPh = @" ";
        _poolSensorCl = @" ";
        _poolGalAcid = @" ";
        _poolGalCl = @" ";
        
        _spaPh = @" ";
        _spaCl = @" ";
        _spaSensorPh = @" ";
        _spaSensorCl = @" ";
        _spaGalAcid = @" ";
        _spaGalCl = @" ";
        
        _newRecord = true;
        _poolfilterBackwash = false;
        _spafilterBackwash = false;
        _updated = false;
    }
    return self;
}

// used to compare dates in an array, sorts by date
- (NSComparisonResult)compareDates:(poolRecord *)record
{
    NSDateFormatter *recDateFormat = [[NSDateFormatter alloc] init];
    [recDateFormat setDateFormat:@"yyyy/MM/dd'T'HH:mm"];
    
    NSString *recDateString = [NSString stringWithFormat: @"%@T%@", record.date, record.time];
    NSDate *recDate = [recDateFormat dateFromString:recDateString];
    
    NSString *dateString = [NSString stringWithFormat: @"%@T%@", self.date, self.time];
    NSDate *thisDate = [recDateFormat dateFromString:dateString];
    
    return [recDate compare:thisDate];
}

@end
