//
//  PMMainViewController.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMMainViewController.h"

#import "PMAppDelegate.h"
#import "PMChatViewController.h"
#import "PMMapViewController.h"
#import "PMProfileViewController.h"
#import "PMTextViewController.h"
#import "PMUser.h"

@implementation PMMainViewController


- (instancetype)init
{
        /*
         * NOTE ABOUT UITABBARCONTROLLER
         * calling [super init] causes viewDidLoad
         * to be called before the init method
         * continues, so make sure to put all
         * viewDidLoad-critical code in viewDidLoad
         * itself.
         */
        self = [super init];
        
        if ( self ) {
                cameraController          = [PMCameraViewController new];
                cameraController.delegate = self;
                
                foundExistingIdentity = NO;
                mapController         = [PMMapViewController new];
                textController        = [PMTextViewController new];
                
                [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] addDelegate:self];
                
                self.delegate            = self;
                self.tabBar.barTintColor = UIColor.blackColor;
                self.viewControllers     = @[cameraController, textController, mapController];
        }
        
        return self;
}

#pragma mark -

- (void)cameraViewDidBeginRecordingVideo:(PMCameraViewController *)cameraView
{
        [UIView animateWithDuration:0.2 animations:^{
                self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                               self.view.bounds.size.height,
                                               self.tabBar.bounds.size.width,
                                               self.tabBar.bounds.size.height);
        }];
}

- (void)cameraViewDidFinishRecordingVideo:(PMCameraViewController *)cameraView
{
        [UIView animateWithDuration:0.2 animations:^{
                self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x,
                                               self.view.bounds.size.height - self.tabBar.bounds.size.height,
                                               self.tabBar.bounds.size.width,
                                               self.tabBar.bounds.size.height);
        }];
}

- (void)dealloc
{
        [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] removeDelegate:self];
}

- (void)directorDetectedBackgroundState
{
        dispatch_async(dispatch_get_main_queue(), ^{
                self.selectedViewController = cameraController;
                
                [cameraController closeViewfinder];
        });
}

- (void)directorDetectedForegroundState
{
        if ( foundExistingIdentity )
                [cameraController openViewfinder];
}

- (void)directorNeedsNewIdentity
{
        foundExistingIdentity = NO;
        
        [self presentProfileForUser:nil];
}

- (void)directorFoundExistingIdentity
{
        foundExistingIdentity = YES;
        
        [cameraController openViewfinder];
}

- (void)loadView
{
        [super loadView];
        
        
}

- (void)presentProfileForUser:(PMUser *)user
{
        PMProfileViewController *profileView;
        
        profileView = [[PMProfileViewController alloc] initWithUser:user];
        
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:profileView animated:YES completion:nil];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(PMViewController *)viewController
{
        if ( ![viewController isEqual:activeController] ) {
                [activeController didChangeControllerFocus:NO];
                [viewController didChangeControllerFocus:YES];
                
                activeController = viewController;
        }
}

- (void)viewDidLoad
{
        [super viewDidLoad];
}


@end
