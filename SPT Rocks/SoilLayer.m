//
//  SoilLayer.m
//  SPT Rocks
//
//  Created by Haluk Isik on 08/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SoilLayer.h"
#import "Measurements.h"

@interface SoilLayer()
@property (nonatomic, strong) NSDictionary *hammerEfficiencies;
@property (nonatomic, strong) Measurements *measurement;
@end

@implementation SoilLayer

@synthesize hammers = _hammers;

#pragma mark - Initializations

static const NSUInteger NUMBER_OF_OUTPUT_SECTIONS = 7;

- (Measurements *)measurement
{
    if (!_measurement) {
        _measurement = [[Measurements alloc] init];
    }
    return _measurement;
}

- (NSArray *)symbols
{
    if (!_symbols) {
        _symbols = @[@"CL", @"CL-ML", @"ML", @"OL", @"CH", @"MH", @"OH",
                     @"GW", @"GP", @"GW-GM", @"GW-GC", @"GP-GM", @"GP-GC", @"GM", @"GC", @"GC-GM",
                     @"SW", @"SP", @"SW-SM", @"SW-SC", @"SP-SM", @"SP-SC", @"SM", @"SC", @"SC-SM"];
    }
    return _symbols;
}

- (NSArray *)hammers
{
    if (!_hammers) {
        _hammers = @[@"Argentina (Donut - Cathead)",
                     @"Brazil (Pin weight - Hand dropped)",
                     @"China (Automatic - Trip)",
                     @"China (Donut - Hand dropped)",
                     @"China (Donut - Cathead)",
                     @"Columbia (Donut - Cathead)",
                     @"Japan (Donut - Tombi trigger)",
                     @"Japan (Donut - Two turns on cathead)",
                     @"UK (Automatic - Trip)",
                     @"USA (Safety - Two turns on cathead)",
                     @"USA (Donut - Two turns on cathead)",
                     @"Venezuela (Donut - Cathead)"];
    }
    return _hammers;
}

- (NSDictionary *)hammerEfficiencies
{
    if (!_hammerEfficiencies)
        _hammerEfficiencies = @{@"Argentina (Donut - Cathead)" : @0.45,
                                @"Brazil (Pin weight - Hand dropped)" : @0.72,
                                @"China (Automatic - Trip)" : @0.60,
                                @"China (Donut - Hand dropped)" : @0.55,
                                @"China (Donut - Cathead)" : @0.50,
                                @"Columbia (Donut - Cathead)" : @0.50,
                                @"Japan (Donut - Tombi trigger)" : @0.80,
                                @"Japan (Donut - Two turns on cathead)" : @0.65,
                                @"UK (Automatic - Trip)" : @0.73,
                                @"USA (Safety - Two turns on cathead)" : @0.57,
                                @"USA (Donut - Two turns on cathead)" : @0.45,
                                @"Venezuela (Donut - Cathead)" : @0.43} ;
    return _hammerEfficiencies;
}

- (NSMutableArray *)calculations
{
    if (!_calculations) {
        _calculations = [[NSMutableArray alloc] init];
        for (int i=0; i<=NUMBER_OF_OUTPUT_SECTIONS-1; i++) {
            _calculations[i] = [[NSMutableArray alloc] init];
        }
    }
    return _calculations;
}

#pragma mark - Definitions and constants

typedef NS_ENUM(NSInteger, SPTRocksStyle) {
    SPTformulaQu,
    SPTformulaSu,
    SPTformulaVs,
    SPTformulaG0,
    SPTformulaEs,
    SPTformulaRelativeCompaction
};

//#define SECTION_EFFECTIVE_STRESS 1
static const CGFloat gravity                = 9.80665;
static const CGFloat atmosphericPressure    = 101.325;

//static const NSUInteger decimalPlaces       = 2;

#pragma mark - Perform SPT

