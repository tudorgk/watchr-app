//
//  TDWelcomeScreenViewController.m
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDWelcomeScreenViewController.h"
#import "TDWatchrAPIManager.h"

@interface TDWelcomeScreenViewController()
-(void) configureView;
-(void) initOtherViews;
-(void) setUpOAuthAccount;
@end

@implementation TDWelcomeScreenViewController

#pragma mark -
#pragma mark Singleton
static TDWelcomeScreenViewController* sharedWelcomeScreen = nil;
+(TDWelcomeScreenViewController*) sharedWelcomeScreen {
    @synchronized(self) {
        if(sharedWelcomeScreen == nil)
            sharedWelcomeScreen = [[UIStoryboard storyboardWithName:@"IntroStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
    }
    return sharedWelcomeScreen;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_visible = ScreenVisibleNone;
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initOtherViews];
	[self configureView];
	[self setUpOAuthAccount];
	
	//check if the user is logged in
	if([[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"watchrAPI"] count] == 0){
			
		//if there are no accounts (this means the user isn't logged in) display the user login screen
	}else{
		//remove the welcome screen
		[self dismissViewControllerAnimated:YES completion:nil];

	}
	
    // Do any additional setup after loading the view.
}

-(void) initOtherViews{
	_loginViewController = [[UIStoryboard storyboardWithName:@"IntroStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewController"];
	_loginViewController.delegate=self;
	
	_registerViewController = [[UIStoryboard storyboardWithName:@"IntroStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"registerViewController"];
	_registerViewController.delegate = self;
	
}

-(void) configureView{
	
	//set the content size for introScrollView
	[self.introScrollView setContentSize:CGSizeMake(2*self.view.bounds.size.width, self.view.bounds.size.height)];
		
	[_loginViewController.view setFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
	[_registerViewController.view setFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
	
	self.introScrollView.delegate = self;
	[self.introScrollView setShowsHorizontalScrollIndicator:NO];
	
	
	//Shimmering effect
	FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.watchrTitle.frame];
	[self.introScrollView addSubview:shimmeringView];
	
	shimmeringView.contentView = self.watchrTitle;
	
	// Start shimmering.
	shimmeringView.shimmeringSpeed = 100.0f;
	shimmeringView.shimmering = YES;
	
}

-(void)setUpOAuthAccount{
	//i think i need to move these two somewhere else
	[[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
													  object:[NXOAuth2AccountStore sharedStore]
													   queue:nil
												  usingBlock:^(NSNotification *aNotification){
													  //everything a ok
													  NXOAuth2Account * account = [[aNotification userInfo] objectForKey:NXOAuth2AccountStoreNewAccountUserInfoKey];
													  
													  if (account) {
														  NSLog(@"success = %@", account.identifier);
														  
														  //save the account identifier to NSUserDefaults
														  [[NSUserDefaults standardUserDefaults] setObject:account.identifier forKey:TDWatchrAPIAccountIdentifier];
														  [[NSUserDefaults standardUserDefaults] synchronize];
														  //we now know that the login was successful.
														  //get the logged in user's information and create a notification for observers
														  [NXOAuth2Request performMethod:@"GET"
																			  onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/users/me"]]
																		 usingParameters:nil
																			 withAccount:[[NXOAuth2AccountStore sharedStore] accountWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:TDWatchrAPIAccountIdentifier] ]
																	 sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
																		 NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
																		 
																	 }
																		 responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
																			 NSString * responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
																			 NSLog(@"responseData = %@", responseString );
																			 NSLog(@"response = %@", [response description]);
																			 NSLog(@"error = %@", [error userInfo]);
																			 
																			 //if error
																			 if (error) {
																				 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[error.userInfo objectForKey:@"NSLocalizedDescription"] message:@"Cannot get the logged in user's information." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
																				 [alert show];
																			 }else{
																				 
																				 NSError * JSONParsingError = nil;
																				 id JSONObject = [NSJSONSerialization
																								  JSONObjectWithData:responseData
																								  options:NSJSONReadingAllowFragments
																								  error:&JSONParsingError];
																				 
																				 if (JSONParsingError) {
																					 NSLog(@"JSON parsing error");
																				 }else{
																					 //save the loggin info to nsuserdefaults
																					 [[NSUserDefaults standardUserDefaults] setObject:responseData forKey:TDWatchrLoggedInUserInformationKey];
																					 [[NSUserDefaults standardUserDefaults] synchronize];
																					 
																					 //post notification
																					 [[NSNotificationCenter defaultCenter] postNotificationName: TDWatchrUserDidLogInNotification object:responseData userInfo:nil];
																					 
																				 }
																				 
																				 
																			 }
																			 
																		 }];
														  
														  
														  //we need to get the categories for the events and the events with default settings
														  
														  //TODO: Testing. Need to perform a first-time setup here. Get countries, profile statuses etc.
														  TDFirstRunManager * firstRunner = [TDFirstRunManager sharedManager];
														  [firstRunner runFirstTimeSetUp];
													  }
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
													  object:[NXOAuth2AccountStore sharedStore]
													   queue:nil
												  usingBlock:^(NSNotification *aNotification){
													  NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
													  //error upon request for access

													  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[error.userInfo objectForKey:@"NSLocalizedDescription"] message:@"There was an error logging in. Please verify that you've inputed your username and password correctly" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
													  [alert show];
												  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

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

- (IBAction)loginButtonPressed:(id)sender {
	//set the frames for the other screens
	[self.introScrollView addSubview:_loginViewController.view];
	[UIView animateWithDuration:0.5f animations:^ {
		[self.introScrollView setContentOffset:CGPointMake(self.view.bounds.size.width,0) animated:NO];
		[self.backgroundImageView setAlpha:0];
		[self.backgroundImageView2 setAlpha:1];
	}];
	_visible=ScreenVisibleLogin;

}

- (IBAction)registerButtonPressed:(id)sender {
	
	[self.introScrollView addSubview:_registerViewController.view];
	[UIView animateWithDuration:0.5f animations:^ {
		[self.introScrollView setContentOffset:CGPointMake(self.view.bounds.size.width,0) animated:NO];
		[self.backgroundImageView setAlpha:0];
		[self.backgroundImageView2 setAlpha:1];

	}];
	_visible = ScreenVisibleRegister;
	
	
}

#pragma mark -
#pragma mark TDRegisterViewControllerDelegate

-(void) userPressedBackButton:(id)sender{
	[UIView animateWithDuration:0.5f animations:^ {
		[self.introScrollView setContentOffset:CGPointMake(0,0) animated:NO];
		[self.backgroundImageView setAlpha:1];
		[self.backgroundImageView2 setAlpha:0];
	} completion:^(BOOL finished){
		if (_visible == ScreenVisibleLogin) {
			[_loginViewController.view removeFromSuperview];
		}else if (_visible == ScreenVisibleRegister){
			[_registerViewController.view removeFromSuperview];
		}
		
		_visible = ScreenVisibleNone;
	}];
}

#pragma mark - Present/Dismiss
-(void) presentWelcomeScreen:(id)sender animated:(BOOL) animated{
	UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:sender forKey:@"sender"];
    [[NSNotificationCenter defaultCenter] postNotificationName: TDWelcomeScreenPresented object:nil userInfo:userInfo];
	
	[rootVC presentViewController:self animated:animated completion:nil];
}

-(void) dismissWelcomeScreen:(id)sender animated:(BOOL) animated{
	UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:sender forKey:@"sender"];
    [[NSNotificationCenter defaultCenter] postNotificationName: TDWelcomeScreenDismissed object:nil userInfo:userInfo];
	
	[rootVC dismissViewControllerAnimated:animated completion:nil];
}


@end
