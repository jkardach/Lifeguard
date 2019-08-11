//
//  GoogleSheet.h
//  PoolLogger
//
//  Created by jim kardach on 5/24/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleSheet : NSObject <NSCoding>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *spreadSheetID;
@property (nonatomic, strong) NSString *range;
@property (nonatomic) BOOL service;     // indicates this is a service account

@end
