//
//  TDAddEventViewController.h
//  watchr
//
//  Created by Tudor Dragan on 29/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class TDAddEventViewController;
@protocol TDAddEventViewControllerDelegate <NSObject>

-(void) controller:(TDAddEventViewController*) addEventViewController didPostEventSuccessfully:(BOOL) success;

@end
@interface TDAddEventViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UITextFieldDelegate>{
	MKPointAnnotation * _watchrEventPoint;
	CLGeocoder * _geocoder;
	
//	MRProgressOverlayView *_progressView;
	UIWindow * _window;
}
@property (weak, nonatomic) IBOutlet UITableView *addEventTableView;
@property (nonatomic, assign) id<TDAddEventViewControllerDelegate> delegate;
-(void) dismissKeyboard:(id)sender;
-(void) submitWatchrEventToServer;
@end
