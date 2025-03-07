//
//  PMMessageHandleAvailabilityResponse.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/8/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessageResponse.h"

@interface PMMessageHandleAvailabilityResponse : PMMessageResponse
{
        NSData *i_handleHash;
}

@property (readonly, nonatomic) NSData *handleHash;

@end
