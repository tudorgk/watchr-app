//
//  TDCoreNavigationController.m
//  watchr
//
//  Created by Tudor Dragan on 19/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDCoreNavigationController.h"
#import "MEDynamicTransition.h"
#import "METransitions.h"
#import "UIViewController+ECSlidingViewController.h"
@interface TDCoreNavigationController ()
@property (nonatomic, strong) METransitions *transitions;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
-(void) configureView;
@end

@implementation TDCoreNavigationController

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
	[self configureView];
	self.transitions.dynamicTransition.slidingViewController = self.slidingViewController;
    // Do any additional setup after loading the view.
}

-(void) configureView{
	NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
	if ([[ver objectAtIndex:0] intValue] >= 7) {
		self.navigationBar.barTintColor = [UIColor colorWithRed:0 green:174.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
		//self.navigationBar.translucent = NO;
	}else {
		self.navigationBar.tintColor = [UIColor colorWithRed:0 green:174.0f/255.0f blue:239.0f/255.0f alpha:1.0f];
	}
	
	NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
	 [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0], NSForegroundColorAttributeName, nil];
	self.navigationBar.titleTextAttributes = attributes;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	
	//set the UIDynamic Transition
	NSDictionary *transitionData = self.transitions.all[3];
    id<ECSlidingViewControllerDelegate> transition = transitionData[@"transition"];
    if (transition == (id)[NSNull null]) {
        self.slidingViewController.delegate = nil;
    } else {
        self.slidingViewController.delegate = transition;
    }
    
    NSString *transitionName = transitionData[@"name"];
    if ([transitionName isEqualToString:METransitionNameDynamic]) {
        self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGestureCustom;
        self.slidingViewController.customAnchoredGestures = @[self.dynamicTransitionPanGesture];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.view addGestureRecognizer:self.dynamicTransitionPanGesture];
    } else {
        self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
        self.slidingViewController.customAnchoredGestures = @[];
        [self.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
	
}

#pragma mark - Properties

- (METransitions *)transitions {
    if (_transitions) return _transitions;
    
    _transitions = [[METransitions alloc] init];
    
    return _transitions;
}

- (UIPanGestureRecognizer *)dynamicTransitionPanGesture {
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}

- (IBAction)menuButtonPressed:(id)sender {
	[self.slidingViewController anchorTopViewToRightAnimated:YES];
}


@end
