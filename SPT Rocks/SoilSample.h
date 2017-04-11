//
//  SoilSample.h
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoilLayer.h"

@interface SoilSample : NSObject

@property (strong, nonatomic) NSMutableArray *layers; // of SoilLayer

@property (nonatomic) NSUInteger hammer;
@property (nonatomic) CGFloat layerHeight;
@property (nonatomic) CGFloat GWT;

- (void) addLayer: (SoilLayer *) newLayer;

@end

