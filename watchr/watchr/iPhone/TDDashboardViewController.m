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
	
}
-(void) configureView;
@end

@implementation TDDashboardViewController

#pragma mark - Initialisation Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_mapState= MapViewVisibilityHidden;
		
				
    }
    return self;
}

-(void)awakeFromNib{
	 self.title = @"Dashboard";
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
	//	NSLog(@"accounts = %@", [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"watchrAPI"]);
	//	for (NXOAuth2Account * account in [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"watchrAPI"]) {
	//		[[NXOAuth2AccountStore sharedStore] removeAccount:account];
	//	}
	
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
	[self.tagFilterButton setCustomTitle:@"Accid." forControlState:UIControlStateNormal];

	

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	TDEventDetailsViewController * detailsController = [[UIStoryboard storyboardWithName:@"EventStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
	[self.navigationController pushViewController:detailsController animated:YES];
	
}

#pragma mark - UITableViewDataSource Methods

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	TDDashboardEventTableViewCell * cell = (TDDashboardEventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"eventCell"];
	return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 10;
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

-(void) managerDidFinishFirstTimeSetUpWithData:(id)data{
	[_welcomeScreen dismissViewControllerAnimated:YES completion:nil];
}


@end
