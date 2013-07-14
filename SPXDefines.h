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

#pragma mark - Universal

#if TARGET_OS_IPHONE

#define SPXColor            UIColor
#define SPXGraphicsContext  UIGraphicsGetCurrentContext()
#define SPXBezierPath       UIBezierPath

#else

#define SPXColor            NSColor
#define SPXGraphicsContext  [[NSGraphicsContext currentContext] graphicsPort]
#define SPXBezierPath       NSBezierPath

#endif

#define STRINGIFY(x) #x
#define OBJC_STRINGIFY(x) @#x

/**
 User Defaults - Provides wrapper for convenience.
 getDefaultsObject(_object);
 setDefaultsObject(_objecT);
 synchronizeDefaults;
 */

#pragma mark - NSUserDefaults

#define getDefaults [NSUserDefaults standardUserDefaults]
#define synchronizeDefaults [[NSUserDefaults standardUserDefaults] synchronize]

// for objects use these
#define setDefaultsObject(_variableName) [[NSUserDefaults standardUserDefaults] setObject:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define getDefaultsObject(_variableName) _variableName = [[NSUserDefaults standardUserDefaults] objectForKey:OBJC_STRINGIFY(_variableName)]

// for primitives use these
#define setDefaultsInteger(_variableName) [[NSUserDefaults standardUserDefaults] setInteger:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define getDefaultsInteger(_variableName) _variableName = [[NSUserDefaults standardUserDefaults] integerForKey:OBJC_STRINGIFY(_variableName)]
#define setDefaultsDouble(_variableName) [[NSUserDefaults standardUserDefaults] setDouble:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define getDefaultsDouble(_variableName) _variableName = [[NSUserDefaults standardUserDefaults] doubleForKey:OBJC_STRINGIFY(_variableName)]
#define setDefaultsFloat(_variableName) [[NSUserDefaults standardUserDefaults] setFloat:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define getDefaultsFloat(_variableName) _variableName = [[NSUserDefaults standardUserDefaults] floatForKey:OBJC_STRINGIFY(_variableName)]
#define setDefaultsBool(_variableName) [[NSUserDefaults standardUserDefaults] setBool:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define getDefaultsBool(_variableName) _variableName = [[NSUserDefaults standardUserDefaults] boolForKey:OBJC_STRINGIFY(_variableName)]

#if TARGET_OS_IPHONE

#define setDefaultsRect(_variableName) [[NSUserDefaults standardUserDefaults] setObject:[NSValue valueWithCGRect:_variableName] forKey:OBJC_STRINGIFY(_variableName)];
#define getDefaultsRect(_variableName) [[[NSUserDefaults standardUserDefaults] objectForKey:OBJC_STRINGIFY(_variableName)] CGRectValue];
#define setDefaultsPoint(_variableName) [[NSUserDefaults standardUserDefaults] setObject:[NSValue valueWithCGPoint:_variableName] forKey:OBJC_STRINGIFY(_variableName)];
#define getDefaultsPoint(_variableName) [[[NSUserDefaults standardUserDefaults] objectForKey:OBJC_STRINGIFY(_variableName)] CGPointValue];

#else

#define setDefaultsRect(_variableName) [[NSUserDefaults standardUserDefaults] setObject:[NSValue valueWithRect:_variableName] forKey:OBJC_STRINGIFY(_variableName)];
#define getDefaultsRect(_variableName) [[[NSUserDefaults standardUserDefaults] objectForKey:OBJC_STRINGIFY(_variableName)] rectValue];
#define setDefaultsPoint(_variableName) [[NSUserDefaults standardUserDefaults] setObject:[NSValue valueWithPoint:_variableName] forKey:OBJC_STRINGIFY(_variableName)];
#define getDefaultsPoint(_variableName) [[[NSUserDefaults standardUserDefaults] objectForKey:OBJC_STRINGIFY(_variableName)] pointValue];

#endif

/**
 NSEncoding - Provides wrapper for convenience.
 encodeObject(_object);
 decodeObject(_object);
 */

#pragma mark - NSCoding

#define encodeObject(_variableName) [aCoder encodeObject:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define decodeObject(_variableName) _variableName = [aDecoder decodeObjectForKey:OBJC_STRINGIFY(_variableName)]

