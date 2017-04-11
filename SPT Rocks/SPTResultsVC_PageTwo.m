//
//  SPTResultsVC_PageTwo.m
//  SPT Rocks
//
//  Created by Haluk Isik on 22/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTResultsVC_PageTwo.h"

@interface SPTResultsVC_PageTwo () <CPTScatterPlotDelegate, CPTPlotSpaceDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *annotation;
@property (nonatomic, strong) CPTLayerAnnotation *layerAnnotation;
@property (nonatomic, strong) NSString *annotationText;
@property (nonatomic, strong) NSMutableArray *dataLabelIndexes;
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) CPTScatterPlot *aaplPlot;
@property (nonatomic, strong) CPTXYPlotSpace *plotSpace;
@property (nonatomic, strong) CPTTextLayer *textLayer;
@end

@implementation SPTResultsVC_PageTwo

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)dataLabelIndexes
{
    if (!_dataLabelIndexes) {
        _dataLabelIndexes = [@[@"-1", @"0"] mutableCopy];
    }
    return _dataLabelIndexes;
}

- (NSArray *)results
{
    if (!_results) {
        _results = @[@"1"];
    }
    return _results;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear called");
    // Get notified of orientation changes
/*    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
*/
    //[[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification
    //                                                    object:[UIDevice currentDevice]];
    //self.hostView.frame = [self currentScreenBoundsDependOnOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification
    //                                                    object:[UIDevice currentDevice]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initPlot];
    // Take over all the gesture recognizers in our view
    // This is great code!
    
    /*
    for (UIGestureRecognizer *gR in self.view.gestureRecognizers) {
        gR.delegate = self;
    }
    */
    UISwipeGestureRecognizer *swipeRightLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [self.view addGestureRecognizer:swipeRightLeft];
    
    self.graph.defaultPlotSpace.delegate = self;
    self.aaplPlot.delegate = self;
    
    // This is crazy shit, don't do it! Causes app to crash!
    //self.hostView.hostedGraph.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.hostView = nil;
    self.graphTitles = nil;
    
    self.symbolTextAnnotation = nil;
    self.annotation = nil;
    self.layerAnnotation = nil;
    self.annotationText = nil;
    self.graph = nil;
    self.aaplPlot = nil;
    self.plotSpace = nil;
    self.textLayer = nil;
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    //self.hostView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
	self.hostView.allowPinchScaling = YES;
	[self.view addSubview:self.hostView];
    //self.view.autoresizesSubviews = YES;
    self.hostView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleHeight);
    // Width constraint, parent view width
    /*[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.hostView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:2
                                                           constant:0]];
     */
}

-(void)configureGraph {
	// 1 - Create the graph
	self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	[self.graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
	self.hostView.hostedGraph = self.graph;
	// 2 - Set graph title
	NSString *title = self.graphTitles[self.pageIndex-1];
    NSLog(@"graph titles: %@", self.graphTitles);
    NSLog(@"page index: %li", (unsigned long)self.pageIndex);
	self.graph.title = title;
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	self.graph.titleTextStyle = titleStyle;
	self.graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	self.graph.titleDisplacement = CGPointMake(0.0f, 20.0f);
	// 4 - Set padding for plot area
	[self.graph.plotAreaFrame setPaddingLeft:20.0f];
	[self.graph.plotAreaFrame setPaddingBottom:0.0f];

	// 5 - Enable user interactions for plot space
	self.plotSpace = (CPTXYPlotSpace *) self.graph.defaultPlotSpace;
	self.plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;

	// 2 - Create the plot 
	self.aaplPlot = [[CPTScatterPlot alloc] init];
	self.aaplPlot.dataSource = self;
	self.aaplPlot.identifier = @"plot 1"; //CPDTickerSymbolAAPL;
    self.aaplPlot.plotSymbolMarginForHitDetection = 5.0f;

	CPTColor *aaplColor = [CPTColor redColor];
	[graph addPlot:self.aaplPlot toPlotSpace:plotSpace];

	// 3 - Set up plot space
	[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:self.aaplPlot, nil]];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
	// 4 - Create styles and symbols
	CPTMutableLineStyle *aaplLineStyle = [self.aaplPlot.dataLineStyle mutableCopy];
	aaplLineStyle.lineWidth = 2.5;
	aaplLineStyle.lineColor = aaplColor;
	self.aaplPlot.dataLineStyle = aaplLineStyle;
	CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	aaplSymbolLineStyle.lineColor = aaplColor;
	CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
	aaplSymbol.lineStyle = aaplSymbolLineStyle;
	aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
	self.aaplPlot.plotSymbol = aaplSymbol;

    // Put an area gradient under the plot above
    CPTColor *areaColor = [CPTColor colorWithComponentRed:0.3
                                                    green:1.0
                                                     blue:0.3
                                                    alpha:0.3];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor
                                                            endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    self.aaplPlot.areaFill = areaGradientFill;
    self.aaplPlot.areaBaseValue = CPTDecimalFromString(@"0.00");

    // Annotation
    self.textLayer = [[CPTTextLayer alloc] init];
    self.symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.plotSpace  anchorPlotPoint:@[@1, @1]];
    self.layerAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:graph];

    //[self.hostView.layer addSublayer:self.textLayer];

}

