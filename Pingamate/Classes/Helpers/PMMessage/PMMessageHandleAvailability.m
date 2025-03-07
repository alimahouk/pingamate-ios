//
//  PMMessageHandleAvailability.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/7/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessageHandleAvailability.h"

#import "PMSec.h"

@implementation PMMessageHandleAvailability


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

- (NSData *)serialize
{
        NSMutableData *data;
        
        /*
         * This message is nothing but the hash of the
         * handle (length not required).
         */
        data = [NSMutableData dataWithData:handleHash];
        
        return data;
}

- (NSString *)handle
{
        return i_handle;
}


@end
