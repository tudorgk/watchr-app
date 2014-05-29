//
//  TDAddEventViewController.m
//  watchr
//
//  Created by Tudor Dragan on 29/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDAddEventViewController.h"
#import "TDBigInputTableViewCell.h"
#import "TDInputTableViewCell.h"
#import "TDMapSelectorTableViewCell.h"
#import "TDSubmitTableViewCell.h"
@interface TDAddEventViewController ()<HPGrowingTextViewDelegate>{
	NSMutableArray * _addEventItems;
	
	//I will instantiate the cells and keep the same reference. no dequeuing for data preservation and increased performance
	TDInputTableViewCell * _eventNameCell;
	TDBigInputTableViewCell * _eventDescriptionCell;
	UITableViewCell * _categorySelectorCell;
	TDMapSelectorTableViewCell * _mapSelectorCell;
	TDSubmitTableViewCell * _submitCell;
}
-(void) initialiseCells;
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
	[self initialiseCells];
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
	
	_addEventItems = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AddEventInputItems" ofType:@"plist"]];
	
	

}

-(void) initialiseCells{
	if(_eventNameCell == nil){
		_eventNameCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"input"];
	}
	
	if(_eventDescriptionCell == nil){
		_eventDescriptionCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"bigInput"];
		[_eventDescriptionCell.cellBigInputField setFont:[UIFont systemFontOfSize:17.0f]];
		[_eventDescriptionCell.cellBigInputField setPlaceholder:@"Event description"];
		[_eventDescriptionCell.cellBigInputField setDelegate:self];
		[_eventDescriptionCell.cellBigInputField setMaxNumberOfLines:2];
	}
	
	if (_categorySelectorCell == nil) {
		_categorySelectorCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"selector"];
	}
	
	if (_mapSelectorCell == nil) {
		_mapSelectorCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"mapSelector"];
		CLLocationCoordinate2D userLocation = _mapSelectorCell.cellPreviewMap.userLocation.location.coordinate;
		MKCoordinateRegion adjustedRegion = [_mapSelectorCell.cellPreviewMap regionThatFits:MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)];
		[_mapSelectorCell.cellPreviewMap setRegion:adjustedRegion animated:YES];
	}
	
	if(_submitCell == nil){
		_submitCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"submit"];
	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.section < [_addEventItems count] && indexPath.section != 0 && indexPath.row !=1) {
		return [[[[_addEventItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"height"] intValue];
	}else if(indexPath.section == 0 && indexPath.row ==1){
		NSLog(@"height on refresh = %lf", _eventDescriptionCell.cellBigInputField.bounds.size.height );
		NSLog(@"frame = %@", NSStringFromCGRect(_eventDescriptionCell.cellBigInputField.bounds));
		return _eventDescriptionCell.cellBigInputField.bounds.size.height + 10;
	}else{
		return 44.0f;
	}

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
		case 0:
			return @"Event details";
			break;
		case 1:
			return @"Category options";
			break;
		case 2:
			return @"Event location";
			break;
			
		default:
			return nil;
			break;
	}

}
#pragma mark - UITableViewDataSource Methods



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
	
    return view;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//add the submit cell
	if(indexPath.section == [_addEventItems count])
		return _submitCell;
	
	if ([[[[_addEventItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cellType"] isEqualToString:@"input"]) {
		return _eventNameCell;
	}
	if ([[[[_addEventItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cellType"] isEqualToString:@"bigInput"]) {
		return _eventDescriptionCell;
	}
	if ([[[[_addEventItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cellType"] isEqualToString:@"selector"]) {
		return _categorySelectorCell;
	}
	if ([[[[_addEventItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cellType"] isEqualToString:@"mapSelector"]) {
		return _mapSelectorCell;
	}
	
	return nil;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section == [_addEventItems count]) {
		return 1;
	}else{
		return [[_addEventItems objectAtIndex:section] count];
	}
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	return [_addEventItems count] + 1;
}

#pragma mark - FPGrowingTextView Delegate Methods

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
	
}
-(void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
	
}


-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
	
}

// Called WITHIN animation block!
-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
	NSLog(@"height = %lf", height);
	UITableViewCell * cell = [self.addEventTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] ;
	[cell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, height + 10)];
	

	[_eventDescriptionCell.cellBigInputField becomeFirstResponder];

}

// Called after animation
-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height{
	
}

-(void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView{
	
}


#pragma mark - Navigation Methods

-(void) userDidCancel:(id)sender{
	[self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

@end
