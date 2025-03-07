//
//  PMUser.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMUser.h"

@implementation PMUser


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                _identifier = NSUUID.UUID.UUIDString;
        }
        
        return self;
}

#pragma mark -

- (BOOL)isEqual:(id)object
{
        if ( object) {
                if ( [object isKindOfClass:PMUser.class] ) {
                        PMUser *user;
                        
                        user = (PMUser *)object;
                        
                        if ( [user.identifier isEqualToString:_identifier] )
                                return YES;
                }
        }
        
        return NO;
}


@end
