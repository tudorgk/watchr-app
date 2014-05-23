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
typedef enum MapViewVisibility : NSInteger MapViewVisibility;
enum MapViewVisibility : NSInteger {
	MapViewVisibilityHidden,
	MapViewVisibilityShown
};

@interface TDDashboardViewController (){
	MapViewVisibility _mapState;
	MKMapView * _dashboardMap;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
    // Do any additional setup after loading the view.
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
@end
