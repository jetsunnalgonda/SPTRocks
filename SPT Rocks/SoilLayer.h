//
//  SoilLayer.h
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoilLayer : NSObject
@property (nonatomic, strong) NSArray *symbols, *hammers;

@property (nonatomic, strong) NSMutableArray *calculations;
@property (nonatomic, strong) NSDictionary *selectedFormulas;

-(NSArray *)performSPT:(NSMutableArray *)inputs usingMeasurement:(NSInteger)measurement;

@end
