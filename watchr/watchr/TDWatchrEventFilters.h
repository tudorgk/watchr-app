//
//  TDWatchrEventFilters.h
//  watchr
//
//  Created by Tudor Dragan on 3/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDWatchrEventFilters : NSObject

@property (nonatomic,strong) NSString * filterOrderBy;
@property (nonatomic,strong) NSString * filterOrderMode;
@property (nonatomic,strong) NSNumber * filterSinceId;
@property (nonatomic,strong) NSNumber * filterSkip;
@property (nonatomic,strong) NSNumber * filterCount;
@property (nonatomic,strong) NSString * filterGeocode;


-(void) setFilterGeocodeWithLatitude:(double)latitude longitude:(double) longitude andRadius:(double) radius;
-(NSDictionary*) filtersToDictionary;

@end
