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
#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotationView.h"
#import "TBClusterAnnotation.h"
typedef enum MapViewVisibility : NSInteger MapViewVisibility;
enum MapViewVisibility : NSInteger {
	MapViewVisibilityHidden,
	MapViewVisibilityShown
};

@interface TDDashboardViewController ()<MKMapViewDelegate>{
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
@property (strong, nonatomic) TBCoordinateQuadTree *coordinateQuadTree;

-(void) registerForNotifications;
-(void) configureView;
-(void) configureTableView;
-(void) configureDataSource;
-(void) pullToRefreshHandler;
-(void) infiniteScrollHandler;
-(void) configureFilters;
-(void) configureLocationManager;
-(void) resetFilterBarButtons;
-(void) refreshDashboardFilters;
-(void) configureQuadTree;

-(void) welcomeScreenDismissed;

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
	 self.title = @"Feed";
	
	_firstRun = YES;
	
	_mapState= MapViewVisibilityHidden;
	
	//add multiple bar button items to navigation bar
	
	//map button
	UIButton * mapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 33)];
	self.mapButton =mapButton;
	[self.mapButton setImage:[UIImage imageNamed:@"dashboard-map-icon.png"] forState:UIControlStateNormal];
	[[self.mapButton imageView] setContentMode:UIViewContentModeCenter];
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
	[self configureQuadTree];
	[self registerForNotifications];
	//present it if there are no accounts registered
	if ([[NSUserDefaults standardUserDefaults] objectForKey:TDWatchrAPIAccountIdentifier] == nil) {
		//this means that the app has no login info
		for (NXOAuth2Account * account in [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"watchrAPI"]) {
			[[NXOAuth2AccountStore sharedStore] removeAccount:account];
		}
		[[TDWelcomeScreenViewController sharedWelcomeScreen] presentWelcomeScreen:self animated:NO];
	}else{
		[_locationManager startUpdatingLocation];
	}

		
	
}

