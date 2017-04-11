//
//  SPTSettingsViewController.m
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTSettingsViewController.h"
#import "SPTChooseFormulaVC.h"
#import "SPTChooseMeasurementVC.h"

@interface SPTSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dismissButton;

@property (nonatomic, strong) NSArray *formulas, *formulaDetails;
//@property (nonatomic, strong) NSArray *whoseFormulas;
@property (nonatomic, strong) NSMutableDictionary *selectedFormulas;
@property (nonatomic, strong) SPTChooseMeasurementVC *measurement;
@property (nonatomic) NSInteger chosenMeasurementSystem;

@end

@implementation SPTSettingsViewController

- (SPTChooseMeasurementVC *)measurement
{
    if (!_measurement) {
        _measurement = [[SPTChooseMeasurementVC alloc] init];
    }
    return _measurement;
}

- (IBAction)dismissAction:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.formulas = [settings objectForKey:@"formula names"];
    self.formulaDetails = [settings objectForKey:@"formula details"];
    NSLog(@"formula names are here: %@", self.formulas);
    NSLog(@"formula details are here: %@", self.formulaDetails);
    self.selectedFormulas = [[settings objectForKey:@"selected formulas"] mutableCopy];
    //    NSString *selectedKey = [NSString stringWithFormat:@"%li", self.formulaToChoose];
    //    self.whoseFormula = [self.selectedFormulas[selectedKey] intValue];
    
    NSNumber *chosenMeasurementSystem = (NSNumber *)[settings objectForKey:@"chosen measurement system"];
    self.chosenMeasurementSystem = [chosenMeasurementSystem integerValue];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UINavigationController *NavController=[[UINavigationController alloc]initWithRootViewController:self.navigationController];
    //[self.navigationController.navigationBar setBounds:CGRectMake(10, -20, 40, 10)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.formulas count];
    else
        return 1; //[self.measurements count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Correlation formulas";
    else
        return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"Settings Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSLog(@"cell is nil");
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        NSInteger whoseFormula = [self.selectedFormulas[[NSString stringWithFormat:@"%li", (long)indexPath.row]] intValue];
        cell.textLabel.text = self.formulas[indexPath.row];
        cell.detailTextLabel.text = self.formulaDetails[indexPath.row][whoseFormula];
        
        NSLog(@"whose formula: %li", (long)whoseFormula);
        NSLog(@"self.selectedFormulas: %@", self.selectedFormulas);
        
        return cell;
    }
    else {
        static NSString *cellIdentifier = @"Settings Cell 2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        cell.textLabel.text = @"Measurement system";
        cell.detailTextLabel.text = self.measurement.measurementSystems[self.chosenMeasurementSystem];
        return cell;
    }
}

#pragma mark - Table view delegate



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqual:@"Choose a formula"]) {
                if ([segue.destinationViewController isKindOfClass:[SPTChooseFormulaVC class]]) {
                    SPTChooseFormulaVC *cfvc = (SPTChooseFormulaVC *)segue.destinationViewController;
                    cfvc.formulaToChoose = indexPath.row;
                    //cfvc.formulaToChoose = ((UITableViewCell *)sender).textLabel.text;
                }
            }
            else if ([segue.identifier isEqual:@"Choose Measurement"]) {
                if ([segue.destinationViewController isKindOfClass:[SPTChooseMeasurementVC class]]) {
                   // SPTChooseMeasurementVC *cmvc = (SPTChooseMeasurementVC *)segue.destinationViewController;
                }
            }
        }
    }
}


@end
