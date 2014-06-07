//
//  TDDashboardViewController.m
//  watchr
//
//  Created by Tudor Dragan on 19/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDDashboardViewController.h"
#import "TDEventDetailsViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "TDAddEventViewController.h"

typedef enum MapViewVisibility : NSInteger MapViewVisibility;
enum MapViewVisibility : NSInteger {
	MapViewVisibilityHidden,
	MapViewVisibilityShown
};

@interface TDDashboardViewController (){
	MapViewVisibility _mapState;
	MKMapView * _dashboardMap;
	TDWelcomeScreenViewController * _welcomeScreen;
	
	NSMutableArray * _dashboardData;
	NSInteger _dashboardDataSkip;
	NSInteger _dashboardDataCount;
	TDWatchrEventFilters * _dashboardFilters;
	NSDictionary * _filterPlist;
	
	//pickers
	ActionSheetCustomPicker * _distancePicker ;
	ActionSheetCustomPicker * _orderByPicker;
	ActionSheetCustomPicker * _orderModePicker;
	NSUInteger _distancePickerIndex;
	NSUInteger _orderByPickerIndex;
	NSUInteger _orderModePickerIndex;
	
	CLLocation * _currentLocation;
	
}
-(void) configureView;
-(void) configureTableView;
-(void) configureDataSource;
-(void) pullToRefreshHandler;
-(void) infiniteScrollHandler;
-(void) configureFilters;
-(void) configureLocationManager;
-(void) resetFilterBarButtons;
-(void) refreshDashboardFilters;
@end

@implementation TDDashboardViewController

#pragma mark - Initialisation Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
		
				
    }
    return self;
}