-(void)configureAxes {

    // Find maximum and minimum values of X axis
    NSLog(@"results = %@", self.results);
    CGFloat maxValue = 1.0f;
    for (NSString *string in self.results)
    {
        NSInteger currentValue = [string intValue];
        NSLog(@"currentValue = %li", (long)currentValue);
        if (currentValue > maxValue)
            maxValue = currentValue;
    }
    CGFloat minValue = maxValue;
    for (NSString *string in self.results)
    {
        NSInteger currentValue = [string intValue];
        NSLog(@"currentValue = %li", (long)currentValue);
        if ((currentValue < minValue) && currentValue > 1)
            minValue = currentValue;
    }
    NSInteger numberOfLayers = [self.results count] ? [self.results count] : 1;
    if (ceil(maxValue-minValue)==0) maxValue = maxValue+minValue;
    
    NSLog(@"maxValue is %li", (long)maxValue);
    NSLog(@"minValue is %li", (long)minValue);
    NSLog(@"number of layers is %li", (long)numberOfLayers);

	// 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor whiteColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [CPTColor whiteColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor whiteColor];
	axisTextStyle.fontName = @"Helvetica-Bold";
	axisTextStyle.fontSize = 11.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor whiteColor];
	tickLineStyle.lineWidth = 2.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineWidth = 0.75;
    gridLineStyle.lineColor = [[CPTColor grayColor] colorWithAlphaComponent:0.6]; // [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];
    
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 1.0f;

	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;

	// 3 - Configure x-axis
	CPTAxis *x = axisSet.xAxis;
	x.title = self.graphTitles[self.pageIndex-1];
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = -35.0f;
	x.axisLineStyle = axisLineStyle;
    x.majorGridLineStyle = gridLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
    x.labelOffset = 16.0f;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 4.0f;
    x.minorTickLength = 2.0f;
	x.tickDirection = CPTSignPositive; //CPTSignNegative;
    NSInteger minorIncrementX = ceil((maxValue-minValue)/numberOfLayers);//10;
    
    NSLog(@"max-min = %f", maxValue-minValue);
	NSInteger majorIncrementX = ceil(minorIncrementX*2.0f);
    NSLog(@"major increment X is %li", (long)majorIncrementX);
    NSLog(@"minor increment X is %li", (long)minorIncrementX);

	CGFloat xMax = maxValue; //70.0f;  // should determine dynamically based on max price
	NSMutableSet *xLabels = [NSMutableSet set];
	NSMutableSet *xMajorLocations = [NSMutableSet set];
	NSMutableSet *xMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrementX; j <= xMax; j += minorIncrementX) {
		NSUInteger mod = j % majorIncrementX;
        NSLog(@"j = %li", (long)j);
        NSLog(@"majorIncrementX = %li", (long)majorIncrementX);
        NSLog(@"minorIncrementX = %li", (long)minorIncrementX);
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:x.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -x.majorTickLength - x.labelOffset;
			if (label) {
				[xLabels addObject:label];
			}
			[xMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
			[xMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	//CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    //CGFloat dateCount = 30.0;
	//NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	//NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
	//NSInteger i = 0;
/*	for (NSString *date in [[CPDStockPriceStore sharedInstance] datesInMonth]) {
		CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
		CGFloat location = i++;
		label.tickLocation = CPTDecimalFromCGFloat(location);
		label.offset = x.majorTickLength;
		if (label) {
			[xLabels addObject:label];
			[xLocations addObject:[NSNumber numberWithFloat:location]];
		}
	}
*/
    x.axisLabels = xLabels;
    x.majorTickLocations = xMajorLocations;
	x.minorTickLocations = xMinorLocations;
    
	//x.majorTickLocations = xLocations;
	// 4 - Configure y-axis
	CPTAxis *y = axisSet.yAxis;
	y.title = @"Layer";
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -30.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 16.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
	NSInteger majorIncrement = 1;
	NSInteger minorIncrement = 1;
	CGFloat yMax = [self.results count]; // 70.0f;  // should determine dynamically based on max price
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -y.majorTickLength - y.labelOffset;
			if (label) {
				[yLabels addObject:label];
			}
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
			[yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
    
    // Set starting zoom level and maximum zoom level
    self.plotSpace.xRange = [CPTPlotRange
                             plotRangeWithLocation:CPTDecimalFromFloat(0.0f-minorIncrementX)
                             length:CPTDecimalFromUnsignedInteger(maxValue+minValue+minorIncrementX)];
    self.plotSpace.yRange = [CPTPlotRange
                             plotRangeWithLocation:CPTDecimalFromFloat(-2.0f)
                             length:CPTDecimalFromUnsignedInteger([self.results count]+3)];
    //self.plotSpace.GlobalXRange = [CPTPlotRange
    //                               plotRangeWithLocation:CPTDecimalFromFloat(minValue*5)
    //                               length:CPTDecimalFromUnsignedInteger(maxValue*5)];
    //self.plotSpace.GlobalYRange = [CPTPlotRange
    //                               plotRangeWithLocation:CPTDecimalFromFloat(-[self.results count])
    //                               length:CPTDecimalFromUnsignedInteger([self.results count])];
    
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
}

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	//return [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    return [self.results count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	//NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    //NSInteger valueCount = 50;
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
            return self.results[index];
			break;

		case CPTScatterPlotFieldY:
            //if (index < valueCount) {
                //NSLog(@"results[0][index] = %@", self.results[index]);
                return [NSNumber numberWithUnsignedInteger:index+1];
            //}
			break;
	}
	return [NSDecimalNumber zero];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ([plot.identifier isEqual:@"plot 1"])
    {
        NSLog(@"data label for plot, index = %lu", (unsigned long)index);
        NSLog(@"data label indexes 0 -> %@, 1 -> %@", self.dataLabelIndexes[0], self.dataLabelIndexes[1]);

        CPTTextLayer *selectedText = [CPTTextLayer layer];
        if (index == [self.dataLabelIndexes[1] integerValue]) {
            NSLog(@"inside if, data label indexes 0 -> %@, 1 -> %@", self.dataLabelIndexes[0], self.dataLabelIndexes[1]);
            //[self.aaplPlot addAnimation:fadeOutAnimation forKey:@"animateOpacity"];
            CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeOutAnimation.duration = 1.0f;
            fadeOutAnimation.beginTime = CACurrentMediaTime()+2.0f;
            fadeOutAnimation.removedOnCompletion = NO;
            fadeOutAnimation.fillMode = kCAFillModeForwards;
            fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0f];
            
            [selectedText addAnimation:fadeOutAnimation forKey:@"animateOpacity"];
            //[selectedText removeAllAnimations];
            
            selectedText.text = @"";
            //selectedText.text = self.annotationText; // @"test text";
            CPTMutableTextStyle *labelTextStyle = [CPTMutableTextStyle textStyle];
            labelTextStyle.fontSize = 16.0f;
            labelTextStyle.fontName = @"Helvetica-Bold";
            labelTextStyle.color = [CPTColor whiteColor];
            selectedText.textStyle = labelTextStyle;
            selectedText.text = self.annotationText;
            return selectedText;
            
        }
        else if (index == [self.dataLabelIndexes[0] integerValue]) {
            selectedText.text = @""; //test text";
            CPTMutableTextStyle *labelTextStyle = [CPTMutableTextStyle textStyle];
            labelTextStyle.fontSize = 10;
            labelTextStyle.fontName = @"Helvetica Neue";
            labelTextStyle.color = [CPTColor whiteColor];
            selectedText.textStyle = labelTextStyle;
            return selectedText;
        }
        //self.dataLabelIndexes[0] = @(index);

    }
    return nil;
}



