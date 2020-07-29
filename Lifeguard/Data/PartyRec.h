//
//  PartyRec.h
//  Lifeguard
//
//  Created by jim kardach on 6/28/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PartyRec : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *memberID;
@property(nonatomic, strong) NSString *invoiceDate;
@property(nonatomic, strong) NSString *partyOccassion;
@property(nonatomic, strong) NSString *partyDate;
@property(nonatomic, strong) NSString *start;
@property(nonatomic, strong) NSString *stop;
@property(nonatomic, strong) NSString *partyTime;
@property(nonatomic, strong) NSString *duration;
@property(nonatomic, strong) NSString *partyType;
@property(nonatomic, strong) NSString *memberType;
@property(nonatomic, strong) NSString *fees;
@property(nonatomic, strong) NSString *partyFee;
@property(nonatomic, strong) NSString *lateFee;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *phone;
@property(nonatomic, strong) NSString *payment;
@property(nonatomic, strong) NSString *check;
@property(nonatomic, strong) NSString *received;
@property(nonatomic, strong) NSString *deposited;
@property(nonatomic, strong) NSString *refund;
@property(nonatomic) BOOL checked;

- (NSComparisonResult)compareDates:(PartyRec *)record;
-(NSArray *)keys;
@end

NS_ASSUME_NONNULL_END
