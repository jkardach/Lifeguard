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
        _tab1Name = @"";
        _tab1sheetID = 0;
        _tab2Name = @"";
        _tab2sheetID = 0;
    }
    return self;
}

#pragma mark - NSCoding delegates
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        self.name = [aDecoder decodeObjectForKey:@"PoolName"];
        self.spreadSheetID = [aDecoder decodeObjectForKey:@"SpreadSheetID"];
        self.range = [aDecoder decodeObjectForKey:@"range"];
        self.service = [aDecoder decodeBoolForKey:@"service"];
        self.tab1Name = [aDecoder decodeObjectForKey:@"tab1Name"];
        self.tab1sheetID = [aDecoder decodeObjectForKey:@"tab1SheetID"];
        self.tab2Name = [aDecoder decodeObjectForKey:@"tab2Name"];
        self.tab2sheetID = [aDecoder decodeObjectForKey:@"tab2SheetID"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"PoolName"];
    [aCoder encodeObject:self.spreadSheetID forKey:@"SpreadSheetID"];
    [aCoder encodeObject:self.range forKey:@"range"];
    [aCoder encodeBool:self.service forKey:@"service"];
    [aCoder encodeObject:self.tab1Name forKey:@"tab1Name"];
    [aCoder encodeObject:self.tab1sheetID forKey:@"tab1SheetID"];
    [aCoder encodeObject:self.tab2Name forKey:@"tab2Name"];
    [aCoder encodeObject:self.tab2sheetID forKey:@"tab2SheetID"];
}

@end
