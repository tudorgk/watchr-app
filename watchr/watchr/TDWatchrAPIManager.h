//
//  TDWatchrAPIManager.h
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDWatchrEventFilters.h"
@protocol TDWatchrAPIManagerDelegate <NSObject>

-(void) WatchrAPIManagerDidFinishWithData:(NSArray *) data forKey:(NSString*) key;
-(void) WatchrAPIManagerDidFinishWithResponse:(NSURLResponse *) response;
-(void) WatchrAPIManagerDidFinishWithError:(NSError *) error;

@end

@interface TDWatchrAPIManager : NSObject
@property (nonatomic,strong) NXOAuth2Account * defaultWatchrAccount;
+(TDWatchrAPIManager *) sharedManager;

-(void) getAllActiveEventsWithFilters:(TDWatchrEventFilters*)filters delegate:(id<TDWatchrAPIManagerDelegate>) delegate;
-(void) getCountryListWithDelegate:(id<TDWatchrAPIManagerDelegate>) delegate;
-(NSArray*) getArrayForKey:(NSString*) key fromResponseData:(NSData*)responseData;
@end
