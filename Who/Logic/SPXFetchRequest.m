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

#import "SPXFetchRequest.h"

@interface SPXFetchRequest ()
@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
@end

@implementation SPXFetchRequest

-(id)initWithEntity:(NSEntityDescription *)entity context:(NSManagedObjectContext *)context
{
    self = [super init];

    if (self)
	{
        _managedObjectContext = context;
		[self setEntity:entity];
	}

    return self;
}

+(instancetype)fetchRequestWithEntityName:(NSString *)entityName
								  context:(NSManagedObjectContext *)context
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    SPXFetchRequest *request = [[SPXFetchRequest alloc] initWithEntity:entity context:context];
	return request;
}

+(NSString *)stringRepresentationForObjectState:(SPXStoreObjectState)state
{
    switch (state) {
        case SPXStoreObjectStateFound:
            return @"Found";
        case SPXStoreObjectStateAdded:
            return @"Added";
        case SPXStoreObjectStateRemoved:
            return @"Removed";
        case SPXStoreObjectStateModified:
            return @"Modified";
    }
}

#pragma mark - Multiple objects

-(NSArray *)fetchAllObjects
{
	return [self fetchObjectsWithPredicate:nil sortDescriptors:nil];
}

-(NSArray *)fetchObjectsWithPredicate:(NSPredicate *)predicate
{
	return [self fetchObjectsWithPredicate:predicate sortDescriptors:nil];
}

-(NSArray *)fetchObjectsWithPredicate:(NSPredicate *)predicate
					  sortDescriptors:(NSArray *)sortDescriptors
{
	[self setPredicate:predicate];
	[self setSortDescriptors:sortDescriptors];

	NSError *error = nil;
	NSArray *objects = [self.managedObjectContext executeFetchRequest:self error:&error];

	if (error)
	{
		DLog(@"SPXFetchRequest failed: %@", error);
		return nil;
	}

	return objects;
}

#pragma mark - Single object

-(NSManagedObject *)fetchObjectWithIdentifier:(id)identifier
								identifierKey:(NSString *)key
									   create:(BOOL)create
                                  objectState:(SPXStoreObjectState *)objectState
{
	NSString *format = [NSString stringWithFormat:@"%@ == \"%@\"", key, identifier];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
	id object = [[self fetchObjectsWithPredicate:predicate sortDescriptors:nil] lastObject];

	if (object)
    {
        if (objectState)
            *objectState = SPXStoreObjectStateModified;
    }
	else
	{
		if (create)
		{
			object = [NSEntityDescription insertNewObjectForEntityForName:self.entityName
												   inManagedObjectContext:self.managedObjectContext];

            if (objectState)
                *objectState = SPXStoreObjectStateAdded;
		}
	}

	return object;
}

@end
