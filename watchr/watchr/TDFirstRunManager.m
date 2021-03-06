//
//  TDFirstRunManager.m
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDFirstRunManager.h"
#import "Country.h"
#import "TDWelcomeScreenViewController.h"
@class TDFirstRunManager;

@interface TDFirstRunManager()<TDWatchrAPIManagerDelegate>{
	BOOL _countriesFinished;
	BOOL _activeEventsFinished;
	NSArray *_activeEvents;
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
		_countriesFinished = _activeEventsFinished = NO;
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
	
	
	//add default values for first run to standard user defaults
	NSDictionary * defaultFilters = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WatchrEventDefaultFilters" ofType:@"plist"]];

	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[defaultFilters objectForKey:TDDefaultOrderByKey] forKey:TDDefaultOrderByKey];
	[userDefaults setObject:[defaultFilters objectForKey:TDDefaultOrderModeKey] forKey:TDDefaultOrderModeKey];
	[userDefaults setObject:[defaultFilters objectForKey:TDDefaultRadiusKey] forKey:TDDefaultRadiusKey];
	[userDefaults synchronize];
	
	TDWatchrEventFilters * filters = [[TDWatchrEventFilters alloc] init];
	filters.filterOrderBy = [defaultFilters objectForKey:TDDefaultOrderByKey];
	filters.filterOrderMode = [defaultFilters objectForKey:TDDefaultOrderModeKey];
	filters.filterCount = [NSNumber numberWithInt:20];
	filters.filterSkip = [NSNumber numberWithInt:0];
	//[[TDWatchrAPIManager sharedManager] getAllActiveEventsWithFilters:filters delegate:self];
	
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

-(void) WatchrAPIManagerDidFinishWithData:(NSArray *)data forKey:(NSString *)key{
	//if the data has the country_list
	if ([key isEqualToString:kTDWatchrManagerCountryKey]) {
		
		NSArray * countryList = data;
		
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
			
		_countriesFinished = YES;
		
	}
//	else if([key isEqualToString:kTDWatchrManagerActiveEventsKey]){
//		//For active events just return them to the owner of the first run manager
//		_activeEvents = (NSArray*)data;
//		_activeEventsFinished =YES;
//	}
//	
	if (_countriesFinished) {
		if(self.delegate!=nil){
			if([self.delegate respondsToSelector:@selector(managerDidFinishFirstTimeSetUpWithData:)])
				[self.delegate managerDidFinishFirstTimeSetUpWithData:nil];
		}
		
		[[TDWelcomeScreenViewController sharedWelcomeScreen] dismissWelcomeScreen:self animated:YES];

	}
}

-(void) WatchrAPIManagerDidFinishWithError:(NSError *)error{
	
	NSLog(@"error = %@ and description =%@", [error userInfo], [error description]);
}

-(void) WatchrAPIManagerDidFinishWithResponse:(NSURLResponse *) response{
	
}

@end
