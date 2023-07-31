//
//  editRecordTVC.m
//  PoolLogger
//
//  Created by jim kardach on 5/22/18.
//  Copyright © 2018 Forkbeardlabs. All rights reserved.
//

#import "editRecordTVC.h"
#import "Alert.h"

@interface editRecordTVC () <UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UITextField *poolPhTF;
@property (weak, nonatomic) IBOutlet UITextField *poolClTF;
@property (weak, nonatomic) IBOutlet UITextField *spaPhTF;
@property (weak, nonatomic) IBOutlet UITextField *spaClTF;
@property (weak, nonatomic) UITextField *commonTF;

// service textFields
@property (weak, nonatomic) IBOutlet UITextField *poolPhSensorTF;
@property (weak, nonatomic) IBOutlet UITextField *poolClSensorTF;
@property (weak, nonatomic) IBOutlet UITextField *poolAcidGalsTF;
@property (weak, nonatomic) IBOutlet UITextField *poolClGalsTF;
@property (weak, nonatomic) IBOutlet UITextField *spaPhSensorTF;
@property (weak, nonatomic) IBOutlet UITextField *spaClSensorTF;
@property (weak, nonatomic) IBOutlet UITextField *spaAcidGalsTF;
@property (weak, nonatomic) IBOutlet UITextField *spaClGalsTF;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaWaterLevelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *poolWaterLevelCell;

// note textView
@property (weak, nonatomic) IBOutlet UITextView *noteTV;

// service tableview cells
@property (weak, nonatomic) IBOutlet UITableViewCell *poolPhSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *poolClSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *poolAcidGalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *poolClGalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *poolBackwashCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaPhSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaClSensorCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaAcidGalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaClGalCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *spaBackwashCell;

@property (weak, nonatomic) UITextField *activeTextField;
@property (weak, nonatomic) UITextView *activeTextView;
@end

@implementation editRecordTVC

#pragma mark - view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setDelegate: self];
    [self.tableView setDataSource:self];
    
    [self initDelegates];
    [self initCellValues];
    //[self initToolBars];        // adds done/cancel button to all textFields with decimalnumber keybard
    
    // observe orientation change notification, to reload table view when device rotated
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // add gesture recognizer to the view
    //UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    //tapRecognizer.numberOfTapsRequired = 1;
    //[self.view addGestureRecognizer:tapRecognizer];
}

-(void)initDelegates
{
    self.noteTV.delegate = self;
    self.poolPhTF.delegate = self;
    self.poolClTF.delegate = self;
    self.spaPhTF.delegate = self;
    self.spaClTF.delegate = self;
    self.commonTF.delegate = self;
    if (self.precord.service) {
        self.poolPhSensorTF.delegate = self;
        self.poolClSensorTF.delegate = self;
        self.poolAcidGalsTF.delegate = self;
        self.poolClGalsTF.delegate = self;
        
        self.spaPhSensorTF.delegate = self;
        self.spaClSensorTF.delegate = self;
        self.spaAcidGalsTF.delegate = self;
        self.spaClGalsTF.delegate = self;
        
    } else {
        // hide service cells if not service
        self.poolPhSensorCell.hidden = true;
        self.poolClSensorCell.hidden = true;
        self.poolAcidGalCell.hidden = true;
        self.poolClGalCell.hidden = true;
        self.poolBackwashCell.hidden = true;
        
        self.spaPhSensorCell.hidden = true;
        self.spaClSensorCell.hidden = true;
        self.spaAcidGalCell.hidden = true;
        self.spaClGalCell.hidden = true;
        self.spaBackwashCell.hidden = true;
    }
}