-(void) configureView{
	//initialize the mapview
	_dashboardMap = [[MKMapView alloc] initWithFrame:self.view.bounds];
	//TODO: Fix user lcoation annotation
	[_dashboardMap setShowsUserLocation:NO];
	[_dashboardMap setDelegate:self];
	MKCoordinateRegion region = _dashboardMap.region;
	region.center = CLLocationCoordinate2DMake(44.428565, 26.103902);
	region.span.longitudeDelta /= 200; // Bigger the value, closer the map view
	region.span.latitudeDelta /= 200;
	[_dashboardMap setRegion:region animated:NO]; // Choose if you want animate or not

	
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
	
	 _refreshControl = [[UIRefreshControl alloc] init];
	[self.dashboardTableView addSubview:_refreshControl];
	[_refreshControl addTarget:self action:@selector(pullToRefreshHandler) forControlEvents:UIControlEventValueChanged];

	
	[self.dashboardTableView addInfiniteScrollWithHandler:^(UIScrollView * scrollView){
		[self infiniteScrollHandler];
	}];
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

-(void) configureQuadTree{
	self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
    self.coordinateQuadTree.mapView = _dashboardMap;
	[NSThread detachNewThreadSelector:@selector(buildTreeWithArray:) toTarget:self.coordinateQuadTree withObject:_dashboardData];
}

-(void) viewDidAppear:(BOOL)animated{
	//check if the Location Manager has permission
	if ([TDWatchrLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
		[self.radiusFilterButton setEnabled:NO];
	}else{
		[[TDWatchrLocationManager sharedManager] startUpdatingLocation];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - notification registration

-(void) registerForNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(welcomeScreenDismissed)
												 name:TDWelcomeScreenDismissed object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(pullToRefreshHandler)
												 name:TDWatchrEventDidChangeNotification
											   object:nil];
	
}

-(void) welcomeScreenDismissed{
	[[TDWatchrLocationManager sharedManager] startUpdatingLocation];
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
	
	//first load
	if (_firstRun) {
		[self pullToRefreshHandler];
		_firstRun = NO;
	}
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
	[self pullToRefreshHandler];
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	TDEventDetailsViewController * detailsController = [[UIStoryboard storyboardWithName:@"EventStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
	[detailsController setWatchrEvent:[NSMutableDictionary dictionaryWithDictionary:[_dashboardData objectAtIndex:indexPath.row]]];
	[self.navigationController pushViewController:detailsController animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 84;
}

#pragma mark - UITableViewDataSource Methods

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	TDDashboardEventTableViewCell * cell = (TDDashboardEventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"eventCell"];
	NSDictionary * cellData =[_dashboardData objectAtIndex:indexPath.row];
	
	cell.cellEventTitleLabel.text = [cellData objectForKey:@"event_name"];
	cell.cellEventDescriptionLabel.text = [cellData objectForKey:@"description"];
	
	NSString *distance = [NSString stringWithFormat:@"%.2fkm", [[cellData objectForKey:@"distance"] floatValue]];
	cell.cellEventDistanceLabel.text = distance;
	
	
	//check if the user voted
	if ([[cellData objectForKey:@"user_voted"] boolValue] == YES) {
		switch ([[cellData objectForKey:@"user_vote_value"] integerValue]) {
			case 0:
				cell.cellRatingLabel.textColor = [UIColor lightGrayColor];
				break;
			case 1:
				cell.cellRatingLabel.textColor = [UIColor colorWithRed:0.21 green:0.64 blue:0.36 alpha:1];
				break;
			case -1:
				cell.cellRatingLabel.textColor = [UIColor colorWithRed:0.87 green:0.08 blue:0.13 alpha:1];
				break;
			default:
				cell.cellRatingLabel.textColor = [UIColor lightGrayColor];
				break;
		}
	}else{
			cell.cellRatingLabel.textColor = [UIColor lightGrayColor];
	}
	
	if ([[cellData objectForKey:@"rating"] isKindOfClass:[NSNull class]]) {
		cell.cellRatingLabel.text = @"-";
	}else{
		cell.cellRatingLabel.text = [cellData objectForKey:@"rating"] ;
	}

	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc ]init];;
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate * date = [dateFormatter dateFromString:[cellData objectForKey:@"created_at"]];
	cell.cellTimeLabel.text = [[TDHelperClass sharedHelper] getStringRepresentationForstartDate:date andEndDate:[NSDate date] ];
	cell.cellEventCategoryImageView.image = [UIImage imageNamed:[[cellData objectForKey:@"category"] objectForKey:@"category_icon"]];
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
													
													if (_dashboardMap.userLocationVisible) {
														CLLocationCoordinate2D userLocation = _dashboardMap.userLocation.location.coordinate;
														MKCoordinateRegion adjustedRegion = [_dashboardMap regionThatFits:MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)];
														[_dashboardMap setRegion:adjustedRegion animated:YES];
													}
													
													[[NSOperationQueue new] addOperationWithBlock:^{
														double scale = _dashboardMap.bounds.size.width / _dashboardMap.visibleMapRect.size.width;
														NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:_dashboardMap.visibleMapRect withZoomScale:scale];
														
														[self updateMapViewAnnotationsWithAnnotations:annotations];
													}];
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
	//set the delegate for add event view controller. it must be the first view controller in the stack to refresh the list
	((TDAddEventViewController*)addEventNavigationController.viewControllers[0]).delegate =self;
	
	//present it
	[self presentViewController:addEventNavigationController animated:YES completion:^{
		
	}];
}
#pragma mark - InfiniteScroll + PullToRefresh Handlers
-(void) infiniteScrollHandler{
	_dashboardDataSkip =[_dashboardData count];
	_dashboardFilters.filterSkip = [NSNumber numberWithInteger:_dashboardDataSkip];
	
	NSLog(@"_infiniteScroll: SKIP = %d ; COUNT = %d", [_dashboardFilters.filterSkip intValue], [_dashboardFilters.filterCount intValue] );
	
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/active"]]
				   usingParameters:[_dashboardFilters filtersToDictionary]
					   withAccount:[[NXOAuth2AccountStore sharedStore] accountWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:TDWatchrAPIAccountIdentifier] ]
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
						   
//						    [NSThread detachNewThreadSelector:@selector(buildTreeWithArray:) toTarget:self.coordinateQuadTree withObject:_dashboardData];
						   [self.coordinateQuadTree performSelector:@selector(buildTreeWithArray:) withObject:_dashboardData];
						   [[NSOperationQueue new] addOperationWithBlock:^{
							   double scale = _dashboardMap.bounds.size.width / _dashboardMap.visibleMapRect.size.width;
							   NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:_dashboardMap.visibleMapRect withZoomScale:scale];
							   
							   [self updateMapViewAnnotationsWithAnnotations:annotations];
						   }];
					   }
						
					   [self.dashboardTableView finishInfiniteScroll];
				   }];
}
-(void) pullToRefreshHandler{
	
	//reset skip and get all refresh the last
	_dashboardFilters.filterCount = [NSNumber numberWithInt:_dashboardDataSkip+_dashboardDataCount];
	_dashboardDataSkip = 0;
	_dashboardFilters.filterSkip= [NSNumber numberWithInt:_dashboardDataSkip];
	
	NSLog(@"_pullToRefresh: SKIP = %d ; COUNT = %d", [_dashboardFilters.filterSkip intValue], [_dashboardFilters.filterCount intValue] );
	
	NSLog(@"filters = %@", [_dashboardFilters filtersToDictionary]);
	
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/active"]]
				   usingParameters:[_dashboardFilters filtersToDictionary]
					   withAccount:[[NXOAuth2AccountStore sharedStore] accountWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:TDWatchrAPIAccountIdentifier] ]
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
				   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
					   //				   NSLog(@"response = %@", [response description]);
					   //				   NSLog(@"error = %@", [error userInfo]);
					   
