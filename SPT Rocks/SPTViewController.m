//
//  SPTViewController.m
//  SPT Rocks
//
//  Created by Haluk Isik on 07/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTViewController.h"
#import "SPTSettingsViewController.h"
#import "SPTResultsViewController.h"
#import "SPTTableViewCell.h"

@interface SPTViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) SPTSettingsViewController *settingsView;
@property (weak, nonatomic) IBOutlet UIImageView *rocksImage;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;      // we are going to have a scrollable view for our inputs
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonPerformSptHSpace;
@property (weak, nonatomic) IBOutlet UIButton *buttonPerformSpt;    // Button to perform SPT calculations and
                                                                    // bring up the modal view to display the results
@property (nonatomic, strong) UIPickerView *hammerPicker; // To add into the corresponding table cells
@property (nonatomic, strong) UIPickerView *soilPicker; // To add into the corresponding table cells
//@property (nonatomic, strong) NSMutableDictionary *shownPickersAtIndexPath; // Shown are: @1, not shown are: @0

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property(nonatomic, getter = isDatePickerShown) BOOL datePickerIsShown;

@property(nonatomic, getter = isHammerPickerShown) BOOL hammerPickerIsShown;
@property(nonatomic, getter = isSoilPickerShown) BOOL soilPickerIsShown;

//@property (nonatomic) NSInteger numberOfPickers;

@property (nonatomic, assign) id currentResponder;  // to deal with tap gestures and text fields
@property (nonatomic) CGFloat scrollHeight, sectionHeight;
@property (nonatomic) CGPoint currentScrollOffset;
@property (nonatomic, strong) UIButton *theAddButton, *theDeleteButton;

@property (nonatomic, strong) SoilSample *soil;
@property (nonatomic, strong) SoilLayer *layer;
@property (nonatomic, strong) Measurements *measurements;
@property (nonatomic, strong) NSMutableArray * layers;
@property (nonatomic, strong) NSMutableArray *sections, *rows;  // Sections and rows of our input data
@property (nonatomic, strong) NSArray *sptInputHeader, *sptInputDataText;
@property (nonatomic, strong) NSDictionary *sptInputUnits;

@property (nonatomic) NSInteger chosenMeasurementSystem;

// Default values for inputs
@property (nonatomic, strong) NSString *defaultSpecificWeight;


@end

@implementation SPTViewController

@synthesize layers = _layers;
//@synthesize measurements = _measurements;

#pragma mark - Initializations

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view
#define hammerPickerTag             50
#define soilPickerTag               60


#define kTitleKey       @"title"   // key for obtaining the data source item's title
#define kDateKey        @"date"    // key for obtaining the data source item's date value

// keep track of which rows have date cells
#define kDateStartRow   5
#define kDateEndRow     6

static NSString *kPickCellID = @"Cell above picker";     // the cells with the start or end date
static NSString *kPickerID = @"Picker"; // the cell containing the date picker
static NSString *kEmptyCell = @"Empty cell"; // the cell that we are going to put our picker views in

static NSUInteger MAXIMUM_LAYERS = 50; // Maximum number of layers that we allow the users to have

#define NUMBER_OF_SECTIONS 2
#define NUMBER_OF_ROWS_IN_SECTION_3 9

- (NSMutableArray *)sections
{
    if (!_sections) {
        _sections = [[NSMutableArray alloc] init];
        for (int i=0; i<=NUMBER_OF_SECTIONS-1; i++) {
            _sections[i] = [[NSMutableArray alloc] init];
        }
        
        _sections[2] = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_ROWS_IN_SECTION_3];

        for (int i=0; i<=NUMBER_OF_ROWS_IN_SECTION_3-1; i++) {
            [_sections[2] addObject:@""];
        }
    }
    return _sections;
}

-(NSMutableArray *)rows
{
    if (!_rows) _rows = [[NSMutableArray alloc] init];
    return _rows;
}

- (NSArray *)sptInputHeader
{
    if (!_sptInputHeader) {
        _sptInputHeader = @[@"Enter Blow Counts",
                            @"Enter specific weight of soil",
                            @"Other information"];
    }
    return _sptInputHeader;
}

- (NSArray *)sptInputDataText
{
    if (!_sptInputDataText) {
        _sptInputDataText = @[@"Ground water table",
                              @"Layer height",
                              @"Rod length",
                              @"Boring diameter",
                              @"Hammer type",
                              @"HAMMER PICKER",
                              @"Soil symbol",
                              @"SOIL PICKER",
                              @"Plasticity index"];
    }
    return _sptInputDataText;
}

