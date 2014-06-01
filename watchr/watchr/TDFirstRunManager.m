//
//  TDFirstRunManager.m
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDFirstRunManager.h"
@class TDFirstRunManager;

@interface TDFirstRunManager(){

}

-(BOOL) firstSetupDidFinish;

@end

@implementation TDFirstRunManager
#pragma mark -
#pragma mark Singleton
static TDFirstRunManager * sharedManager = nil;
+(TDFirstRunManager *) sharedManager {
    @synchronized(self) {
        if(sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}


-(id) init{
	self = [super init];
	if (self) {
		
	}
	return self;
}

-(BOOL) firstSetupDidFinish{
	//TODO
	return NO;
}

-(void) runFirstTimeSetUp{
	//get the counties
	[self initCoreDataHelper];
	
	[[TDWatchrAPIManager sharedManager] getCountryListForRequestingObject:self];
}

#pragma mark - Core Data Methods

#pragma mark Init
-(void)initCoreDataHelper
{
    udevCoreDataHelper * coreDataHelper = [udevCoreDataHelper sharedInstance];
    [coreDataHelper initializeCoreDataWithModelName:@"WatchrDB"];
    
    //TODO: make states
    [coreDataHelper deleteAllObjectsForEntity:@"Country" withPredicate:nil];
}

@end
