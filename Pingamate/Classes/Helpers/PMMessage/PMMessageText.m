//
//  PMMessageText.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/2/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessageText.h"

@implementation PMMessageText


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                
        }
        
        return self;
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


@end
