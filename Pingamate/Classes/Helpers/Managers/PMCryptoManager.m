//
//  PMCryptoManager.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMCryptoManager.h"

#import "constants.h"
#import "PMModelManager.h"
#import "PMUser.h"

@implementation PMCryptoManager


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                
        }
        
        return self;
}

#pragma mark -

- (EVP_PKEY *)userKey
{
        return clientKey;
}

- (NSData *)decryptServerMessage:(NSData *)messageData
{
        NSData *decryptionKey;
        
        if ( !messageData )
                return nil;
        
        decryptionKey = [PMSec ECDH:clientKey publicKey:serverPublicKey];
        
        return [PMSec AESDecrypt:messageData key:decryptionKey];
}

- (NSData *)encryptServerMessage:(NSData *)messageData
{
        NSData *encryptionKey;
        
        if ( !messageData )
                return nil;
        
        encryptionKey = [PMSec ECDH:clientKey publicKey:serverPublicKey];
        
        return [PMSec AESEncrypt:messageData key:encryptionKey];
}

- (NSData *)decryptMessage:(NSData *)messageData forUser:(PMUser *)user
{
        NSData *decryptionKey;
        
        if ( !messageData )
                return nil;
        
        decryptionKey = [PMSec ECDH:clientKey publicKey:user.publicKey];
        
        return [PMSec AESDecrypt:messageData key:decryptionKey];
}

- (NSData *)encryptMessage:(NSData *)messageData forUser:(PMUser *)user
{
        NSData *encryptionKey;
        
        if ( !messageData )
                return nil;
        
        encryptionKey = [PMSec ECDH:clientKey publicKey:user.publicKey];
        
        return [PMSec AESEncrypt:messageData key:encryptionKey];
}

- (NSData *)signMessage:(NSData *)digest
{
        ECDSA_SIG *signature;
        NSData *signatureEncoded;
        
        if ( !digest )
                return nil;
        
        signature        = [PMSec ECDSASign:digest key:clientKey];
        signatureEncoded = [PMSec encodeSignature:signature];
        
        return signatureEncoded;
}

- (void)bootstrap
{
        [PMSec initLibrary];
        
        // Check for the server's key (must match hardcoded checksum).
        serverPublicKey = [PMSec fetchPublicKey:[NSBundle.mainBundle pathForResource:PM_FILE_SERVER_PUBLIC_KEY ofType:@"pem"]];
        
        if ( serverPublicKey ) {
                NSData *encoding;
                NSData *checksum;
                NSString *hash;
                
                encoding = [PMSec encodeKey:serverPublicKey];
                checksum = [PMSec SHA:encoding];
                hash     = [PMSec dtostr:checksum];
                
                if ( ![hash isEqualToString:PM_SERVER_KEY_CHECKSUM] )
                        NSLog(@"Server's public key is corrupt!");
        } else {
                NSLog(@"Missing server's public key!");
        }
        
        // Check for the client's keys.
        clientKey = [PMSec fetchPrivateKey:[PMModelManager pathForClientPrivateKey]];
        
        if ( !clientKey ) {
                NSLog(@"Generating fresh keys!");
                
                clientKey = [PMSec generateKey];
                
                [PMSec dumpPrivateKey:clientKey path:[PMModelManager pathForClientPrivateKey]];
                [PMSec dumpPublicKey:clientKey path:[PMModelManager pathForClientPublicKey]];
                
                if ( [_delegate respondsToSelector:@selector(cryptoManagerDidCreateNewKey:)] )
                        [_delegate cryptoManagerDidCreateNewKey:self];
        } else {
                if ( [_delegate respondsToSelector:@selector(cryptoManagerFoundExistingKey:)] )
                        [_delegate cryptoManagerFoundExistingKey:self];
        }
}


@end