-(void)initCellValues
{
    self.date.text = [NSString stringWithFormat:@"Date: %@", self.precord.date];
    self.time.text = [NSString stringWithFormat:@"Time: %@", self.precord.time];
    
    // initialize textfields
    self.poolPhTF.text = [self updateValue:self.precord.poolPh];
    self.poolClTF.text = [self updateValue:self.precord.poolCl];
    self.spaPhTF.text = [self updateValue:self.precord.spaPh];
    self.spaClTF.text = [self updateValue:self.precord.spaCl];
    //
    self.noteTV.text = [self updateValue:self.precord.note];
    self.precord.spaWaterLevel = TRUE;
    self.precord.poolWaterLevel = TRUE;
    
    // initialize checkmarks for water level
    if (self.precord.poolWaterLevel) {
        self.poolWaterLevelCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.poolWaterLevelCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (self.precord.spaWaterLevel) {
        self.spaWaterLevelCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.spaWaterLevelCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.precord.service) {
        self.poolPhSensorTF.text = [self updateValue:self.precord.poolSensorPh];
        self.poolClSensorTF.text = [self updateValue:self.precord.poolSensorCl];
        self.poolAcidGalsTF.text = [self updateValue:self.precord.poolGalAcid];
        self.poolClGalsTF.text = [self updateValue:self.precord.poolGalCl];
        
        self.spaPhSensorTF.text = [self updateValue:self.precord.spaSensorPh];
        self.spaClSensorTF.text = [self updateValue:self.precord.spaSensorCl];
        self.spaAcidGalsTF.text = [self updateValue:self.precord.spaGalAcid];
        self.spaClGalsTF.text = [self updateValue:self.precord.spaGalCl];
        
        if (self.precord.poolfilterBackwash) {
            self.poolBackwashCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.poolBackwashCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (self.precord.spafilterBackwash) {
            self.spaBackwashCell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.spaBackwashCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

-(NSString *)updateValue: (NSString *)poolRecVal
{
    NSString *value = @"";
    if (![poolRecVal isEqualToString:@" "]) {
        value = poolRecVal;
    }
    return value;
}

- (void)allResignFirstResponder
{
    [self.poolClTF resignFirstResponder];
    [self.poolPhTF resignFirstResponder];
    [self.spaClTF resignFirstResponder];
    [self.spaPhTF resignFirstResponder];
    if (self.precord.service) {
        [self.poolPhSensorTF resignFirstResponder];
        [self.poolClSensorTF resignFirstResponder];
        [self.poolAcidGalsTF resignFirstResponder];
        [self.poolClGalsTF resignFirstResponder];
        
        [self.spaPhSensorTF resignFirstResponder];
        [self.spaClSensorTF resignFirstResponder];
        [self.spaAcidGalsTF resignFirstResponder];
        [self.spaClGalsTF resignFirstResponder];
    }
    [self.noteTV resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
// sec1=date, sec2/3=pool/spa, sec4 notes/button
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 1;   // default sections 0, 3 have 1 row
    if (section == 1 || section == 2) {
        if (self.precord.service) {
            rows = 8;
        } else {
            rows = 3;
        }
    } else if (section == 3) {
        rows = 2;
    }
    return rows;
}

#pragma mark - textfield delegate method

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    self.precord.updated = true;
    switch (textField.tag) {
        case 0:
            self.precord.poolPh = textField.text;
            break;
        case 1:
            self.precord.poolCl = textField.text;
            break;
        case 2:
            self.precord.poolSensorPh = textField.text;
            break;
        case 3:
            self.precord.poolSensorCl = textField.text;
            break;
        case 4:
            self.precord.poolGalAcid = textField.text;
            break;
        case 5:
            self.precord.poolGalCl = textField.text;
            break;
        case 6:
            self.precord.spaPh = textField.text;
            break;
        case 7:
            self.precord.spaCl = textField.text;
            break;
        case 8:
            self.precord.spaSensorPh = textField.text;
            break;
        case 9:
            self.precord.spaSensorCl = textField.text;
            break;
        case 10:
            self.precord.spaGalAcid = textField.text;
            break;
        case 11:
            self.precord.spaGalCl = textField.text;
            break;
            
        default:
            self.precord.updated = false;
            break;
    }

    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.backgroundColor = [UIColor greenColor];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    textView.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.activeTextView = textView;
    self.precord.note = textView.text;
    self.precord.updated = true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if (textView.text.length + text.length > 140){
        if (location != NSNotFound){
            [textView resignFirstResponder];
        }
        return NO;
    }
    else if (location != NSNotFound){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.precord.updated = true;
    if(indexPath.row == 2) {
        if(indexPath.section == 2) {
            self.precord.poolWaterLevel = !self.precord.poolWaterLevel;
            if(self.precord.poolWaterLevel) {
                self.poolWaterLevelCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                self.poolWaterLevelCell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {  // section 2 is spa
            self.precord.spaWaterLevel = !self.precord.spaWaterLevel;
            if(self.precord.spaWaterLevel) {
                self.spaWaterLevelCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                self.spaWaterLevelCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    if (indexPath.row == 6) {
        if (indexPath.section == 1) {
            self.precord.poolfilterBackwash = !self.precord.poolfilterBackwash;
            if (self.precord.poolfilterBackwash) {
                self.poolBackwashCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                self.poolBackwashCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        if (indexPath.section == 2) {
            self.precord.spafilterBackwash = !self.precord.spafilterBackwash;
            if (self.precord.spafilterBackwash) {
                self.spaBackwashCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                self.spaBackwashCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    [self.tableView reloadData];
}



#pragma mark - textfield delegate method

- (void)backgroundTapped:(UITapGestureRecognizer*)recognizer {
    [self allResignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void) orientationChanged:(NSNotification *)note
{
    [self.tableView reloadData];
}

- (IBAction)EnterRecord:(UIButton *)sender {
    // check to make sure no values are being left in the text fields
    self.precord.poolPh = self.poolPhTF.text;
    self.precord.poolCl = self.poolClTF.text;
    self.precord.spaPh = self.spaPhTF.text;
    self.precord.spaCl = self.spaClTF.text;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // check if water level was checked, if not send alert and exit
//    if(!self.precord.poolWaterLevel || !self.precord.spaWaterLevel) {
//        [Alert showAlert:@"Check the water level!"
//                 message:@"The pool or spa water level was not checked.  Check the water level, and if it is ok, put a checkmark on the record!"
//          viewController:self];
//    } else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}


@end
