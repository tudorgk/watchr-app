//
//  TDFirstRunManager.h
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol TDFirstRunManagerDelegate <NSObject>

-(void) managerDidFinishFirstTimeSetUpWithData:(id) data;

@end

@interface TDFirstRunManager : NSObject
@property (nonatomic, assign) id<TDFirstRunManagerDelegate> delegate;

+(TDFirstRunManager*) sharedManager;
-(void) runFirstTimeSetUp;

@end
