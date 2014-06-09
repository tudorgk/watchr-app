//
//  TDSelectLocationViewController.h
//  watchr
//
//  Created by Tudor Dragan on 9/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TDAnnotation.h"
#import <QuartzCore/QuartzCore.h>
@class TDSelectLocationViewController;
@protocol TDSelectLocationViewControllerDelegate <NSObject>

-(void)controller:(TDSelectLocationViewController*) selectionController diSelectAnnotation:(TDAnnotation*) annotation sameAsUserLocation:(BOOL) sameAsUserLocation;

@end

@interface TDSelectLocationViewController : UIViewController<MKMapViewDelegate>{
	CLGeocoder * _geocoder;
	TDAnnotation * _selectedPointAnnotation;
	MKPinAnnotationView * _selectedAnnotationView;
}
@property (nonatomic,assign) id<TDSelectLocationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet MKMapView *mapSelectorMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *userLocationBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBarButtonItem;
- (IBAction)userLocationBarButtonItemPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
