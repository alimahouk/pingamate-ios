//
//  PMLiveReaction.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/6/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMLiveReaction.h"

@implementation PMLiveReaction

- (instancetype)initWithReaction:(UIImage *)reaction
{
        self = [super init];
        
        if ( self ) {
                _reaction = reaction;
        }
        
        return self;
}

#pragma mark -

- (BOOL)isEqual:(id)object
{
        if ( object &&
             [object isKindOfClass:PMLiveReaction.class] ) {
                PMLiveReaction *temp;
                
                temp = (PMLiveReaction *)object;
                
                if ( [temp.userID isEqualToString:_userID] )
                        return YES;
        }
        
        return NO;
}

- (UIImage *)boomerang
{
        NSArray *reversedFrames;
        NSMutableArray *allFrames;
        UIImage *boomerang;
        
        allFrames      = [NSMutableArray arrayWithArray:_reaction.images];
        reversedFrames = [[allFrames reverseObjectEnumerator] allObjects];
        
        [allFrames addObjectsFromArray:reversedFrames];
        
        boomerang = [UIImage animatedImageWithImages:allFrames duration:1.0];
        
        return boomerang;
}

@end
