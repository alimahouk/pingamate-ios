//
//  PMViewController.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMViewController.h"

@implementation PMViewController


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                _isFocusedController = NO;
        }
        
        return self;
}

- (void)didChangeControllerFocus:(BOOL)focused
{
        _isFocusedController = focused;
}


@end
