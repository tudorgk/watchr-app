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
#import "TDPhotoPickerTableViewCell.h"
#import "CTAssetsPickerController.h"
@interface TDAddEventViewController ()<HPGrowingTextViewDelegate,CTAssetsPickerControllerDelegate,UINavigationControllerDelegate>{
	NSMutableArray * _addEventItems;
	NSMutableArray * _selectedPhotos;
	NSMutableArray * _thumbnails;
	
	
	//I will instantiate the cells and keep the same reference. no dequeuing for data preservation and increased performance
	TDInputTableViewCell * _eventNameCell;
	TDBigInputTableViewCell * _eventDescriptionCell;
	UITableViewCell * _categorySelectorCell;
	TDMapSelectorTableViewCell * _mapSelectorCell;
	TDSubmitTableViewCell * _submitCell;
	TDPhotoPickerTableViewCell * _photoPickerCell;
	CTAssetsPickerController * _picker;


}
-(void) initialiseCells;
-(void) configureView;
-(void) configureTableView;
-(void) userDidCancel:(id) sender;
-(void) clearSelectedAssets;
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

	
	_selectedPhotos = [[NSMutableArray alloc] init];
	_thumbnails = [[NSMutableArray alloc] init];
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
	
	
	_picker = [[CTAssetsPickerController alloc] init];
	_picker.delegate=self;
	[_picker.navigationBar setBarTintColor:[UIColor blackColor]];
	_picker.navigationBar.tintColor = [UIColor whiteColor];
	NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								 [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0], NSForegroundColorAttributeName, nil];
	_picker.navigationBar.titleTextAttributes = attributes;
	

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
	
	if(_photoPickerCell == nil){
		_photoPickerCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"photoPicker"];
		UITapGestureRecognizer * tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
		[_photoPickerCell.cellThumbnailsScrollView addGestureRecognizer:tapper];

	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.section) {
		case 3:
		{
			[self presentViewController:_picker animated:YES completion:nil];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
			break;
			
		default:
			break;
	}
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
		case 3:
			return @"Photo attachments";
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
	if ([[[[_addEventItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"cellType"] isEqualToString:@"photoPicker"]) {
		return _photoPickerCell;
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

#pragma mark - CTAssetsPickerControllerDelegate
-(void) clearSelectedAssets{
	//set up the selected photos array for sending
	[_selectedPhotos removeAllObjects];
	
	
	//remove the thumbnails from the cell's scrollview
	for (UIView * view in _thumbnails) {
		[view removeFromSuperview];
	}
	
	[_thumbnails removeAllObjects];
	
	//set the contentfor the scrollview to 0
	[_photoPickerCell.cellThumbnailsScrollView setContentSize:CGSizeMake(0, 0)];
	//set the label to visible
	[_photoPickerCell.cellMessageLabel setHidden:NO];

}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{

	[self clearSelectedAssets];
	
	[_selectedPhotos addObjectsFromArray:assets];
	
	if (_selectedPhotos.count>0) {
		
		for (int i=0 ; i<_selectedPhotos.count;i++) {
			ALAsset *asset = [_selectedPhotos objectAtIndex:i];
			
			//create a imageView for the photo
			UIImageView *imageView= [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
			[imageView setFrame:CGRectMake(i*60+10 , 5, 50, 50)];
			[imageView setClipsToBounds:YES];
			[imageView setContentMode:UIViewContentModeScaleAspectFill];
			
			//add it to the cell's view array
			[_thumbnails addObject:imageView];
			
			//add it to the scroll view
			[_photoPickerCell.cellThumbnailsScrollView addSubview:[_thumbnails objectAtIndex:i]];
			
		}
		
		[_photoPickerCell.cellThumbnailsScrollView setContentSize:CGSizeMake(_selectedPhotos.count * 60 + 10, _photoPickerCell.cellThumbnailsScrollView.frame.size.height)];
		
		
		//hide the label
		[_photoPickerCell.cellMessageLabel setHidden:YES];
	}
	
	[_picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker{
	[self clearSelectedAssets];
	[_picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Navigation Methods

-(void) userDidCancel:(id)sender{
	[self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

-(void) scrollViewTapped:(id) sender{
	[self.addEventTableView.delegate tableView:self.addEventTableView didSelectRowAtIndexPath: [self.addEventTableView indexPathForCell:_photoPickerCell]];
}

@end
