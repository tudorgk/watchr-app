//
//  NSNull+TDJSON.m
//  watchr
//
//  Created by Tudor Dragan on 2/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "NSNull+TDJSON.h"


@interface NSNull (JSON)
@end

@implementation NSNull (JSON)

- (NSUInteger)length { return 0; }

- (NSInteger)integerValue { return 0; };

- (int)intValue { return 0; };

- (float)floatValue { return 0; };

- (NSString *)description { return @"0(NSNull)"; }

- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }

- (id)objectForKey:(id)key { return nil; }

- (BOOL)boolValue { return NO; }

@end