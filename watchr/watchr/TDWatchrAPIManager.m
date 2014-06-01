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

-(NSArray* ) getCountryListForRequestingObject:(id)requester{
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/country/all"]]
				   usingParameters:nil
					   withAccount:_defaultWatchrAccount
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
               responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
				   NSLog(@"response = %@", [response description]);
				   NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
				   NSLog(@"responseData = %@", responseString);
				   NSLog(@"error = %@", [error userInfo]);
				   				   
				   NSError * JSONParsingError = [[NSError alloc] init];
				   id JSONObject = [NSJSONSerialization
									JSONObjectWithData:responseData
									options:NSJSONReadingMutableContainers
									error:&JSONParsingError];
				   
				   NSLog(@"%@",JSONObject);

               }];
	return nil;
}

-(NSArray*) getAllActiveEventsWithFilters:(NSDictionary*)filters forRequestingObject:(id) requester{
	return nil;
}

@end
