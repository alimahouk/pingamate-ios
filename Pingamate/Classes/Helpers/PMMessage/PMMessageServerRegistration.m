//
//  PMMessageServerGreeting.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/7/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessageServerRegistration.h"

#import "PMSec.h"

@implementation PMMessageServerRegistration


- (instancetype)initWithHandle:(NSString *)handle
{
        if ( handle ) {
                self = [super init];
                
                if ( self ) {
                        i_handle   = handle;
                        handleHash = [PMSec SHAString:handle];
                }
                
                return self;
        }
        
        return nil;
}

#pragma mark -

- (instancetype)initWithData:(NSData *)data
{
        if ( data ) {
                self = [super init];
                
                if ( self ) {
                        
                }
                
                return self;
        }
        
        return nil;
}

- (NSData *)serialize
{
        NSMutableData *data;
        
        
        
        return data;
}

- (NSString *)handle
{
        return i_handle;
}


@end
