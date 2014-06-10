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
#import "TDSelectLocationViewController.h"
#define kFontSize 17.0 // fontsize
#define kTextViewWidth 302

#define kTDWatchrEventNameKey @"event_name"
#define kTDWatchrEventDescriptionKey @"event_description"
#define kTDWatchrEventCategoriesKey @"categories"
#define kTDWatchrEventLatitudeKey @"latitude"
#define kTDWatchrEventLongitudeKey @"longitude"
#define kTDWatchrEventMediaArrayKey @"media[]"

@interface TDAddEventViewController ()<CTAssetsPickerControllerDelegate,UINavigationControllerDelegate,TDMapSelectorTableViewCellDelegate,TDSelectLocationViewControllerDelegate,CLLocationManagerDelegate>{
	//the form
	NSMutableArray * _addEventItems;
	
	
	//photos
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
	
	//Data for creating the request
	NSString * _eventDescriptionString;
	NSString * _eventNameString;
	
	UITapGestureRecognizer * _dismissKeyboardTapper;
	id _activeInputField;
	
	//Add CLLocation manager
	CLLocationManager * _addLocationManager;
	CLLocation * _currentLocation;


}
-(void) initialiseCells;
-(void) configureView;
-(void) configureTableView;
-(void) userDidCancel:(id) sender;
-(void) clearSelectedAssets;
-(void) configureMapCellDefaultValues;
-(void) configureLocationManager;
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

	_selectedPhotos = [[NSMutableArray alloc] init];
	_thumbnails = [[NSMutableArray alloc] init];

	[self configureView];
	[self configureTableView];
	[self initialiseCells];
	[self configureLocationManager];
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
	
	_window = [[[UIApplication sharedApplication] delegate] window];
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

	_activeInputField = nil;
	//add a tap gesture recognizer to dismiss the keyboard
	_dismissKeyboardTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
	[self.addEventTableView addGestureRecognizer:_dismissKeyboardTapper];
	

}

-(void) initialiseCells{
	if(_eventNameCell == nil){
		_eventNameCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"input"];
		_eventNameCell.cellInputField.delegate = self;
		_eventNameString = @"";
	}
	
	if(_eventDescriptionCell == nil){
		_eventDescriptionCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"bigInput"];
		[_eventDescriptionCell.cellBigInputField setFont:[UIFont systemFontOfSize:17.0f]];
		[_eventDescriptionCell.cellBigInputField setDelegate:self];
		
		// set the model
		_eventDescriptionString = @"";
		
		// create a rect for the text view so it's the right size coming out of IB. Size it to something that is form fitting to the string in the model.
		float height = [self heightForTextView:_eventDescriptionCell.cellBigInputField containingString:_eventDescriptionString];
		CGRect textViewRect = CGRectMake(10, 2, kTextViewWidth, height);
		
		_eventDescriptionCell.cellBigInputField.frame = textViewRect;
		
		// now that we've resized the frame properly, let's run this through again to get proper dimensions for the contentSize.
		_eventDescriptionCell.cellBigInputField.contentSize = CGSizeMake(kTextViewWidth, [self heightForTextView:_eventDescriptionCell.cellBigInputField containingString:_eventDescriptionString]);
		
		_eventDescriptionCell.cellBigInputField.text = _eventDescriptionString;
	}
	
	if (_categorySelectorCell == nil) {
		_categorySelectorCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"selector"];
		_categorySelectorCell.detailTextLabel.text = @"None";
	}
	
	if (_mapSelectorCell == nil) {
		_mapSelectorCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"mapSelector"];
		_mapSelectorCell.delegate = self;
		
		CLLocationCoordinate2D defaultCoordonate = CLLocationCoordinate2DMake(44.428565, 26.103902);
		MKCoordinateRegion adjustedRegion = [_mapSelectorCell.cellPreviewMap regionThatFits:MKCoordinateRegionMakeWithDistance(defaultCoordonate, 200, 200)];
		[_mapSelectorCell.cellPreviewMap setRegion:adjustedRegion animated:YES];
	}
	
	if(_submitCell == nil){
		_submitCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"submit"];
		UITapGestureRecognizer * tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitButtonTapped:)];
		[_submitCell.cellSubmitLabel addGestureRecognizer:tapper];
	}
	
	if(_photoPickerCell == nil){
		_photoPickerCell = [self.addEventTableView dequeueReusableCellWithIdentifier:@"photoPicker"];
		UITapGestureRecognizer * tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
		[_photoPickerCell.cellThumbnailsScrollView addGestureRecognizer:tapper];
	}
	
}

