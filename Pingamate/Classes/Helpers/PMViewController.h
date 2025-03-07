//
//  PMViewController.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import UIKit;

@interface PMViewController : UIViewController

@property (nonatomic) BOOL isFocusedController;

- (void)didChangeControllerFocus:(BOOL)focused;

@end
