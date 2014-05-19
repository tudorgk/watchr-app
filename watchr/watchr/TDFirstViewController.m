//
//  TDFirstViewController.m
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDFirstViewController.h"
#import "UIViewController+ECSlidingViewController.h"
@interface TDFirstViewController ()
@property (nonatomic, strong) UIViewController *transitionsNavigationController;
@end

@implementation TDFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// topViewController is the transitions navigation controller at this point.
    // It is initially set as a User Defined Runtime Attributes in storyboards.
    // We keep a reference to this instance so that we can go back to it without losing its state.
    self.transitionsNavigationController = (UIViewController *)self.slidingViewController.topViewController;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
