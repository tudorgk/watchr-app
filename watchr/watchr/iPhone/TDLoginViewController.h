//
//  TDRegisterViewController.h
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDWelcomeNavigationDelegate.h"

@interface TDLoginViewController : UIViewController<UITextFieldDelegate>{
	NSString * _username;
	NSString * _password;
}
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *loginFormTextFields;
@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;
@property (assign,nonatomic) id<TDWelcomeNavigationDelegate> delegate;
- (IBAction)loginButtonPressed:(id)sender;

- (IBAction)backButtonPressed:(id)sender;

@end
