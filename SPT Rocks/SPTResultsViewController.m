//
//  SPTResultsViewController.m
//  SPT Rocks
//
//  Created by Haluk Isik on 22/04/14.
//  Copyright (c) 2014 Haluk Isik. All rights reserved.
//

#import "SPTResultsViewController.h"

@interface SPTResultsViewController () <UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

// Page controller related
// We have 2 pages to display our results
// Page #1 displays the results in numbers in a tableView
// Page #2 displays the same results in a scatter plot graph
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) BOOL shouldHideStatusBar;

@end

@implementation SPTResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get notified of orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification
                                                        object:[UIDevice currentDevice]];

    // Create the data model
    _pageTitles = @[@"SPT Results", @"Effective stress", @"Relative compaction", @"qu", @"su", @"Es", @"vs", @"G0"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    SPTResultsVC_PageOne *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Get our data source from the first page
    self.results = startingViewController.results;
    self.graphTitles = startingViewController.sptOutputHeader;
    
    // Change the size of page view controller
    //self.pageViewController.view.frame = CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height - 80);
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.navigationController.navigationBarHidden = YES;
    }
    else {
        self.pageViewController.view.frame = CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height - 80);
        self.navigationController.navigationBarHidden = NO;
    }
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleHeight);
    
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Take over all the gesture recognizers in our view
    // This is great code!
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            //view.scrollEnabled = NO;
            //for (UIGestureRecognizer *gR in view.gestureRecognizers) {
                //gR.delegate = self;
                NSLog(@"set the delegate for a gesture recognizer");
            //}
        }
    }
    /*
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (UIScrollView *)view;
            
            UIPanGestureRecognizer* panGestureRecognizer = scrollView.panGestureRecognizer;
            [panGestureRecognizer addTarget:self action:@selector(move:)];
        }
    }

    */


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.pageTitles = nil;
    self.inputs = nil;
    self.results = nil;
    self.graphTitles = nil;
}

#pragma mark - Results Pages

- (id)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    if (index == 0) {
        NSLog(@"results view controller, index = 0");
        // Create a new view controller and pass suitable data.
        SPTResultsVC_PageOne *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsPageOne"];
        pageContentViewController.navigationItem.title = @"wdsd"; //self.pageTitles[index];
        pageContentViewController.inputs = self.inputs;
        NSLog(@"inputs: %@", self.inputs);
        pageContentViewController.pageIndex = 0;
        return pageContentViewController;
    }
    else {
        NSLog(@"results view controller, index = %lu", (unsigned long)index);
        // Create a new view controller and pass suitable data.
        SPTResultsVC_PageTwo *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsPageTwo"];
        pageContentViewController.navigationItem.title = self.pageTitles[index];
        pageContentViewController.pageIndex = index;
        pageContentViewController.results = self.results[index-1];
        pageContentViewController.graphTitles = self.graphTitles;
        pageContentViewController.view.frame = super.view.frame;
        return pageContentViewController;
    }

    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    //NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    NSUInteger index;
    
    if ([viewController isKindOfClass:[SPTResultsVC_PageOne class]]) {
        index = 0;
    }
    else if ([viewController isKindOfClass:[SPTResultsVC_PageTwo class]]) {
        index = ((SPTResultsVC_PageTwo *) viewController).pageIndex;
    }
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    //NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    NSUInteger index;
    
    if ([viewController isKindOfClass:[SPTResultsVC_PageOne class]]) {
        index = 0;
    }
    else if ([viewController isKindOfClass:[SPTResultsVC_PageTwo class]]) {
        index = ((SPTResultsVC_PageTwo *) viewController).pageIndex;
    }
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index == [self.pageTitles count]) {
        return nil;
    }
    index++;

    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void) move:(UIPanGestureRecognizer *)recognizer
{
    NSLog(@"gesture recognizer");

}

#pragma mark - Gesture recognizer delegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        CGPoint point = [touch locationInView:self.view];
        NSLog(@"it is a swipe gesture!, point = %@", NSStringFromCGPoint(point));

        //Examine point and return NO, if gesture should be ignored.
        if ((point.x >= self.view.frame.origin.x+50) && (point.x <= self.view.bounds.size.width-50)) {
            NSLog(@"gesture is inside the bounds, point = %@", NSStringFromCGPoint(point));
            return NO;
        }
        
    }
    return YES;
}

# pragma mark - Orientation Changes

- (void) orientationChanged:(NSNotification *)note
{
    NSLog(@"orientation changed");
    NSLog(@"orientation in results view controller");
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            NSLog(@"portrait orientation");
            self.pageViewController.view.frame = CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height - 80);
            self.navigationController.navigationBarHidden = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"landscape orientation");
            self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.navigationController.navigationBarHidden = YES;
            [self setNeedsStatusBarAppearanceUpdate];

            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"unknown orientation");
            break;
        default:
            NSLog(@"default orientation");
            //self.pageViewController.view.frame = CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height - 80);
            break;
    };
}

- (BOOL)prefersStatusBarHidden {
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        // code for landscape orientation
        self.shouldHideStatusBar = YES;
        return YES;
    }
    self.shouldHideStatusBar = NO;
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
