//
//  ConfigTVC.m
//  PoolLogger
//
//  Created by jim kardach on 5/24/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import "ConfigTVC.h"
#import "AppDelegate.h"

@interface ConfigTVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *spreadsheetID;
@property (weak, nonatomic) IBOutlet UITextField *range;
@property (weak, nonatomic) IBOutlet UISwitch *lifeguardServiceButton;

@end

@implementation ConfigTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.name.delegate = self;
    self.spreadsheetID.delegate = self;
    self.range.delegate = self;
    
    self.name.text = self.sheet.name;
    self.spreadsheetID.text = self.sheet.spreadSheetID;
    self.range.text = self.sheet.range;
    if (self.sheet.service) {
        self.lifeguardServiceButton.on = true;
    } else {
        self.lifeguardServiceButton.on = false;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate saveModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

#pragma mark - textfield delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == 0) {
        self.sheet.name = textField.text;
    } else if (textField.tag == 1) {
        self.sheet.spreadSheetID = textField.text;
    } else if (textField.tag == 2) {
        self.sheet.range = textField.text;
    }
    
    return YES;
}
- (IBAction)lifeguardService:(UISwitch *)sender
{
    if (sender.on) {
        self.sheet.service = true;
    } else {
        self.sheet.service = false;
    }
}

@end
