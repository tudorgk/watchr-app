//
//  TDAnnotation.h
//  watchr
//
//  Created by Tudor Dragan on 9/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@interface TDAnnotation : NSObject <MKAnnotation>{
    CLLocationCoordinate2D _coordinate;
    NSString * _address;
    NSString * _title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSNumber *locationId;

- (id)init;
- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate title:(NSString*)newTitle andAddress:(NSString*) address;

@end
