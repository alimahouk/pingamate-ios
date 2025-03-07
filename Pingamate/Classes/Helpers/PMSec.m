//
//  PMSec.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMSec.h"

#import <openssl/conf.h>
#import <openssl/err.h>
#import <openssl/ssl.h>

#import "PMUtil.h"

@implementation PMSec


/**
 * Decodes a DER-encoded ECDSA signature.
 * @return A pointer to the ECDSA_SIG structure or NULL.
 */
+ (ECDSA_SIG *)decodeSignature:(NSData *)data
{
        const unsigned char *q;
        
        q = data.bytes;
        
        return d2i_ECDSA_SIG(NULL, &q, data.length);
}

/**
 * Signs the given hash with the given private key.
 */
+ (ECDSA_SIG *)ECDSASign:(NSData *)hash key:(EVP_PKEY *)pkey
{
        EC_KEY *ec_key = EVP_PKEY_get1_EC_KEY(pkey);
        
        return ECDSA_do_sign(hash.bytes, (int)hash.length, ec_key);
}

/**
 * Converts DER data into a public key.
 * @return The key.
 */
+ (EVP_PKEY *)decodeKey:(NSData *)data
{
        EVP_PKEY *key;
        const unsigned char *q;
        
        q = data.bytes;
        
        key = d2i_PUBKEY(NULL, &q, data.length);
        
        return key;
}

+ (EVP_PKEY *)fetchPrivateKey:(NSString *)path
{
        EC_KEY *ec_key;
        EVP_PKEY *pkey;
        FILE *f_key;
        
        ec_key = NULL;
        f_key  = [PMUtil openFile:path];
        pkey   = NULL;
        
        if ( f_key ) {
                ec_key = PEM_read_ECPrivateKey(f_key, NULL, NULL, NULL);
                
                if ( ec_key )
                        assert(EC_KEY_check_key(ec_key) == 1);
                
                fclose(f_key);
        }
        
        if ( ec_key ) {
                pkey = EVP_PKEY_new();
                
                assert(EVP_PKEY_assign_EC_KEY(pkey, ec_key) == 1);
        }
        
        return pkey;
}

+ (EVP_PKEY *)fetchPublicKey:(NSString *)path
{
        EC_KEY *ec_key;
        EVP_PKEY *pkey;
        FILE *f_key;
        
        ec_key = NULL;
        f_key  = [PMUtil openFile:path];
        pkey   = NULL;
        
        if ( f_key ) {
                ec_key = PEM_read_EC_PUBKEY(f_key, NULL, NULL, NULL);
                
                /*
                 * If this is a private key, don't bother trying to open
                 * the public key's file (doesn't exist anyway). The public
                 * key is computed using the private key.
                 */
                if ( ec_key )
                        assert(EC_KEY_check_key(ec_key) == 1);
                
                fclose(f_key);
        }
        
        if ( ec_key ) {
                pkey = EVP_PKEY_new();
                
                assert(EVP_PKEY_assign_EC_KEY(pkey, ec_key) == 1);
        }
        
        return pkey;
}

+ (EVP_PKEY *)generateKey
{
        BIO *bio;
        EC_KEY *ec_key;
        EVP_PKEY *pkey;
        
        bio    = BIO_new(BIO_s_mem());
        ec_key = EC_KEY_new_by_curve_name(NID_secp256k1);
        pkey   = EVP_PKEY_new();
        
        EC_KEY_set_asn1_flag(ec_key, OPENSSL_EC_NAMED_CURVE);
        
        // Create the public/private EC key pair here.
        if ( !(EC_KEY_generate_key(ec_key)) )
                BIO_printf(bio, "crypto_gen_keys: error generating the ECC key.");
        
        /*
         * Converting the EC key into a PKEY structure lets us
         * handle the key just like any other key pair.
         */
        if ( !EVP_PKEY_assign_EC_KEY(pkey, ec_key) )
                BIO_printf(bio, "crypto_gen_keys: error assigning ECC key to EVP_PKEY structure.");
        
        // Cleanup.
        BIO_free_all(bio);
        
        return pkey;
}