-(void) configureMapCellDefaultValues{
	_geocoder = [[CLGeocoder alloc] init];
		
	if (_watchrEventPoint == nil) {
		_watchrEventPoint = [[MKPointAnnotation alloc] init];
		CLLocationCoordinate2D userLocation = _currentLocation.coordinate;
		_watchrEventPoint.coordinate = userLocation;
		
		MKCoordinateRegion adjustedRegion = [_mapSelectorCell.cellPreviewMap regionThatFits:MKCoordinateRegionMakeWithDistance(_watchrEventPoint.coordinate, 200, 200)];
		[_mapSelectorCell.cellPreviewMap setRegion:adjustedRegion animated:YES];
		
		//setup the label
		[_geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
			CLPlacemark * placemark = [placemarks firstObject];
			_mapSelectorCell.cellTitleLabel.text = placemark.name;
		}];
		
		[_mapSelectorCell.cellPreviewMap addAnnotation:_watchrEventPoint];
	}
}

-(void) configureLocationManager{
	_addLocationManager = [[CLLocationManager alloc] init];
	_addLocationManager.delegate = self;
    _addLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [_addLocationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
	[self subscribeToKeyboardEvents:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self subscribeToKeyboardEvents:NO];
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	if (status == kCLAuthorizationStatusAuthorized) {
		[[TDWatchrLocationManager sharedManager] startUpdatingLocation];
	}else{

	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	_currentLocation = [locations lastObject];
	[self configureMapCellDefaultValues];
}


#pragma maek - Keyboard handlers

-(void) dismissKeyboard:(id)sender{
	if (_activeInputField!=nil) {
		if ([_activeInputField respondsToSelector:@selector(resignFirstResponder)]) {
			[_activeInputField resignFirstResponder];
			_activeInputField = nil;
		}
	}
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

- (void) keyboardDidShow:(NSNotification *)nsNotification {
	
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
    CGRect newFrame = [self.addEventTableView frame];
	
    CGFloat kHeight = kbSize.height;
	
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
	
    newFrame.size.height -= kHeight;
	
    [self.addEventTableView setFrame:newFrame];
	
}

- (void) keyboardWillHide:(NSNotification *)nsNotification {
	
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [self.addEventTableView frame];
	
    CGFloat kHeight = kbSize.height;
	
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
	
    newFrame.size.height += kHeight;
	
    // save the content offset before the frame change
    CGPoint contentOffsetBefore = self.addEventTableView.contentOffset;
	
    [self.addEventTableView setHidden:YES];
	
    // set the new frame
    [self.addEventTableView setFrame:newFrame];
	
    // get the content offset after the frame change
    CGPoint contentOffsetAfter =  self.addEventTableView.contentOffset;
	
    // content offset initial state
    [self.addEventTableView setContentOffset:contentOffsetBefore];
	
    [self.addEventTableView setHidden:NO];
	
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.addEventTableView setContentOffset:contentOffsetAfter];
                     }
                     completion:^(BOOL finished){
                         // do nothing for the time being...
                     }
     ];
	
}




