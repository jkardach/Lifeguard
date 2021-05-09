//
//  GoogleSheet.h
//  PoolLogger
//
//  Created by jim kardach on 5/24/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

@import Foundation;
#import "GTLRSheets.h"
#import "SheetTab.h"

@protocol GoogleSheetDelegate
@required
- (void)createRecord:(GTLRSheets_ValueRange *) result;  // this passes the result of the query back

@optional


@end

@interface GoogleSheet : NSObject <NSCoding>
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *spreadSheetID;
@property (nonatomic, strong) NSString *tabName;
@property (nonatomic, strong) NSString *tabsheetID;
@property (nonatomic, strong) GTLRSheetsService *sheetService;
@property (nonatomic, strong) NSString *range;
@property (nonatomic) BOOL service;     // indicates this is a service account
@property (nonatomic, strong) NSMutableDictionary *tabs;  // dictionary of tabs
@property (nonatomic, strong) GTLRSheets_ValueRange *result; 

-(void)setDelegate:(id)newDelegate;

-(void)readSheetWith:(NSString *)tabName tabRange:(NSString *)tabRange;
@end
