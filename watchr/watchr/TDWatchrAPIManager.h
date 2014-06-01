//
//  TDWatchrAPIManager.h
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDWatchrAPIManager : NSObject

+(TDWatchrAPIManager *) sharedManager;

-(NSArray*) getAllActiveEventsWithFilters:(NSDictionary*)filters forRequestingObject:(id) requester;
-(NSArray*) getCountryListForRequestingObject:(id) requester;
@end