#pragma mark - TDMapSelectorTableViewCellDelegate methods
-(void) mapSelectorCell:(TDMapSelectorTableViewCell*) mapCell myLocationButtonPressed:(id) sender{
	NSLog(@"map selector delegate my location button pressed");
	
	//set the location to be the same with the user's location. animate preview map
	_watchrEventPoint.coordinate = _mapSelectorCell.cellPreviewMap.userLocation.coordinate;
	[_mapSelectorCell.cellPreviewMap addAnnotation:_watchrEventPoint];
	MKCoordinateRegion adjustedRegion = [_mapSelectorCell.cellPreviewMap regionThatFits:MKCoordinateRegionMakeWithDistance(_watchrEventPoint.coordinate, 200, 200)];
	[_mapSelectorCell.cellPreviewMap setRegion:adjustedRegion animated:YES];


	//Reverse geocode the position and write the address in cellTitleLabel
	[_geocoder reverseGeocodeLocation:_mapSelectorCell.cellPreviewMap.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error updating location" message:@"Check if you have location services turned om" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			[alert show	];
			_mapSelectorCell.cellTitleLabel.text = @"";
		}else{
		CLPlacemark * placemark = [placemarks firstObject];
			_mapSelectorCell.cellTitleLabel.text = placemark.name;
		}
	}];
	
	//change the button's icon
	[_mapSelectorCell.cellMyLocationButton setImage:[UIImage imageNamed:@"user-location-on.png"] forState:UIControlStateNormal];
	

}
-(void) mapSelectorCell:(TDMapSelectorTableViewCell*) mapCell mapTapped:(id)sender{
	//TODO: push the point selector view controller
	TDSelectLocationViewController * selectLocation = [[UIStoryboard storyboardWithName:@"EventStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"selectLocation"];
	selectLocation.delegate = self;
	[self.navigationController pushViewController:selectLocation animated:YES];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
	
	_eventNameString =[textField.text stringByReplacingCharactersInRange:range withString:string];
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	_eventNameString =textField.text;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
	_activeInputField = textField;
}

#pragma mark - UITextViewDelegate methods

- (void) textViewDidChange:(UITextView *)textView
{
    _eventDescriptionString	 = textView.text;
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
	_activeInputField = textView;
}

-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	
	_eventDescriptionString = [textView.text stringByReplacingCharactersInRange:range withString:text];

	if ([_eventDescriptionString isEqualToString:@""]) {
		[_eventDescriptionCell.cellPlaceholderLabel setHidden:NO];
	}else{
		[_eventDescriptionCell.cellPlaceholderLabel setHidden:YES];
	}
	
    [self.addEventTableView beginUpdates];
    [self.addEventTableView endUpdates];
	return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView == _eventDescriptionCell.cellBigInputField) {
        _eventDescriptionString = textView.text;
    }
}

