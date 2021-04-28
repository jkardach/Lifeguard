//
//  FamilyRec.h
//  Lifeguard
//
//  Created by jim kardach on 6/28/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface FamilyRec : NSObject <NSCopying>

@property(nonatomic, strong) NSString *date;  //
@property(nonatomic, strong) NSString *firstName;  // first name of parent 1
@property(nonatomic, strong) NSString *firstName2; // first name of parent 2
@property(nonatomic, strong) NSString *kidsNames; // first names of kid first names, comma seperated
@property(nonatomic, strong) NSString *lastName;  // family name
@property(nonatomic, strong) NSString *memberID;
@property(nonatomic, strong) NSString *memType;
@property(nonatomic, strong) NSString *familyMembers;  // total number of family members
@property(nonatomic) int members;  // number of family members checked in
@property(nonatomic) int guests;   // number of guests checked in
@property(nonatomic, strong) NSString *kidsDroppedOff;  // names of kids dropped off (no parents)
@property(nonatomic, strong) NSString *email; // email 1
@property(nonatomic, strong) NSString *phone; // cellphone 1
@property(nonatomic, strong) NSString *email2;  // email 2
@property(nonatomic, strong) NSString *phone2;  // cellphone 2
@property(nonatomic, strong) NSString *signOut;
@property(nonatomic, strong) NSString *optPhone; // optional phone entered at check-in
@property(nonatomic, strong) NSString *landLine; // registered landline phone
@property(nonatomic) int signInRow;                       // row of record in signIn sheet
@property(nonatomic) BOOL eligable;     // eligable to make reservation

@property(nonatomic) BOOL droppedOff;   // were kids dropped off
@property(nonatomic) BOOL checked;
@property(nonatomic) BOOL updated;
@property(nonatomic) BOOL added;

@property(nonatomic) BOOL hasRes;    // has reservation
@property(nonatomic, strong) NSString *resDate;  // reservation date
@property(nonatomic, strong) NSString *resStart;  // start time of reservation
@property(nonatomic, strong) NSString *resStop;  // stop time of reservation
@property(nonatomic, strong) NSString *lapStart;   // start time of lap reservation
@property(nonatomic) BOOL lapSwimmerRes;  // this is a lap swimmer reservation
@property(nonatomic) NSInteger lapSwimmers;  // number of lap swimmers for this reservation
//@property(nonatomic) BOOL missedReservation;
@property(nonatomic) BOOL missedReservationSaved;
@property(nonatomic) BOOL noShow;  // did not make reservation

-(NSMutableArray *)addEmails:(NSMutableArray *)emails;
-(NSMutableArray *)addSMSs:(NSMutableArray *)smss;
-(void)sendEmail:(id)viewController subject:(NSString *)subject body:(NSString *)body ToEmails:(NSArray *)emails;
-(void)sendEmail:(id)viewController subject:(NSString *)subject email1:(BOOL)email1;
-(void)sendSMS:(id)viewController to:(NSArray *)phones withBody:(NSString *)body;
-(void)sendSMS:(id)viewController phone1:(int)phone1;
-(void)call:(id)viewController phone1:(BOOL)phone1;

-(NSString *)getNames;
-(BOOL)didTheyMissReservation;
-(NSArray *)getFamilyValueArray;
-(NSArray *)getSignInValueArray;
-(NSArray *)getMissedResValueArray;
-(BOOL)timeToSaveMissedReservation;
-(NSArray *)signinKeys;
-(NSArray *)famKeys;
-(UIImage *)getLogo;
-(id)copyWithZone:(NSZone * _Nullable)zone;

+(FamilyRec *) convertToFamObj: (NSArray *)member;
+(FamilyRec *)convertToSignIn: (NSArray *)input;
+(BOOL)isToday:(NSDate *)aDate;
+(NSDate *)stringToDate:(NSString *)dateStr;
+(BOOL)even:(int)value;
@end

NS_ASSUME_NONNULL_END
