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
		_filterSinceId = nil;
		_filterSkip = nil;
		_filterCount = nil;
		_filterGeocode = nil;
	}
	return self;
}

-(void) setFilterGeocodeWithLatitude:(double)latitude longitude:(double) longitude andRadius:(double) radius{
	_filterGeocode=[NSString stringWithFormat:@"%lf,%lf,%lf", latitude,longitude,radius];
}

-(NSDictionary*) filtersToDictionary{
	
	NSMutableDictionary * filterDict = [NSMutableDictionary new];
	
	if(_filterOrderBy !=nil)
		[filterDict setObject:_filterOrderBy forKey:@"order_by"];
	if(_filterOrderMode !=nil)
		[filterDict setObject:_filterOrderMode forKey:@"order_mode"];
	if(_filterSinceId !=nil)
		[filterDict setObject:_filterSinceId forKey:@"since_id"];
	if(_filterSkip !=nil)
		[filterDict setObject:_filterSkip forKey:@"skip"];
	if(_filterCount !=nil)
		[filterDict setObject:_filterCount forKey:@"count"];
	if(_filterGeocode !=nil)
		[filterDict setObject:_filterGeocode forKey:@"geocode"];

	return filterDict;
}

@end
