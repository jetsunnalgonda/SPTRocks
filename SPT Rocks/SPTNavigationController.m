//
//  SPTNavigationController.m
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTNavigationController.h"

@interface SPTNavigationController ()

@end

@implementation SPTNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view's nagivation bar
    self.navigationBar.barTintColor = [UIColor colorWithRed:237/255.0 green:217/255.0 blue:135/255.0 alpha:0.8];
    //self.navigationBar.backgroundColor = [UIColor orangeColor];

}
- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(self.view.bounds.size.width, 2.0f);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
