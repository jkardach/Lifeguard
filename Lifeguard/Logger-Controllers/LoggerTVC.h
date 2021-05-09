//
//  LoggerTVC.h
//  PoolLogger
//
//  Created by jim kardacselh on 5/21/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

@import UIKit;
@import GoogleSignIn;

#import "GoogleSheet.h"

@interface LoggerTVC : UITableViewController
@property (nonatomic, strong) GoogleSheet *sheet;
@end
