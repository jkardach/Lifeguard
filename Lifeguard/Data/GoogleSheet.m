//
//  GoogleSheet.m
//  PoolLogger
//
//  Created by jim kardach on 5/24/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import "GoogleSheet.h"

@implementation GoogleSheet

- (id)init
{
    if (self = [super init]) {
        _name = @"";
        _spreadSheetID = @"";
        _range = @"";
        _service = false;
    }
    return self;
}

#pragma mark - NSCoding delegates
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        self.name = [aDecoder decodeObjectForKey:@"PoolName"];
        self.spreadSheetID = [aDecoder decodeObjectForKey:@"SheetID"];
        self.range = [aDecoder decodeObjectForKey:@"range"];
        self.service = [aDecoder decodeBoolForKey:@"service"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"PoolName"];
    [aCoder encodeObject:self.spreadSheetID forKey:@"SheetID"];
    [aCoder encodeObject:self.range forKey:@"range"];
    [aCoder encodeBool:self.service forKey:@"service"];
}

@end
