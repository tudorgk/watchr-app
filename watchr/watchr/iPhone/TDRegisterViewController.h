//
//  TDLoginViewController.h
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDWelcomeNavigationDelegate.h"

@interface TDRegisterViewController : UIViewController<UITextFieldDelegate,NSURLConnectionDataDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	NSString * _username;
	NSString * _password;
	NSString * _email;
	NSString * _confirmPassword;
	NSInteger _country;
	NSInteger _gender;
	
	UIImage * _profileImage;
	
	int _responseStatusCode;
}
@property (weak, nonatomic) IBOutlet UIScrollView *registerScrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (assign,nonatomic) id<TDWelcomeNavigationDelegate> delegate;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *registerFormTextFields;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSelector;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)registerButtonPressed:(id)sender;
-(IBAction)profileImageViewTapped:(id)sender;

@end
