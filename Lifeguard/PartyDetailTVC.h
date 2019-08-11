//
//  PartyDetailTVC.h
//  Lifeguard
//
//  Created by jim kardach on 7/2/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PartyRec.h"

NS_ASSUME_NONNULL_BEGIN

@interface PartyDetailTVC : UITableViewController
@property (nonatomic, strong) PartyRec *rec;
@end

NS_ASSUME_NONNULL_END
