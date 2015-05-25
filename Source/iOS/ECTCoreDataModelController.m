// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTCoreDataModelController.h"

#import <CoreData/CoreData.h>

@interface ECTCoreDataModelController ()

@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext* privateContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation ECTCoreDataModelController

- (void)startupWithCallback:(ECModelControllerStartupCallbackBlock)callback
{
	[super startupWithCallback:callback];
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
	NSManagedObjectModel* mom = [NSManagedObjectModel mergedModelFromBundles:nil];

	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
	NSString* name = [info objectForKey:@"ECCoreDataName"];
	NSString* version = [info objectForKey:@"ECCoreDataVersion"];

	NSPersistentStoreCoordinator* psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
	NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	NSManagedObjectContext* poc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	[poc setPersistentStoreCoordinator:psc];
	moc.parentContext = poc;

	self.persistentStoreCoordinator = psc;
	self.managedObjectContext = moc;
	self.privateContext = poc;
	self.managedObjectModel = mom;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		NSDictionary* options = @{
			NSMigratePersistentStoresAutomaticallyOption: @YES,
			NSInferMappingModelAutomaticallyOption: @YES,
			NSSQLitePragmasOption: @{ @"journal_mode": @"DELETE" }
		};
		NSError* error = nil;
		NSURL* dataURL = [[NSFileManager defaultManager] URLForApplicationDataPath:@"data"];
		NSURL* storeUrl = [dataURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-v%@.sqllite", name, version]];
		BOOL ok = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error] != nil;
		ECModelControllerStartupCallbackBlock startupCallback = self.startupBlock;
		if (startupCallback)
			startupCallback(ok ? nil : error);
	});
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
	NSArray* fetchedObjects = [self.managedObjectContext executeFetchRequest:request error:&error];
	NSManagedObject* result = [fetchedObjects firstObjectOrNil];

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

- (NSArray*)allEntitiesForName:(NSString*)entityName predicate:(NSPredicate*)predicate sort:(NSString*)sort
{
	NSArray* sortDescriptors = self.sorts[sort];
	NSError* error = nil;
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
	request.entity = entity;
	request.predicate = predicate;
	request.sortDescriptors = sortDescriptors;
	NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&error];

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

- (NSManagedObject*)firstEntityForName:(NSString*)entityName predicate:(NSPredicate*)predicate sort:(NSString*)sort
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

- (NSManagedObject*)firstEntityForName:(NSString*)entityName sort:(NSString*)sort
{
	return [self firstEntityForName:entityName predicate:nil sort:sort];
}

- (NSArray*)allEntitiesForName:(NSString*)entityName sorted:(NSString*)sort
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

	[self saveWithCallback:nil];
}

- (id)insertEntityForName:(NSString*)name
{
	id entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.managedObjectContext];
	return entity;
}

- (void)saveWithCallback:(ECModelControllerSaveCallbackBlock)callback
{
    if (!callback)
        callback = ^(NSError* error) {};
    
	NSManagedObjectContext* moc = self.managedObjectContext;
	NSManagedObjectContext* poc = self.privateContext;
    __block NSError* error = nil;
	if (poc.hasChanges || moc.hasChanges)
    {
        [moc performBlockAndWait:^{
            if (![moc save:&error])
            {
                NSLog(@"error %@", error);
                [ECErrorReporter reportError:error message:@"couldn't save main context"];
                callback(error);
            }
            else
            {
                [poc performBlock:^{
                    if (![poc save:&error])
                    {
                        NSLog(@"error %@", error);
                        [ECErrorReporter reportError:error message:@"couldn't save private context"];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(error);
                    });
                }];
            }
        }];
    }
    else
    {
        callback(nil);
    }
}

@end
