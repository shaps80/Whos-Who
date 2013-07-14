/*
   Copyright (c) 2013 net mobile UK. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY net mobile UK `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL net mobile UK OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPXStore.h"

NSString * const SPXModelVersionKey = @"SPXModelVersionKey";

@interface SPXStore ()

@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSMutableDictionary *entityIdentifiers;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(NSURL *)applicationDocumentsDirectory;

@end

@implementation SPXStore

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Lifecycle

+(instancetype)storeWithDatabaseName:(NSString *)databaseName modelName:(NSString *)modelName
{
	if (!(databaseName.length && modelName.length))
	{
		NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
														 reason:@"Invalid database or model name specified"
													   userInfo:nil];
		[exception raise];
	}

	return [[SPXStore alloc] initWithDatabaseName:databaseName modelName:modelName];
}

- (id)init
{
	NSAssert(NO, @"You must use the designated initializer -initWithDatabaseName:modelName:");
	return nil;
}

-(id)initWithDatabaseName:(NSString *)databaseName modelName:(NSString *)modelName
{
	self = [super init];

	if (self)
	{
		_databaseName = databaseName;
		_modelName = modelName;

		[self updateModel];
	}

	return self;
}

#pragma mark - Saving

-(void)saveContext
{
	NSError *error = nil;
	[_managedObjectContext save:&error];
}

#pragma mark - Entity Identifiers

-(NSMutableDictionary *)entityIdentifiers
{
	return _entityIdentifiers ?: (_entityIdentifiers = [[NSMutableDictionary alloc] init]);
}

-(void)setIdentifier:(NSString *)identifier forEntityName:(NSString *)entitiyName
{
	[_entityIdentifiers setObject:identifier forKey:entitiyName];
}

-(NSString *)identifierForEntityName:(NSString *)entityName
{
	NSString *identifier = [_entityIdentifiers objectForKey:entityName];
	return identifier ?: @"identifier";
}

#pragma mark - Model

-(void)updateModel
{
	NSManagedObjectModel *model = [self managedObjectModel];
	_managedObjectModel = model;
	NSArray *versionIdentifiers = [model.versionIdentifiers allObjects];

	if (![versionIdentifiers count])
	{
		DLog(@"Error: No model found!");
		return;
	}

	NSString *currentVersionIdentifier = [[model.versionIdentifiers allObjects] objectAtIndex:0];

	if ([[[NSUserDefaults standardUserDefaults] stringForKey:SPXModelVersionKey] isEqualToString:currentVersionIdentifier])
		return;

	[[NSUserDefaults standardUserDefaults] setValue:currentVersionIdentifier forKey:SPXModelVersionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
        return _managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

    if (coordinator)
	{
        _managedObjectContext = [[NSManagedObjectContext alloc]
											initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		
        [_managedObjectContext performBlockAndWait:^
		{
			 [_managedObjectContext setPersistentStoreCoordinator:coordinator];
		}];

    }
	
    return _managedObjectContext;
}

-(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
        return _managedObjectModel;

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_modelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
        return _persistentStoreCoordinator;

	NSError *error = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory]
					   URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _databaseName]];

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
	{
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark - File management

-(NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
