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

#import <Foundation/Foundation.h>
#import "SPXPerson.h"

typedef void (^SPXImageCacheCompletionBlock)(UIImage *image);

/**
 This class provided image caching for the SPXPerson profile image data.

 Note: This class is designed specifically for SPXPerson object, however we could easily make this suite other object types by removing the passing of the person object and instead passing in remote (and possible local) paths and perhaps also a size so we can download a single image and provide internal resizing (where applicable) to return the specific image we need, without incurring additional downloads when not necessary.
 */
@interface SPXImageCache : NSObject

/**
 @abstract      A singleton for easy access
 */
+(instancetype)sharedInstance;

/**
 @abstract      Returns the profile image for a person
 @param         person The person object to get the profile image for
 @param         completion The completion block to execute when the image is found or downloaded
 @discussion    We use 2 level caching here, memory and disk. If it cannot be found in either, then we download asynchronously and return when finished.
                We then save it to disk and add it to the memory cache.
 */
-(void)imageForPerson:(SPXPerson *)person
       withCompletion:(SPXImageCacheCompletionBlock)completion;

@end