-(void)awakeFromNib{
	 self.title = @"Dashboard";
	
	_mapState= MapViewVisibilityHidden;
	
	//add multiple bar button items to navigation bar
	
	//map button
	UIButton * mapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 33)];
	self.mapButton =mapButton;
	[self.mapButton setTitle:@"Map" forState:UIControlStateNormal];
    self.mapButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	self.mapButton.titleLabel.textColor = [UIColor whiteColor];
	[self.mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *mapButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.mapButton];
	
	//add button
	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem * addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];

	
	[self.navigationItem setRightBarButtonItems:@[addButtonItem,mapButtonItem] animated:YES];
	
	_dashboardData = [NSMutableArray new];
	_dashboardDataSkip = 0;
	_dashboardDataCount = 20;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
	[self configureDataSource];
	[self configureTableView];
	[self configureFilters];
	[self configureLocationManager];
	[self refreshDashboardFilters];
	//present it
	_welcomeScreen = [[UIStoryboard storyboardWithName:@"IntroStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
	[_welcomeScreen.view setBackgroundColor:[UIColor clearColor]];
	_welcomeScreen.ownerViewController = self;
	//present it
	[self presentViewController:_welcomeScreen animated:NO completion:nil];
		
	
}

-(void) configureView{
	//initialize the mapview
	_dashboardMap = [[MKMapView alloc] initWithFrame:self.view.bounds];
	[_dashboardMap setShowsUserLocation:YES];
	
	//set the delegate and datasource
	[self.dashboardTableView setDelegate:self];
	[self.dashboardTableView setDataSource:self];
	
	//set up the filter buttons
	//radius button
	UIImage * radiusImage = [UIImage imageNamed:@"user-location-small-icon.png"];
	[self.radiusFilterButton setImage:radiusImage forState:UIControlStateNormal];
	[self.radiusFilterButton setCustomTitle:@"2km" forControlState:UIControlStateNormal];

	
	
//	//sort button
	UIImage * sortImage = [UIImage imageNamed:@"sort-small-icon.png"];
	[self.sortingFilterButton setImage:sortImage forState:UIControlStateNormal];
	[self.sortingFilterButton setCustomTitle:@"Rating" forControlState:UIControlStateNormal];

//
//	//tags button
	UIImage * tagsImage = [UIImage imageNamed:@"tags-small-icon.png"];
	[self.tagFilterButton setImage:tagsImage forState:UIControlStateNormal];
	[self.tagFilterButton setCustomTitle:@"Desc." forControlState:UIControlStateNormal];
	
	
	

	

}

-(void) configureTableView{
	
	// setup pull-to-refresh
    [self.dashboardTableView addPullToRefreshWithActionHandler:^{
        [self pullToRefreshHandler];
    }];
	
    // setup infinite scrolling
    [self.dashboardTableView addInfiniteScrollingWithActionHandler:^{
        [self infiniteScrollHandler];
    }];
	
	self.dashboardTableView.showsInfiniteScrolling = YES;
}

-(void) configureDataSource{
	
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
	//setup dashboard filters
	_dashboardFilters = [[TDWatchrEventFilters alloc] init];
	_dashboardFilters.filterOrderBy = [userDefaults objectForKey:TDDefaultOrderByKey];
	_dashboardFilters.filterOrderMode = [userDefaults objectForKey:TDDefaultOrderModeKey];
	_dashboardFilters.filterCount = [NSNumber numberWithInteger:_dashboardDataCount];
	_dashboardFilters.filterSkip = [NSNumber numberWithInteger:_dashboardDataSkip];
	
}

-(void) configureFilters{
	_distancePickerIndex = 0;
	_orderByPickerIndex =0;
	_orderModePickerIndex = 0;
	
	_filterPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WatchrEventFilterOptions" ofType:@"plist"]];
	
	_distancePicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Select radius" delegate:self showCancelButton:NO origin:self.view ];
	_orderByPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Order by" delegate:self showCancelButton:NO origin:self.view ];
	_orderModePicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Sort" delegate:self showCancelButton:NO origin:self.view ];
	[self resetFilterBarButtons];
}

-(void) configureLocationManager{
	[[TDWatchrLocationManager sharedManager] setDelegate:self];
}

-(void) refreshDashboardFilters{
	//sets up the filters
	_dashboardFilters.filterOrderBy	= [[[_filterPlist objectForKey:TDDefaultOrderByKey] objectAtIndex:_orderByPickerIndex] objectForKey:@"filter"];
	_dashboardFilters.filterOrderMode = [[[_filterPlist objectForKey:TDDefaultOrderModeKey] objectAtIndex:_orderModePickerIndex] objectForKey:@"filter"];
	if ([TDWatchrLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
		//set the geocode as well
		[_dashboardFilters setFilterGeocodeWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude andRadius:[[[[_filterPlist objectForKey:TDDefaultRadiusKey] objectAtIndex:_distancePickerIndex] objectForKey:@"filter"] doubleValue]];
	}else{
		_dashboardFilters.filterGeocode = nil;
	}
}

-(void) viewDidAppear:(BOOL)animated{
	//check if the Location Manager has permission
//	if ([TDWatchrLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
//		[self.radiusFilterButton setEnabled:NO];
//	}else{
//		[[TDWatchrLocationManager sharedManager] startUpdatingLocation];
//	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	if (status == kCLAuthorizationStatusAuthorized) {
		[self.radiusFilterButton setEnabled:YES];
		[[TDWatchrLocationManager sharedManager] startUpdatingLocation];
	}else{
		[self.radiusFilterButton setEnabled:NO];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	_currentLocation = [locations lastObject];
	[_dashboardFilters setFilterGeocodeWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude andRadius:[[[[_filterPlist objectForKey:TDDefaultRadiusKey] objectAtIndex:_distancePickerIndex] objectForKey:@"filter"] doubleValue]];
}

#pragma mark - Action Picker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if (pickerView == _distancePicker.pickerView) {
		//if it's the distance picker view
		return [[_filterPlist objectForKey:TDDefaultRadiusKey] count];
	}else if(pickerView == _orderByPicker.pickerView){
		return [[_filterPlist objectForKey:TDDefaultOrderByKey] count];
	}else{
		return [[_filterPlist objectForKey:TDDefaultOrderModeKey] count];
	}
	return 0;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	if (pickerView == _distancePicker.pickerView) {
		//if it's the distance picker view
		return [[[_filterPlist objectForKey:TDDefaultRadiusKey] objectAtIndex:row] objectForKey:@"label"];
	}else if(pickerView == _orderByPicker.pickerView){
		return [[[_filterPlist objectForKey:TDDefaultOrderByKey] objectAtIndex:row] objectForKey:@"label"];
	}else{
		return [[[_filterPlist objectForKey:TDDefaultOrderModeKey] objectAtIndex:row] objectForKey:@"label"];
	}
	return @"";
}

