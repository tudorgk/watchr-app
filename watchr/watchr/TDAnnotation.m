//
//  TDAnnotation.m
//  watchr
//
//  Created by Tudor Dragan on 9/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDAnnotation.h"

@implementation TDAnnotation

- (id) init{
	self = [super init];
	if (self) {
		_title = @"";
		_subtitle = @"";
		_coordinate = CLLocationCoordinate2DMake(44.426783, 26.104374);
	}
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate title:(NSString*)newTitle andAddress:(NSString*) address{
    
    self = [super init];
    if (self != nil){
        _coordinate = newCoordinate;
        _title = newTitle;
        _subtitle = address;
    }
    return(self);
}

- (NSString *)title {
    return _title;
}

- (NSString *)subtitle {
    [NSString stringWithFormat:@"Latitude: %.4f, Longitude: %.4f", _coordinate.latitude, _coordinate.longitude];
    return _subtitle;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

@end
