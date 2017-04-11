//
//  SPTResultsViewController.h
//  SPT Rocks
//
//  Created by Haluk Isik on 22/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTResultsVC_PageOne.h"
#import "SPTResultsVC_PageTwo.h"

@interface SPTResultsViewController : UIViewController
@property (strong, nonatomic) NSArray *pageTitles;

@property (nonatomic, strong) NSMutableArray *inputs;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *graphTitles;

@end
