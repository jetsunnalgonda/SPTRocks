//
//  SPTChooseMeasurementVC.m
//  SPT Rocks
//
//  Created by Haluk Isik on 20/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTChooseMeasurementVC.h"

@interface SPTChooseMeasurementVC () //<UITableViewDataSource, UITableViewDelegate>


@end

@implementation SPTChooseMeasurementVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)measurementSystems
{
    if (!_measurementSystems) {
        _measurementSystems = @[@"Metric (S.I.)",
                                @"Imperial (USA)"];
    }
    return _measurementSystems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"choose a measurement view did load");
    //[self.tableView setDelegate:self];
    //[self.tableView setDataSource:self];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSNumber *chosenMeasurementSystem = (NSNumber *)[settings objectForKey:@"chosen measurement system"];
    self.chosenMeasurementSystem = [chosenMeasurementSystem integerValue];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.measurementSystems count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Measurement Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row == self.chosenMeasurementSystem) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.textLabel.text = self.measurementSystems[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chosenMeasurementSystem = indexPath.row;
    [self.tableView reloadData];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [settings setObject:@(self.chosenMeasurementSystem) forKey:@"chosen measurement system"];
    [settings synchronize];
    
    NSNumber *chosenMeasurementSystem = (NSNumber *)[settings objectForKey:@"chosen measurement system"];
    
    NSLog(@"chosen measurement system is now: %@", chosenMeasurementSystem);
    
    [self.navigationController popViewControllerAnimated:YES];
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

@end