/**
 * Saves the given key to the disk.
 * @return 0 on success, 1 if the file could not be created, or -1 if there
 * was a problem with the passed key.
 */
+ (int)dumpPrivateKey:(EVP_PKEY *)pkey path:(NSString *)path
{
        const BIGNUM *private_key;
        EC_KEY *ec_key;
        FILE *f_key;
        int err_no;
        
        ec_key = EVP_PKEY_get1_EC_KEY(pkey);
        err_no = 0;
        
        if ( ec_key ) {
                f_key       = [PMUtil makeFile:path];
                private_key = EC_KEY_get0_private_key(ec_key);
                
                if ( f_key ) {
                        if ( private_key ) {
                                if ( !PEM_write_ECPrivateKey(f_key, ec_key, NULL, NULL, 0, NULL, NULL) ) {
                                        [self error];
                                        
                                        err_no = EXIT_FAILURE;
                                }
                        } else {
                                err_no = -1;
                        }
                        
                        EC_KEY_free(ec_key);
                        fclose(f_key);
                } else {
                        err_no = 1;
                }
        } else {
                err_no = -1;
        }
        
        return err_no;
}

/**
 * Saves the given key to the disk.
 * @return 0 on success, 1 if the file could not be created, or -1 if there
 * was a problem with the passed key.
 */
+ (int)dumpPublicKey:(EVP_PKEY *)pkey path:(NSString *)path
{
        EC_KEY *ec_key;
        FILE *f_key;
        int err_no;
        
        ec_key = EVP_PKEY_get1_EC_KEY(pkey);
        err_no = 0;
        
        if ( ec_key ) {
                f_key = [PMUtil makeFile:path];
                
                if ( f_key ) {
                        if ( !PEM_write_EC_PUBKEY(f_key, ec_key) ) {
                                [self error];
                                
                                err_no = EXIT_FAILURE;
                        }
                        
                        EC_KEY_free(ec_key);
                        fclose(f_key);
                } else {
                        err_no = 1;
                }
        } else {
                err_no = -1;
        }
        
        return err_no;
}

/**
 * Verfies that a signature was created by the private half of the given
 * public key.
 * @return 1 if the signature is okay, 0 if the signature is incorrect, or
 * -1 if an error occured.
 */
+ (int)ECDSAVerify:(NSData *)hash signature:(ECDSA_SIG *)sign key:(EVP_PKEY *)pkey
{
        EC_KEY *ec_key;
        
        ec_key = EVP_PKEY_get1_EC_KEY(pkey);
        
        return ECDSA_do_verify(hash.bytes, (int)hash.length, sign, ec_key);
}

/**
 * AES algorithms courtesy of the
 * <a href="https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption">OpenSSL wiki</a>.
 * @return The length of the plaintext.
 */
+ (NSData *)AESDecrypt:(NSData *)ciphertext key:(NSData *)key
{
        EVP_CIPHER_CTX *ctx;
        NSData *plaintext;
        unsigned char *buffer;
        int len;
        
        buffer = NULL;
        ctx    = NULL;
        len    = 0;
        
        // Create & initialise the context.
        if ( !(ctx = EVP_CIPHER_CTX_new()) )
                [self error];
        
        /*
         * Initialise the decryption operation. IMPORTANT - ensure you use a key
         * and IV size appropriate for your cipher.
         * In this example we are using 256 bit AES (i.e. a 256 bit key). The
         * IV size for *most* modes is the same as the block size. For AES this
         * is 128 bits.
         */
        if ( EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key.bytes, NULL) != 1 ) {
                [self error];
                
                return nil;
        }
        
        /*
         * Provide the message to be decrypted, and obtain the plaintext output.
         * EVP_DecryptUpdate can be called multiple times if necessary.
         */
        if ( EVP_DecryptUpdate(ctx, buffer, &len, ciphertext.bytes, (int)ciphertext.length) != 1 ) {
                [self error];
                
                return nil;
        }
        
        /*
         * Finalise the decryption. Further plaintext bytes may be written at
         * this stage.
         */
        if ( EVP_DecryptFinal_ex(ctx, buffer + len, &len) != 1 ) {
                [self error];
                
                return nil;
        }
        
        plaintext = [NSData dataWithBytes:buffer length:(len * sizeof(unsigned char))];
        
        // Clean up.
        EVP_CIPHER_CTX_free(ctx);
        
        return plaintext;
}