-(NSArray *)performSPT:(NSMutableArray *)inputs usingMeasurement:(NSInteger)measurement
{
    NSLog(@"inside SoilLayer - performSPT");
    
    // Multipliers for conversion from metric/imperial into metric
    CGFloat distanceMultiplier = [self.measurement.multipliers[distance][measurement] floatValue];
    CGFloat smallDistanceMultiplier = [self.measurement.multipliers[distanceSmall][measurement] floatValue];
    CGFloat specificWeightMultiplier = [self.measurement.multipliers[specificWeight][measurement] floatValue];
    
    // Multipliers for conversion from metric into metric/imperial
    CGFloat stressMultiplier = [self.measurement.multipliers[stress][measurement] floatValue];
    CGFloat largeStressMultiplier = [self.measurement.multipliers[stressLarge][measurement] floatValue];
    CGFloat velocityMultiplier = [self.measurement.multipliers[velocity][measurement] floatValue];
    
    // Get the inputs
    CGFloat GWT             = [inputs[2][0] floatValue]*distanceMultiplier;
    CGFloat layerHeight     = [inputs[2][1] floatValue]*distanceMultiplier;
    CGFloat rodLength       = [inputs[2][2] floatValue]*distanceMultiplier;
    CGFloat boringDiameter  = [inputs[2][3] floatValue]*smallDistanceMultiplier;
    CGFloat hammerEffect    = [self.hammerEfficiencies[inputs[2][4]] floatValue];
    NSString *soilSymbol    = inputs[2][6];
    CGFloat plasticityIndex = [inputs[2][8] floatValue];

    NSLog(@"got the GWT, layerHeight, rodLength, boringDiameter values");
    NSLog(@"%f # %f # %f # %f", GWT, layerHeight, rodLength, boringDiameter);
    
    
    // We need to have a designated array for the stress variable in order to be able to perform iteration on it
    NSMutableArray *stresses = [[NSMutableArray alloc] init];
    
    for(NSUInteger i=0, count=[inputs[0] count]; i<count; i++) {
        
        // Calculate stresses
        CGFloat stress = [(NSString *)inputs[1][i] floatValue] * layerHeight * specificWeightMultiplier;
        stress = i ? stress + [stresses[i-1] floatValue] : stress;
        [stresses addObject:@(stress)];
    
        // Calculate effective stresses
        CGFloat stressEffective = stress;
        if (layerHeight * (i+1) - GWT > 0) {
            stressEffective = stress - (layerHeight * (i+1) - GWT) * gravity;
        }
        
        // Calculate the cE coefficients
        CGFloat cE = hammerEffect;
        
        // Calculate the cB from boring diameter
        CGFloat cB;
        if (boringDiameter>65 && boringDiameter<115)
            cB = 1.0;
        else if (boringDiameter == 150)
            cB = 1.05;
        else if (boringDiameter == 200)
            cB = 1.15;
        else
            cB = 1.0;
        
        // Calculate the cR from rod length
        CGFloat cR;
        if (rodLength<3)
            cR = 1.0;
        else if (rodLength>=3 && rodLength<4)
            cR = 0.75;
        else if (rodLength>=4 && rodLength<6)
            cR = 0.85;
        else if (rodLength>=6 && rodLength<9)
            cR = 0.95;
        else if (rodLength>=9 && rodLength<30)
            cR = 1.0;
        else
            cR = 1.2;

        // Calculate the cN coefficients
        CGFloat cN;
        if (stress) {
            if (stress > 100)
                cN = (100 / sqrt(stress));
            else
                cN = 1;
        }

        // Get the sptN coefficients from input
        CGFloat sptN = [inputs[0][i] floatValue];

        NSLog(@"sptN = %f, cE = %f, cB = %f, cR = %f", sptN, cE, cB, cR);
        
        // Calculate the n60 coefficients
        CGFloat n60 = sptN * cE * cB * cR;

        // Calculate relative compaction
        CGFloat relativeCompaction = [self correlateTheParameter:SPTformulaRelativeCompaction
                                                            With:sptN
                                                             And:n60
                                                             And:plasticityIndex
                                                             And:stressEffective
                                                             And:soilSymbol];
        // Calculate qu
        CGFloat qu = [self correlateTheParameter:SPTformulaQu
                                            With:sptN
                                             And:n60
                                             And:plasticityIndex
                                             And:stressEffective
                                             And:soilSymbol];
        // Calculate su: Undrained shear stregth
        CGFloat su = [self correlateTheParameter:SPTformulaSu
                                            With:sptN
                                             And:n60
                                             And:plasticityIndex
                                             And:stressEffective
                                             And:soilSymbol];
        // Calculate vs
        CGFloat vs = [self correlateTheParameter:SPTformulaVs
                                            With:sptN
                                             And:n60
                                             And:plasticityIndex
                                             And:stressEffective
                                             And:soilSymbol];
        
        // Calculate Es
        CGFloat Es = [self correlateTheParameter:SPTformulaEs
                                            With:sptN
                                             And:n60
                                             And:plasticityIndex
                                             And:stressEffective
                                             And:soilSymbol];
       // Calculate G0
        CGFloat G0 = [self correlateTheParameter:SPTformulaG0
                                            With:sptN
                                             And:n60
                                             And:plasticityIndex
                                             And:stressEffective
                                             And:soilSymbol];

        
        // Convert the calculations into chosen units
        stressEffective *= stressMultiplier;
        qu *= stressMultiplier;
        su *= stressMultiplier;
        vs *= velocityMultiplier;
        Es *= largeStressMultiplier;
        G0 *= largeStressMultiplier;
        
        // Store the outputs in an array which is our interface variable
        [self.calculations[0] addObject:stressEffective<0 ? @"N/A": [@(stressEffective) stringValue]];
        [self.calculations[1] addObject:relativeCompaction<0 ? @"N/A": [@(relativeCompaction) stringValue]];
        [self.calculations[2] addObject:qu<0 ? @"N/A": [@(qu) stringValue]];
        [self.calculations[3] addObject:su<0 ? @"N/A": [@(su) stringValue]];
        [self.calculations[4] addObject:vs<0 ? @"N/A": [@(vs) stringValue]];
        [self.calculations[5] addObject:Es<0 ? @"N/A": [@(Es) stringValue]];
        [self.calculations[6] addObject:G0<0 ? @"N/A": [@(G0) stringValue]];

        NSLog(@"effective stress: %f", stressEffective);
        NSLog(@"relative compaction: %f", relativeCompaction);
        NSLog(@"qu: %f", qu);
        NSLog(@"su: %f", su);
        NSLog(@"vs: %f", vs);
        NSLog(@"Es: %f", Es);
        NSLog(@"G0: %f", G0);
    }
    
    NSLog(@"spt done, calculations: %@", self.calculations);

    
    return self.calculations;
    
/*    return @[@[@"27", @"54", @"81", @"108", @"135", @"147,3"],
             @[@"28", @"35", @"32", @"34", @"53", @"59"],
             @[@"150", @"250", @"200", @"225", @"600", @"700"],
             @[@"39", @"65", @"52", @"58", @"156", @"195"],
             @[@"2058", @"2928", @"3039", @"3412", @"4980", @"5481"],
             @[@"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A"],
             @[@"8079", @"13546", @"15402", @"18261", @"27278", @"29774"]];
*/
}

