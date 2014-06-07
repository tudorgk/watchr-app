//
//  TDWatchrLocationManager.m
//  watchr
//
//  Created by Tudor Dragan on 7/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDWatchrLocationManager.h"

@implementation TDWatchrLocationManager


#pragma mark -
#pragma mark Singleton
static TDWatchrLocationManager * sharedManager = nil;
+(TDWatchrLocationManager*) sharedManager {
    @synchronized(self) {
        if(sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

-(id)init{
	self = [super init];
	if (self) {
		
	}
	return self;
}

@end
