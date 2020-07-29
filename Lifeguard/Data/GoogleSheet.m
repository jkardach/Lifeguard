//
//  GoogleSheet.m
//  PoolLogger
//
//  Created by jim kardach on 5/24/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import "GoogleSheet.h"
#import "Alert.h"

@implementation GoogleSheet

- (id)init
{
    if (self = [super init]) {
        _name = @"";
        _spreadSheetID = @"";
        _service = false;
        _tabName = @"";
        _range = @"";
        _tabsheetID = @"";

    }
    return self;
}

-(NSMutableDictionary *)tabs {
    if (!_tabs) {
        _tabs = [[NSMutableDictionary alloc] init];
    }
    return _tabs;
}

- (void) setDelegate:(id)newDelegate {
    self.delegate = newDelegate;
}

-(void)readSheetWith:(NSString *)tabName tabRange:(NSString *)tabRange
{
    NSString *range = [NSString stringWithFormat:@"%@!%@", tabName, tabRange];
    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:self.spreadSheetID
                                                            range:range];
    SEL selectorA = @selector(func1:result:error:);
    SEL selectorB = @selector(func2:result:error:);
    SEL selectorC;
    NSInteger x = 0;
    
    switch (x) {
        case 0:
            selectorC = selectorA;
            break;
        case 1:
            selectorC = selectorB;
            break;
            
        default:
            selectorC = selectorA;
            break;
    }
    
    [self.sheetService executeQuery:query delegate:self didFinishSelector:(selectorC)];
}

-(void)func1: (GTLRServiceTicket *)ticket result: (GTLRSheets_ValueRange *) result error: (NSError *) error {
    if (error == nil) {
        self.result = result;  // stores the result
        [self.delegate createRecord:result];     // this moves the
    } else {
        NSString *message = [NSString stringWithFormat:@"Error getting display result sheet data: %@\n", error.localizedDescription];
        [Alert showAlert:@"Error" message:message viewController: self.delegate];
    }
}
-(void)func2: (GTLRServiceTicket *)ticket result: (GTLRSheets_ValueRange *) result error: (NSError *) error {
    if (error == nil) {
        self.result = result;  // stores the result
        [self.delegate createRecord:result];     // this moves the
    } else {
        NSString *message = [NSString stringWithFormat:@"Error getting display result sheet data: %@\n", error.localizedDescription];
        [Alert showAlert:@"Error" message:message viewController: self.delegate];
    }
}
/*
- (void) updateRec: (poolRecord *)poolRecToUpdate
       withTabName:(NSString *)tabName
          tabRange:(NSString *)tabRange
        controller:(id) controller
{
    // first find the row of the record to update
    NSString *range = [NSString stringWithFormat:@"%@!%@", tabName, tabRange];

    GTLRSheetsQuery_SpreadsheetsValuesGet *query =
    [GTLRSheetsQuery_SpreadsheetsValuesGet queryWithSpreadsheetId:self.spreadSheetID
                                                            range:range];
    [self.sheetService executeQuery:query
                  completionHandler:^(GTLRServiceTicket *ticket,
                                      GTLRSheets_ValueRange *result,
                                      NSError *error) {
        int rowOfRec = 0;
        if (error == nil) {
            NSArray *rows = result.values;
            if (rows.count > 0) {
                for (NSArray *row in rows) {
                    if (row.count > 1) {
                        if (([poolRecToUpdate.date isEqualToString:row[0]])&&([poolRecToUpdate.time isEqualToString:row[1]])) {
                            break;  // this is the record with the date and time stamps
                        }
                    } else {
                        break;
                    }
                    rowOfRec++;
                }
            }
            rowOfRec -= 1;  // array starts at zero, spreadsheet row starts at 1
            [self updateRecordAtRow:rowOfRec poolRecord:poolRecToUpdate];  // update spreadsheet row
        } else {
            NSString *message = [NSString stringWithFormat:@"Error: %@\n", error.localizedDescription];
            [Alert showAlert:@"Error" message:message viewController:self];
        }
    }];
}
*/

#pragma mark - NSCoding delegates
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        self.name = [aDecoder decodeObjectForKey:@"PoolName"];
        self.spreadSheetID = [aDecoder decodeObjectForKey:@"SpreadSheetID"];
        //self.range = [aDecoder decodeObjectForKey:@"range"];
        self.service = [aDecoder decodeBoolForKey:@"service"];
        self.tabName = [aDecoder decodeObjectForKey:@"tabName"];
        self.tabsheetID = [aDecoder decodeObjectForKey:@"tabSheetID"];
        //self.tab2Name = [aDecoder decodeObjectForKey:@"tab2Name"];
        //self.tab2sheetID = [aDecoder decodeObjectForKey:@"tab2SheetID"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"PoolName"];
    [aCoder encodeObject:self.spreadSheetID forKey:@"SpreadSheetID"];
    //[aCoder encodeObject:self.range forKey:@"range"];
    [aCoder encodeBool:self.service forKey:@"service"];
    [aCoder encodeObject:self.tabName forKey:@"tabName"];
    [aCoder encodeObject:self.tabsheetID forKey:@"tabSheetID"];
    //[aCoder encodeObject:self.tab2Name forKey:@"tab2Name"];
    //[aCoder encodeObject:self.tab2sheetID forKey:@"tab2SheetID"];
}

@end
