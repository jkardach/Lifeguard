//
//  PartyDetailTVC.m
//  Lifeguard
//
//  Created by jim kardach on 7/2/19.
//  Copyright © 2019 Forkbeardlabs. All rights reserved.
//

#import "PartyDetailTVC.h"

@interface PartyDetailTVC ()

@end

@implementation PartyDetailTVC

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"Name(memberID): %@(%@)", self.rec.name, self.rec.memberID];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"Date Time: %@", self.rec.start];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"Email: %@", self.rec.email];
            break;
        case 3:
            cell.textLabel.text = [NSString stringWithFormat:@"Phone: %@", self.rec.phone];
            break;
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"MemberType: %@", self.rec.memberType];
            break;
        case 5:
            cell.textLabel.text = [NSString stringWithFormat:@"Duration: %@ hrs", self.rec.duration];
            break;
        case 6:
            cell.textLabel.text = [NSString stringWithFormat:@"Fees: %@ ", self.rec.fees];
            break;
        case 7:
            cell.textLabel.text = [NSString stringWithFormat:@"Party Fee: %@ ", self.rec.partyFee];
            break;
        case 8:
            cell.textLabel.text = [NSString stringWithFormat:@"Late Fee: %@ ", self.rec.lateFee];
            break;
        case 9:
            cell.textLabel.text = [NSString stringWithFormat:@"Payment: %@ ", self.rec.payment];
            break;
            
        default:
            break;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"Name(memberID): %@(%@)", self.rec.name, self.rec.memberID];
    }
    return cell;
}
@end
