//
//  ShowCheckedInTVC.h
//  Lifeguard
//
//  Created by jim kardach on 7/21/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

@import UIKit;
#import "FamilyRec.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShowCheckedInTVC : UITableViewController
@property (nonatomic, strong) FamilyRec *member;
@end

NS_ASSUME_NONNULL_END
