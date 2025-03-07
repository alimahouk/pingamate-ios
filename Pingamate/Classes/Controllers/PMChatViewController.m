//
//  PMChatViewController.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMChatViewController.h"

#import "PMAppDelegate.h"
#import "PMUser.h"
#import "PMUserBubble.h"

@implementation PMChatViewController


- (instancetype)initWithUser:(PMUser *)user
{
        self = [super init];
        
        if ( self ) {
                activeUser        = user;
                _darkThemeEnabled = NO;
                messages          = [NSMutableOrderedSet orderedSet];
                messageIndex      = 0;
                
                [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] addDelegate:self];
        }
        
        return self;
}

#pragma mark -

- (PMUser *)user
{
        return activeUser;
}

- (void)dealloc
{
        [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] removeDelegate:self];
}

- (void)dismissView
{
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadView
{
        [super loadView];
        
        self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        
        backgroundView                   = [[UIVisualEffectView alloc] initWithFrame:self.view.bounds];
        backgroundView.contentView.alpha = 0.0;
        
        chatView                                = [[UIScrollView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        chatView.contentSize                    = CGSizeMake(UIScreen.mainScreen.bounds.size.width + 1, UIScreen.mainScreen.bounds.size.height + 1);
        chatView.delegate                       = self;
        chatView.pagingEnabled                  = YES;
        chatView.showsHorizontalScrollIndicator = NO;
        chatView.showsVerticalScrollIndicator   = NO;
        
        closeButton                 = [UIButton buttonWithType:UIButtonTypeSystem];
        closeButton.frame           = CGRectMake(UIScreen.mainScreen.bounds.size.width - 37, 32, 32, 32);
        closeButton.titleLabel.font = [UIFont systemFontOfSize:32];
        
        messageTarget                  = [[PMUserBubble alloc] initWithUser:activeUser];
        messageTarget.darkThemeEnabled = _darkThemeEnabled;
        messageTarget.frame            = CGRectMake((UIScreen.mainScreen.bounds.size.width / 2) - ((self.view.bounds.size.height - ((self.view.bounds.size.width * 4) / 3) - 69) / 2),
                                                    20,
                                                    self.view.bounds.size.height - ((self.view.bounds.size.width * 4) / 3) - 69,
                                                    self.view.bounds.size.height - ((self.view.bounds.size.width * 4) / 3) - 69);
        messageTarget.showsName        = YES;
        
        [closeButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:@"×" forState:UIControlStateNormal];
        [closeButton setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
        
        if ( _darkThemeEnabled )
                [closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        else
                [closeButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        
        [messageTarget setNeedsDisplay];
        
        [self.view addSubview:backgroundView];
        [backgroundView.contentView addSubview:messageTarget];
        [backgroundView.contentView addSubview:chatView];
        [backgroundView.contentView addSubview:closeButton];
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        
}

- (void)viewDidAppear:(BOOL)animated
{
        UIBlurEffect *backgroundBlur;
        
        [super viewDidAppear:animated];
        
        backgroundBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        
        [UIView animateWithDuration:0.2 animations:^{
                backgroundView.effect            = backgroundBlur;
                backgroundView.contentView.alpha = 1.0;
                self.view.backgroundColor        = UIColor.clearColor;
        }];
}


@end
