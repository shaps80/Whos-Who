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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 These enum values define the various states for an object when returned via SPXFetchRequest
 */
typedef enum
{
	SPXStoreObjectStateFound                /* The object was found, already exists */,
	SPXStoreObjectStateAdded                /* The object was added to the context */,
	SPXStoreObjectStateRemoved              /* The object was removed from the context */,
	SPXStoreObjectStateModified             /* The object was modified in the context */,
} SPXStoreObjectState;

/**
 The SPXStore class is a CoreData based store that encapsulates all the management of the CoreData model and database.
 It also adds some convenience for dealing with identifiers and simplifies loading the model and persisting the context's changes to disk.
 */
@interface SPXStore : NSObject

/// @return The managedObjectContext associated with this store
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/**
 @abstract      Creates a store using the specified names for the database and model
 @param         databaseName The name to use for saving this data to disk
 @param         modelName The name of the model to load
 @return        An SPXStore instance with its model loaded and saved to disk and an NSManagedObjectContext
 */
+(instancetype)storeWithDatabaseName:(NSString *)databaseName modelName:(NSString *)modelName;

/**
 @abstract      Sets the identifier key, used by SPXFetchRequest for the specified entityName
 @param         identifier The identifier key for this entity
 @param         entityName The name of the entity this identifier applies to
 */
-(void)setIdentifier:(NSString *)identifier forEntityName:(NSString *)entitiyName;

/**
 @abstract      Returns the identifier key used for the given entityName
 @param         entityName The name of the entity
 @return        An NSString instance of the identifier key
 */
-(NSString *)identifierForEntityName:(NSString *)entityName;

/**
 @abstract      Saves the NSManagedContext changes
 */
-(void)saveContext;

@end