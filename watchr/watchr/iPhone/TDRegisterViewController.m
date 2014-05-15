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
@end

@implementation TDRegisterViewController

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


- (IBAction)backButtonPressed:(id)sender {
	[self.delegate userPressedBackButton:sender];
}

- (IBAction)registerButtonPressed:(id)sender {
}
@end
