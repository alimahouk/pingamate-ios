//
//  PMAppDelegate.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMAppDelegate.h"

#import "constants.h"
#import "PMDirector.h"
#import "PMMainViewController.h"
#import "PMUser.h"

@implementation PMAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        _director      = [PMDirector new];
        mainController = [PMMainViewController new];
        
        _window                    = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _window.rootViewController = mainController;
        _window.tintColor          = PM_THEME_RED;
        
        [_window makeKeyAndVisible];
        [_director action];
        
        return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        [_director saveContext];
        
        backgroundTask = [application beginBackgroundTaskWithName:@"EnteringBackgroundTask" expirationHandler:^{
                [application endBackgroundTask:backgroundTask];
                
                backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [_director applicationDidEnterBackground];
                [application endBackgroundTask:backgroundTask];
                
                backgroundTask = UIBackgroundTaskInvalid;
        });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        [_director applicationDidEnterForeground];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


@end
