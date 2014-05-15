//
//  TDLoginViewController.h
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TDRegisterViewControllerDelegate <NSObject>

-(void) userPressedBackButton:(id)sender;

@end

@interface TDRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *registerScrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (assign,nonatomic) id<TDRegisterViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *registerFormTextFields;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)registerButtonPressed:(id)sender;

@end
