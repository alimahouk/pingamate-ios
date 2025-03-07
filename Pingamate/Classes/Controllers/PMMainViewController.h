//
//  PMMainViewController.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

#import "PMCameraViewController.h"
#import "PMDirector.h"

@class PMMapViewController;
@class PMTextViewController;
@class PMViewController;

@interface PMMainViewController : UITabBarController <PMCameraViewControllerDelegate, PMDirectorDelegate, UITabBarControllerDelegate>
{
        PMCameraViewController *cameraController;
        PMMapViewController *mapController;
        PMTextViewController *textController;
        PMViewController *activeController;
        BOOL foundExistingIdentity;
}


@end
