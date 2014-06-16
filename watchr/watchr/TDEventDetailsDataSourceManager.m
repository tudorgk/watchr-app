//
//  TDEventDetailsDataSourceManager.m
//  watchr
//
//  Created by Tudor Dragan on 16/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDEventDetailsDataSourceManager.h"

@implementation TDEventDetailsDataSourceManager

-(id) init{
	self = [super init];
	if (self) {
		_activeDataSource = TDEventActiveDataSourceFollowers;
		NSLog(@"activeDataSource = %d", self.activeDataSource);
	}
	return self;
}

@end
