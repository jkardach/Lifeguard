//
//  Alert.m
//  Lifeguard
//
//  Created by jim kardach on 7/25/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import "Alert.h"

@implementation Alert

// Helper for showing an alert
+(void)showAlert:(NSString *)title message:(NSString *)message viewController: (UITableViewController *) controller {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
