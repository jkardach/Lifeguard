//
//  ShowFamiliesTVC.h
//  Lifeguard
//
//  Created by jim kardach on 9/18/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FamilyRec.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShowFamiliesTVC : UITableViewController
@property(nonatomic, strong) FamilyRec *family;
@end

NS_ASSUME_NONNULL_END
