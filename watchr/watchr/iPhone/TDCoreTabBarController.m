//
//  TDCoreTabBarController.m
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDCoreTabBarController.h"

@interface TDCoreTabBarController (){
	UINavigationController * _introNavCntroller;
}

@end

@implementation TDCoreTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib{
	//instantiate the Intro Nav Controller
	_introNavCntroller = (UINavigationController*) [[UIStoryboard storyboardWithName:@"IntroStoryboard_iPhone" bundle:nil] instantiateInitialViewController];

	[self.view addSubview:_introNavCntroller.view];
	[self.view bringSubviewToFront:_introNavCntroller.view];
	
	//now fade out splash image
	//watchr[UIView transitionWithView:self.view duration:3.0f options:UIViewAnimationOptionTransitionNone animations:^(void){_introNavCntroller.view.alpha=0.0f;} completion:^(BOOL finished){[_introNavCntroller.view removeFromSuperview];}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"View did load");
	
	
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated{

}

-(void) viewWillAppear:(BOOL)animated{
		
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

@end