#pragma mark - Gesture recognizer

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
      shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"gesture recognizer");
    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]
        || [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        CGPoint point = [touch locationInView:self.view];
        NSLog(@"point.x = %f", point.x);
        NSLog(@"point.y = %f", point.y);
        
        if(point.x < 100 || point.x > 924) return YES;
        
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"should be required to fail");
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gesture recognizer should begin");

    return YES;
}
- (BOOL)handleSingleTap:(UITapGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch {
    
    NSLog(@"sdfghj");
    if ([touch.view isKindOfClass:[UIControl class]]) { // <<<< EXC_BAD_ACCESS HERE
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    [self.view endEditing:YES]; // dismiss the keyboard
    return YES; // handle the touch
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        // advance page
        NSLog(@"swipe right");
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx
{
    NSLog(@"scatterplot was selected, idx: %lu", (unsigned long)idx);
    //int plotNumber = 0;
    /*
    for (int i = 0; i < [self.results count]; i++)
    {
        if ([self.results objectAtIndex:i] != [NSNull null]
            &&
            [(NSString *)plot.identifier isEqualToString:
             [NSString stringWithFormat:@"%@-%@",[[self.results objectAtIndex:i] objectAtIndex:0],[[self.results objectAtIndex:i] objectAtIndex:1]]
             ])
        {
            plotNumber = i;
            break;
        }
    }
    */
    //if (self.symbolTextAnnotation != nil)
    //{
    //    self.symbolTextAnnotation = nil;
    //}
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x = [NSNumber numberWithInt:(int)idx];
    NSNumber *y = [NSNumber numberWithInt:[self.results[idx] intValue]];
    NSLog(@"y= %@", y);
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    NSLog(@"yString= %@", yString);
    
    // (Alloc init the annotation)
    self.symbolTextAnnotation.anchorPlotPoint = anchorPoint;
    NSLog(@"anchorPoint = %@", anchorPoint);
    NSLog(@"symbolTextAnnotation = %@", self.symbolTextAnnotation);
    // = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:anchorPoint];

    
    // Now add the annotation to the plot area
    self.textLayer.text = yString;
    self.textLayer.textStyle = hitAnnotationTextStyle;
    NSLog(@"textLayer : %@", self.textLayer);
    NSLog(@"textLayer.text : %@", self.textLayer.text);
    
    
    self.symbolTextAnnotation.contentLayer = self.textLayer;
    //self.symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    //self.symbolTextAnnotation.contentAnchorPoint = CGPointMake(0.0f, 20.0f);

    //[self.graph.plotAreaFrame.plotArea addAnnotation:self.symbolTextAnnotation];
    //[self.aaplPlot addAnnotation:self.symbolTextAnnotation];
    //[self.aaplPlot.plotArea addAnnotation:self.symbolTextAnnotation];
    
    //[self.textLayer removeFromSuperlayer];
    //[self.graph.plotAreaFrame.plotArea insertSublayer:self.textLayer atIndex:0];
    
    //NSLog(@"self.symbolTextAnnotation : %@",self.symbolTextAnnotation);
    NSLog(@"anchorPoint : %@",anchorPoint);
    
    self.annotationText = yString;
    self.dataLabelIndexes[0] = self.dataLabelIndexes[1];
    self.dataLabelIndexes[1] = @(idx);
    
    //CGPoint basePoint;
    
    //basePoint = [self.aaplPlot convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:CGPointMake([self.results[idx] floatValue], idx) fromLayer:self.graph.plotAreaFrame.plotArea];
    //basePoint = [self.aaplPlot convertPoint:CGPointMake([self.results[idx] floatValue], idx) fromLayer:self.graph.plotAreaFrame.plotArea];
    //self.layerAnnotation.contentLayer = self.textLayer;
    //self.layerAnnotation.contentAnchorPoint = CGPointMake(idx, idx); //basePoint;
    //[self.graph.plotAreaFrame.plotArea addAnnotation:self.layerAnnotation];
    //[self.aaplPlot addAnnotation:self.layerAnnotation];
    
    [self.graph reloadData];

    [UIView animateWithDuration:0.45
                          delay:1.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{self.annotationText = @"0";}
                     completion:nil];
    
}
 
/*
- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"touch");
    CPTGraph *graph = self.hostView.hostedGraph;

    if (_annotation)
    {
        [graph.plotAreaFrame.plotArea removeAnnotation:_annotation];
        _annotation = nil;
    }

    CPTMutableTextStyle *annotationTextStyle = [CPTMutableTextStyle textStyle];
    annotationTextStyle.color = [CPTColor whiteColor];
    annotationTextStyle.fontSize = 16.0f;
    annotationTextStyle.fontName = @"Helvetica-Bold";

    //NSValue *value = [self.results objectAtIndex:index];

    //CGPoint point = [value CGPointValue];
    //NSString *number1 = [NSString stringWithFormat:@"%.2f", point.x];
    //NSString *number2 = [NSString stringWithFormat:@"%.2f", point.y];

    NSString *number1 = self.results[index];
    NSString *number2 = [NSString stringWithFormat:@"%i", index];
    //NSLog(@"x and y are, %.2f, %.2f", point.x, point.y);
    //NSLog(@"number1 and number2 are, %.2f, %.2f", point.x, point.y);
    
    //NSNumber *x = [NSNumber numberWithFloat:point.x];
    //NSNumber *y = [NSNumber numberWithFloat:point.y];
    
    NSNumber *x = [NSNumber numberWithInt:index];
    NSNumber *y = [NSNumber numberWithInt:[self.results[index] intValue]];
    
    NSArray *anchorPoint = [NSArray arrayWithObjects: x, y, nil];
    
    NSString *final = [number1 stringByAppendingString:number2];
    NSLog(@"final is %@",final);
    
    
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:final style:annotationTextStyle];
    _annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    _annotation.contentLayer = textLayer;
    _annotation.displacement = CGPointMake(0.0f, 0.0f);
    [graph.plotAreaFrame.plotArea addAnnotation:_annotation];
}
*/
/*
#pragma mark - CPTScatterPlot delegate method

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    //CPTXYGraph *graph = [graphs objectAtIndex:0];
    
    if (self.symbolTextAnnotation) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:self.symbolTextAnnotation];
        self.symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    //NSNumber *x = [[plotData objectAtIndex:index] valueForKey:@"x"];
    //NSNumber *y = [[plotData objectAtIndex:index] valueForKey:@"y"];
    NSNumber *x = [NSNumber numberWithFloat:index];
    NSNumber *y = [NSNumber numberWithFloat:[self.results[index] floatValue]];
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    NSLog(@"anchorPoint = %@", anchorPoint);
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    self.symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    self.symbolTextAnnotation.contentLayer = textLayer;
    self.symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [self.graph.plotAreaFrame.plotArea addAnnotation:self.symbolTextAnnotation];
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -

-(CGRect)currentScreenBoundsDependOnOrientation
{
    
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    CGFloat width = CGRectGetWidth(screenBounds)  ;
    CGFloat height = CGRectGetHeight(screenBounds) ;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds ;
}

# pragma mark - Orientation Changes



- (void) orientationChanged:(NSNotification *)note
{
    NSLog(@"orientation changed");
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            NSLog(@"portrait orientation");
            self.navigationController.navigationBarHidden = NO;
            self.hostView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"landscape orientation");
            self.navigationController.navigationBarHidden = YES;
            self.hostView.frame = CGRectMake(0, -120, self.view.frame.size.width, self.view.frame.size.height);
            self.hostView.bounds = CGRectMake(0, -120, self.view.bounds.size.width, self.view.bounds.size.height);
            
            break;
        default:
            self.navigationController.navigationBarHidden = NO;
            self.hostView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            break;
    };
}


@end
