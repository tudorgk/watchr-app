//
//  TDWatchrAPIManager.h
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDWatchrAPIManagerDelegate <NSObject>

@optional
-(void) WatchrAPIManagerDidFinishWithData:(NSDictionary *) data;
-(void) WatchrAPIManagerDidFinishWithResponse:(NSURLResponse *) response;
-(void) WatchrAPIManagerDidFinishWithError:(NSError *) error;

@end

@interface TDWatchrAPIManager : NSObject

+(TDWatchrAPIManager *) sharedManager;

-(void) getAllActiveEventsWithFilters:(NSDictionary*)filters delegate:(id<TDWatchrAPIManagerDelegate>) delegate;
-(void) getCountryListWithDelegate:(id<TDWatchrAPIManagerDelegate>) delegate;
@end