- (NSDictionary *)sptInputUnits
{
    if (!_sptInputUnits) {
        _sptInputUnits = @{@"Ground water table": distance,
                           @"Layer height": distance,
                           @"Rod length": distance,
                           @"Boring diameter": distanceSmall};
    }
    return _sptInputUnits;
}
/*
- (NSDictionary *)shownPickersAtIndexPath
{
    if (!_shownPickersAtIndexPath) {
        _shownPickersAtIndexPath = [@{[NSIndexPath indexPathForRow:5 inSection:2]: @0,
                                     [NSIndexPath indexPathForRow:7 inSection:2]: @0} mutableCopy];
    }
    return _shownPickersAtIndexPath;
}
*/
- (SoilLayer *)layer
{
    if (!_layer) {
        _layer = [[SoilLayer alloc] init];
    }
    return _layer;
}

- (Measurements *)measurements
{
    if (!_measurements) {
        _measurements = [[Measurements alloc] init];
    }
    return _measurements;
}


/*
- (UIPickerView *)hammerPicker
{
    if (_hammerPicker) {
        NSLog(@"hammer picker get method");
        _hammerPicker = [[UIPickerView alloc] init]; //WithFrame:CGRectMake(0, 0, 100, 40)];
        _hammerPicker.showsSelectionIndicator = YES;
        _hammerPicker.delegate = self;
        _hammerPicker.dataSource = self;
        _hammerPicker.tag = kDatePickerTag;
    }
    return _hammerPicker;
}
*/
/*
- (UIPickerView *)soilPicker
{
    if (_soilPicker) {
        _soilPicker = [[UIPickerView alloc] init];
        _soilPicker.showsSelectionIndicator = YES;
    }
    return _soilPicker;
}
*/
-(NSMutableArray *)layers
{
    if (!_layers) _layers = [[NSMutableArray alloc] init];
    //if(self.tableView) self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+350);
    //NSLog(@"scroll height: %f", self.tableView.contentSize.height);
    return _layers;
}

- (void)setLayers:(NSMutableArray *)layers
{
    _layers = layers;
    //NSLog(@"new scroll size");
}
/*
- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, self.scrollHeight);
}
*/

- (void)setScrollHeight:(CGFloat)scrollHeight
{
    _scrollHeight = scrollHeight;
    //self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollHeight+150);
}

static CGFloat MARGIN_TOP = 95;
//static CGFloat INPUT_TEXT_HEIGHT = 40;
static CGFloat MARGIN_LEFT = 100;
static CGFloat MARGIN_LEFT_LABEL = 10;
static CGFloat INPUT_WIDTH = 150;
static CGFloat BUTTON_MARGIN = 60;
//static CGFloat LABEL_WIDTH = 80;

#pragma mark - Add and delete buttons

- (UIButton *)theAddButton
{
    if (!_theAddButton) {
        // Create a Button that adds a new input field
        _theAddButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_theAddButton addTarget:self
                   action:@selector(addNewCell)
         forControlEvents:UIControlEventTouchUpInside];
        [_theAddButton setTitle:@"" forState:UIControlStateNormal];
        [_theAddButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [self.view addSubview:_theAddButton];
        _theAddButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_MARGIN, MARGIN_TOP, 30.0, 30.0);
    }
    return _theAddButton;
}

- (UIButton *)theDeleteButton
{
    if (!_theDeleteButton) {
        // Create a Button that deletes an input field
        _theDeleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_theDeleteButton addTarget:self
                          action:@selector(deleteCell)
                forControlEvents:UIControlEventTouchUpInside];
        [_theDeleteButton setTitle:@"" forState:UIControlStateNormal];
        [_theDeleteButton setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.view addSubview:_theDeleteButton];
        _theDeleteButton.frame = CGRectMake(MARGIN_LEFT+MARGIN_LEFT_LABEL+INPUT_WIDTH, MARGIN_TOP*2, 30.0, 30.0);
    }
    return _theDeleteButton;
}
/*
- (void)addInputFields
{
    // Create Layer input label
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(MARGIN_LEFT_LABEL, MARGIN_TOP+self.scrollHeight, LABEL_WIDTH, INPUT_TEXT_HEIGHT)];
    [myLabel setBackgroundColor:[UIColor clearColor]];
    [myLabel setText:@"Layer 1"];
//    [self.scrollView addSubview:myLabel];

    // Create Layer input Text field
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP+self.scrollHeight, INPUT_WIDTH, INPUT_TEXT_HEIGHT)];
    [myTextField setBackgroundColor:[UIColor clearColor]];
    [myTextField setText:@""];
    [myTextField setBorderStyle: UITextBorderStyleRoundedRect];
//    [self.scrollView addSubview:myTextField];
    myTextField.delegate = self;
*/
    // Channge the button's location
    //self.theAddButton.frame = CGRectMake(MARGIN_LEFT+MARGIN_LEFT_LABEL+INPUT_WIDTH, MARGIN_TOP+self.scrollHeight, 30.0, 30.0);

