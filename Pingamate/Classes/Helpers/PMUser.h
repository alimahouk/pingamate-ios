//
//  PMUser.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/16/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

#import <openssl/evp.h>
#import "constants.h"

@interface PMUser : NSObject

@property (nonatomic) EVP_PKEY *publicKey;
@property (strong, nonatomic) NSString *handle;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *displayPhoto;
@property (nonatomic) PMUserPresence presence;

@end
