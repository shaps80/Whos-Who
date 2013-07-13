//
//  SPXAppDelegate.m
//  Who
//
//  Created by Shaps Mohsenin on 12/07/2013.
//  Copyright (c) 2013 Snippex. All rights reserved.
//

#import "SPXAppDelegate.h"
#import "SPXStoreManager.h"

@implementation SPXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SPXStore *store = [SPXStore storeWithDatabaseName:@"Who" modelName:@"Who"];
    [SPXStoreManager addStore:store withName:@"Who"];

    return YES;
}

@end
