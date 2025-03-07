//
//  PMLiveReaction.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/6/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import UIKit;

@interface PMLiveReaction : NSObject

@property (nonatomic) NSString *userID;
@property (nonatomic) UIImage *reaction;
@property (nonatomic, readonly) UIImage *boomerang;

- (instancetype)initWithReaction:(UIImage *)reaction;

- (UIImage *)boomerang;

@end
