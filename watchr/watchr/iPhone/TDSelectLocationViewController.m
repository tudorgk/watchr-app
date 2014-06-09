//
//  TDSelectLocationViewController.m
//  watchr
//
//  Created by Tudor Dragan on 9/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDSelectLocationViewController.h"

@interface TDSelectLocationViewController (){
	BOOL _userLocationSelected;
}
-(void) configureView;
@end

@implementation TDSelectLocationViewController

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

}

-(void) configureView{
	self.title = @"Event Position";
	_userLocationSelected = YES;
	
	[self.mapSelectorMapView setDelegate:self];
	
	//instantiate the geocoder
	if (_geocoder == nil) {
		_geocoder = [[CLGeocoder alloc] init];
	}
	
	if (_selectedPointAnnotation == nil) {
		_selectedPointAnnotation = [[TDAnnotation alloc] init];
		_selectedPointAnnotation.coordinate = self.mapSelectorMapView.userLocation.location.coordinate;
		_selectedPointAnnotation.title = @"watchr event";
		
		MKCoordinateRegion adjustedRegion = [self.mapSelectorMapView regionThatFits:MKCoordinateRegionMakeWithDistance(_selectedPointAnnotation.coordinate, 400, 400)];
		[self.mapSelectorMapView setRegion:adjustedRegion animated:YES];

		[self.mapSelectorMapView addAnnotation:_selectedPointAnnotation];
		[_geocoder reverseGeocodeLocation:self.mapSelectorMapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
			if (error) {
				UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error updating location" message:@"Check if you have location services turned om" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
				[alert show	];
				_selectedPointAnnotation.subtitle =@"";
			}else{
				CLPlacemark * placemark = [placemarks firstObject];
				_selectedPointAnnotation.subtitle = placemark.name;
			}
		}];
	}
	
	
	//adding long press gesture recognizer
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.25; //user needs to press for 2 seconds
    [self.mapSelectorMapView addGestureRecognizer:lpgr];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Gesture Handler Method

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
	//change the user location to off
	[self.userLocationBarButtonItem setImage:[UIImage imageNamed:@"user-location-off.png"]];
	_userLocationSelected = NO;
	
	
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
	
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapSelectorMapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapSelectorMapView convertPoint:touchPoint toCoordinateFromView:self.mapSelectorMapView];
    _selectedPointAnnotation.coordinate =touchMapCoordinate;
    
	if (_selectedAnnotationView == nil) {
		_selectedAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:_selectedPointAnnotation reuseIdentifier:@"point"];
		[self.mapSelectorMapView removeAnnotation:_selectedPointAnnotation];
		[self.mapSelectorMapView addAnnotation:_selectedPointAnnotation];
	}else{
		[self.mapSelectorMapView removeAnnotation:_selectedPointAnnotation];
		[_selectedPointAnnotation setCoordinate:touchMapCoordinate];
		[self.mapSelectorMapView addAnnotation:_selectedPointAnnotation];
	}
	
	CLLocation * selectedLocation = [[CLLocation alloc] initWithLatitude:_selectedPointAnnotation.coordinate.latitude longitude:_selectedPointAnnotation.coordinate.longitude];
	[_geocoder reverseGeocodeLocation:selectedLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error updating location" message:@"Check if you have location services turned om" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			[alert show	];
			_selectedPointAnnotation.subtitle =@"";
		}else{
			CLPlacemark * placemark = [placemarks firstObject];
			_selectedPointAnnotation.subtitle = placemark.name;
		}
	}];
	
}

#pragma mark
#pragma mark MK MapView Annotation Delegates


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
	//    NSLog(@"%@", views);
    
    for(MKAnnotationView * annotation in views){
        [annotation setSelected:YES animated:YES];
    }
}
- (MKAnnotationView *)mapView:(MKMapView *)myMapView viewForAnnotation:(id < MKAnnotation >)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[self.mapSelectorMapView dequeueReusableAnnotationViewWithIdentifier:@"point"];
    if(pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"point"] ;
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        pinView.draggable = YES;
    } else {
        pinView.annotation = annotation;
		
    }
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
	
    switch (oldState) {
        case MKAnnotationViewDragStateStarting:
            [annotationView setSelected:NO animated:NO];
            break;
            
        default:
            break;
    }
    
    switch (newState) {
        case MKAnnotationViewDragStateEnding:
        {
            CLLocation * selectedLocation = [[CLLocation alloc] initWithLatitude:_selectedPointAnnotation.coordinate.latitude longitude:_selectedPointAnnotation.coordinate.longitude];
			[_geocoder reverseGeocodeLocation:selectedLocation completionHandler:^(NSArray *placemarks, NSError *error) {
				if (error) {
					UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error updating location" message:@"Check if you have location services turned om" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
					[alert show	];
					_selectedPointAnnotation.subtitle =@"";
				}else{
					CLPlacemark * placemark = [placemarks firstObject];
					_selectedPointAnnotation.subtitle = placemark.name;
				}
			}];
            [annotationView setSelected:YES animated:YES];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - Actions
- (IBAction)userLocationBarButtonItemPressed:(id)sender {
	
	//change the user location to off
	[self.userLocationBarButtonItem setImage:[UIImage imageNamed:@"user-location-on.png"]];
	_userLocationSelected = YES;
	_selectedPointAnnotation.coordinate =self.mapSelectorMapView.userLocation.coordinate;
    
	if (_selectedAnnotationView == nil) {
		_selectedAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:_selectedPointAnnotation reuseIdentifier:@"point"];
		[self.mapSelectorMapView removeAnnotation:_selectedPointAnnotation];
		[self.mapSelectorMapView addAnnotation:_selectedPointAnnotation];
	}else{
		[self.mapSelectorMapView removeAnnotation:_selectedPointAnnotation];
		[self.mapSelectorMapView addAnnotation:_selectedPointAnnotation];
	}
	
	CLLocation * selectedLocation = [[CLLocation alloc] initWithLatitude:_selectedPointAnnotation.coordinate.latitude longitude:_selectedPointAnnotation.coordinate.longitude];
	[_geocoder reverseGeocodeLocation:selectedLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error) {
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error updating location" message:@"Check if you have location services turned om" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			[alert show	];
			_selectedPointAnnotation.subtitle =@"";
		}else{
			CLPlacemark * placemark = [placemarks firstObject];
			_selectedPointAnnotation.subtitle = placemark.name;
		}
	}];
	MKCoordinateRegion adjustedRegion = [self.mapSelectorMapView regionThatFits:MKCoordinateRegionMakeWithDistance(_selectedPointAnnotation.coordinate, 400, 400)];
	[self.mapSelectorMapView setRegion:adjustedRegion animated:YES];

}

- (IBAction)doneButtonPressed:(id)sender {
	
	if(_delegate!=nil){
		if([_delegate respondsToSelector:@selector(controller:diSelectAnnotation:sameAsUserLocation:)]){
			if (_userLocationSelected) {
				[_delegate controller:self diSelectAnnotation:_selectedPointAnnotation sameAsUserLocation:YES];
			}else{
				[_delegate controller:self diSelectAnnotation:_selectedPointAnnotation sameAsUserLocation:NO];
			}
		}
	}
}
@end
