//
//  PMDirector.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/30/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMDirector.h"

#import "PMLiveReaction.h"
#import "PMLiveReactionCapture.h"
#import "PMMessageServerRegistrationResponse.h"
#import "PMModelManager.h"
#import "PMProtocol.h"
#import "PMUser.h"
#import "PMUserManager.h"
#import "PMUtil.h"

@implementation PMDirector


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                callbacks = [NSMutableDictionary dictionary];
                
                cryptoManager          = [PMCryptoManager new];
                cryptoManager.delegate = self;
                
                delegates           = [NSMutableSet new];
                liveReactionCapture = [PMLiveReactionCapture new];
                modelManager        = [PMModelManager new];
                
                networkManager          = [PMNetworkManager new];
                networkManager.delegate = self;
                
                userManager = [PMUserManager new];
        }
        
        return self;
}

#pragma mark -

- (NSData *)decryptServerMessage:(NSData *)messageData
{
        return [cryptoManager decryptServerMessage:messageData];
}

- (NSData *)encryptServerMessage:(NSData *)messageData
{
        return [cryptoManager encryptServerMessage:messageData];
}

- (NSData *)decryptMessage:(NSData *)messageData forUser:(PMUser *)user
{
        return [cryptoManager decryptMessage:messageData forUser:user];
}

- (NSData *)encryptMessage:(NSData *)messageData forUser:(PMUser *)user
{
        return [cryptoManager decryptMessage:messageData forUser:user];
}

- (NSData *)signMessage:(NSData *)digest
{
        return [cryptoManager signMessage:digest];
}

- (NSOrderedSet<PMUser *> *)userContacts
{
        return userManager.users;
}

- (void)action
{
        [modelManager bootstrap];
        [cryptoManager bootstrap];
}

- (void)addDelegate:(id<PMDirectorDelegate>)delegate
{
        [delegates addObject:delegate];
}

- (void)applicationDidEnterBackground
{
        for ( id delegate in delegates )
                if ( [delegate respondsToSelector:@selector(directorDetectedBackgroundState)] )
                        [delegate directorDetectedBackgroundState];
}

- (void)applicationDidEnterForeground
{
        for ( id delegate in delegates )
                if ( [delegate respondsToSelector:@selector(directorDetectedForegroundState)] )
                        [delegate directorDetectedForegroundState];
}

- (void)checkAvailability:(void (^)(PMMessageHandleAvailabilityResponse *response))responseHandler forHandle:(NSString *)handle
{
        if ( handle ) {
                NSData *messageData;
                NSString *messageID;
                
                messageData = [PMProtocol availabilityForHandle:handle messageID:&messageID];
                
                if ( messageData ) {
                        [callbacks setObject:[responseHandler copy] forKey:messageID];
                        [networkManager send:messageData];
                }
        }
}

- (void)cryptoManagerDidCreateNewKey:(PMCryptoManager *)manager
{
        [NSUserDefaults.standardUserDefaults removeObjectForKey:NSUDKEY_USER_HANDLE];
        
        for ( id delegate in delegates )
                if ( [delegate respondsToSelector:@selector(directorNeedsNewIdentity)] )
                        [delegate directorNeedsNewIdentity];
}

- (void)cryptoManagerFoundExistingKey:(PMCryptoManager *)manager
{
        if ( ![NSUserDefaults.standardUserDefaults objectForKey:NSUDKEY_USER_HANDLE] ) {
                for ( id delegate in delegates )
                        if ( [delegate respondsToSelector:@selector(directorNeedsNewIdentity)] )
                                [delegate directorNeedsNewIdentity];
        } else {
                [networkManager connect];
                
                for ( id delegate in delegates )
                        if ( [delegate respondsToSelector:@selector(directorFoundExistingIdentity)] )
                                [delegate directorFoundExistingIdentity];
        }
}

- (void)networkManagerDidConnect:(PMNetworkManager *)manager
{
        [self registerWithServer:^(PMMessageServerRegistrationResponse *response){
                if ( response.error ) {
                        
                }
        }];
}

- (void)networkManagerDidDisconnect:(PMNetworkManager *)manager
{
        
}

- (void)networkManager:(PMNetworkManager *)manager didReceiveMessage:(NSData *)messageData
{
        PMMessage *message;
        
        message = [PMProtocol deserializeMessage:messageData];
        
        if ( message ) {
                if ( [message isKindOfClass:PMMessageResponse.class] ) {
                        PMMessageResponse *serverResponse;
                        void (^responseHandler)(PMMessage *);
                        
                        serverResponse = (PMMessageResponse *)message;
                        
                        if ( serverResponse.referenceID ) {
                                responseHandler = [callbacks objectForKey:serverResponse.referenceID];
                                
                                responseHandler(serverResponse);
                                
                                [callbacks removeObjectForKey:serverResponse.referenceID]; // All handled; delete the reference.
                        }
                }
        }
}

- (void)liveReaction:(void (^)(PMLiveReaction *liveReaction))completionHandler
{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *images;
                PMLiveReaction *reaction;
                UIImage *finalImage;
                
                images = [[liveReactionCapture liveReaction] mutableCopy];
                
                // We need to reload the images as JPEGs to get their true orientation.
                for ( int i = 0; i < images.count; i++ ) {
                        UIImage *image;
                        
                        image     = images[i];
                        image     = [PMUtil imageByCroppingImage:image toSize:CGSizeMake(image.size.width, image.size.width)];
                        images[i] = [[UIImage alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];
                }
                
                finalImage = [UIImage animatedImageWithImages:images duration:1.0];
                
                reaction        = [[PMLiveReaction alloc] initWithReaction:finalImage];
                reaction.userID = _user.identifier;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(reaction);
                });
        });
}

- (void)pauseLiveReaction
{
        [liveReactionCapture stopCamera];
}

- (void)registerWithServer:(void (^)(PMMessageServerRegistrationResponse *response))responseHandler
{
        NSData *messageData;
        NSString *messageID;
        
        messageData = [PMProtocol serverGreeting:&messageID];
        
        if ( messageData ) {
                [callbacks setObject:[responseHandler copy] forKey:messageID];
                [networkManager send:messageData];
        }
}

- (void)removeDelegate:(id<PMDirectorDelegate>)delegate
{
        [delegates removeObject:delegate];
}

- (void)resumeLiveReaction
{
        [liveReactionCapture startCamera];
}

- (void)saveContext
{
        [modelManager saveContext];
}


@end
