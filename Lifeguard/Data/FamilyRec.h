//
//  FamilyRec.h
//  Lifeguard
//
//  Created by jim kardach on 6/28/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FamilyRec : NSObject
@property(nonatomic, strong) NSString *date;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *memberID;
@property(nonatomic, strong) NSString *memType;
@property(nonatomic, strong) NSString *familyMembers;
@property(nonatomic) int members;
@property(nonatomic) int guests;
@property(nonatomic, strong) NSString *kidsDroppedOff;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *phone;
@property(nonatomic, strong) NSString *email2;
@property(nonatomic, strong) NSString *phone2;
@property(nonatomic, strong) NSString *signOut;
@property(nonatomic, strong) NSString *optPhone;
@property(nonatomic) int signInRow;                       // row of record in signIn sheet
@property(nonatomic) BOOL eligable;

@property(nonatomic) BOOL droppedOff;
@property(nonatomic) BOOL checked;
@property(nonatomic) BOOL updated;

@property(nonatomic) BOOL hasRes;
@property(nonatomic, strong) NSString *resStart;
@property(nonatomic, strong) NSString *resStop;


- (void)sendSMS:(id)viewController phone1:(int)phone1;
- (void)call:(id)viewController phone1:(BOOL)phone1;
- (void)sendEmail:(id)viewController subject:(NSString *)subject email1:(BOOL)email1;
@end

NS_ASSUME_NONNULL_END
