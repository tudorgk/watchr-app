//
//  TDSideMenuViewController.m
//  watchr
//
//  Created by Tudor Dragan on 23/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDSideMenuViewController.h"
#import "TDProfileHeaderView.h"
#import <QuartzCore/QuartzCore.h>
@interface TDSideMenuViewController (){
	int * _selectedRow;
}
-(void) configureView;
-(void) configureTableView;
@end

@implementation TDSideMenuViewController

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
	[self configureView];
	[self configureTableView];

}

-(void) configureView{
	self.sideMenuTableView.delegate = self;
	self.sideMenuTableView.dataSource = self;
	
	self.edgesForExtendedLayout=UIRectEdgeNone;
	self.extendedLayoutIncludesOpaqueBars=NO;
	self.automaticallyAdjustsScrollViewInsets=NO;
	
	

}

-(void) configureTableView{
	
	[self.sideMenuTableView registerNib:[UINib nibWithNibName:@"TDProfileHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"profileHeader"];
	
	_menuEntries = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuItems" ofType:@"plist"]];

	//set the first row to selected
	_selectedRow = (int*) calloc(_menuEntries.count, sizeof(int));
	_selectedRow[0]= 1;
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
	
	for (int i=0; i<_menuEntries.count; i++) {
		_selectedRow[i]=0;
	}
	_selectedRow[indexPath.row] = 1;

	
	[tableView reloadData];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 60;
}


#pragma mark - UITableViewDataSource Methods

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	TDProfileHeaderView * profileHeader = (TDProfileHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"profileHeader"];
	
	profileHeader.circleView.layer.cornerRadius = 25;
	profileHeader.circleView.layer.masksToBounds = YES;
	
	profileHeader.profileImageView.layer.cornerRadius = 22;
	profileHeader.profileImageView.layer.masksToBounds = YES;

	
	return profileHeader;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
	
    return view;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
	
	cell.textLabel.text = [[_menuEntries objectAtIndex:indexPath.row] objectForKey:@"name"];
	
	if (_selectedRow[indexPath.row] == 1) {
		cell.imageView.image = [UIImage imageNamed:[[_menuEntries objectAtIndex:indexPath.row] objectForKey:@"selectedIcon"]];
	}else{
		cell.imageView.image = [UIImage imageNamed:[[_menuEntries objectAtIndex:indexPath.row] objectForKey:@"deselectedIcon"]];
	}
	
	return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _menuEntries.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}


@end