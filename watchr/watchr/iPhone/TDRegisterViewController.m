//
//  TDLoginViewController.m
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDRegisterViewController.h"

@interface TDRegisterViewController ()
-(void) configureView;
-(void) genderSelected;
@end

@implementation TDRegisterViewController

-(id) init{
	self = [super init];
	if (self) {
		_country = 40; //TODO: Only for testing
		_gender = 1;
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) awakeFromNib{
	_country = 40; //TODO: Only for testing
	_gender = 1;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
	
	//add gesture recognizer ot profile photo image view
	UITapGestureRecognizer *_tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewTapped:)];
	[_profilePhotoImageView addGestureRecognizer:_tapper];
	
	//photo corner radius
	_profilePhotoImageView.layer.cornerRadius = 5.0f;
	_profilePhotoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
	_profilePhotoImageView.layer.borderWidth = 1.0f;
	_profilePhotoImageView.layer.masksToBounds = YES;
}


- (void)viewDidAppear:(BOOL)animated{
	[self subscribeToKeyboardEvents:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self subscribeToKeyboardEvents:NO];
}


- (void) keyboardDidShow:(NSNotification *)nsNotification {
	
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
    CGRect newFrame = [self.registerScrollView frame];
	
    CGFloat kHeight = kbSize.height;
	
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
	
    newFrame.size.height -= kHeight;
	
    [self.registerScrollView setFrame:newFrame];
	
}

- (void) keyboardWillHide:(NSNotification *)nsNotification {
	
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [self.registerScrollView frame];
	
    CGFloat kHeight = kbSize.height;
	
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
	
    newFrame.size.height += kHeight;
	
    // save the content offset before the frame change
    CGPoint contentOffsetBefore = self.registerScrollView.contentOffset;
	
    [self.registerScrollView setHidden:YES];
	
    // set the new frame
    [self.registerScrollView setFrame:newFrame];
	
    // get the content offset after the frame change
    CGPoint contentOffsetAfter =  self.registerScrollView.contentOffset;
	
    // content offset initial state
    [self.registerScrollView setContentOffset:contentOffsetBefore];
	
    [self.registerScrollView setHidden:NO];
	
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.registerScrollView setContentOffset:contentOffsetAfter];
                     }
                     completion:^(BOOL finished){
                         // do nothing for the time being...
                     }
     ];
	
}

-(void) configureView{
	
	for (UITextField * textField in self.registerFormTextFields){
		UIColor *color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.33];
		textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.attributedPlaceholder.string attributes:@{NSForegroundColorAttributeName: color}];
	}
	
	//set the register scroll contentsize
	[self.registerScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
	
	//set delegates
	for (UITextField *textField in self.registerFormTextFields) {
		[textField setDelegate:self];
	}
	
	//register the segmented control
	[self.genderSelector addTarget:self
						 action:@selector(genderSelected)
			   forControlEvents:UIControlEventValueChanged];
	
}

- (void)subscribeToKeyboardEvents:(BOOL)subscribe{
	
    if(subscribe){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Methods

-(void) genderSelected{
	if (self.genderSelector.selectedSegmentIndex == 0) {
		_gender = 1;
	}else{
		_gender = 2;
	}
}

- (IBAction)backButtonPressed:(id)sender {
	[self.delegate userPressedBackButton:sender];
}

- (IBAction)registerButtonPressed:(id)sender {

	for (UITextField *textField in self.registerFormTextFields) {
		if ([textField.text isEqualToString:@""]) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Fields empty" message:@"Please input the required fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			[alert show];
		return;
		}
	
	}

	//validate the passwords first
	if (![_password isEqualToString:_confirmPassword]) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Passwords do not match" message:@"Please verify your passwords" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[alert show];
		return;
	}
	
	
	
	NSString *post = [NSString stringWithFormat:@"&username=%@&email=%@&password=%@&country=%d&gender=%d",_username,_email,_password,_country,_gender];
	
	NSLog(@"%@", post);
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",TDAPIBaseURL, TDRegisterFromURL]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:[NSString stringWithFormat:@"%d",post.length] forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
	
	if(conn)
	{
		NSLog(@"Connection Successful");
	}
	else
	{
		NSLog(@"Connection could not be made");
	}
}

#pragma mark - UITextFieldDelegate methods

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	
	NSString *inputText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	if (textField == self.emailTextField) {
		_email = inputText;
	}else if (textField == self.usernameTextField){
		_username = inputText;
	}else if (textField == self.passwordTextField){
		_password = inputText;
	}else if (textField == self.confirmPasswordTextField){
		_confirmPassword = inputText;
	}
	
	return YES;
}

#pragma	mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	_responseStatusCode = [httpResponse statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data{
	NSLog(@"success = %@" , [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	
	NSError * error = [[NSError alloc] init];
	
	id JSONObject = [NSJSONSerialization
					 JSONObjectWithData:data
					 options:NSJSONReadingMutableContainers
					 error:&error];
	
	NSLog(@"%@",JSONObject);
	
	if (_responseStatusCode !=400) {
		//everything is ok. user created. attempt login
		[[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"watchrAPI" username:_username password:_password];
	}else{
		//display the errors
		NSMutableString * responseString = [[NSMutableString alloc] init];
		for (NSString * errorMessage in [JSONObject objectForKey:@"error"]) {
			
			NSLog(@"error message =%@", errorMessage);
			[responseString appendFormat:@"%@ ",errorMessage];

		}
		
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Registration Error" message:responseString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[alert show];
	}
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"error = %@", [error description]);
}

-(IBAction)profileImageViewTapped:(id)sender{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
															  message:@"Device has no camera"
															 delegate:nil
													cancelButtonTitle:@"OK"
													otherButtonTitles: nil];
        
        [myAlertView show];
		return;
    }
	
	UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing Photo", nil];
	[actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	
	
	
	switch (buttonIndex) {
		case 0:
		{
			//Take Photo
			[self takePhoto:nil];
		}
			break;
		case 1:
		{
			//Choose existing
			[self selectPhoto:nil];
		}
			break;
			
		default:
		{
			//Cancel
		}
			break;
	}
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}


- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
	
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
	_profileImage = chosenImage;
    self.profilePhotoImageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
   	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
    [picker dismissViewControllerAnimated:YES completion:NULL];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
	
}
@end
