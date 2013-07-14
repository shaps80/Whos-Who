//
//  SPXPerson.h
//  Who
//
//  Created by Shaps Mohsenin on 13/07/2013.
//  Copyright (c) 2013 Snippex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define SPXPersonKeyName                    @"name"
#define SPXPersonKeyRole                    @"role"
#define SPXPersonKeyBiography               @"biography"
#define SPXPersonKeyIdentifier              @"identifier"
#define SPXPersonKeyImageRemotePath         @"imageRemotePath"
#define SPXPersonKeyImageLocalPath          @"imageLocalPath"

@interface SPXPerson : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * biography;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * imageRemotePath;
@property (nonatomic, retain) NSString * imageLocalPath;

@end
