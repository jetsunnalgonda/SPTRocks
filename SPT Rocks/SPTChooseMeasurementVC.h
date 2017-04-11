//
//  SPTChooseMeasurementVC.h
//  SPT Rocks
//
//  Created by Haluk Isik on 20/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPTChooseMeasurementVC : UITableViewController
@property (nonatomic) NSInteger chosenMeasurementSystem;
@property (nonatomic, strong) NSArray *measurementSystems;
@end
