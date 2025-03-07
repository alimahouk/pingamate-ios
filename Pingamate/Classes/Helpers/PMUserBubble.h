//
//  PMUserBubble.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/18/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

#define DEFAULT_BUBBLE_SIZE     50

@class PMLiveReaction;
@class PMUser;

@interface PMUserBubble : UIView
{
        CAShapeLayer *presenceFrame;
        CAShapeLayer *selectionFrame;
        PMLiveReaction *liveReaction;
        PMUser *activeUser;
        UIButton *thumbnail;
        UILabel *nameLabel;
}

@property (nonatomic) PMLiveReaction *reaction;
@property (nonatomic, readonly) PMUser *user;
@property (nonatomic) BOOL darkThemeEnabled;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL showsName;

- (instancetype)initWithUser:(PMUser *)user;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
