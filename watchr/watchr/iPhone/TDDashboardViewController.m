//
//  TDDashboardViewController.m
//  watchr
//
//  Created by Tudor Dragan on 19/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDDashboardViewController.h"

@interface TDDashboardViewController ()

@end

@implementation TDDashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

-(void)awakeFromNib{
	 self.title = @"Dashboard";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end
