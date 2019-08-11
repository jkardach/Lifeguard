//
//  CheckInTVCellTableViewCell.m
//  Lifeguard
//
//  Created by jim kardach on 7/22/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "CheckInTVCellTableViewCell.h"

@implementation CheckInTVCellTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnCellAtIndex:withSender:)]) {
        [self.delegate didClickOnCellAtIndex:_cellIndex withSender:sender];
    }
}

@end