/*    // Create a horizontal line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_LABEL, MARGIN_TOP+INPUT_TEXT_HEIGHT+self.scrollHeight+3, self.scrollView.bounds.size.width-MARGIN_LEFT_LABEL*2, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:lineView];
*/
    // Set scroll height
    //self.scrollHeight += INPUT_TEXT_HEIGHT+10;
    
//    [self.tableView reloadData];
/*
}
*/

#pragma mark - View life cycle

-(void)viewWillAppear:(BOOL)animated
{
    [self.layers addObject:@"City"];
    //[self.layers addObject:@"City2"];
    NSLog(@"self.layers count: %li", (unsigned long)[self.layers count]);

    [self.tableView registerNib:[UINib nibWithNibName:@"SPTInputCell"
                                               bundle:nil]
         forCellReuseIdentifier:@"SPTTableViewCell"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView reloadData];

    // Set delegates and data sources for hammer types and soil symbols
    self.hammerPicker.delegate = self;
    self.hammerPicker.dataSource = self;
    self.soilPicker.delegate = self;
    self.soilPicker.dataSource = self;

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //[settings synchronize];
    NSNumber *chosenMeasurementSystem = (NSNumber *)[settings objectForKey:@"chosen measurement system"];
    // Choose the measurement system
    self.chosenMeasurementSystem = [chosenMeasurementSystem integerValue];
    
    // Set some default values for inputs
    if (self.chosenMeasurementSystem == 0)
        self.defaultSpecificWeight = @"18.0";
    else
        self.defaultSpecificWeight = @"110";
    
    [super viewWillAppear:YES];
    NSLog(@"delegate set");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get notified of orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // Get and set NSUserDefaults

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *formulas = [settings objectForKey:@"formula names"];
    if (!formulas) {
        formulas = @[@"Unconfined compressive strength",
                     @"Undrained shear strength",
                     @"Shear wave velocity",
                     @"Dynamic shear modulus"];
        [settings setObject:formulas forKey:@"formula names"];
    }
    NSArray *formulaDetails = [settings objectForKey:@"formula details"];
    if (!formulaDetails) {
        formulaDetails = @[@[@"Sanglerat (1972) and Tomlinson (1986)",
                             @"Sowers (1979)",
                             @"Nixon (1982)",
                             @"Kulhawy and Mayne (1990)"],
                           @[@"Stroud (1974)",
                             @"Sowers (1979)",
                             @"Sivrikaya and Toğrol (2002)"],
                           @[@"Iyisan (1996)",
                             @"Okamoto et al. (1989)",
                             @"Imai and Tonouchi (1989)",
                             @"Imai (1977)",
                             @"Imai et al. (1976)",
                             @"Imai and Yoshimura (1970)"],
                           @[@"Seed et al. (1986)",
                             @"Imai and Yokota (1982)",
                             @"Imai and Tonouchi (1982)",
                             @"NAVFAC (1982)"]];
        [settings setObject:formulaDetails forKey:@"formula details"];
    }
    NSArray *formulaEffectiveDetails = [settings objectForKey:@"formula effective details"];
    //if (formulaEffectiveDetails) formulaEffectiveDetails = nil;
    //[settings removeObjectForKey:@"formula effective details"];
    if (!formulaEffectiveDetails) {
        formulaEffectiveDetails = @[@[@"For clays with plasticity index ≥ 3",
                                      @"For all clays of any plasticity",
                                      @"For all clays of any plasticity",
                                      @"For all clays of any plasticity"],
                                    @[@"For all clays",
                                      @"For clays with plasticity index ≥ 3",
                                      @"For clays with plasticity index ≥ 3"],
                                    @[@"For clays, silty sands or gravels",
                                      @"For sands and peats",
                                      @"For all soil types",
                                      @"For clays and sands",
                                      @"For all soil types",
                                      @"For all soil types"],
                                    @[@"For all soil types",
                                      @"For all soil types",
                                      @"For all soil types",
                                      @"For all soil types"]];
        [settings setObject:formulaEffectiveDetails forKey:@"formula effective details"];
    }
    
    NSDictionary *selectedFormulas = [settings dictionaryForKey:@"selected formulas"];
    if (!selectedFormulas) {
        selectedFormulas = @{@"0": @"0",
                             @"1": @"0",
                             @"2": @"0",
                             @"3": @"0"};
        [settings setObject:selectedFormulas forKey:@"selected formulas"];
    }
    NSNumber *chosenMeasurementSystem = (NSNumber *)[settings objectForKey:@"chosen measurement system"];
    if (!chosenMeasurementSystem) {
        chosenMeasurementSystem = @0;
        [settings setObject:chosenMeasurementSystem forKey:@"chosen measurement system"];
    }
    
    NSLog(@"chosen measurement system: %@", chosenMeasurementSystem);
    
    // Choose the measurement system
    self.chosenMeasurementSystem = [chosenMeasurementSystem integerValue];

    // Set background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"soil-2"]];
/*    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soil"]];
    [tempImageView setFrame:self.view.frame];
    
    [self.view addSubview: tempImageView];
    [self.view sendSubviewToBack:tempImageView];
*/
	// Table view style
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 80.0, 0.0);
    //self.tableView.allowsSelection = YES;
    
    // Add the settings button and wire its view
    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [settingsView addTarget:self action:@selector(showSettingsView:) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    [self.navigationItem setLeftBarButtonItem:settingsButton];
    
    // Add a tap gesture recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
    singleTap.delegate = self;

    /*
    // Create the "Input values" label
    UILabel *inputValuesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MARGIN_LEFT_LABEL, self.view.bounds.size.width, INPUT_TEXT_HEIGHT)];
    //inputValuesLabel.numberOfLines = 0; //will wrap text in new line
    //[inputValuesLabel sizeToFit];
    //inputValuesLabel.minimumScaleFactor = 1.0;
    //inputValuesLabel.adjustsFontSizeToFitWidth = YES;
    inputValuesLabel.textAlignment = NSTextAlignmentCenter;
    [inputValuesLabel setBackgroundColor:[UIColor clearColor]];
    inputValuesLabel.text = @"Enter SPT values";
    [self.tableView addSubview:inputValuesLabel];
     */
    
    // Change the location of the buttons
    self.theAddButton.frame = CGRectMake(MARGIN_LEFT+MARGIN_LEFT_LABEL+INPUT_WIDTH, MARGIN_TOP, 30.0, 30.0);
    self.theDeleteButton.frame = CGRectMake(MARGIN_LEFT+MARGIN_LEFT_LABEL+INPUT_WIDTH, MARGIN_TOP*1.4, 30.0, 30.0);
    //[self addInputFields];
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"other cell"];
    
    self.hammerPicker = [[UIPickerView alloc] init]; //WithFrame:CGRectMake(0, 0, 100, 40)];
    self.hammerPicker.showsSelectionIndicator = YES;
    self.hammerPicker.delegate = self;
    self.hammerPicker.dataSource = self;
    self.hammerPicker.tag = hammerPickerTag;
    self.hammerPicker.hidden = YES;
    self.hammerPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.soilPicker = [[UIPickerView alloc] init]; //WithFrame:CGRectMake(0, 0, 100, 40)];
    self.soilPicker.showsSelectionIndicator = YES;
    self.soilPicker.delegate = self;
    self.soilPicker.dataSource = self;
    self.soilPicker.tag = soilPickerTag;
    self.soilPicker.hidden = YES;
    self.soilPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Default values for pickers
    self.sections[2][4] = self.layer.hammers[0];
    self.sections[2][6] = self.layer.symbols[0];

}
#pragma mark - Table view data source

