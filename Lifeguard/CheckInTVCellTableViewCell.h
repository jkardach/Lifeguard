//
//  CheckInTVCellTableViewCell.h
//  Lifeguard
//
//  Created by jim kardach on 7/22/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

@import UIKit;
@protocol CellDelegate <NSObject>
- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withSender:(UIButton * _Nullable)sender;
@end

NS_ASSUME_NONNULL_BEGIN

@interface CheckInTVCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (weak, nonatomic) id<CellDelegate>delegate;
@property (assign, nonatomic) NSInteger cellIndex;


@end

NS_ASSUME_NONNULL_END
