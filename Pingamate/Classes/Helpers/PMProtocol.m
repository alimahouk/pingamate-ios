//
//  PMProtocol.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/27/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMProtocol.h"

#import "PMAppDelegate.h"
#import "constants.h"
#import "PMDirector.h"
#import "PMMessageHandleAvailability.h"
#import "PMMessageServerRegistration.h"

@implementation PMProtocol

+ (BOOL)isValidMessage:(NSData *)message
{
        unsigned char magic_num[PM_MAGIC_NUM_LEN] = PM_MAGIC_NUM;
        
        if ( memcmp(message.bytes, magic_num, PM_MAGIC_NUM_LEN) == 0 )
                return YES;
        
        return NO;
}

+ (PMMessage *)deserializeMessage:(NSData *)messageData
{
        if ( !messageData )
                return nil;
}

+ (NSData *)prependHeader:(NSData *)messageData
{
        NSData *messageDigest;
        NSData *signature;
        NSMutableData *header;
        uint32_t byteLength;
        
        if ( !messageData )
                return nil;
        
        messageDigest = [PMSec SHA:messageData];
        signature     = [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] signMessage:messageDigest];
        byteLength    = (uint32_t)(messageData.length + 4 + signature.length); // We only include the first 4 bytes of the digest.
        
        return header;
}

+ (NSData *)availabilityForHandle:(NSString *)handle messageID:(NSString **)messageID
{
        NSData *envelope;
        NSData *messageDataEncrypted;
        NSData *messageDataPlain;
        PMMessageHandleAvailability *message;
        
        if ( !handle )
                return nil;
        
        message              = [[PMMessageHandleAvailability alloc] initWithHandle:handle];
        messageDataPlain     = [message serialize];
        messageDataEncrypted = [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] encryptServerMessage:messageDataPlain];
        envelope             = [self prependHeader:messageDataEncrypted];
        
        if ( messageID )
                *messageID = message.identifier;
        
        return [message serialize];
}

+ (NSData *)serverGreeting:(NSString **)messageID
{
        PMMessageServerRegistration *message;
        
        message = [PMMessageServerRegistration new];
        
        if ( messageID )
                *messageID = message.identifier;
        
        return [message serialize];
}

+ (uint32_t)messageSize:(NSData *)message
{
        uint32_t len;
        
        len = 0;
        
        if ( message &&
             [self isValidMessage:message] ) {
                unsigned char *bytes = (unsigned char *)message.bytes;
                int index;
                
                index = PM_MAGIC_NUM_LEN;
                len   = (uint32_t)bytes[index + 3] |
                        ( (uint32_t)bytes[index + 2] << 8 ) |
                        ( (uint32_t)bytes[index + 1] << 16 ) |
                        ( (uint32_t)bytes[index] << 24 );// First 4 bytes contain the message length (excluding the magic number).
        }
        
        return len;
}

@end
