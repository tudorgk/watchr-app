//
//  TDEventDetailsDataSourceManager.h
//  watchr
//
//  Created by Tudor Dragan on 16/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	TDEventActiveDataSourceDetails = 0,
	TDEventActiveDataSourceComments = 1,
	TDEventActiveDataSourceFollowers = 2
} TDEventActiveDataSource;

@interface TDEventDetailsDataSourceManager : NSObject

@property (nonatomic,assign) TDEventActiveDataSource activeDataSource;

@end
