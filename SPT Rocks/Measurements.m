//
//  Measurements.m
//  SPT Rocks
//
//  Created by Haluk Isik on 20/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "Measurements.h"

@implementation Measurements

#pragma mark - Unit definitions

NSString *const distance = @"distance";
NSString *const distanceSmall = @"distanceSmall";
NSString *const stress = @"stress";
NSString *const stressLarge = @"stressLarge";
NSString *const specificWeight = @"specificWeight";
NSString *const velocity = @"velocity";

#pragma mark -
                                // I didn't separate inputs and outputs
- (NSDictionary *)multipliers   // Calculations will be in metric system, so we need our inputs in metric units
{
    if (!_multipliers) { // input multipliers (from metric/imperial to metric
        _multipliers = @{distance: @[@1, @0.3048], // multipliers for metric, imperial (US) (, and imperial (UK) )
                         distanceSmall: @[@1, @25.4],
                         specificWeight: @[@1, @0.1648],
                         // These are output multipliers ( from metric to metric/imperial)
                         stress: @[@1, @0.145],
                         stressLarge: @[@1, @0.145],
                         velocity: @[@1, @3.28084]};
    }
    return _multipliers;
}

- (NSDictionary *)labels
{
    if (!_labels) {
        _labels = @{distance: @[@"m", @"ft"], // labels for metric, imperial (US) (, and imperial (UK) )
                    distanceSmall: @[@"mm", @"in."],
                    stress: @[@"kPa", @"psi"],
                    stressLarge: @[@"GPa", @"ksi"],
                    specificWeight: @[@"kN/m³", @"lb/ft³"],
                    velocity: @[@"m/s", @"ft/s"]};
    }
    return _labels;
}



@end
