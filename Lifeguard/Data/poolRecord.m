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
        _poolPh = @"-";
        _poolCl = @"-";
        _poolSensorPh = @"-";
        _poolSensorCl = @"-";
        _poolGalAcid = @"-";
        _poolGalCl = @"-";
        
        _spaPh = @"-";
        _spaCl = @"-";
        _spaSensorPh = @"-";
        _spaSensorCl = @"-";
        _spaGalAcid = @"-";
        _spaGalCl = @"-";
        
        _newRecord = true;
        _poolfilterBackwash = false;
        _spafilterBackwash = false;
        _updated = false;
        _poolWaterLevel = false;
        _spaWaterLevel = false;
        _service = false;
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

-(NSArray *)keys {
    if (self.service) {
        // 0-18
        return @[@"date", @"time",
                 @"poolPh", @"poolCl",@"poolSensorPh", @"poolSensorCl",
                 @"poolGalAcid", @"poolGalCl", @"poolfilterBackwash",
                 @"spaPh", @"spaCl",@"spaSensorPh", @"spaSensorCl",
                 @"spaGalAcid", @"spaGalCl", @"spafilterBackwash",
                 @"note", @"poolWaterLevel", @"spaWaterLevel"];
    } else {
        // 0-8
        return @[@"date", @"time", @"poolPh", @"poolCl", @"spaPh", @"spaCl",
                 @"note", @"poolWaterLevel", @"spaWaterLevel"];
    }
}
-(NSArray *)valueArray {
    NSString *poolWaterLevel = @"FALSE";
    NSString *spaWaterLevel = @"FALSE";
    NSString *poolBackwash = @"FALSE";
    NSString *spaBackwash = @"FALSE";
    if (self.poolfilterBackwash) {
        poolBackwash = @"TRUE";
    }
    if (self.spafilterBackwash) {
        spaBackwash = @"TRUE";
    }
    if(self.poolWaterLevel) {
        poolWaterLevel = @"TRUE";
    }
    if(self.spaWaterLevel) {
        spaWaterLevel = @"TRUE";
    }
    NSArray *valueArray;
    if(self.service) {
        valueArray = @[
            @[self.date, self.time,
              self.poolPh, self.poolCl,
              self.poolSensorPh, self.poolSensorCl,
              self.poolGalAcid, self.poolGalCl, poolBackwash,
              self.spaPh, self.spaCl,
              self.spaSensorPh, self.spaSensorCl,
              self.spaGalAcid, self.spaGalCl, spaBackwash,
              self.note, poolWaterLevel, spaWaterLevel]
        ];
    } else {
        valueArray = @[
            @[self.date, self.time, self.poolPh,
              self.poolCl, self.spaPh, self.spaCl,
              self.note, self, spaWaterLevel]
        ];
    }
    return valueArray;
}
@end
