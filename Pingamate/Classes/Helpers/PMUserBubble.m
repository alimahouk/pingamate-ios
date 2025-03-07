//
//  PMUserBubble.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/18/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMUserBubble.h"

#import "PMLiveReaction.h"
#import "PMUser.h"

@implementation PMUserBubble


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                [self setup];
        }
        
        return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
        self = [super initWithFrame:frame];
        
        if ( self ) {
                [self setup];
        }
        
        return self;
}

- (instancetype)initWithUser:(PMUser *)user
{
        self = [super init];
        
        if ( self ) {
                activeUser = user;
                
                [self setup];
        }
        
        return self;
}

#pragma mark -

- (BOOL)showsName
{
        return !nameLabel.hidden;
}

- (PMLiveReaction *)reaction
{
        return liveReaction;
}

- (PMUser *)user
{
        return activeUser;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
        [thumbnail addTarget:target action:action forControlEvents:controlEvents];
}

- (void)drawRect:(CGRect)rect
{
        CAShapeLayer *circleMask;
        UIBezierPath *circleMaskPath;
        UIBezierPath *presenceFramePath;
        UIBezierPath *selectionFramePath;
        
        [super drawRect:rect];
        
        if ( presenceFrame ) {
                [presenceFrame removeFromSuperlayer];
                
                presenceFrame = nil;
        }
        
        if ( selectionFrame ) {
                [selectionFrame removeFromSuperlayer];
                
                selectionFrame = nil;
        }
        
        circleMaskPath     = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, thumbnail.bounds.size.width, thumbnail.bounds.size.height)
                                                       cornerRadius:(MAX(thumbnail.bounds.size.width, thumbnail.bounds.size.height) / 2)];
        presenceFramePath  = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(thumbnail.frame.origin.x - 1, thumbnail.frame.origin.y - 1, thumbnail.bounds.size.width + 2, thumbnail.bounds.size.height + 2)
                                                       cornerRadius:(MAX(thumbnail.bounds.size.width, thumbnail.bounds.size.height) / 2)];
        selectionFramePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(thumbnail.frame.origin.x - 3, thumbnail.frame.origin.y - 3, thumbnail.bounds.size.width + 6, thumbnail.bounds.size.height + 6)
                                                       cornerRadius:(MAX(thumbnail.bounds.size.width, thumbnail.bounds.size.height) / 2)];
        
        circleMask             = [CAShapeLayer layer];
        circleMask.path        = circleMaskPath.CGPath;
        circleMask.fillColor   = UIColor.blackColor.CGColor;
        circleMask.strokeColor = UIColor.blackColor.CGColor;
        circleMask.lineWidth   = 0;
        
        presenceFrame           = [CAShapeLayer layer];
        presenceFrame.path      = presenceFramePath.CGPath;
        presenceFrame.fillColor = UIColor.clearColor.CGColor;
        presenceFrame.lineWidth = 2;
        
        selectionFrame           = [CAShapeLayer layer];
        selectionFrame.path      = selectionFramePath.CGPath;
        selectionFrame.fillColor = UIColor.clearColor.CGColor;
        selectionFrame.lineWidth = 2;
        
        if ( activeUser.presence == PMUserPresenceOnline )
                presenceFrame.strokeColor = UIColor.greenColor.CGColor;
        else
                presenceFrame.strokeColor = UIColor.whiteColor.CGColor;
        
        if ( _selected )
                selectionFrame.strokeColor = PM_THEME_BLUE.CGColor;
        else
                selectionFrame.strokeColor = UIColor.clearColor.CGColor;
        
        thumbnail.layer.mask = circleMask;
        
        [self.layer addSublayer:selectionFrame];
        [self.layer addSublayer:presenceFrame];
}

- (void)setFrame:(CGRect)frame
{
        [super setFrame:frame];
        
        nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, frame.size.width - 19, frame.size.width, nameLabel.bounds.size.height);
        thumbnail.frame = CGRectMake(thumbnail.frame.origin.x, thumbnail.frame.origin.y, frame.size.width - 33, frame.size.width - 33);
}

- (void)setNeedsDisplay
{
        [super setNeedsDisplay];
        
        if ( liveReaction ) {
                [thumbnail setImage:[liveReaction.boomerang imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        } else {
                if ( activeUser.displayPhoto )
                        [thumbnail setImage:[activeUser.displayPhoto imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                else
                        [thumbnail setImage:[[UIImage imageNamed:@"UserSilhouette"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        
        if ( activeUser.name )
                nameLabel.text = activeUser.name;
        else
                nameLabel.text = activeUser.handle;
        
        if ( _darkThemeEnabled )
                nameLabel.textColor = UIColor.whiteColor;
        else
                nameLabel.textColor = UIColor.blackColor;
}

- (void)setReaction:(PMLiveReaction *)reaction
{
        liveReaction = reaction;
        
        [self setNeedsDisplay];
}

- (void)setShowsName:(BOOL)showsName
{
        nameLabel.hidden = !showsName;
}

- (void)setup
{
        self.frame  = CGRectMake(0, 0, DEFAULT_BUBBLE_SIZE, thumbnail.bounds.size.height + nameLabel.frame.origin.y + nameLabel.bounds.size.height);
        self.opaque = NO;
        
        _darkThemeEnabled = NO;
        
        nameLabel                           = [[UILabel alloc] initWithFrame:CGRectMake(0, DEFAULT_BUBBLE_SIZE + 5, self.bounds.size.width, 15)];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        nameLabel.backgroundColor           = UIColor.clearColor;
        nameLabel.font                      = [UIFont systemFontOfSize:13];
        nameLabel.hidden                    = YES;
        nameLabel.minimumScaleFactor        = 10.0 / nameLabel.font.pointSize;
        nameLabel.numberOfLines             = 1;
        nameLabel.opaque                    = NO;
        nameLabel.textAlignment             = NSTextAlignmentCenter;
        
        thumbnail       = [UIButton buttonWithType:UIButtonTypeSystem];
        thumbnail.frame = CGRectMake(17, 10, DEFAULT_BUBBLE_SIZE, DEFAULT_BUBBLE_SIZE);
        
        [self addSubview:thumbnail];
        [self addSubview:nameLabel];
}


@end
