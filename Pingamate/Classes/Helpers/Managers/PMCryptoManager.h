//
//  PMCryptoManager.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Foundation;

#import "PMSec.h"

@class PMCryptoManager;
@class PMUser;

@protocol PMCryptoManagerDelegate <NSObject>

- (void)cryptoManagerDidCreateNewKey:(PMCryptoManager *)manager;
- (void)cryptoManagerFoundExistingKey:(PMCryptoManager *)manager;

@end

@interface PMCryptoManager : NSObject
{
        EVP_PKEY *clientKey;
        EVP_PKEY *serverPublicKey;
}

@property (nonatomic, readonly) EVP_PKEY *userKey;
@property (nonatomic, weak) id<PMCryptoManagerDelegate> delegate;

- (NSData *)decryptServerMessage:(NSData *)messageData;
- (NSData *)encryptServerMessage:(NSData *)messageData;
- (NSData *)decryptMessage:(NSData *)messageData forUser:(PMUser *)user;
- (NSData *)encryptMessage:(NSData *)messageData forUser:(PMUser *)user;
- (NSData *)signMessage:(NSData *)digest;

- (void)bootstrap;

@end