/**
 * AES algorithms courtesy of the
 * <a href="https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption">OpenSSL wiki</a>.
 * @return The length of the cyphertext.
 */
+ (NSData *)AESEncrypt:(NSData *)plaintext key:(NSData *)key
{
        EVP_CIPHER_CTX *ctx;
        NSData *ciphertext;
        unsigned char *buffer;
        int len;
        
        buffer = NULL;
        ctx    = NULL;
        len    = 0;
        
        // Create & initialise the context.
        if ( !(ctx = EVP_CIPHER_CTX_new()) )
                [self error];
        
        /*
         * Initialise the encryption operation. IMPORTANT - ensure you use a key
         * and IV size appropriate for your cipher.
         * In this example we are using 256 bit AES (i.e. a 256 bit key). The
         * IV size for *most* modes is the same as the block size. For AES this
         * is 128 bits.
         */
        if ( EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key.bytes, NULL) != 1 ) {
                [self error];
                
                return nil;
        }
        
        /*
         * Provide the message to be encrypted, and obtain the encrypted output.
         * EVP_EncryptUpdate can be called multiple times if necessary.
         */
        if ( EVP_EncryptUpdate(ctx, buffer, &len, plaintext.bytes, (int)plaintext.length) != 1 ) {
                [self error];
                
                return nil;
        }
        
        /*
         * Finalise the encryption. Further ciphertext bytes may be written at
         * this stage.
         */
        if ( EVP_EncryptFinal_ex(ctx, buffer + len, &len) != 1 ) {
                [self error];
                
                return nil;
        }
        
        ciphertext = [NSData dataWithBytes:buffer length:(len * sizeof(unsigned char))];
        
        // Clean up.
        EVP_CIPHER_CTX_free(ctx);
        
        return ciphertext;
}

/**
 * Converts a public key into DER format.
 * @return The length of the data, or -1 if an error occurred.
 */
+ (NSData *)encodeKey:(EVP_PKEY *)key
{
        unsigned char *buffer;
        int key_len;
        
        buffer  = NULL;
        key_len = i2d_PUBKEY(key, NULL);
        
        i2d_PUBKEY(key, &buffer);
        
        return [NSData dataWithBytes:buffer length:(key_len * sizeof(unsigned char))];
}

/**
 * DER-encodes the contents of ECDSA_SIG object.
 * @return The length of the DER encoded ECDSA_SIG object or 0.
 */
+ (NSData *)encodeSignature:(ECDSA_SIG *)sign
{
        unsigned char *buffer;
        int size;
        
        size = i2d_ECDSA_SIG(sign, &buffer);
        
        return [NSData dataWithBytes:buffer length:(size * sizeof(unsigned char))];
}

/**
 * Generates an elliptic curve Diffie-Hellman secret out of a key pair.
 * The secret is SHA-256-hashed.
 * @return The secret.
 */