//					   NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding	];
//					   NSLog(@"%@", responseString);
					   
					   if (error) {
						   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving events" message:[[error userInfo] description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
						   [alert show];
					   }else{
						   [_dashboardData removeAllObjects];
						   NSArray * data =[[TDWatchrAPIManager sharedManager] getArrayForKey:@"data" fromResponseData:responseData ];
//						   NSLog(@"data = %@", data);
						   [_dashboardData addObjectsFromArray:data];
						   [self.dashboardTableView reloadData];
						   
//						   [NSThread detachNewThreadSelector:@selector(buildTreeWithArray:) toTarget:self.coordinateQuadTree withObject:_dashboardData];
						   [self.coordinateQuadTree performSelector:@selector(buildTreeWithArray:) withObject:_dashboardData];
						   [[NSOperationQueue new] addOperationWithBlock:^{
							   double scale = _dashboardMap.bounds.size.width / _dashboardMap.visibleMapRect.size.width;
							   NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:_dashboardMap.visibleMapRect withZoomScale:scale];
							   
							   [self updateMapViewAnnotationsWithAnnotations:annotations];
						   }];

					   }

					   [_refreshControl endRefreshing];
				   }];

}


#pragma mark - TDAddEventViewControllerDelegate methods

-(void) controller:(TDAddEventViewController *)addEventViewController didPostEventSuccessfully:(BOOL)success{
	if (success) {
		[self pullToRefreshHandler];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}


#pragma mark - TDWatchrApiManagerDelegate methods

-(void) WatchrAPIManagerDidFinishWithData:(NSArray *)data forKey:(NSString *)key{

}

-(void) WatchrAPIManagerDidFinishWithError:(NSError *)error{
	
}
-(void) WatchrAPIManagerDidFinishWithResponse:(NSURLResponse *)response{
	
}
#pragma mark - Annotation Methods

- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
	
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
	
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:_dashboardMap.annotations];
	[before removeObject:[_dashboardMap userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
	
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
	
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
	
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
	
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_dashboardMap addAnnotations:[toAdd allObjects]];
        [_dashboardMap removeAnnotations:[toRemove allObjects]];
    }];

}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = _dashboardMap.bounds.size.width / _dashboardMap.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
		
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
	if ([annotation isKindOfClass:[MKUserLocation class]]){
		return nil;
	}else{
		static NSString *const TBAnnotatioViewReuseID = @"TBAnnotatioViewReuseID";
		
		TBClusterAnnotationView *annotationView = (TBClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TBAnnotatioViewReuseID];
		
		if (!annotationView) {
			annotationView = [[TBClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TBAnnotatioViewReuseID];
		}
		
		annotationView.canShowCallout = YES;
		if ([annotation isKindOfClass:[TBClusterAnnotation class]]) {
			
			NSInteger  annotationCount = [(TBClusterAnnotation *)annotation count];
			
			if (annotationCount == 1) {
				//the actual event
				annotationView.countLabel.hidden = YES;
				annotationView.count = annotationCount;
				// grab the original image
				UIImage *originalImage = [UIImage imageNamed:[[[_dashboardData objectAtIndex:((TBClusterAnnotation*)annotation).index]objectForKey:@"category"] objectForKey:@"category_icon"]];
				// scaling set to 2.0 makes the image 1/2 the size.
				UIImage *scaledImage =
                [UIImage imageWithCGImage:[originalImage CGImage]
									scale:(originalImage.scale * 1.2)
							  orientation:(originalImage.imageOrientation)];
				
				annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:scaledImage];
				
			}else{
				annotationView.count = annotationCount;
				annotationView.countLabel.hidden = NO;
			}
		}
		
		return annotationView;

	}
	
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}


@end