- (void)addNewCell
{
    if ([self.sections[0] count] < MAXIMUM_LAYERS) {
    
        [self.tableView beginUpdates];
        
        // Add a row object (for the first two sections) with a default value which will be used for our model
        [self.layers addObject:@"City"];
        [self.sections[0] addObject:@""];
        [self.sections[1] addObject:[NSString stringWithFormat:@"%@", self.defaultSpecificWeight]];
        
        // Insert row for the blow count section
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.sections[0] count] - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        // Insert row for the soil specific weight section
        indexPath = [NSIndexPath indexPathForRow:([self.sections[0] count] - 1) inSection:1];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        // Scroll to the end of the row at the current section
        //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [self.tableView endUpdates];
    }
    
}

- (void)deleteCell
{
    if ([self.sections[0] count]) {

        [self.tableView beginUpdates];
        
        // Remove the row object (for the first two sections)
        [self.layers removeObjectAtIndex:[self.layers count]-1];
        [self.sections[0] removeObjectAtIndex:[self.sections[0] count] -1];
        [self.sections[1] removeObjectAtIndex:[self.sections[1] count] -1];

        // Remove row from the blow count section
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.sections[0] count] ) inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        // Remove row from the soil specific weight section
        indexPath = [NSIndexPath indexPathForRow:([self.sections[0] count] ) inSection:1];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        // Scroll to the end of the row at the current section
        //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [self.tableView endUpdates];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sptInputHeader count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return [self.sptInputHeader objectAtIndex:section];
}
/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]init]; //WithFrame:CGRectMake(0,200,300,244)];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,20)];
    tempLabel.backgroundColor=[UIColor lightGrayColor];
    tempLabel.shadowColor = [UIColor orangeColor];
    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = [UIColor blackColor]; //here you can change the text color of header.
