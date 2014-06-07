//
//  TDWatchrLocationManager.h
//  watchr
//
//  Created by Tudor Dragan on 7/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface TDWatchrLocationManager : CLLocationManager

+(TDWatchrLocationManager*) sharedManager;

@end
