//
//  AppDelegate.h
//  googleSheetsTest
//
//  Created by jim kardach on 5/3/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//  Client ID for "Lifeguard"
//  229185246988-v8shefau0te7hh87stnthd6vfiagql95.apps.googleusercontent.com
//  See https://developers.google.com/identity/sign-in/ios/start for google signIn
#import <UIKit/UIKit.h>
#import "GTLRSheets.h"
#import "GTLRCalendar.h"
@import GoogleSignIn;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *poolSheets;
@property (nonatomic, strong) GIDAuthentication *authentication;
@property (nonatomic, strong) GTLRSheetsService *sheetService;
@property (nonatomic, strong) GTLRCalendarService *calendarService;
@property (nonatomic, strong) GIDGoogleUser *theUser;

- (void)signInToGoogle: (id) delegate;
- (void)reSignInToGoogle: (id) delegate;
- (void)saveModel;

@end

