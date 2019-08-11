//
//  FCell.h
//  googleSheetsTest
//
//  Created by jim kardach on 5/25/17.
//  Copyright © 2017 Forkbeardlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *top;
@property (weak, nonatomic) IBOutlet UILabel *bottom;


@end
