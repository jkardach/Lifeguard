//
//  Alert.h
//  Lifeguard
//
//  Created by jim kardach on 7/25/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

//@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface Alert : NSObject
+(void)showAlert:(NSString *)title message:(NSString *)message viewController: (UITableViewController *) controller;
@end

NS_ASSUME_NONNULL_END
