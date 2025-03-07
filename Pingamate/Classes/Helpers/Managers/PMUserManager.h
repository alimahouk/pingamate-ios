//
//  PMUserManager.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/2/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import Foundation;

#import "PMUser.h"

@interface PMUserManager : NSObject
{
        NSMutableOrderedSet<PMUser *> *list;
}

@property (nonatomic, readonly) NSOrderedSet<PMUser *> *users;

- (void)addUser:(PMUser *)user;
- (void)removeUser:(PMUser *)user;

@end
