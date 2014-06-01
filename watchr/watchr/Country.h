//
//  Country.h
//  watchr
//
//  Created by Tudor Dragan on 1/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Country : NSManagedObject

@property (nonatomic, retain) NSNumber * country_id;
@property (nonatomic, retain) NSString * iso2;
@property (nonatomic, retain) NSString * short_name;
@property (nonatomic, retain) NSString * long_name;
@property (nonatomic, retain) NSString * iso3;
@property (nonatomic, retain) NSNumber * numcode;
@property (nonatomic, retain) NSString * un_member;
@property (nonatomic, retain) NSNumber * calling_code;
@property (nonatomic, retain) NSString * cctld;

@end
