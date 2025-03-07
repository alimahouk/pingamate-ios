//
//  PMDirector.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/30/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

#import "PMCryptoManager.h"
#import "PMNetworkManager.h"

@class PMLiveReaction;
@class PMLiveReactionCapture;
@class PMMessageHandleAvailabilityResponse;
@class PMMessageResponse;
@class PMMessageServerRegistrationResponse;
@class PMModelManager;
@class PMUser;
@class PMUserManager;

@protocol PMDirectorDelegate <NSObject>
@optional

/**
 * Called when the app is sent to the
 * background by the user.
 */
- (void)directorDetectedBackgroundState;

/**
 * Called when the app is sent to the
 * foreground by the user.
 */
- (void)directorDetectedForegroundState;

/**
 * Called when the app completes the
 * server handshake & a connection is
 * successfully established.
 */
- (void)directorDidConnect;

/**
 * Called when the app detects an existing
 * user.
 */
- (void)directorFoundExistingIdentity;

/**
 * Called when the app generates a new
 * key, i.e. when creating a new user.
 */
- (void)directorNeedsNewIdentity;

@end

@interface PMDirector : NSObject <PMCryptoManagerDelegate, PMNetworkManagerDelegate>
{
        NSMutableDictionary *callbacks;
        NSMutableSet<id<PMDirectorDelegate>> *delegates;
        PMCryptoManager *cryptoManager;
        PMLiveReactionCapture *liveReactionCapture;
        PMModelManager *modelManager;
        PMNetworkManager *networkManager;
        PMUserManager *userManager;
}

@property (strong, nonatomic) PMUser *user;
@property (readonly, nonatomic) NSOrderedSet<PMUser *> *userContacts;

- (NSData *)decryptServerMessage:(NSData *)messageData;
- (NSData *)encryptServerMessage:(NSData *)messageData;
- (NSData *)decryptMessage:(NSData *)messageData forUser:(PMUser *)user;
- (NSData *)encryptMessage:(NSData *)messageData forUser:(PMUser *)user;
- (NSData *)signMessage:(NSData *)digest;

- (void)action;
- (void)addDelegate:(id<PMDirectorDelegate>)delegate;
- (void)applicationDidEnterBackground;
- (void)applicationDidEnterForeground;
- (void)checkAvailability:(void (^)(PMMessageHandleAvailabilityResponse *response))responseHandler forHandle:(NSString *)handle;
- (void)liveReaction:(void (^)(PMLiveReaction *liveReaction))completionHandler;
- (void)pauseLiveReaction;
- (void)registerWithServer:(void (^)(PMMessageServerRegistrationResponse *response))responseHandler;
- (void)removeDelegate:(id<PMDirectorDelegate>)delegate;
- (void)resumeLiveReaction;
- (void)saveContext;

@end
