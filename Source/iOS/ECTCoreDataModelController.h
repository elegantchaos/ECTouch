// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTModelController.h"

#import <CoreData/CoreData.h>

@class NSManagedObjectModel;
@class NSPersistentStoreCoordinator;
@class NSManagedObjectContext;

@interface ECTCoreDataModelController : ECTModelController

@property (strong, nonatomic) NSDictionary* sorts;

- (void)startupCoreData;
- (void)shutdownCoreData;

- (void)saveWithCallback:(ECModelControllerSaveCallbackBlock)callback;

- (id)findEntityForName:(NSString*)entityName forKey:(NSString*)key value:(NSString*)value;
- (id)findOrCreateEntityForName:(NSString*)entityName forKey:(NSString*)key value:(NSString*)value wasFound:(BOOL*)wasFound;
- (NSArray*)allEntitiesForName:(NSString*)entityName predicate:(NSPredicate*)predicate sort:(NSString*)sort;
- (NSArray*)allEntitiesForName:(NSString*)entityName sorted:(NSString*)sort;
- (NSManagedObject*)firstEntityForName:(NSString*)entityName predicate:(NSPredicate*)predicate sort:(NSString *)sort;
- (NSManagedObject*)firstEntityForName:(NSString*)entityName sort:(NSString *)sort;
- (void)deleteAllEntitiesForName:(NSString*)entityName;
- (id)insertEntityForName:(NSString*)name;

@end
