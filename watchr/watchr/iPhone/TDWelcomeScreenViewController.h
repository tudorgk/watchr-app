//
//  TDWelcomeScreenViewController.h
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDRegisterViewController.h"
#import "TDLoginViewController.h"
#import "FBShimmeringView.h"
#import "TDWelcomeNavigationDelegate.h"

typedef enum ScreenVisible : NSInteger ScreenVisible;
enum ScreenVisible : NSInteger {
	ScreenVisibleNone,
	ScreenVisibleLogin,
	ScreenVisibleRegister
};

@interface TDWelcomeScreenViewController : UIViewController<UIScrollViewDelegate,TDWelcomeNavigationDelegate>{
	TDLoginViewController * _loginViewController;
	TDRegisterViewController * _registerViewController;
	ScreenVisible _visible;
}

@property (weak, nonatomic) IBOutlet UILabel *watchrTitle;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIScrollView *introScrollView;
@property (weak, nonatomic) IBOutlet UIView *welcomeView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView2;
- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)registerButtonPressed:(id)sender;

@end