- (void)configurePickerView:(UIPickerView *)pickerView{
	pickerView.delegate =self;
	pickerView.dataSource =self;
	
	
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (pickerView == _distancePicker.pickerView) {
		//if it's the distance picker view
		_distancePickerIndex = row;
	}else if(pickerView == _orderByPicker.pickerView){
		_orderByPickerIndex = row;
	}else{
		_orderModePickerIndex = row;
	}
	
	NSLog(@"distance = %d, order by = %d, order mode = %d",_distancePickerIndex,_orderByPickerIndex,_orderModePickerIndex);
}


- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
	[self resetFilterBarButtons];
	
	[self refreshDashboardFilters];
	
	//trigger the refresh
	[self.dashboardTableView triggerPullToRefresh];
}

- (void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
	//does nothing really
	
	[self resetFilterBarButtons];
	
	//get the data with fitlers set
}

#pragma mark - Picker Actions
-(void) resetFilterBarButtons{
	[self.tagFilterButton setCustomTitle:[[[_filterPlist objectForKey:TDDefaultOrderByKey] objectAtIndex:_orderByPickerIndex] objectForKey:@"label"] forControlState:UIControlStateNormal];
	[self.radiusFilterButton setCustomTitle:[[[_filterPlist objectForKey:TDDefaultRadiusKey] objectAtIndex:_distancePickerIndex] objectForKey:@"label"] forControlState:UIControlStateNormal];
	[self.sortingFilterButton setCustomTitle:[[[_filterPlist objectForKey:TDDefaultOrderModeKey] objectAtIndex:_orderModePickerIndex] objectForKey:@"label"] forControlState:UIControlStateNormal];
}

- (IBAction)radiusFilterButtonPressed:(id)sender {
	_distancePickerIndex = 0;
	[_distancePicker showActionSheetPicker];
}

- (IBAction)orderByButtonPressed:(id)sender {
	_orderByPickerIndex = 0;
	[_orderByPicker showActionSheetPicker];
}

- (IBAction)orderModeButtonPressed:(id)sender {
	_orderModePickerIndex = 0;
	[_orderModePicker showActionSheetPicker];
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	TDEventDetailsViewController * detailsController = [[UIStoryboard storyboardWithName:@"EventStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
	[self.navigationController pushViewController:detailsController animated:YES];
	
}

#pragma mark - UITableViewDataSource Methods

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	TDDashboardEventTableViewCell * cell = (TDDashboardEventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"eventCell"];
	NSDictionary * cellData =[_dashboardData objectAtIndex:indexPath.row];
	
	cell.cellEventTitleLabel.text = [cellData objectForKey:@"event_name"];
	cell.cellEventDescriptionLabel.text = [cellData objectForKey:@"description"];
	cell.cellEventDistanceLabel.text = [[cellData objectForKey:@"distance"] stringValue];
	cell.cellRatingLabel.text = [cellData objectForKey:@"rating"];
	cell.cellTimeLabel.text = [cellData objectForKey:@"created_at"];
	return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [_dashboardData count];
}


#pragma mark - Navigation Methods

- (IBAction)mapButtonPressed:(id)sender {
	if (_mapState == MapViewVisibilityHidden) {
		[self.dashboardTableView showOrigamiTransitionWith:_dashboardMap
											 NumberOfFolds:3
												  Duration:0.5
												 Direction:XYOrigamiDirectionFromTop
												completion:^(BOOL finished) {
													CLLocationCoordinate2D userLocation = _dashboardMap.userLocation.location.coordinate;
													MKCoordinateRegion adjustedRegion = [_dashboardMap regionThatFits:MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)];
													[_dashboardMap setRegion:adjustedRegion animated:YES];
												}];
		
		
		
		_mapState = MapViewVisibilityShown;
	}else{
		[self.dashboardTableView hideOrigamiTransitionWith:_dashboardMap
									 NumberOfFolds:3
										  Duration:0.5
										 Direction:XYOrigamiDirectionFromTop
										completion:^(BOOL finished) {
											NSLog(@"Map view hidden");
										}];
		_mapState = MapViewVisibilityHidden;
	}
				
}

