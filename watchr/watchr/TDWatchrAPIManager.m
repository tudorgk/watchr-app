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
					   if(delegate!=nil){
						   if([delegate respondsToSelector:@selector(WatchrAPIManagerDidFinishWithError:)])
							   [delegate WatchrAPIManagerDidFinishWithError:error];
						   return ;
					   }
				   }
				   
				   if(delegate!=nil){
					   if([delegate respondsToSelector:@selector(WatchrAPIManagerDidFinishWithResponse:)])
						   [delegate WatchrAPIManagerDidFinishWithResponse:response];
				   }
				   countryArray = [self getArrayForKey:@"data" fromResponseData:responseData ];
				   if(delegate!=nil){
					   if([delegate respondsToSelector:@selector(WatchrAPIManagerDidFinishWithData:forKey:)])
						   [delegate WatchrAPIManagerDidFinishWithData:countryArray forKey:kTDWatchrManagerCountryKey];
				   }
               }];
	
	
}



-(void ) getAllActiveEventsWithFilters:(TDWatchrEventFilters *)filters delegate:(id<TDWatchrAPIManagerDelegate>)delegate{

	__block NSArray * activeEventsArray = nil;
		
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/active"]]
				   usingParameters:[filters filtersToDictionary]
					   withAccount:_defaultWatchrAccount
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
				   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
					   //				   NSLog(@"response = %@", [response description]);
					   //				   NSLog(@"error = %@", [error userInfo]);
					   
					   if(error) {
						   if(delegate!=nil){
							   if([delegate respondsToSelector:@selector(WatchrAPIManagerDidFinishWithError:)])
								   [delegate WatchrAPIManagerDidFinishWithError:error];
							   return ;
						   }
					   }
					   
					   if(delegate!=nil){
							   if([delegate respondsToSelector:@selector(WatchrAPIManagerDidFinishWithResponse:)])
								   [delegate WatchrAPIManagerDidFinishWithResponse:response];
					   }
					   
					   activeEventsArray = [self getArrayForKey:@"data" fromResponseData:responseData ];
					   
					   if(delegate!=nil){
						   if([delegate respondsToSelector:@selector(WatchrAPIManagerDidFinishWithData:forKey:)])
							   [delegate WatchrAPIManagerDidFinishWithData:activeEventsArray forKey:kTDWatchrManagerActiveEventsKey];
					   }
					   
				   }];


}

-(NSArray*) getArrayForKey:(NSString*) key fromResponseData:(NSData*)responseData{
	NSError * JSONParsingError = nil;
	id JSONObject = [NSJSONSerialization
					 JSONObjectWithData:responseData
					 options:NSJSONReadingMutableContainers
					 error:&JSONParsingError];
	
	if (JSONParsingError) {
		return nil;
	}
	
	return [JSONObject objectForKey:key];

}

@end
