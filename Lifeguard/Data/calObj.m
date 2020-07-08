//
//  calObj.m
//  Lifeguard
//
//  Created by jim kardach on 6/24/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "calObj.h"

@implementation calObj

- (id)init {
    if (self = [super init]) {
        _start = @"";
        _end = @"";
        _memberId = @"";
        _lapSwimmer = NO;
        _numberLapSwimmers = 0;
    }
    return self;
}

@end
