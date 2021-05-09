//
//  poolRecord.h
//  PoolLogger
//
//  Created by jim kardach on 5/21/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

@import Foundation;
#import "GTLRSheets.h"

@interface poolRecord : NSObject
@property (nonatomic, strong) GTLRSheetsService *sheetService;
@property(nonatomic, strong) NSString *date;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, strong) NSString *poolPh;
@property(nonatomic, strong) NSString *poolCl;
@property(nonatomic, strong) NSString *poolSensorPh;
@property(nonatomic, strong) NSString *poolSensorCl;
@property(nonatomic, strong) NSString *poolGalAcid;
@property(nonatomic, strong) NSString *poolGalCl;
@property(nonatomic) BOOL poolWaterLevel;
@property(nonatomic) BOOL poolfilterBackwash;

@property(nonatomic, strong) NSString *spaPh;
@property(nonatomic, strong) NSString *spaCl;
@property(nonatomic, strong) NSString *spaSensorPh;
@property(nonatomic, strong) NSString *spaSensorCl;
@property(nonatomic, strong) NSString *spaGalAcid;
@property(nonatomic, strong) NSString *spaGalCl;
@property(nonatomic) BOOL spaWaterLevel;
@property(nonatomic) BOOL spafilterBackwash;

@property(nonatomic, strong) NSString *note;
@property(nonatomic) BOOL newRecord;
@property(nonatomic) BOOL updated;
@property(nonatomic) BOOL service;

- (NSComparisonResult)compareDates:(poolRecord *)record;
-(NSArray *)keys;
-(NSArray *)valueArray;

@end
