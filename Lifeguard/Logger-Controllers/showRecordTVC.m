//
//  showRecordTVC.m
//  PoolLogger
//
//  Created by jim kardach on 5/22/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import "showRecordTVC.h"
#import "editRecordTVC.h"
#import "FileRoutines.h"

@interface showRecordTVC ()

@property (weak, nonatomic) IBOutlet UILabel *clRange;
@property (weak, nonatomic) IBOutlet UILabel *phRange;

@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *poolLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaLabel;
@property (weak, nonatomic) IBOutlet UITextView *note;

// additional Service fields
@property (weak, nonatomic) IBOutlet UILabel *poolSensorLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaSensorLabel;
@property (weak, nonatomic) IBOutlet UILabel *poolGalsLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaGalsLabel;

// Service Tableview Cells
@property (weak, nonatomic) IBOutlet UITableViewCell *poolSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *poolGalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaGalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *poolBackWashCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaBackwashCell;

@property (nonatomic, strong) FileRoutines *tools;

@end

@implementation showRecordTVC

#pragma mark setters/getters

- (FileRoutines *)tools {
    if (!_tools) {
        _tools = [[FileRoutines alloc] init];
    }
    return _tools;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!self.precord.service) {
        self.poolSensorCell.hidden = true;
        self.spaSensorCell.hidden = true;
        self.poolGalCell.hidden = true;
        self.spaGalCell.hidden = true;
        self.poolBackWashCell.hidden = true;
        self.spaBackwashCell.hidden = true;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];
    [self initValues];

}

-(void)initValues
{
    self.clRange.textAlignment = NSTextAlignmentLeft;
    self.clRange.text = @"CL Spa:3-10ppm Pool:2-10ppm";
    [self.clRange setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    self.clRange.textColor = [self.tools getUIColorObjectFromHexString:@"#e17055" alpha:1];
    
    self.phRange.textAlignment = NSTextAlignmentRight;
    self.phRange.text = @"pH: 7.2-7.8";
    [self.phRange setFont:[UIFont fontWithName:@"Arial-BoldMT" size:17]];
    self.phRange.textColor = [self.tools getUIColorObjectFromHexString:@"#0984e3" alpha:1];
    
    
    self.date.text = [NSString stringWithFormat:@"Date: %@", self.precord.date];
    self.time.text = [NSString stringWithFormat:@"Time: %@", self.precord.time];
    self.poolLabel.text = [NSString stringWithFormat:@"pH:%@, CL:%@ppm", self.precord.poolPh, self.precord.poolCl];
    self.spaLabel.text = [NSString stringWithFormat:@"pH:%@, CL:%@ppm", self.precord.spaPh, self.precord.spaCl];
    self.note.text = self.precord.note;
    if (self.precord.service) {
        self.poolSensorLabel.text = [NSString stringWithFormat:@"pH:%@, CL:%@ppm",
                                     self.precord.poolSensorPh, self.precord.poolSensorCl];
        self.spaSensorLabel.text = [NSString stringWithFormat:@"pH:%@, CL:%@ppm",
                                    self.precord.spaSensorPh, self.precord.spaSensorCl];
        self.poolGalsLabel.text = [NSString stringWithFormat:@"Acid: %@gal, CL: %@gal",
                                   self.precord.poolGalAcid, self.precord.poolGalCl];
        self.spaGalsLabel.text = [NSString stringWithFormat:@"Acid: %@gal, CL:%@gal",
                                   self.precord.spaGalAcid, self.precord.spaGalCl];
        if (self.precord.poolfilterBackwash) {
            self.poolBackWashCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.poolBackWashCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (self.precord.spafilterBackwash) {
            self.spaBackwashCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.spaBackwashCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 1;
    if (section == 0) {
        rows = 2;
    } else if (section == 1 || section ==2) {
        if (self.precord.service) {
            rows = 4;
        }
    }
    return rows;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditRecord"]) {
        
        editRecordTVC *erTVC = [segue destinationViewController];
        erTVC.precord = self.precord;
    }
}

@end