//    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
    tempLabel.font = [UIFont systemFontOfSize:14];
//    tempLabel.text=@"Header Text";
    tempLabel.text = [self.sptInputHeader objectAtIndex:section];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2 && [self hasInlineDatePicker])
    {
        // we have a picker, so allow for it in the number of rows in this section
        NSInteger numRows = [self.sections[section] count];
        return ++numRows;
    }

    return [self.sections[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table view cell");
    NSString *cellIdentifier = @"SPTTableViewCell";
    SPTTableViewCell *cell;
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        cell = (SPTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        //SoilLayer *layer = self.layers[indexPath.row];
        //for (SPTTableViewCell *aCell in )
        cell.cellInputText.delegate = self;
        cell.cellInputText.text = self.sections[indexPath.section][indexPath.row];
        cell.cellLabel.text = [NSString stringWithFormat:@"Layer %li", (long)indexPath.row+1];
        cell.unitLabel.text = @"";
        if (indexPath.section == 1) cell.unitLabel.text = self.measurements.labels[specificWeight][self.chosenMeasurementSystem];
        NSLog(@"label: %@", self.measurements.labels[specificWeight][0]);
        
        //[cell addSubview:self.theAddButton];
        
        // Remove previous button
        //if (indexPath.row>1) {
        //    SPTTableViewCell *previousCell = (SPTTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
        //[previousCell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        //}
    }
    else {
        if (indexPath.row < 4 || indexPath.row == 8) {
            cell = (SPTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            //SoilLayer *layer = self.layers[indexPath.row];
            cell.cellInputText.delegate = self;
            cell.cellInputText.text = self.sections[indexPath.section][indexPath.row];
            cell.cellLabel.text = self.sptInputDataText[indexPath.row] ? self.sptInputDataText[indexPath.row] : @"";
            cell.unitLabel.text = self.measurements.labels[self.sptInputUnits[cell.cellLabel.text]][self.chosenMeasurementSystem];
            //cell.cellLabel.text = [NSString stringWithFormat:@"asd %li", (long)indexPath.row+1];
        }
        else {
            
            UITableViewCell *cellWithPicker;
            //if (cellWithPicker == nil) {
            //    cellWithPicker = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"other cell"];
            //}
            NSLog(@"indexPath.row = %li", (long)indexPath.row);
            if (indexPath.row == 4) {
                cellWithPicker = [tableView dequeueReusableCellWithIdentifier:kPickCellID forIndexPath:indexPath];
                cellWithPicker.textLabel.text = self.sptInputDataText[indexPath.row];
                cellWithPicker.detailTextLabel.text = self.sections[indexPath.section][indexPath.row];
                
                cellWithPicker.indentationWidth = 5;
                cellWithPicker.indentationLevel = 1;
                //[cell addSubview:self.hammerPicker];
                
                //id pickerView = cellWithPicker;
                //NSLog(@"subview: %@",pickerView = cellWithPicker.subviews[0]);
                return cellWithPicker;
            }
            else if (indexPath.row == 5) {
                //cellWithPicker = [tableView dequeueReusableCellWithIdentifier:kPickerID forIndexPath:indexPath];
                //[cell addSubview:self.soilPicker];
                //cellWithPicker.detailTextLabel.text = @"hammer picker";
                cellWithPicker = [tableView dequeueReusableCellWithIdentifier:kEmptyCell forIndexPath:indexPath];
                [cellWithPicker addSubview:self.hammerPicker];
                NSLog(@"hammer picker: %@", self.hammerPicker);
                //self.hammerPicker.delegate = self;
                //self.hammerPicker.dataSource = self;
                return cellWithPicker;
            }
            else if (indexPath.row == 6) {
                cellWithPicker = [tableView dequeueReusableCellWithIdentifier:kPickCellID forIndexPath:indexPath];
                cellWithPicker.textLabel.text = self.sptInputDataText[indexPath.row];
                //[cell addSubview:self.soilPicker];
                cellWithPicker.detailTextLabel.text = self.sections[indexPath.section][indexPath.row];
                cellWithPicker.indentationWidth = 5;
                cellWithPicker.indentationLevel = 1;
                return cellWithPicker;
            }
            else if (indexPath.row == 7) {
                //cellWithPicker = [tableView dequeueReusableCellWithIdentifier:kPickerID forIndexPath:indexPath];
                //[cell addSubview:self.soilPicker];
                //cellWithPicker.detailTextLabel.text = @"soil picker";
                cellWithPicker = [tableView dequeueReusableCellWithIdentifier:kEmptyCell forIndexPath:indexPath];
                [cellWithPicker addSubview:self.soilPicker];
                NSLog(@"soil picker: %@", self.soilPicker);
                return cellWithPicker;
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:10];
//    cell.textLabel.backgroundColor=[UIColor redColor];
//    cell.textLabel.frame = CGRectMake(10, 20, 100,22);
//    cell.detailTextLabel.frame = CGRectMake(10, 20, 200,22);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = tableView.rowHeight;
    
    if ([self isHammerPickerRowAtIndexPath:indexPath]) {
        //[self.tableView beginUpdates];
        heightForRow = (self.isHammerPickerShown) ? 180.0 : 0.0;
        //[self.tableView endUpdates];
    }
    else if ([self isSoilPickerRowAtIndexPath:indexPath]) {
        heightForRow = (self.isSoilPickerShown) ? 180.0 : 0.0;
    }
    
    return heightForRow;
}

- (void)addRemovePickerForSelectedIndexPath:(NSIndexPath *)indexPath removing: (BOOL)removing
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:2]];
    
    if (removing)
    {
        [self.sections[2] removeObjectAtIndex:[self.sections[2] count] -1];
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.sections[2] addObject:@""];
        NSLog(@"insert rows at index paths");
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:2]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    NSLog(@"updates have begun");
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
        NSLog(@"self.datePickerIndexPath.row = %li /n indexPath.row = %li", (long)self.datePickerIndexPath.row, (long)indexPath.row);
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:2]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:2];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:2];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    //[self updateDatePicker];
}



