//
//  SheetTab.m
//  Lifeguard
//
//  Created by jim kardach on 7/8/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "SheetTab.h"

@implementation SheetTab
- (id)init
{
    if (self = [super init]) {
        _name = @"";
        _sheetID = @"";
        _range = @"";
        _supportsBulk = false;
        _batchRangePE = @"";
        _batchRangeLE = @"";
        _batchRangeTR = @"";
    }
    return self;
}


@end
