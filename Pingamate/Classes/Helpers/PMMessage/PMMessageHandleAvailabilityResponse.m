//
//  PMMessageHandleAvailabilityResponse.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/8/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessageHandleAvailabilityResponse.h"

#import "constants.h"
#import "PMSec.h"

@implementation PMMessageHandleAvailabilityResponse


- (instancetype)initWithData:(NSData *)data
{
        // The data should contain a hash + 1 error byte.
        if ( data &&
             data.length == (SHA256_DIGEST_LENGTH + 1) * sizeof(unsigned char) ) {
                self = [super init];
                
                if ( self ) {
                        unsigned char *bytes;
                        unsigned char  hash[SHA256_DIGEST_LENGTH];
                        unsigned int length;
                        char errorByte;
                        
                        bytes  = (unsigned char *)data.bytes;
                        length = SHA256_DIGEST_LENGTH * sizeof(unsigned char);
                        
                        memcpy(hash, data.bytes, length);
                        
                        errorByte    = bytes[SHA256_DIGEST_LENGTH];
                        i_handleHash = [NSData dataWithBytes:hash length:length];
                        
                        if ( errorByte == 1 )
                                self.error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                                                 code:PMErrorHandleUnavailable
                                                             userInfo:@{NSLocalizedDescriptionKey: @"Handle unavailable"}];
                }
                
                return self;
        }
        
        return nil;
}

#pragma mark -

- (NSData *)handleHash
{
        return i_handleHash;
}


@end
