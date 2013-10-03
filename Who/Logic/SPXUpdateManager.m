/*
 Copyright (c) 2013 Snippex. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY Snippex `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL Snippex OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPXUpdateManager.h"
#import "SPXFetchRequest.h"
#import "SPXPerson+SPXAdditions.h"
#import "TFHpple.h"

#define SPXBaseURL                      @"http://theappbusiness.com/our-team"

#define trim(string)                    [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

@interface SPXUpdateManager ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation SPXUpdateManager

+(instancetype)sharedInstance
{
	static SPXUpdateManager *_sharedInstance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		_sharedInstance = [[self alloc] init];
	});
  
	return _sharedInstance;
}

-(NSOperationQueue *)queue
{
  if (!_queue)
  {
    _queue = [[NSOperationQueue alloc] init];
    [_queue setMaxConcurrentOperationCount:1];
  }
  
  return _queue;
}

-(void)updateWithContext:(NSManagedObjectContext *)context
              completion:(SPXUpdateCompletionBlock)completion
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  
  NSURL *url = [NSURL URLWithString:SPXBaseURL];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
   {
     if (!error)
     {
       NSArray *attributesList = [self attributesFromHTMLData:data];
       SPXFetchRequest *request = [SPXFetchRequest fetchRequestWithEntityName:@"Person" context:context];
       
       NSMutableSet *originalSet = [NSMutableSet setWithArray:[request fetchAllObjects]];
       NSMutableSet *updatesSet = [[NSMutableSet alloc] init];
       
       for (NSDictionary *attributes in attributesList)
       {
         SPXStoreObjectState state;
         SPXPerson *person = (SPXPerson *)[request fetchObjectWithIdentifier:attributes[@"identifier"]
                                                               identifierKey:@"identifier"
                                                                      create:YES
                                                                 objectState:&state];
         
         [person setAttributes:attributes];
         [updatesSet addObject:person];
         
         DLog(@"%@ Person: %@", [SPXFetchRequest stringRepresentationForObjectState:state], person.name);
       }
       
       // This code simply removes the updated items from the original set
       // whatever is left, should be removed
       {
         [originalSet minusSet:updatesSet];
         
         for (SPXPerson *person in originalSet)
           [context deleteObject:person];
       }
       
       NSError *error = nil;
       
       if (![context save:&error])
         DLog(@"%@", error);
       
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }
     
     if (completion)
       completion(error);
   }];
}

/**
 Simple helper method to return an array of dictionaries (1 for each person) from the original HTML
 */
-(NSArray *)attributesFromHTMLData:(NSData *)data
{
  NSMutableArray *items = [[NSMutableArray alloc] init];
  
  TFHpple *parser = [TFHpple hppleWithHTMLData:data];
  NSString *searchString = @"//div[@class='threecol profile ']";
  NSArray *nodes = [parser searchWithXPathQuery:searchString];
  
  for (TFHppleElement *element in nodes)
  {
    NSArray *h3_tags = [element childrenWithTagName:@"h3"];
    NSArray *p_tags = [element childrenWithTagName:@"p"];
    NSArray *img_tags = [element childrenWithTagName:@"div"];
    
    NSString *name = [[[[h3_tags objectAtIndex:0] children] lastObject] content];
    NSString *role = [[[[p_tags objectAtIndex:0] children] lastObject] content];
    NSString *biography = [[[[p_tags objectAtIndex:1] children] lastObject] content];
    NSString *imagePath = [[[[img_tags objectAtIndex:0] children] lastObject] objectForKey:@"src"];
    NSString *identifier = [NSString stringWithFormat:@"%d", [imagePath hash]];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    [attributes setObject:trim(name) forKey:SPXPersonKeyName];
    [attributes setObject:trim(role) forKey:SPXPersonKeyRole];
    [attributes setObject:trim(biography) forKey:SPXPersonKeyBiography];
    [attributes setObject:trim(identifier) forKey:SPXPersonKeyIdentifier];
    [attributes setObject:trim(imagePath) forKey:SPXPersonKeyImageRemotePath];
    [attributes setObject:trim(identifier) forKey:SPXPersonKeyIdentifier];
    
    [items addObject:attributes];
  }
  
  return items;
}

@end
