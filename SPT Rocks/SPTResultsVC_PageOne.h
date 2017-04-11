//
//  SPTResultsViewController.h
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPTResultsVC_PageOne : UIViewController
@property NSUInteger pageIndex;

@property (nonatomic, strong) NSMutableArray *inputs;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSArray *sptOutputHeader;

- (NSString *)stringByFormattingString:(NSString *)string toPrecision:(NSInteger)precision;
- (NSNumber *)numberFromString:(NSString *)string;

@end
