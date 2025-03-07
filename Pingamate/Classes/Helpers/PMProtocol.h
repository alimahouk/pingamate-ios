//
//  PMProtocol.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/27/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Foundation;

@class PMMessage;

@interface PMProtocol : NSObject

+ (BOOL)isValidMessage:(NSData *)message;

+ (PMMessage *)deserializeMessage:(NSData *)messageData;

+ (NSData *)availabilityForHandle:(NSString *)handle messageID:(NSString **)messageID;
+ (NSData *)serverGreeting:(NSString **)messageID;

+ (uint32_t)messageSize:(NSData *)message;

@end