- (CGFloat)correlateTheParameter:(SPTRocksStyle)theParameter
                            With:(CGFloat)sptN
                             And:(CGFloat)n60
                             And:(CGFloat)plasticityIndex
                             And:(CGFloat)stressEffective
                             And:(NSString *)soilSymbol
{

    NSString *selectedKey = [NSString stringWithFormat:@"%i", (int)theParameter];
    NSUInteger whoseFormula = [self.selectedFormulas[selectedKey] intValue];
    
    switch (theParameter) {
        case SPTformulaRelativeCompaction:
            NSLog(@"Calculating relative compaction, n60 = %f", n60);
            return 25 * pow(atmosphericPressure, -0.12)*pow(n60, 0.46);
            break;
        case SPTformulaQu:
            NSLog(@"Calculating qu, whose formula = %li", (unsigned long)whoseFormula);

            switch (whoseFormula) {
                case 0: // Sanglerat (1972) and Tomlinson (1986)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"]) {
                        if (plasticityIndex>=3 && plasticityIndex<15)
                            return sptN * 25;
                        else if (plasticityIndex>=15 && plasticityIndex<30)
                            return sptN * 15;
                        else if (plasticityIndex>=30)
                            return sptN * 7.5;
                        else
                            return -1;
                    }
                    else
                        return -1;
                    break;
                case 1: // Sowers (1979)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"])
                        return sptN * 25;
                    else if ([soilSymbol isEqualToString:@"CL-ML"])
                        return sptN * 20;
                    else
                        return -1;
                    break;
                case 2: // Nixon (1979)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"])
                        return sptN * 24;
                    else
                        return -1;
                    break;
                case 3: // Kulhawy and Mayne (1990)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"])
                        return pow(sptN,0.72) * 58;
                    else
                        return -1;
                    break;
                    
                default:
                    break;
            }
            break;

        case SPTformulaSu:
            NSLog(@"Calculating su");
            switch (whoseFormula) {
                case 0: // Stroud (1974)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"]) {
                        NSLog(@"Calculating su, plasitcity index = %f", plasticityIndex);
                        if (plasticityIndex<20)
                            return sptN * 6.5;
                        else if (plasticityIndex>=20 && plasticityIndex<30)
                            return sptN * 4.5;
                        else if (plasticityIndex>=30)
                            return sptN * 4.2;
                        else
                            return -1;
                    }
                    else
                        return -1;
                    break;
                case 1: // Sowers (1979)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"]) {
                        NSLog(@"Calculating su, plasitcity index = %f", plasticityIndex);
                        if (plasticityIndex>=3 && plasticityIndex<15)
                            return sptN * 3.75;
                        else if (plasticityIndex>=15 && plasticityIndex<30)
                            return sptN * 7.5;
                        else if (plasticityIndex>=30)
                            return sptN * 12.5;
                        else
                            return -1;
                    }
                    else
                        return -1;
                    break;
                case 2: // Sivrikaya and Toğrol (2002)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"]) {
                        NSLog(@"Calculating su, plasitcity index = %f", plasticityIndex);
                        if (plasticityIndex>=3 && plasticityIndex<15)
                            return n60 * 4.93;
                        else if (plasticityIndex>=15 && plasticityIndex<30)
                            return n60 * 6.18;
                        else if (plasticityIndex>=30)
                            return n60 * 6.82;
                        else
                            return -1;
                    }
                    else
                        return -1;
                    break;
                default:
                    break;
            }

            break;
        case SPTformulaVs:
            switch (whoseFormula) {
                case 0: // İyisan (1996)
                    if ([soilSymbol isEqualToString:@"CL"])
                        return 47.3 * pow(sptN, 0.324) * (10 * pow(stressEffective, 0.27));
                    else if ([soilSymbol isEqualToString:@"SM"])
                        return 54.0 * pow(sptN, 0.332) * (10 * pow(stressEffective, 0.221));
                    else if ([[soilSymbol substringToIndex:1] isEqualToString:@"G"])
                        return (205.7 * pow(sptN, 0.074)) * (10 * pow(stressEffective, 0.177));
                    else
                        return 51.5 * pow(sptN, 0.516);
                    break;
                case 1: // Okamoto et al. (1989)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"S"] || [[soilSymbol substringToIndex:1] isEqualToString:@"P"])
                        return 125 * pow(sptN, 0.3);
                    else
                        return -1;
                    break;
                case 2: // Imai and Tonouchi (1989)
                    return 97 * pow(sptN, 0.314);
                case 3: // Imai (1977)
                    if ([[soilSymbol substringToIndex:1] isEqualToString:@"C"])
                        return 114 * pow(sptN, 0.29);
                    else if ([[soilSymbol substringToIndex:1] isEqualToString:@"S"])
                        return 97 * pow(sptN, 0.32);
                    else
                        return -1;
                    break;
                case 4: // Imai et al. (1976)
                    return 89.8 * pow(sptN, 0.341);
                case 5: // Imai and Yoshimura (1970)
                    return 76 * pow(sptN, 0.33);
                default:
                    break;
            }

            break;
        case SPTformulaEs:
            if ([[soilSymbol substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"SM"])
                return 300 * (n60 + 15);
            else if ([[soilSymbol substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"SC"])
                return 320 * (n60 + 15);
            else if ([[soilSymbol substringToIndex:1] isEqualToString:@"G"] ||
                [soilSymbol length]>2 ? ([[soilSymbol substringToIndex:1] isEqualToString:@"C"] &&
                                         [[soilSymbol substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"G"]) : 0) {
                    if (n60<=15)
                        return 600 * (n60 + 6);
                    else
                        return 600 * (n60 + 6) + 2000;
                }
            else
                return -1;
            break;
        case SPTformulaG0:
            switch (whoseFormula) {
                case 0: // Seed et al. (1986)
                    return 20000 * pow(n60, 1/3) * 0.0479 * sqrt(stressEffective);
                    
                case 1: // Imai and Yokota (1982)
                    return -1;
                    
                case 2: // Imai and Tonouchi (1982)
                    return 14400 * pow(sptN, 0.68);
                    
                case 3: // NAVFAC (1982)
                    return 12000 * pow(n60, 0.8);
                    
                default:
                    break;
            }
            
        default:
            break;
    }
    return -1;
}



@end
