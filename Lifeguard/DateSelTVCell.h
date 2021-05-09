//
//  DateSelTVCell.h
//  Lifeguard
//
//  Created by jim kardach on 7/10/20.
//  Copyright © 2020 Forkbeardlabs. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface DateSelTVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIButton *nextDate;
@property (weak, nonatomic) IBOutlet UIButton *prevDate;

@end

NS_ASSUME_NONNULL_END
