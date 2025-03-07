//
//  PMMessage.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/30/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMMessage.h"

#import "PMSec.h"

@implementation PMMessage


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                _timeSent   = NSDate.date;
                _identifier = [PMSec UUIDString];
        }
        
        return self;
}

- (instancetype)initWithData:(NSData *)data
{
        self = [super init];
        
        if ( self ) {
                
        }
        
        return self;
}

#pragma mark -

- (BOOL)isEqual:(id)object
{
        if ( object) {
                if ( [object isKindOfClass:PMMessage.class] ) {
                        PMMessage *message;
                        
                        message = (PMMessage *)object;
                        
                        if ( [message.identifier isEqualToString:_identifier] )
                                return YES;
                }
        }
        
        return NO;
}

- (NSData *)serialize
{
        return nil;
}


@end
