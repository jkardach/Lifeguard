//
//  ConfigTVC.h
//  PoolLogger
//
//  Created by jim kardach on 5/24/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

@import UIKit;
#import "GoogleSheet.h"

@interface ConfigTVC : UITableViewController
@property (strong, nonatomic) GoogleSheet *sheet;
@end
