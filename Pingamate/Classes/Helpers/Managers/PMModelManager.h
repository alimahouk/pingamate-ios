//
//  PMModelManager.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/29/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import CoreData;
@import Foundation;

@interface PMModelManager : NSObject

@property (strong, readonly) NSPersistentContainer *persistentContainer;

+ (NSString *)pathForKeyDirectory;
+ (NSString *)pathForClientPrivateKey;
+ (NSString *)pathForClientPublicKey;
+ (NSString *)pathForImageDirectory;
+ (NSString *)pathForPartnerPublicKey:(NSString *)partnerID;
+ (NSString *)pathForVideoDirectory;

+ (NSURL *)pathForImage:(NSString *)messageID ofType:(NSString *)type;
+ (NSURL *)pathForLiveReactionBuffer;
+ (NSURL *)pathForVideo:(NSString *)messageID ofType:(NSString *)type;

- (void)bootstrap;
- (void)saveContext;

@end
