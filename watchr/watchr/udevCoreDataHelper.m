#import "udevCoreDataHelper.h"

@interface udevCoreDataHelper()
{
    NSThread *autoreleaseThread;
    
    NSMutableArray *_threadArray;
    NSMutableDictionary *_contexts;
}

@end

@implementation udevCoreDataHelper

static udevCoreDataHelper *sharedInstance = nil;

+(udevCoreDataHelper *)sharedInstance
{
    if(!sharedInstance)
        sharedInstance = [[udevCoreDataHelper alloc] init];
    
    return sharedInstance;
}

-(void)initializeCoreDataWithModelName:(NSString *)name
{
    
    //Init model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"momd"];

    self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    //Init store coordinator
    NSString *sqliteFileName = [NSString stringWithFormat:@"%@.sqlite",name];
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:sqliteFileName];
    
    NSError *error = nil;
    self.coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![self.coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //Init context
    if (self.coordinator != nil)
    {
        self.context = [[NSManagedObjectContext alloc] init];
        [self.context setPersistentStoreCoordinator:self.coordinator];
        [self.context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    
    _contexts = [[NSMutableDictionary alloc] init];
    _threadArray = [[NSMutableArray alloc] init];
    
    autoreleaseThread = [[NSThread alloc] initWithTarget:self selector:@selector(checkThreadArray) object:nil];
    [autoreleaseThread start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextHasChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
}

#pragma mark - Retrieve objects

-(NSManagedObject *)insertObjectForEntity:(NSString *)entity
{
    NSManagedObjectContext *context = [self getContextForCurrentThread];
    
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
}

// Fetch objects with a predicate
-(NSMutableArray *)getObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending
{
    NSManagedObjectContext *context = [self getContextForCurrentThread];
    
    // Create fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    // If a predicate was specified then use it in the request
    if (predicate != nil)
        [request setPredicate:predicate];
    
    // If a sort key was passed then use it in the request
    if (sortKey != nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
    }
    
    // Execute the fetch request
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    // If the returned array was nil then there was an error
    if (mutableFetchResults == nil)
        NSLog(@"Couldn't get objects for entity %@", entityName);
    
    // Return the results
    return mutableFetchResults;
}

-(NSMutableArray *)getObjectsForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray *)sortDescription
{
    NSManagedObjectContext *context = [self getContextForCurrentThread];
    
    // Create fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    // If a predicate was specified then use it in the request
    if (predicate != nil)
        [request setPredicate:predicate];
    
    if (sortDescription != nil) {
        [request setSortDescriptors:sortDescription];
    }
    
    // Execute the fetch request
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    // If the returned array was nil then there was an error
    if (mutableFetchResults == nil)
        NSLog(@"Couldn't get objects for entity %@", entityName);
    
    // Return the results
    return mutableFetchResults;
}

#pragma mark - Count objects

// Get a count for an entity with a predicate
-(NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *context = [self getContextForCurrentThread];
    
    // Create fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    [request setIncludesPropertyValues:NO];
    
    // If a predicate was specified then use it in the request
    if (predicate != nil)
        [request setPredicate:predicate];
    
    // Execute the count request
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    // If the count returned NSNotFound there was an error
    if (count == NSNotFound)
        NSLog(@"Couldn't get count for entity %@", entityName);
    
    // Return the results
    return count;
}


#pragma mark - Delete Objects

// Delete all objects for a given entity
-(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    NSManagedObjectContext *context = [self getContextForCurrentThread];
    
    // Create fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    // Ignore property values for maximum performance
    [request setIncludesPropertyValues:YES];
    
    // If a predicate was specified then use it in the request
    if (predicate != nil)
        [request setPredicate:predicate];
    
    // Execute the count request
    NSError *error = nil;
    
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];
    
    // Delete the objects returned if the results weren't nil
    if (fetchResults != nil) {
        for (NSManagedObject *manObj in fetchResults) {
            [context deleteObject:manObj];
        }
    } else {
        NSLog(@"Couldn't delete objects for entity %@", entityName);
        return NO;
    }
    
    return YES;
}

-(void)deleteObject:(NSManagedObject *)object
{
    NSManagedObjectContext *context = [self getContextForCurrentThread];
    [context deleteObject:object];
}

-(void)saveContextForCurrentThread
{
    NSError *error = nil;
    NSManagedObjectContext *context = [self getContextForCurrentThread];
    
    if (context != nil)
    {
        if ([context hasChanges] && ![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Internal Methods

-(NSManagedObjectContext *)getContextForCurrentThread
{
    @synchronized(_threadArray)
    {
        NSThread *currentThread = [NSThread currentThread];
        
        if([currentThread isMainThread])
            return self.context;
        
        NSValue *threadKey = [NSValue valueWithNonretainedObject:currentThread];
        
        NSManagedObjectContext *context = [_contexts objectForKey:threadKey];
        
        if(!context)
        {
            context = [[NSManagedObjectContext alloc] init];
            [context setPersistentStoreCoordinator:self.coordinator];
            [context setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
            
            [_contexts setObject:context forKey:threadKey];
            [_threadArray addObject:currentThread];
        }
        
        return context;
    }
}


- (void)contextHasChanged:(NSNotification*)notification
{
    if ([notification object] == self.context) return;
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextHasChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    [self.context mergeChangesFromContextDidSaveNotification:notification];
}

- (void)checkThreadArray
{
    while(YES)
    {
        @synchronized(_threadArray)
        {
            NSMutableArray *toKeep = [[NSMutableArray alloc] init];
            
            for(NSThread *thread in _threadArray)
            {
                if(thread.isFinished)
                {
                    NSValue *threadKey = [NSValue valueWithNonretainedObject:thread];
                    [_contexts removeObjectForKey:threadKey];
                }
                else
                {
                    [toKeep addObject:thread];
                }
            }
            
            [_threadArray removeAllObjects];
            [_threadArray addObjectsFromArray:toKeep];
            
            toKeep = nil;
        }
    }
    
}

#pragma mark - Deprecated

-(void)destroyContextForCurrentThread
{
    //DEPRECATED
}
@end