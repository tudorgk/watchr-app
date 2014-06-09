//
//  TDHelperClass.m
//  watchr
//
//  Created by Tudor Dragan on 9/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDHelperClass.h"

@implementation TDHelperClass

+(void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
