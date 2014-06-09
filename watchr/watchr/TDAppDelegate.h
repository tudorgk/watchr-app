//
//  TDAppDelegate.h
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
@interface TDAppDelegate : UIResponder <UIApplicationDelegate>{
	UINavigationController * _welcomeScreen;
	ECSlidingViewController * _rootViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) ECSlidingViewController *rootViewController;
- (NSURL *)applicationDocumentsDirectory;

@end
