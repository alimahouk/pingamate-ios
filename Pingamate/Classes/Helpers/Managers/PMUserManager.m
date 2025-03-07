//
//  PMUserManager.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/2/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMUserManager.h"

@implementation PMUserManager


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                list = [NSMutableOrderedSet orderedSet];
                
                [self loadUsers];
                
                for ( int i = 0; i < 2; i++ ) {
                        PMUser *contact;
                        
                        contact = [PMUser new];
                        
                        if ( i == 0 ) {
                                contact.handle = @"PayvanD";
                                contact.name   = @"Diana";
                        } else {
                                contact.handle = @"qrm70";
                                contact.name   = @"Dad";
                        }
                        
                        
                        [self addUser:contact];
                }
        }
        
        return self;
}

#pragma mark -

- (NSOrderedSet<PMUser *> *)users
{
        return list;
}

- (void)addUser:(PMUser *)user
{
        [list addObject:user];
}

- (void)loadUsers
{
        
}

- (void)removeUser:(PMUser *)user
{
        
}


@end
