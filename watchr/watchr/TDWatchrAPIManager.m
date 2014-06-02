//
//  TDWatchrAPIManager.m
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDWatchrAPIManager.h"
@class TDWatchrAPIManager;
@interface TDWatchrAPIManager(){
	NXOAuth2Account * _defaultWatchrAccount;
}

@end
@implementation TDWatchrAPIManager

#pragma mark -
#pragma mark Singleton
static TDWatchrAPIManager * sharedManager = nil;
+(TDWatchrAPIManager *) sharedManager {
    @synchronized(self) {
        if(sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}


-(id) init{
	self = [super init];
	if (self) {
		_defaultWatchrAccount = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:TDWatchrAPIAccountIdentifier] ];
	}
	return self;
}

-(void ) getCountryListWithDelegate:(id<TDWatchrAPIManagerDelegate>)delegate{
	
	__block NSArray * countryArray = nil;
	
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/country/all"]]
				   usingParameters:nil
					   withAccount:_defaultWatchrAccount
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
               responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
//				   NSLog(@"response = %@", [response description]);
//				   NSLog(@"error = %@", [error userInfo]);
				   
				   if (error) {
					   [delegate WatchrAPIManagerDidFinishWithError:error];
				   }
				   
				   [delegate WatchrAPIManagerDidFinishWithResponse:response];
				   
				   countryArray = [self getArrayForKey:@"data" fromResponseData:responseData withResponse:response andError:error];
				   [delegate WatchrAPIManagerDidFinishWithData:@{@"country_list" : countryArray}];
               }];
	
	
}



-(void ) getAllActiveEventsWithFilters:(NSDictionary *)filters delegate:(id<TDWatchrAPIManagerDelegate>)delegate{
	
	//TODO: Parameters are nil for testing
	
	__block NSArray * activeEventsArray = nil;
	
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/active"]]
				   usingParameters:nil
					   withAccount:_defaultWatchrAccount
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
				   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
					   //				   NSLog(@"response = %@", [response description]);
					   //				   NSLog(@"error = %@", [error userInfo]);
					   
					   if (error) {
						   [delegate WatchrAPIManagerDidFinishWithError:error];
					   }
					   
					   [delegate WatchrAPIManagerDidFinishWithResponse:response];
					   
					   activeEventsArray = [self getArrayForKey:@"data" fromResponseData:responseData withResponse:response andError:error];
					   [delegate WatchrAPIManagerDidFinishWithData:@{@"active_events" : activeEventsArray}];
				   }];


}

-(NSArray*) getArrayForKey:(NSString*) key fromResponseData:(NSData*)responseData withResponse:(NSURLResponse*) response andError:(NSError* ) error{
	NSError * JSONParsingError = nil;
	id JSONObject = [NSJSONSerialization
					 JSONObjectWithData:responseData
					 options:NSJSONReadingMutableContainers
					 error:&JSONParsingError];
	
	if (JSONParsingError) {
		return nil;
	}else if (error){
		//TODO: Display the error using delegate methods
		return nil;
	}
	
	return [JSONObject objectForKey:key];

}

@end