- (CGFloat)heightForTextView:(UITextView*)textView containingString:(NSString*)string
{
	
	CGSize maximumLabelSize = CGSizeMake(kTextViewWidth - 10, FLT_MAX);
		
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setLineBreakMode:NSLineBreakByCharWrapping];
	
	NSDictionary * stringAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kFontSize],
										NSParagraphStyleAttributeName: style};
	
	CGSize textViewSize = [string boundingRectWithSize:maximumLabelSize
													 options:NSStringDrawingUsesLineFragmentOrigin
												  attributes:stringAttributes context:nil].size;
	
	
    float verticalPadding = kFontSize;
    return textViewSize.height + verticalPadding;
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.section) {
		case 3:
		{
			[self presentViewController:_picker animated:YES completion:nil];
			
		}
			break;
		case 4:
		{
			//submit
			[_activeInputField resignFirstResponder];
			[self submitWatchrEventToServer];
		}
			break;
			
		default:
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.section < [_addEventItems count] && indexPath.section != 0 && indexPath.row !=1) {
		return [[[[_addEventItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"height"] intValue];
	}else if(indexPath.section == 0 && indexPath.row ==1){
		float height = [self heightForTextView:_eventDescriptionCell.cellBigInputField containingString:_eventDescriptionString];
        return height + kFontSize; // a little extra padding is needed
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
#pragma mark - Watchr API handlers

-(void) submitWatchrEventToServer{
	
	// Block whole window
	MRProgressOverlayView * progressView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:@"Posting event" mode:MRProgressOverlayViewModeDeterminateHorizontalBar animated:YES];
	
	NSMutableDictionary * parameters = [NSMutableDictionary new];
	
	[parameters setObject:_eventNameString forKey:kTDWatchrEventNameKey];
	[parameters setObject:_eventDescriptionString forKey:kTDWatchrEventDescriptionKey];
	[parameters setObject:[NSNumber numberWithDouble:_watchrEventPoint.coordinate.latitude] forKey:kTDWatchrEventLatitudeKey];
	[parameters setObject:[NSNumber numberWithDouble:_watchrEventPoint.coordinate.longitude] forKey:kTDWatchrEventLongitudeKey];
	
	
	if ([_selectedPhotos count]!=0) {
		//if we post an event with w/ media

		//setup the parameters
		/*
		 'event_name' => 'required|max:100',
		 'event_description' => 'max:400',
		 'categories' => 'required|array', //don't need to send categories (if it's empty, category is unknown(5))
		 'latitude' => 'required|numeric',
		 'longitude' => 'required|numeric'
		 'media' => 'array|required'
		 */
		//send the request
		NSMutableArray * mediaArray = [NSMutableArray new];
		
		for (ALAsset * assetIter in _selectedPhotos) {
			UIImage * image = [[UIImage alloc] initWithCGImage:[[assetIter defaultRepresentation] fullResolutionImage]];
			NSData *imgData = UIImageJPEGRepresentation(image, 1);
			NSInputStream * inputStream = [[NSInputStream alloc] initWithData:imgData];
			NSLog(@"Size of Image(bytes):%d",[imgData length]);
			
			NXOAuth2FileStreamWrapper * file = [NXOAuth2FileStreamWrapper wrapperWithStream:inputStream contentLength:[imgData length] fileName:[[assetIter defaultRepresentation] filename]];
			[mediaArray addObject:file];
			
			
		}
		[parameters setObject:mediaArray forKey:kTDWatchrEventMediaArrayKey];
		
		[NXOAuth2Request performMethod:@"POST"
							onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/new_with_media"]]
					   usingParameters:parameters
						   withAccount:[[TDWatchrAPIManager sharedManager] defaultWatchrAccount]
				   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
					   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
					   
					   double sent = bytesSend;
					   double total = bytesTotal;
					   float ratio = sent/total;
					   
					   [progressView setProgress:ratio animated:YES];
				   }
					   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
						   NSString * responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
						   NSLog(@"responseData = %@", responseString );
						   NSLog(@"response = %@", [response description]);
						   NSLog(@"error = %@", [error userInfo]);
						   
						   //if error
						   if (error) {
							   //Dismiss
							   progressView.mode = MRProgressOverlayViewModeCross;
							   progressView.titleLabelText = @"Failed to post event";
							   [TDHelperClass performBlock:^{
								   [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES ];
								   if (_delegate) {
									   if ([_delegate respondsToSelector:@selector(controller:didPostEventSuccessfully:)]) {
										   [_delegate controller:self didPostEventSuccessfully:NO];
									   }
								   }
							   } afterDelay:1.0];

							   return;
						   }
						   //Dismiss
						   progressView.mode = MRProgressOverlayViewModeCheckmark;
						   progressView.titleLabelText = @"Event posted";
						   [TDHelperClass performBlock:^{
							   [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES ];
							   //TODO: dismiss this view controller and notify the delegate that the event was added
							   if (_delegate) {
								   if ([_delegate respondsToSelector:@selector(controller:didPostEventSuccessfully:)]) {
									   [_delegate controller:self didPostEventSuccessfully:YES];
								   }
							   }
						   } afterDelay:1.0];
						
					   }];
	
	}else{
		//if we post an event with w/o media
		//setup the parameters
		/*
		 'event_name' => 'required|max:100',
		 'event_description' => 'max:400',
		 'categories' => 'required|array', //don't need to send categories (if it's empty, category is unknown(5))
		 'latitude' => 'required|numeric',
		 'longitude' => 'required|numeric'
		 */
			
		//send the request
		[NXOAuth2Request performMethod:@"POST"
							onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/new"]]
					   usingParameters:parameters
						   withAccount:[[TDWatchrAPIManager sharedManager] defaultWatchrAccount]
				   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
					   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
   					   
					   double sent = bytesSend;
					   double total = bytesTotal;
					   float ratio = sent/total;
					   
					   [progressView setProgress:ratio animated:YES];
				   }
					   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
						   NSString * responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
						   NSLog(@"responseData = %@", responseString );
						   NSLog(@"response = %@", [response description]);
						   NSLog(@"error = %@", [error userInfo]);
						   
						   
						   
						   //if error
						   if (error) {
							   //Dismiss
							   
							   progressView.mode = MRProgressOverlayViewModeCross;
							   progressView.titleLabelText = @"Failed to post event";
							   [TDHelperClass performBlock:^{
								   [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES ];
								   if (_delegate) {
									   if ([_delegate respondsToSelector:@selector(controller:didPostEventSuccessfully:)]) {
										   [_delegate controller:self didPostEventSuccessfully:NO];
									   }
								   }
							   } afterDelay:1.0];
							   
  							   return;
						   }
						   
						   //Dismiss
						   progressView.mode = MRProgressOverlayViewModeCheckmark;
						   progressView.titleLabelText = @"Event posted";
						   [TDHelperClass performBlock:^{
							   [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES ];
							    //TODO: dismiss this view controller and notify the delegate that the event was added
							   if (_delegate) {
								   if ([_delegate respondsToSelector:@selector(controller:didPostEventSuccessfully:)]) {
									   [_delegate controller:self didPostEventSuccessfully:YES];
								   }
							   }
						   } afterDelay:1.0];
  						  
					   }];
	}
}

