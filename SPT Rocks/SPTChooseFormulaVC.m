//
//  SPTChooseFormulaVC.m
//  SPT Rocks
//
//  Created by Haluk Isik on 11/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTChooseFormulaVC.h"

@interface SPTChooseFormulaVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSUInteger whoseFormula;
@property (nonatomic, strong) NSArray *currentFormulaDetails, *formulas, *formulaEffectiveDetails;
@property (nonatomic, strong) NSMutableDictionary *selectedFormulas;
@end

@implementation SPTChooseFormulaVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *formulaDetails = [settings objectForKey:@"formula details"];
    self.formulas = [settings objectForKey:@"formula names"];
    self.selectedFormulas = [[settings objectForKey:@"selected formulas"] mutableCopy];
    NSString *selectedKey = [NSString stringWithFormat:@"%li", (unsigned long)self.formulaToChoose];
    self.whoseFormula = [self.selectedFormulas[selectedKey] intValue];
    
    NSArray *formulaEffectiveArray = [settings objectForKey:@"formula effective details"];
    NSLog(@"got formula effective details array in SPTChooseFormulaVC: %@", formulaEffectiveArray);
    self.formulaEffectiveDetails = formulaEffectiveArray[self.formulaToChoose];
    
    NSLog(@"formula to choose: %li", (unsigned long)self.formulaToChoose);
    NSLog(@"whose formula: %li", (unsigned long)self.whoseFormula);
    NSLog(@"formula details: %@", formulaDetails);
    NSLog(@"formula effective details array: %@", formulaEffectiveArray);
    self.currentFormulaDetails = (NSArray *)formulaDetails[self.formulaToChoose];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"selected formulas: %@", self.selectedFormulas);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.formulas[self.formulaToChoose];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentFormulaDetails count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Formula Detail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row == self.whoseFormula) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    cell.textLabel.text = self.currentFormulaDetails[indexPath.row];
    cell.detailTextLabel.text = self.formulaEffectiveDetails[indexPath.row];
    NSLog(@"self.formulaEffectiveDetails = %@", self.formulaEffectiveDetails);
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.whoseFormula = indexPath.row;
    [self.tableView reloadData];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [self.selectedFormulas setValue:[NSString stringWithFormat:@"%li", (unsigned long)self.whoseFormula]
                             forKey:[NSString stringWithFormat:@"%li", (unsigned long)self.formulaToChoose]];

    [settings setObject:self.selectedFormulas forKey:@"selected formulas"];
    [settings synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