#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select row at index path. row = %li", (long)indexPath.row);
/*    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kPickCellID)
    {
        NSLog(@"reuse identifier matches");
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        //[self addRemovePickerForSelectedIndexPath:indexPath removing:NO];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
*/
    if ([self isHammerLabelRowAtIndexPath:indexPath])
    {
        self.HammerPickerIsShown = ! self.isHammerPickerShown;
        self.hammerPicker.hidden = !self.hammerPicker.hidden;
        
        //NSIndexPath *pickerPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        //self.shownPickersAtIndexPath[pickerPath] = @(![self.shownPickersAtIndexPath[pickerPath] integerValue]);
        //NSLog(@"shown pickers : %@", self.shownPickersAtIndexPath);
        //NSLog(@"---- %@", @(![self.shownPickersAtIndexPath[pickerPath] integerValue]));
        [tableView beginUpdates];
        [tableView endUpdates];
        if (self.isHammerPickerShown) {
            [self scrollViewToTextField:self.hammerPicker];
            self.currentResponder = self.hammerPicker;
        }
    }
    else if ([self isSoilLabelRowAtIndexPath:indexPath]) {
        self.SoilPickerIsShown = ! self.isSoilPickerShown;
        self.soilPicker.hidden = !self.soilPicker.hidden;
        [tableView beginUpdates];
        [tableView endUpdates];
        if (self.isSoilPickerShown) {
            [self scrollViewToTextField:self.soilPicker];
            self.currentResponder = self.soilPicker;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)isDateLabelRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return ([self.datePickerIndexPath compare:indexPath] == NSOrderedSame);
    return (indexPath.section == 2) && (indexPath.row == 4 || indexPath.row == 6);
}
- (BOOL)isHammerLabelRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return ([self.datePickerIndexPath compare:indexPath] == NSOrderedSame);
    return (indexPath.section == 2) && (indexPath.row == 4);
}

- (BOOL)isSoilLabelRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return ([self.datePickerIndexPath compare:indexPath] == NSOrderedSame);
    return (indexPath.section == 2) && (indexPath.row == 6);
}
- (BOOL)isDatePickerRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return ([self.datePickerIndexPath compare:indexPath] == NSOrderedSame);
    return (indexPath.section == 2) && (indexPath.row == 5 || indexPath.row == 7);
    //NSIndexPath *pickerPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    //BOOL isItAPicker = self.shownPickersAtIndexPath[indexPath] != nil;
    //NSLog(@"is it a picker? : %i", isItAPicker);
    //NSLog(@"what is it? : %@, indexPath : %@", self.shownPickersAtIndexPath[indexPath], indexPath);
    //return self.shownPickersAtIndexPath[indexPath] != nil;
}
- (BOOL)isHammerPickerRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 2) && (indexPath.row == 5);

}
- (BOOL)isSoilPickerRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 2) && ( indexPath.row == 7);

}
/*
- (BOOL)isDatePickerShownAtIndexPath:(NSIndexPath *)indexPath
{
    //return ([self.datePickerIndexPath compare:indexPath] == NSOrderedSame);
    return [self.shownPickersAtIndexPath[indexPath] integerValue];
}
*/
#pragma mark - Text Field Related

