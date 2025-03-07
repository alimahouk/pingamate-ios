//
//  PMAppDelegate.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

@class PMDirector;
@class PMMainViewController;
@class PMUser;

@interface PMAppDelegate : UIResponder <UIApplicationDelegate>
{
        PMMainViewController *mainController;
        UIBackgroundTaskIdentifier backgroundTask;
}

@property (strong, nonatomic) PMDirector *director;
@property (strong, nonatomic) UIWindow *window;

@end

