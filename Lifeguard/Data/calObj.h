//
//  calObj.h
//  Lifeguard
//
//  Created by jim kardach on 6/24/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface calObj : NSObject
@property (nonatomic, strong) NSString *start;
@property (nonatomic, strong) NSString *end;
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic) BOOL lapSwimmer;
@property (nonatomic) int numberLapSwimmers;


@end

NS_ASSUME_NONNULL_END
