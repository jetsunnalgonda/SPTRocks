//
//  SoilSample.m
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SoilSample.h"

@implementation SoilSample

- (NSMutableArray *) layers {
    if (!_layers)
        _layers = [[NSMutableArray alloc] init];
    return _layers;
}

//@synthesize layer, layerHeight, gwt, hammer;

- (void) addLayer: (SoilLayer *) newLayer {
    [self.layers addObject: newLayer];
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        //SoilLayer *layer = [[SoilLayer alloc] init];
        //layer.cE = 1;
        self.layerHeight = 1.5;
    }
    
    return self;
}

@end
