//
//  TDWelcomeScreenViewController.m
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDWelcomeScreenViewController.h"

@interface TDWelcomeScreenViewController ()
-(void) configureView;
-(void) initOtherViews;
@end

@implementation TDWelcomeScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initOtherViews];
	[self configureView];
    // Do any additional setup after loading the view.
}

-(void) initOtherViews{
	_loginViewController = [[UIStoryboard storyboardWithName:@"IntroStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewController"];
	
	_registerViewController = [[UIStoryboard storyboardWithName:@"IntroStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"registerViewController"];
	_registerViewController.delegate = self;
	
}

-(void) configureView{
	
	//set the content size for introScrollView
	[self.introScrollView setContentSize:CGSizeMake(2*self.view.bounds.size.width, self.view.bounds.size.height)];
		
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
	[_loginViewController.view setFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (IBAction)registerButtonPressed:(id)sender {
	
	
	[self.introScrollView addSubview:_registerViewController.view];
	[UIView animateWithDuration:0.5f animations:^ {
		[self.introScrollView setContentOffset:CGPointMake(self.view.bounds.size.width,0) animated:NO];
		[self.backgroundImageView setAlpha:0];
		[self.backgroundImageView2 setAlpha:1];

	}];
	
}

#pragma mark -
#pragma mark TDRegisterViewControllerDelegate

-(void) userPressedBackButton:(id)sender{
	[UIView animateWithDuration:0.5f animations:^ {
		[self.introScrollView setContentOffset:CGPointMake(0,0) animated:NO];
		[self.backgroundImageView setAlpha:1];
		[self.backgroundImageView2 setAlpha:0];
	} completion:^(BOOL finished){
		[_registerViewController.view removeFromSuperview];
	}];


	
}

@end
