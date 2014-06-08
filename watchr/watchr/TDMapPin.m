//
//  TDMapPin.m
//  watchr
//
//  Created by Tudor Dragan on 8/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDMapPin.h"

@implementation TDMapPin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    if (self != nil) {
        _coordinate = location;
        _title = placeName;
        _subtitle = description;
	}
    return self;
}




@end