- (IBAction)menuButtonPressed:(id)sender {
	[self.slidingViewController anchorTopViewToRightAnimated:YES];
}

-(IBAction)addButtonPressed:(id)sender
{
	UINavigationController * addEventNavigationController  = [[UIStoryboard storyboardWithName:@"EventStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"addEventNavigationController"];
	
	[self presentViewController:addEventNavigationController animated:YES completion:^{
		
	}];
}
#pragma mark - InfiniteScroll + PullToRefresh Handlers
-(void) infiniteScrollHandler{
	_dashboardDataSkip +=20;
	_dashboardFilters.filterSkip = [NSNumber numberWithInteger:_dashboardDataSkip];
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/active"]]
				   usingParameters:[_dashboardFilters filtersToDictionary]
					   withAccount:[[TDWatchrAPIManager sharedManager] defaultWatchrAccount]
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
				   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
					   //				   NSLog(@"response = %@", [response description]);
					   //				   NSLog(@"error = %@", [error userInfo]);
					   if (error) {
						   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving events" message:[[error userInfo] description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
						   [alert show];
					   }else{
						   [self.dashboardTableView beginUpdates];
						   NSArray * data =[[TDWatchrAPIManager sharedManager] getArrayForKey:@"data" fromResponseData:responseData ];
						   [_dashboardData addObjectsFromArray:data];
						   
						   NSMutableArray * reloadIndexPathsArray = [NSMutableArray new];
						   for (int i = _dashboardData.count - data.count ; i<_dashboardData.count; i++) {
							   [reloadIndexPathsArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
						   }
						   
						   [self.dashboardTableView insertRowsAtIndexPaths:reloadIndexPathsArray withRowAnimation:UITableViewRowAnimationTop];
						   [self.dashboardTableView endUpdates];
					   }
						
					   [self.dashboardTableView.infiniteScrollingView stopAnimating];
					   
				   }];
}
-(void) pullToRefreshHandler{
	
	//reset skip
	_dashboardDataSkip = 0;
	_dashboardFilters.filterSkip= [NSNumber numberWithInt:_dashboardDataSkip];
	
	NSLog(@"filters = %@", [_dashboardFilters filtersToDictionary]);
	
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/active"]]
				   usingParameters:[_dashboardFilters filtersToDictionary]
					   withAccount:[[TDWatchrAPIManager sharedManager] defaultWatchrAccount]
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
				   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
					   //				   NSLog(@"response = %@", [response description]);
					   //				   NSLog(@"error = %@", [error userInfo]);
					   if (error) {
						   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving events" message:[[error userInfo] description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
						   [alert show];
					   }else{

						   [_dashboardData removeAllObjects];
						   NSArray * data =[[TDWatchrAPIManager sharedManager] getArrayForKey:@"data" fromResponseData:responseData ];
						   [_dashboardData addObjectsFromArray:data];
						   [self.dashboardTableView reloadData];

					   }
					   
					   [self.dashboardTableView.pullToRefreshView stopAnimating];
					   
				   }];

}

#pragma mark - TDFirstTunManagerDelegate methods

-(void) managerDidFinishFirstTimeSetUpWithData:(id)data{
	[self.dashboardTableView triggerPullToRefresh];
	[_welcomeScreen dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TDWatchrApiManagerDelegate methods

-(void) WatchrAPIManagerDidFinishWithData:(NSArray *)data forKey:(NSString *)key{

}

-(void) WatchrAPIManagerDidFinishWithError:(NSError *)error{
	
}
-(void) WatchrAPIManagerDidFinishWithResponse:(NSURLResponse *)response{
	
}


@end
