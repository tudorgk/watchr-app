//
//  TDDashboardViewController.h
//  watchr
//
//  Created by Tudor Dragan on 19/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UIView+Origami.h"
#import "TDDashboardEventTableViewCell.h"
#import "TDDashboardFilterButton.h"
#import "TDWelcomeScreenViewController.h"
#import "ActionSheetCustomPicker.h"
#import "TDWatchrLocationManager.h"
#import	"TDAddEventViewController.h"

@interface TDDashboardViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,TDWatchrAPIManagerDelegate,ActionSheetCustomPickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate,TDAddEventViewControllerDelegate>{
	
	TDWatchrLocationManager * _locationManager;
	UIRefreshControl * _refreshControl;
	
	BOOL _firstRun;

}
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UITableView *dashboardTableView;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
- (IBAction)mapButtonPressed:(id)sender;
- (IBAction)menuButtonPressed:(id)sender;
-(IBAction)addButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet TDDashboardFilterButton *radiusFilterButton;
@property (weak, nonatomic) IBOutlet TDDashboardFilterButton *sortingFilterButton;
@property (weak, nonatomic) IBOutlet TDDashboardFilterButton *tagFilterButton;

- (IBAction)radiusFilterButtonPressed:(id)sender;
- (IBAction)orderByButtonPressed:(id)sender;
- (IBAction)orderModeButtonPressed:(id)sender;

@end
