//
//  SPTResultsViewController.m
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTResultsVC_PageOne.h"
#import "SoilLayer.h"
#import "SPTChooseMeasurementVC.h"
#import "Measurements.h"

@interface SPTResultsVC_PageOne () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *sptOutputUnits;
@property (nonatomic, strong) SoilLayer *layer;
@property (nonatomic, strong) NSNumberFormatter *formatter;
//@property (nonatomic, strong) SPTChooseMeasurementVC *measurement;
@property (nonatomic, strong) Measurements *measurements;
@property (nonatomic) NSInteger chosenMeasurementSystem;

@end

//static const NSUInteger decimalPlaces;

@implementation SPTResultsVC_PageOne

#pragma mark - Initializations
/*
- (SPTChooseMeasurementVC *)measurement
{
    if (!_measurement) {
        _measurement = [[SPTChooseMeasurementVC alloc] init];
    }
    return _measurement;
}
*/
- (NSNumberFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSNumberFormatter alloc] init];
        [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
        [_formatter setSecondaryGroupingSize:3];
        [_formatter setMaximumFractionDigits:2];
        [_formatter setMinimumFractionDigits:0];
        [_formatter setUsesSignificantDigits: YES];
        [_formatter setMaximumSignificantDigits:4];
        [_formatter setMinimumSignificantDigits:2];
    }
    return _formatter;
}

- (SoilLayer *)layer
{
    if (!_layer) _layer = [[SoilLayer alloc] init];
    return _layer;
}

- (Measurements *)measurements
{
    if (!_measurements) {
        _measurements = [[Measurements alloc] init];
    }
    return _measurements;
}

- (NSArray *)sptOutputHeader
{
    if (!_sptOutputHeader) {
        _sptOutputHeader = @[@"Effective stress",
                             @"Relative compaction",
                             @"qu (Unconfined compressive strength)",
                             @"su (Undrained shear strength)",
                             @"vs (Shear wave velocity)",
                             @"Es (Stress-deformation modulus)",
                             @"G0 (Dynamic shear modulus)"];
    }
    return _sptOutputHeader;
}

- (NSDictionary *)sptOutputUnits
{
    if (!_sptOutputUnits) {
        _sptOutputUnits = @{@"Effective stress": stress,
                            @"qu (Unconfined compressive strength)": stress,
                            @"su (Undrained shear strength)": stress,
                            @"vs (Shear wave velocity)": velocity,
                            @"Es (Stress-deformation modulus)": stressLarge,
                            @"G0 (Dynamic shear modulus)": stressLarge};
    }
    return _sptOutputUnits;
}

-(NSArray *)results
{
    if (!_results) {
        _results = [[NSArray alloc] init];
    }
    return _results;
}

- (void)setInputs:(NSMutableArray *)inputs
{
    _inputs = inputs;
    if (self.view.window) [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.results count]; //[self.sptOutputHeader count]; //[self.results count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sptOutputHeader objectAtIndex:section]; //@"Results";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results ? [self.results[section] count] : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SPT Results Cell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //if (indexPath.section < [self.inputs count] && indexPath.row < [self.inputs[2] count])
    cell.textLabel.text = [NSString stringWithFormat:@"Layer %li", (long)indexPath.row+1];
    cell.detailTextLabel.text = self.results[indexPath.section][indexPath.row];
    
    
    // Check if the formula is not applicable
    if ([cell.detailTextLabel.text isEqualToString:@"N/A"]) {
        NSLog(@"formula not applicable - %@", cell.detailTextLabel.text);
        cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@"N/A"
                                                                              attributes:@{
                                                                                           NSForegroundColorAttributeName : [UIColor grayColor],
                                                                                           NSFontAttributeName: [UIFont italicSystemFontOfSize:14]}];
    }
    else {
        // Round off the outputs to a certain decimal place(s)
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:cell.detailTextLabel.text];
        cell.detailTextLabel.text = [self.formatter stringFromNumber:number];
        
        // Add units
        NSString *unitLabel = self.sptOutputUnits[self.sptOutputHeader[indexPath.section]];
        NSLog(@"unit label is: %@", unitLabel);
        NSString *unit = self.measurements.labels[unitLabel][self.chosenMeasurementSystem];
        NSAttributedString *attributedUnit = [[NSAttributedString alloc] initWithString:unit?unit:@""
                                                                             attributes:@{
                                                                                          NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                                                          NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:cell.detailTextLabel.text];
        
        // Concatenate results and units
        [result appendAttributedString: [[NSAttributedString alloc] initWithString:@" " ]];
        [result appendAttributedString: attributedUnit];
        cell.detailTextLabel.attributedText = result;
    }
    
    return cell;
}

#pragma mark - View Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Table view style
    //self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //[self.tableView setBackgroundColor:[UIColor clearColor]];
    //self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 80.0, 0.0);
    
    NSLog(@"spt about to be performed with these inputs: %@", self.inputs);
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.layer.selectedFormulas = [settings objectForKey:@"selected formulas"];
    NSNumber *chosenMeasurementSystem = (NSNumber *)[settings objectForKey:@"chosen measurement system"];
    self.chosenMeasurementSystem = [chosenMeasurementSystem integerValue];
    
    self.results = [self.layer performSPT:self.inputs usingMeasurement:self.chosenMeasurementSystem];
    NSLog(@"spt performed");
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.inputs = nil;
    self.sptOutputHeader = nil;
    
    self.sptOutputUnits = nil;
    self.layer = nil;
    self.formatter = nil;
    self.measurements = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Formatting strings

- (NSNumber *)numberFromString:(NSString *)string
{
    if (string.length) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        return [f numberFromString:string];
    } else {
        return nil;
    }
}

- (NSString *)stringByFormattingString:(NSString *)string toPrecision:(NSInteger)precision
{
    NSNumber *numberValue = [self numberFromString:string];
    
    if (numberValue) {
        NSString *formatString = [NSString stringWithFormat:@"%%.%ldf", (long)precision];
        return [NSString stringWithFormat:formatString, numberValue.floatValue];
    } else {
        /* return original string */
        return string;
    }
}

@end
