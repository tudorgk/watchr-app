//
//  TDAppDelegate.m
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDAppDelegate.h"
#import "TDDashboardViewController.h"

@interface TDAppDelegate (){
	TDDashboardViewController * _dashboardViewController;
}

@end

@implementation TDAppDelegate
@synthesize rootViewController=_rootViewController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
    // Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		//iPad
	} else {
		//iPhone
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
		_rootViewController = (ECSlidingViewController *) self.window.rootViewController;
		_dashboardViewController =[[UIStoryboard storyboardWithName:@"DashboardStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
		_rootViewController.topViewController = _dashboardViewController;
		_rootViewController.underLeftViewController = [[UIStoryboard storyboardWithName:@"SideMenuStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
	
		//TODO: Remove all accounts for testing purpouses
		NSLog(@"accounts = %@", [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"watchrAPI"]);
//		for (NXOAuth2Account * account in [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"watchrAPI"]) {
//			[[NXOAuth2AccountStore sharedStore] removeAccount:account];
//		}
		
	}
    return YES;
}

+ (void)initialize;
{
    [[NXOAuth2AccountStore sharedStore] setClientID:@"b9a498c3d5a0ba46214d1d000bad50b6"
                                             secret:@"0f9e736b70e4c093fac59ad8d567c73c"
											  scope:[NSSet setWithObject:@"basic"]
                                   authorizationURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",TDAPIBaseURL, @"/oauth/authorize"]]
                                           tokenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",TDAPIBaseURL, @"/oauth/access_token"]]
                                        redirectURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",TDAPIBaseURL, @"/"]]
                                     forAccountType:@"watchrAPI"];
		
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}
@end
