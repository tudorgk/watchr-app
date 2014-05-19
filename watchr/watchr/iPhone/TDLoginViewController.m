//
//  TDRegisterViewController.m
//  watchr
//
//  Created by Tudor Dragan on 15/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDLoginViewController.h"

@interface TDLoginViewController ()
-(void) configureView;
@end

@implementation TDLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
    // Do any additional setup after loading the view.
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
	
    CGRect newFrame = [self.loginScrollView frame];
	
    CGFloat kHeight = kbSize.height;
	
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
	
    newFrame.size.height -= kHeight;
	
    [self.loginScrollView setFrame:newFrame];
	
}

- (void) keyboardWillHide:(NSNotification *)nsNotification {
	
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [self.loginScrollView frame];
	
    CGFloat kHeight = kbSize.height;
	
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
	
    newFrame.size.height += kHeight;
	
    // save the content offset before the frame change
    CGPoint contentOffsetBefore = self.loginScrollView.contentOffset;
	
    [self.loginScrollView setHidden:YES];
	
    // set the new frame
    [self.loginScrollView setFrame:newFrame];
	
    // get the content offset after the frame change
    CGPoint contentOffsetAfter =  self.loginScrollView.contentOffset;
	
    // content offset initial state
    [self.loginScrollView setContentOffset:contentOffsetBefore];
	
    [self.loginScrollView setHidden:NO];
	
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.loginScrollView setContentOffset:contentOffsetAfter];
                     }
                     completion:^(BOOL finished){
                         // do nothing for the time being...
                     }
     ];
	
}

-(void) configureView{
	
	for (UITextField * textField in self.loginFormTextFields){
		UIColor *color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.33];
		textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.attributedPlaceholder.string attributes:@{NSForegroundColorAttributeName: color}];
	}
	
	//set the register scroll contentsize
	[self.loginScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 280)];
	
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
}

- (IBAction)backButtonPressed:(id)sender {
	[self.delegate userPressedBackButton:sender];
}
@end