+ (NSData *)ECDH:(EVP_PKEY *)privateKey publicKey:(EVP_PKEY *)publicKey
{
        EC_KEY *ec_private_key;
        EC_KEY *ec_public_key;
        NSData *secret;
        unsigned char *tmp;
        int field_size;
        int secret_len;
        int secret_len_final;
        
        ec_private_key   = EVP_PKEY_get1_EC_KEY(privateKey);
        ec_public_key    = EVP_PKEY_get1_EC_KEY(publicKey);
        field_size       = 0;
        secret_len       = 0;
        secret_len_final = 0;
        tmp              = NULL;
        
        // Calculate the size of the buffer for the shared secret.
        field_size = EC_GROUP_get_degree(EC_KEY_get0_group(ec_private_key));
        secret_len = (field_size + 7) / 8;
        
        // Allocate the memory for the shared secret
        if ( !(tmp = OPENSSL_malloc(secret_len)) )
                [self error];
        
        // Derive the shared secret.
        secret_len = ECDH_compute_key(tmp, secret_len, EC_KEY_get0_public_key(ec_public_key), ec_private_key, NULL);
        
        if ( secret_len <= 0 ) {
                OPENSSL_free(tmp);
                
                secret_len_final = -1;
        } else {
                /*
                 * Never use a derived secret directly. Typically, it is passed
                 * through some hash function to produce a key.
                 */
                secret = [NSData dataWithBytes:(const void *)tmp length:(secret_len * sizeof(unsigned char))];
                secret = [self SHA:secret];
        }
        
        return secret;
}

/**
 * Generates the double SHA-256 hash of the given binary data.
 */
+ (NSData *)SHA:(NSData *)data
{
        unsigned char buffer[SHA256_DIGEST_LENGTH];
        unsigned char tmp[SHA256_DIGEST_LENGTH];
        
        SHA256(data.bytes, data.length, tmp);
        SHA256(tmp, SHA256_DIGEST_LENGTH, buffer);
        
        return [NSData dataWithBytes:buffer length:(SHA256_DIGEST_LENGTH * sizeof(unsigned char))];
}

/**
 * Generates the SHA-256 hash of the given string.
 */
+ (NSData *)SHAString:(NSString *)str
{
        return [self SHA:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 * Converts a digest string into a byte array &
 * sets @p size to the size of the array.
 */
+ (NSData *)strtod:(NSString *)str size:(int *)size
{
        BIGNUM *input;
        NSData *digest;
        unsigned char *buffer;
        
        input  = BN_new();
        *size  = BN_hex2bn(&input, str.UTF8String);
        *size  = (*size + 1) / 2; // BN_hex2bn() returns number of hex digits
        buffer = malloc(*size);
        
        BN_bn2bin(input, buffer);
        
        digest = [NSData dataWithBytes:buffer length:(*size * sizeof(unsigned char))];
        
        BN_free(input);
        free(buffer);
        
        return digest;
}

/**
 * Generates a hash of a UUID.
 */
+ (NSData *)UUID
{
        return [self SHAString:NSUUID.UUID.UUIDString];
}

/**
 * Converts a byte array containing a digest into its string representation.
 */
+ (NSString *)dtostr:(NSData *)data
{
        BIGNUM *output;
        NSString *str;
        
        output = BN_new();
        
        BN_bin2bn(data.bytes, (int)data.length, output);
        
        str = [NSString stringWithUTF8String:BN_bn2hex(output)];
        
        BN_free(output);
        
        return str;
}

/**
 * Generates a UUID.
 * @return The hash of the UUID.
 */
+ (NSString *)UUIDString
{
        NSData *hash;
        
        hash = [self SHAString:NSUUID.UUID.UUIDString];
        
        return [self dtostr:hash];
}

+ (void)cleanup
{
        CRYPTO_cleanup_all_ex_data();
        ERR_free_strings();
        EVP_cleanup();
}

/**
 * Prints out all the errors generated by OpenSSL.
 */
+ (void)error
{
        ERR_print_errors_fp(stderr);
}

/**
 * Initialises the OpenSSL library.
 */
+ (void)initLibrary
{
        if ( SSL_library_init() ) {
                OpenSSL_add_all_ciphers();
                OpenSSL_add_all_digests();
        } else {
                exit(EXIT_FAILURE);
        }
}


@end
