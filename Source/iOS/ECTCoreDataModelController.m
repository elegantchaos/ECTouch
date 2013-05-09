// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/12/2011
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTCoreDataModelController.h"

#import <CoreData/CoreData.h>

@interface ECTCoreDataModelController()

@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation ECTCoreDataModelController

- (void)dealloc
{
    [_managedObjectModel release];
	[_managedObjectContext release];
	[_persistentStoreCoordinator release];
    [_sorts release];
	
    [super dealloc];
}

- (void)startup
{
	[super startup];
	[self startupCoreData];
}

- (void)shutdown
{
	[self shutdownCoreData];
	[super shutdown];
}

#pragma mark -
#pragma mark Core Data

- (void)startupCoreData
{
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
	NSString* name = [info objectForKey:@"ECCoreDataName"];
	NSString* version = [info objectForKey:@"ECCoreDataVersion"];
	
    NSURL* url = [[NSFileManager defaultManager] URLForApplicationDataPath:@"data"];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-v%@.sqllite", name, version]];

	NSError *error = nil;
    NSPersistentStoreCoordinator* psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	if ([psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error])
    {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
        [moc setPersistentStoreCoordinator:psc];
        self.persistentStoreCoordinator = psc;
        self.managedObjectContext = moc;
        [moc release];
    }
    [psc release];
}

- (void)shutdownCoreData
{
	
}

- (id)findEntityForName:(NSString*)entityName forKey:(NSString*)key value:(NSString*)value
{
    NSError* error = nil;
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	NSString* predicateFormat = [NSString stringWithFormat:@"%@ like %@", key, @"%@"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateFormat, value];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSManagedObject* result = [fetchedObjects firstObjectOrNil];
    [request release];
    
    return result;
}

- (id)findOrCreateEntityForName:(NSString*)entityName forKey:(NSString*)key value:(NSString*)value wasFound:(BOOL*)wasFound
{
    NSManagedObject* result = [self findEntityForName:entityName forKey:key value:value];
	if (wasFound)
	{
		*wasFound = (result != nil);
	}
	
    if (result)
    {
        ECDebug(ModelChannel, @"retrieved %@ with %@ == %@, %@", entityName, key, value, result);
	}
	else
	{
        ECDebug(ModelChannel, @"made %@ with %@ == %@, %@", entityName, key, value, result);
		NSError* error = nil;
        result = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
		[result setValue:value forKey:key];
        [self.managedObjectContext save:&error];
    }
    
    return result;
}

- (NSArray*)allEntitiesForName:(NSString*)entityName predicate:(NSPredicate*)predicate sort:(NSString *)sort
{
	NSArray* sortDescriptors = self.sorts[sort];
    NSError* error = nil;
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    request.predicate = predicate;
	request.sortDescriptors = sortDescriptors;
    NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&error];
    [request release];

	if (result)
    {
        ECDebug(ModelChannel, @"retrieved %d %@ entities", [result count], entityName);
	}
	else
	{
        ECDebug(ModelChannel, @"couldn't get %@ entities, error: @%", entityName, error);
    }

	if (predicate)
	{
		ECDebug(ModelChannel, @"predicate was %@", predicate);
	}

    return result;
}

- (NSManagedObject*)firstEntityForName:(NSString*)entityName predicate:(NSPredicate*)predicate sort:(NSString *)sort
{
	NSArray* sortDescriptors = self.sorts[sort];
    NSError* error = nil;
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    request.entity = entity;
    request.predicate = predicate;
	request.sortDescriptors = sortDescriptors;
	request.fetchLimit = 1;
    NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&error];
    [request release];

	if (result)
    {
        ECDebug(ModelChannel, @"retrieved %d %@ entities", [result count], entityName);
	}
	else
	{
        ECDebug(ModelChannel, @"couldn't get %@ entities, error: @%", entityName, error);
    }

	if (predicate)
	{
		ECDebug(ModelChannel, @"predicate was %@", predicate);
	}

    return [result firstObjectOrNil];
}

- (NSManagedObject*)firstEntityForName:(NSString*)entityName sort:(NSString *)sort
{
	return [self firstEntityForName:entityName predicate:nil sort:sort];
}

- (NSArray*)allEntitiesForName:(NSString*)entityName sorted:(NSString *)sort
{
	return [self allEntitiesForName:entityName predicate:nil sort:sort];
}

- (void)deleteAllEntitiesForName:(NSString*)entityName
{
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext]];
	[request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
	
	NSError* error = nil;
	NSArray* objects = [self.managedObjectContext executeFetchRequest:request error:&error];
	[request release];

	if (objects)
	{
		for (NSManagedObject* object in objects)
		{
			[self.managedObjectContext deleteObject:object];
		}
	}
	else
	{
		[ECErrorReporter reportError:error message:@"couldn't delete all %@ entities", entityName];
	}
	
	[self save];
}

- (void)save
{
	NSError* error = nil;
	if (![self.managedObjectContext save:&error])
	{
		NSLog(@"error %@", error);
		
		[ECErrorReporter reportError:error message:@"couldn't save model"];
	}
}

@end
