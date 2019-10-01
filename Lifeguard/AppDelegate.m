//
//  AppDelegate.m
//  googleSheetsTest
//
//  Created by jim kardach on 5/3/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//

#import "AppDelegate.h"
#import "GoogleSheet.h"
#import "FileRoutines.h"
#import "poolRecord.h"

@interface AppDelegate ()
@property (nonatomic, strong) FileRoutines *fileH;
@end

@implementation AppDelegate


#pragma mark = setters/getters
- (NSMutableArray *) poolSheets
{
    if (!_poolSheets) {
        _poolSheets = [[NSMutableArray alloc] init];
        
        GoogleSheet *initSheet = [[GoogleSheet alloc] init];
        initSheet.name = @"Saratoga Swim Club";
        initSheet.spreadSheetID = @"13u7WLeKiXEpn6rGJeKB81I6SUR6GGcvJR8ccRetCcns";
        initSheet.range = @"LifeGuard";
        initSheet.service = false;
        [_poolSheets addObject:initSheet];
    }
    return _poolSheets;
}

- (GTLRSheetsService *)service {
    if (!_service) {
        _service = [[GTLRSheetsService alloc] init];
    }
    return _service;
}

// file save/restore routines
- (FileRoutines *)fileH
{
    if (!_fileH)
    _fileH = [[FileRoutines alloc] init];
    return _fileH;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *filename = [self.fileH filenameWithPrefix:@"Pool"
                                               eventKey:@""
                                                postfix:@""
                                                    ext:@"Data"];
    if ([self.fileH fileExists:filename]) {
        self.poolSheets = [self.fileH restoreObjectFromFilename:filename];
    } else {
        
    }
    [GIDSignIn sharedInstance].clientID = @"229185246988-tdt93711nfb3t3cvrn8ooet4ibspnhe9.apps.googleusercontent.com";
    [GIDSignIn sharedInstance].delegate = (id<GIDSignInDelegate>) self;
    [GIDSignIn sharedInstance].scopes = [NSArray arrayWithObjects:kGTLRAuthScopeSheetsSpreadsheets, nil];
    
    return YES;
}


#pragma mark - Google Sign-in delegates
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    NSLog(@"Did execute the google sign-in openURL delegate");
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    NSLog(@"Did execute the google sign-in -didSignInForUser- delegate");
    
    if (error != nil) {
        NSLog(@"Authentication Error");
        //[self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    } else {
        self.service.authorizer = user.authentication.fetcherAuthorizer;
    }

    NSDictionary *statusText = @{@"statusText":
                                     [NSString stringWithFormat:@"Signed in user: %@",
                                      user.profile.name]};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"authUINotification"
     object:nil
     userInfo:statusText];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    NSLog(@"Did execute the google did disconnect with user delegate");
    // Perform any operations when the user disconnects from app here.
    // ...
}

- (void)saveModel
{
    
    NSString *filename = [self.fileH filenameWithPrefix:@"Pool"
                                               eventKey:@""
                                                postfix:@""
                                                    ext:@"Data"];
    [self.fileH saveObject:self.poolSheets filename:filename];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [self saveModel];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveModel];
}


@end
