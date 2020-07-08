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
@property (nonatomic, strong) NSArray *tabs;  // an array of tabs in the sheet
@property (nonatomic, strong) NSString *range;
@property(nonatomic, strong) NSString *tab1Name;
@property(nonatomic, strong) NSNumber *tab1sheetID;
@property(nonatomic, strong) NSString *tab2Name;
@property(nonatomic, strong) NSNumber *tab2sheetID;
@property (nonatomic) BOOL service;     // indicates this is a service account

@end
