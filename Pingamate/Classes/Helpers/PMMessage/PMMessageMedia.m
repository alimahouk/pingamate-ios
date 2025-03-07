//
//  PMMessageMedia.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessageMedia.h"

@implementation PMMessageMedia


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                _mediaType = PMMediaTypeNone;
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

- (instancetype)initWithMediaType:(PMMediaType)mediaType
{
        self = [super init];
        
        if ( self ) {
                _mediaType = mediaType;
        }
        
        return self;
}

- (NSData *)serialize
{
        NSMutableData *data;
        
        
        
        return data;
}


@end
