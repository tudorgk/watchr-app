//
//  TDHelperClass.h
//  watchr
//
//  Created by Tudor Dragan on 9/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDHelperClass : NSObject

+(void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay ;

@end
