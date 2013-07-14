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

#import "SPXImageCache.h"

@interface SPXImageCache ()
@property (nonatomic, strong) NSCache *imageCache;
@end

@implementation SPXImageCache

+(SPXImageCache *)sharedInstance
{
	static SPXImageCache *_sharedInstance = nil;
	static dispatch_once_t oncePredicate;
	dispatch_once(&oncePredicate, ^{
		_sharedInstance = [[self alloc] init];
	});

	return _sharedInstance;
}

-(NSCache *)imageCache
{
    return _imageCache ?: (_imageCache = [[NSCache alloc] init]);
}

-(void)imageForPerson:(SPXPerson *)person
       withCompletion:(SPXImageCacheCompletionBlock)completion
{
    UIImage *image = nil;

    // first we check memory cache
    image = [self.imageCache objectForKey:person];
    
    if (image)
    {
        if (completion) completion(image);
        return;
    }

    // next we check disk cache
    image = [[UIImage alloc] initWithContentsOfFile:person.imageLocalPath];
    
    if (image)
    {
        [self.imageCache setObject:image forKey:person];
        if (completion) completion(image);
        return;
    }

    // if we still don't have it, let download the image asynchronously and
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:person.imageRemotePath]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (error)
        {
            DLog(@"%@", error);
            return;
        }

        UIImage *image = [[UIImage alloc] initWithData:data];

        if (image)
        {
            NSError *error = nil;
            NSURL *localDestination = [NSURL URLWithString:[person.imageRemotePath lastPathComponent]
                                             relativeToURL:[self applicationCacheDirectoryURL]];

            person.imageLocalPath = localDestination.path;

            if (![person.managedObjectContext save:&error])
                DLog(@"%@", error);

            [data writeToURL:localDestination atomically:YES];
            [self.imageCache setObject:image forKey:person];
        }

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
        }
    }];
}

-(NSURL *)applicationCacheDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
