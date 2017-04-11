//
//  Measurements.h
//  SPT Rocks
//
//  Created by Haluk Isik on 20/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Measurements : NSObject

@property (nonatomic, strong) NSDictionary *multipliers, *labels;

extern NSString *const distance;
extern NSString *const distanceSmall;
extern NSString *const stress;
extern NSString *const stressLarge;
extern NSString *const specificWeight;
extern NSString *const velocity;


@end