#pragma mark - Navigation Methods

-(void) userDidCancel:(id)sender{
	[self dismissViewControllerAnimated:YES completion:^{}];
}

-(void) scrollViewTapped:(id) sender{
	[self.addEventTableView.delegate tableView:self.addEventTableView didSelectRowAtIndexPath: [self.addEventTableView indexPathForCell:_photoPickerCell]];
}

-(void) submitButtonTapped:(id) sender{
	[self.addEventTableView.delegate tableView:self.addEventTableView didSelectRowAtIndexPath: [self.addEventTableView indexPathForCell:_submitCell]];
}

#pragma mark - TDSelectLocationViewControllerDelegate methods
-(void) controller:(TDSelectLocationViewController *)selectionController diSelectAnnotation:(TDAnnotation *)annotation sameAsUserLocation:(BOOL)sameAsUserLocation{
	
	_watchrEventPoint.coordinate = annotation.coordinate;
	
	if (sameAsUserLocation) {
		[_mapSelectorCell.cellMyLocationButton setImage:[UIImage imageNamed:@"user-location-on.png"] forState:UIControlStateNormal];
	}else{
		[_mapSelectorCell.cellMyLocationButton setImage:[UIImage imageNamed:@"user-location-off.png"] forState:UIControlStateNormal];
	}
	
	[_mapSelectorCell.cellPreviewMap addAnnotation:_watchrEventPoint];
	MKCoordinateRegion adjustedRegion = [_mapSelectorCell.cellPreviewMap regionThatFits:MKCoordinateRegionMakeWithDistance(_watchrEventPoint.coordinate, 200, 200)];
	[_mapSelectorCell.cellPreviewMap setRegion:adjustedRegion animated:NO];
	
	
	//Reverse geocode the position and write the address in cellTitleLabel
	CLLocation * selectedLocation = [[CLLocation alloc] initWithLatitude:_watchrEventPoint.coordinate.latitude longitude:_watchrEventPoint.coordinate.longitude];
	[_geocoder reverseGeocodeLocation:selectedLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error updating location" message:@"Check if you have location services turned om" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			[alert show	];
			_mapSelectorCell.cellTitleLabel.text = @"";
		}else{
			CLPlacemark * placemark = [placemarks firstObject];
			_mapSelectorCell.cellTitleLabel.text = placemark.name;
		}
	}];
	
	//pop the select location view controller
	[self.navigationController popViewControllerAnimated:YES];

}



@end
