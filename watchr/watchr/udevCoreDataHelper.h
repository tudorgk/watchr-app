#if !__has_feature(objc_arc)
#warning ARC is required for udevCoreDataHelper
#endif

#ifndef CORE_DATA_HELPER_H
#define CORE_DATA_HELPER_H

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface udevCoreDataHelper : NSObject

@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSManagedObjectContext *context;

/**
 Get singleton object
 */
+(udevCoreDataHelper *)sharedInstance;


/**
 Get the context used in the current thread
 */
-(NSManagedObjectContext *)getContextForCurrentThread;


/**
 Initialize Core Data
 */
-(void)initializeCoreDataWithModelName:(NSString *)name;


/**
 Save changes made in the current thread
 */
-(void)saveContextForCurrentThread;


/**
 Release the context for the current thread
 Important! Must be called after finishing all Core Data operations on a specific thread
 */
-(void)destroyContextForCurrentThread __attribute__((deprecated));


/**
 Insert object
 The inserted object is returned by the function
 */
-(NSManagedObject*)insertObjectForEntity:(NSString*)entity;


/**
 Get objects from a specific entity
 predicate and sortKey values can be nil
 */
-(NSMutableArray *)getObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending;

/** 
 * Get objects from a specific entity with a sort descriptor
 */
-(NSMutableArray *)getObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescription;


/**
 Delete objects for a specific Entity
 predicate can be nil
 */
-(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;

/**
 Delete a managed object
 */

-(void)deleteObject:(NSManagedObject *)object;

/**
 Number of objects in a specific entity
 predicate can be nil
 */
-(NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate;

@end
#endif