//
//  PMSec.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Foundation;

#import <openssl/ecdsa.h>
#import <openssl/evp.h>
#import <openssl/sha.h>

@interface PMSec : NSObject

+ (ECDSA_SIG *)decodeSignature:(NSData *)data;
+ (ECDSA_SIG *)ECDSASign:(NSData *)hash key:(EVP_PKEY *)pkey;

+ (EVP_PKEY *)decodeKey:(NSData *)data;
+ (EVP_PKEY *)fetchPrivateKey:(NSString *)path;
+ (EVP_PKEY *)fetchPublicKey:(NSString *)path;
+ (EVP_PKEY *)generateKey;

+ (int)dumpPrivateKey:(EVP_PKEY *)pkey path:(NSString *)path;
+ (int)dumpPublicKey:(EVP_PKEY *)pkey path:(NSString *)path;
+ (int)ECDSAVerify:(NSData *)hash signature:(ECDSA_SIG *)sign key:(EVP_PKEY *)pkey;

+ (NSData *)AESDecrypt:(NSData *)ciphertext key:(NSData *)key;
+ (NSData *)AESEncrypt:(NSData *)plaintext key:(NSData *)key;
+ (NSData *)encodeKey:(EVP_PKEY *)key;
+ (NSData *)ECDH:(EVP_PKEY *)privateKey publicKey:(EVP_PKEY *)publicKey;
+ (NSData *)encodeSignature:(ECDSA_SIG *)sign;
+ (NSData *)SHA:(NSData *)data;
+ (NSData *)SHAString:(NSString *)str;
+ (NSData *)strtod:(NSString *)str size:(int *)size;
+ (NSData *)UUID;

+ (NSString *)dtostr:(NSData *)data;
+ (NSString *)UUIDString;

+ (void)cleanup;
+ (void)initLibrary;

@end