// for primitive types, use the following
#define encodeFloat(_variableName) [aCoder encodeFloat:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define encodeInteger(_variableName) [aCoder encodeInteger:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define encodeDouble(_variableName) [aCoder encodeDouble:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define encodeBool(_variableName) [aCoder encodeBool:_variableName forKey:OBJC_STRINGIFY(_variableName)]

#define decodeFloat(_variableName) _variableName = [aDecoder decodeFloatForKey:OBJC_STRINGIFY(_variableName)]
#define decodeInteger(_variableName) _variableName = [aDecoder decodeIntegerForKey:OBJC_STRINGIFY(_variableName)]
#define decodeDouble(_variableName) _variableName = [aDecoder decodeDoubleForKey:OBJC_STRINGIFY(_variableName)]
#define decodeBool(_variableName) _variableName = [aDecoder decodeBoolForKey:OBJC_STRINGIFY(_variableName)]

#if TARGET_OS_IPHONE

#define encodeRect(_variableName) [aCoder encodeCGRect:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define encodePoint(_variableName) [aCoder encodeCGPoint:_variableName forKey:OBJC_STRINGIFY(_variableName)]

#define decodeRect(_variableName) _variableName = [aDecoder decodeCGRectForKey:OBJC_STRINGIFY(_variableName)]
#define decodePoint(_variableName) _variableName = [aDecoder decodeCGPointForKey:OBJC_STRINGIFY(_variableName)]

#else

#define encodeRect(_variableName) [aCoder encodeRect:_variableName forKey:OBJC_STRINGIFY(_variableName)]
#define encodePoint(_variableName) [aCoder encodePoint:_variableName forKey:OBJC_STRINGIFY(_variableName)]

#define decodeRect(_variableName) _variableName = [aDecoder decodeRectForKey:OBJC_STRINGIFY(_variableName)]
#define decodePoint(_variableName) _variableName = [aDecoder decodePointForKey:OBJC_STRINGIFY(_variableName)]

#endif

/**
 Perform selector - Provides wrapper for convenience.
 */

#pragma mark - Perform Selector

#define PERFORM_SELECTOR(THE_OBJECT, THE_SELECTOR) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR] : nil)
#define PERFORM_SELECTOR_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
#define PERFORM_SELECTOR_WITH_ARG2(THE_OBJECT, THE_SELECTOR, ARG1, ARG2) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:ARG1 withObject:ARG2] : nil)

/**
 Requires Super - Provides compiler warning when super is not called on a method that requires it.
 -(void)myMethod NS_REQUIRES_SUPER;
 */

#pragma mark - Requires Super

#ifndef NS_REQUIRES_SUPER
#if __has_attribute(objc_requires_super)
#define NS_REQUIRES_SUPER __attribute((objc_requires_super))
#else
#define NS_REQUIRES_SUPER
#endif
#endif

/**
 Weak Variables - automatically inserts __weak/weak in iOS 5 and above, and __unsafe_unretained/assign older versions
 id __WEAK object;
 @property (WEAK) object;
 */

#pragma mark - Weak Pointers

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000

#define __WEAK      __weak
#define WEAK        weak

#else

#define __WEAK      __unsafe_unretained
#define WEAK        assign

#endif

/**
 DLog - Provides a simpler implementation that is guaranteed to be removed in RELEASE mode.
 LogMethod - Provides a simply way to log the current class and method to the console.
 DLog(@"%@", object);
 logMethod;
 
 Logging format (date, line_number, class, method, format)

    2013-07-12 00:52:00 | 193 | NMNotifier | initializeWithAppKey:appSecret: | Initialized key and secret 
 */

#pragma mark - Logging

#if DEBUG

#import <Foundation/Foundation.h>

static NSString * getTimestamp()
{
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
        formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"MMM dd yyyy, hh:mm:ss"];
    return [formatter stringFromDate:[NSDate date]];
}

// allow us to log method and class while in debug mode
#define logMethod DLog((@"%@ | %d | %@ | %@ "), getTimestamp(), __LINE__, NSStringFromClass([self class]), NSStringFromSelector(_cmd));

// should use DLog vs DLog to ensure its completely disabled when not in debug mode
#define DLog(fmt, ...) NSLog((@"%@ | %d | %@ | %@ | " fmt), getTimestamp(), __LINE__, NSStringFromClass([self class]), NSStringFromSelector(_cmd), ##__VA_ARGS__);
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else

// is we're in release mode, we disable these
#define DLog(...)
#define logMethod

#endif