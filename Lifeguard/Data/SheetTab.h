//
//  SheetTab.h
//  Lifeguard
//
//  Created by jim kardach on 7/8/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface SheetTab : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sheetID;
@property (nonatomic, strong) NSString *range;

@property (nonatomic) BOOL supportsBulk;
@property (nonatomic, strong) NSString *batchRangePE;
@property (nonatomic, strong) NSString *batchRangeLE;
@property (nonatomic, strong) NSString *batchRangeTR;
@end

NS_ASSUME_NONNULL_END
