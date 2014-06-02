//
//  NSNull+TDJSON.h
//  watchr
//
//  Created by Tudor Dragan on 2/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (TDJSON)

- (NSUInteger)length;

- (int) intValue;

- (NSInteger)integerValue ;

- (float)floatValue;

- (NSString *)description;

- (NSArray *)componentsSeparatedByString:(NSString *)separator;

- (id)objectForKey:(id)key;

- (BOOL)boolValue ;

@end
