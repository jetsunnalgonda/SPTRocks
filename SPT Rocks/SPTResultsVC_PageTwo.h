//
//  SPTResultsVC_PageTwo.h
//  SPT Rocks
//
//  Created by Haluk Isik on 22/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPTResultsVC_PageTwo : UIViewController <CPTPlotDataSource> //, UIGestureRecognizerDelegate>
@property NSUInteger pageIndex;
@property (nonatomic, strong) CPTGraphHostingView *hostView;

@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *graphTitles;

@end