// Resign text field on return
-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    //[self.scrollView setContentOffset:CGPointMake(0,-65) animated:YES];
    [self.tableView setContentOffset:self.currentScrollOffset animated:YES];
    [textField resignFirstResponder];
    return YES;
}

// Dismiss text field on tap of the view
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //NSLog(@"scroll height: %f", self.scrollView.bounds.size.height);
    //self.currentScrollOffset = self.tableView.contentOffset;
    //[self.tableView setContentOffset:CGPointMake(0,textField.center.y+50) animated:YES];
    [self scrollViewToTextField:textField];
    self.currentResponder = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Get the cell in which the textfield is embedded
    // This is great code !!
    id textFieldSuper = textField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        //NSLog(@"got the textfield cell");
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    //NSLog(@"index path section of the text being edited: %li", indexPath.section);
    
    // Store the value to our model
    self.sections[indexPath.section][indexPath.row] = textField.text;
}

- (void)scrollViewToTextField:(id)textField
{
    // Set the current _scrollOffset, so we can return the user after editing
    self.currentScrollOffset = self.tableView.contentOffset;
    
    // Get a pointer to the text field's cell
    UITableViewCell *theTextFieldCell = (UITableViewCell *)[textField superview];
    
    // Get the text fields location
    CGPoint point = [theTextFieldCell convertPoint:theTextFieldCell.frame.origin toView:self.tableView];
    
    // Scroll to cell
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        // code for landscape orientation
        [self.tableView setContentOffset:CGPointMake(0, point.y - 110) animated: YES];
    }
    else {
        [self.tableView setContentOffset:CGPointMake(0, point.y - 210) animated: YES];
    }
    
    // Add some padding at the bottom to 'trick' the scrollView.
//    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, point.y - 160, 0)];
}

- (void)resignOnTap:(id)iSender
{
    //[self.scrollView setContentOffset:CGPointMake(0,-65) animated:YES];
    [self.tableView setContentOffset:self.currentScrollOffset animated:YES];
    [self.currentResponder resignFirstResponder];
}

/*
- (IBAction)singleTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"Single tap");
    [self.currentResponder resignFirstResponder];
}
*/
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    Class UIPickerTableView = NSClassFromString(@"UIPickerTableView");
    Class UIPickerTableViewWrapperCell = NSClassFromString(@"UIPickerTableViewWrapperCell");
    
    if ([touch.view isKindOfClass:[UIControl class]]
        ||[touch.view isKindOfClass:[UILabel class]]
        ||[touch.view isKindOfClass:[UIPickerTableView class]]
        ||[touch.view isKindOfClass:[UIPickerTableViewWrapperCell class]]) {
        // we touched a button, slider, or other UIControl
        NSLog(@"ignore the touch");
        return NO; // ignore the touch
    }
    NSLog(@"handle the touch, the class is: %@", touch.view.class);
    
    return YES; // handle the touch
}

#pragma mark - Picker view

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"picker view is: %@", pickerView);
    NSLog(@"self.layer.symbols.count, %li",(unsigned long)self.layer.symbols.count);
    if (pickerView.tag == hammerPickerTag) {
        return self.layer.hammers.count;
    }
    else return self.layer.symbols.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"title for row: %@", self.layer.symbols[row]);
    if (pickerView.tag == hammerPickerTag) {
        return self.layer.hammers[row];
    }
    else return self.layer.symbols[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"pickerview did select - row : %li", (long)row);
    if (pickerView.tag == hammerPickerTag) {
        self.sections[2][4] = self.layer.hammers[row];
    }
    else self.sections[2][6] = self.layer.symbols[row];
    [self.tableView reloadData];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *retval = (id)view;
    if (!retval) {
        retval = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                           [pickerView rowSizeForComponent:component].width,
                                                           [pickerView rowSizeForComponent:component].height)];
    }
    retval.opaque = NO;
    retval.backgroundColor = [UIColor clearColor];
    retval.font = [UIFont boldSystemFontOfSize:16];
    retval.textAlignment = NSTextAlignmentCenter;
    retval.text = [self pickerView:pickerView titleForRow:row forComponent:component];
