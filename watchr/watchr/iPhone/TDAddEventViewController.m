//
//  TDAddEventViewController.m
//  watchr
//
//  Created by Tudor Dragan on 29/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDAddEventViewController.h"

@interface TDAddEventViewController ()
-(void) configureView;
-(void) configureTableView;
-(void) userDidCancel:(id) sender;
@end

@implementation TDAddEventViewController

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
	[self configureTableView];
    // Do any additional setup after loading the view.
}

-(void) configureView{
	self.title = @"Add new event";
	
	self.navigationController.navigationBar.barTintColor = [UIColor redColor];
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								 [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0], NSForegroundColorAttributeName, nil];
	self.navigationController.navigationBar.titleTextAttributes = attributes;
	//set the dismiss Button
	
	UIButton * dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
	[dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	dismissButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
	[dismissButton addTarget:self action:@selector(userDidCancel:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem * dismissButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dismissButton];
	
	[self.navigationItem setLeftBarButtonItem:dismissButtonItem];
}

-(void) configureTableView{
	[self.addEventTableView setDataSource:self];
	[self.addEventTableView setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setSelected:YES];
	
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 60;
}


#pragma mark - UITableViewDataSource Methods



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
	
    return view;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"addCell"];
	
	
	return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 10;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	return 2;
}

#pragma mark - Navigation Methods

-(void) userDidCancel:(id)sender{
	[self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

@end
