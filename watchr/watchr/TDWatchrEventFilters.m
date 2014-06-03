//
//  TDWatchrEventFilters.m
//  watchr
//
//  Created by Tudor Dragan on 3/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDWatchrEventFilters.h"

@implementation TDWatchrEventFilters

-(id) init{
	self = [super init];
	if (self) {
		_filterOrderBy=@"created_at";
		_filterOrderMode =@"DESC";
		_filterSinceId = (NSNumber*)[NSNull null];
		_filterSkip = (NSNumber*)[NSNull null];
		_filterCount = (NSNumber*)[NSNull null];
		_filterGeocode = (NSString*)[NSNull null];
	}
	return self;
}

-(void) setFilterGeocodeWithLatitude:(double)latitude longitude:(double) longitude andRadius:(double) radius{
	_filterGeocode=[NSString stringWithFormat:@"%lf,%lf,%lf", latitude,longitude,radius];
}

-(NSDictionary*) filtersToDictionary{
	return [NSDictionary dictionaryWithObjects:@[_filterOrderBy,
												 _filterOrderMode,
												 _filterSinceId,
												 _filterSkip,
												 _filterCount,
												 _filterGeocode,
												 ]
									   forKeys:@[@"order_by",
												 @"order_mode",
												 @"since_id",
												 @"skip",
												 @"count",
												 @"geocode"
												 ]];
}

@end