/*
    if (component == 0) {
        retval.textAlignment = NSTextAlignmentRight;
        //retval.text = [NSString stringWithFormat:@"%ld ", (long)row];
        retval.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    } else {
        retval.textAlignment = NSTextAlignmentLeft;
        //retval.text = [NSString stringWithFormat:@" .%ld", (long)row];
        retval.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    }
 */
    return retval;
}

/*! Returns the major version of iOS, (i.e. for iOS 6.1.3 it returns 6)
 */
NSUInteger DeviceSystemMajorVersion()
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:2]];
    UIPickerView *checkDatePicker = (UIPickerView *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
/*
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIPickerView *targetedDatePicker = (UIPickerView *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
            NSDictionary *itemData = self.sptInputDataText[self.datePickerIndexPath.row - 1];
            [targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:NO];
        }
    }
}
*/

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    NSLog(@"has inline date picker?");
    NSLog(@"self.datePickerIndexPath = %@", self.datePickerIndexPath);
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if (indexPath.section == 2) {
        if ((indexPath.row == kDateStartRow) ||
            (indexPath.row == kDateEndRow || ([self hasInlineDatePicker] && (indexPath.row == kDateEndRow + 1))))
        {
            hasDate = YES;
        }
    }
    
    return hasDate;
}
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    NSLog(@"width for component method");
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        return self.view.frame.size.width;
    }

    return self.view.frame.size.width;
}
*/
#pragma mark - SPT Results and Settings

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show SPT Results"]) {
        /*
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *resultsView = [((UINavigationController *)segue.destinationViewController).viewControllers firstObject];
            UIBarButtonItem *MKbackBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(backButton:)];
            [resultsView.navigationItem setLeftBarButtonItem:MKbackBtn];
            //NSLog(@"results view class: %@", [resultsView class]);
        }
         */
        if ([segue.destinationViewController isKindOfClass:[SPTResultsViewController class]]) {
            SPTResultsViewController *resultsVC = (SPTResultsViewController *)segue.destinationViewController;
            resultsVC.inputs = self.sections;
            NSLog(@"resultsVC.inputs = %@", resultsVC.inputs);
            NSLog(@"self.sections = %@", self.sections);
        }
    }
    else if ([[segue identifier] isEqualToString:@"Show Settings"]) {
        if ([segue.destinationViewController isKindOfClass:[SPTSettingsViewController class]]) {
            //SPTSettingsViewController *settingsVC = (SPTSettingsViewController *)segue.destinationViewController;
            
        }
    }

}
/*
-(IBAction)backButton:(id)sender
{
    UIViewController* parent = [self parentViewController];
    if(parent==nil) {
        parent = [self presentingViewController];
    }
    [parent dismissViewControllerAnimated:YES completion:nil];
}
*/
# pragma mark - Settings View

- (void)showSettingsView:(id)sender
{
    [self performSegueWithIdentifier:@"Show Settings" sender:sender];
}

# pragma mark - Orientation Changes

- (void) orientationChanged:(NSNotification *)note
{
    NSLog(@"orientation changed");
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:

            /* start special animation */
            NSLog(@"portrait orientation");
            self.theAddButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_MARGIN, MARGIN_TOP, 30.0, 30.0);
            self.theDeleteButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_MARGIN, MARGIN_TOP*1.4, 30.0, 30.0);
            self.rocksImage.hidden = NO;
            self.tableViewBottomSpaceConstraint.constant = 45;
            self.buttonPerformSptHSpace.constant = 120;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"landcape orientation");

            self.theAddButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_MARGIN, MARGIN_TOP+30, 30.0, 30.0);
            self.theDeleteButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_MARGIN, MARGIN_TOP*1.4+30, 30.0, 30.0);
            self.rocksImage.hidden = YES;
            self.tableViewBottomSpaceConstraint.constant = 0;
            //self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.view.frame.size.height-self.tableViewBottomSpaceConstraint.constant);
            self.buttonPerformSptHSpace.constant = self.view.frame.size.width-90;
            NSLog(@"self.view.frame.size.height = %f", self.view.frame.size.height);
            break;
        default:
            NSLog(@"default orientation");

            self.theAddButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_MARGIN, MARGIN_TOP, 30.0, 30.0);
            self.theDeleteButton.frame = CGRectMake(self.view.frame.size.width-BUTTON_MARGIN, MARGIN_TOP*1.4, 30.0, 30.0);
            //self.rocksImage.hidden = NO;
            break;
    };
}


@end
