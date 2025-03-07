//
//  PMChatViewController.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

#import "PMDirector.h"

@class PMIMView;
@class PMUser;
@class PMUserBubble;

@interface PMChatViewController : UIViewController <PMDirectorDelegate, UIScrollViewDelegate>
{
        NSMutableOrderedSet<PMIMView *> *messages;
        PMUser *activeUser;
        PMUserBubble *messageTarget;
        UIButton *closeButton;
        UIScrollView *chatView;
        UIVisualEffectView *backgroundView;
        NSInteger messageIndex;
}

@property (nonatomic) BOOL darkThemeEnabled;
@property (nonatomic, readonly) PMUser *user;

- (instancetype)initWithUser:(PMUser *)user;

@end
