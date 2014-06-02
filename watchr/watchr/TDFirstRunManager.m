//
//  TDFirstRunManager.m
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDFirstRunManager.h"
#import "Country.h"
#import "NSNull+TDJSON.h"
@class TDFirstRunManager;

@interface TDFirstRunManager()<TDWatchrAPIManagerDelegate>{

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
	
	[[TDWatchrAPIManager sharedManager] getCountryListWithDelegate:self];
	[[TDWatchrAPIManager sharedManager] getAllActiveEventsWithFilters:nil delegate:self];
	
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

#pragma mark - TDWatchrAPIManagerDelegate

-(void) WatchrAPIManagerDidFinishWithData:(NSDictionary *)data{
	//if the data has the country_list
	if ([[data allKeys] containsObject:@"country_list"]) {
		
		NSArray * countryList = [data objectForKey:@"country_list"];
		
		for (NSDictionary * country in countryList) {
			Country *newCountryRecord = (Country *)[[udevCoreDataHelper sharedInstance] insertObjectForEntity:@"Country"];
			
			newCountryRecord.country_id = [NSNumber numberWithInt:[[country objectForKey:@"country_id"]intValue]];
			newCountryRecord.calling_code = [NSNumber numberWithInt:[[country objectForKey:@"calling_code"]intValue]];
			newCountryRecord.cctld	= [country objectForKey:@"cctld"] ;
			newCountryRecord.iso2 = [country objectForKey:@"iso2"] ;
			newCountryRecord.iso3 = [country objectForKey:@"iso3"] ;
			newCountryRecord.short_name	= [country objectForKey:@"short_name"] ;
			newCountryRecord.long_name = [country objectForKey:@"long_name"] ;
			newCountryRecord.numcode = [NSNumber numberWithInt:[[country objectForKey:@"numcode"]intValue]];
			newCountryRecord.un_member = [country objectForKey:@"un_member"] ;

		}
		
		[[udevCoreDataHelper sharedInstance] saveContextForCurrentThread];

	}
	
	//display the core data records to check if it works.
	 NSArray *coreDataCountries = [[udevCoreDataHelper sharedInstance] getObjectsForEntity:@"Country" withPredicate:nil andSortDescriptors:nil];
	for (Country * country in coreDataCountries) {
		NSLog(@"country_name = %@", country.long_name);
	}//it works!
	
}

-(void) WatchrAPIManagerDidFinishWithError:(NSError *)error{
	
}

@end
