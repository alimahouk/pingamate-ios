//
//  PMMessageServerRegistration.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/7/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMessage.h"

@interface PMMessageServerRegistration : PMMessage
{
        NSData *handleHash;
        NSString *i_handle;
}

@property (readonly, nonatomic) NSString *handle;

@end
