//
//  PMNetworkManager.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/26/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import Foundation;

#import "GCDAsyncSocket.h"

@class PMNetworkManager;

@protocol PMNetworkManagerDelegate <NSObject>

- (void)networkManagerDidConnect:(PMNetworkManager *)manager;
- (void)networkManagerDidDisconnect:(PMNetworkManager *)manager;
- (void)networkManager:(PMNetworkManager *)manager didReceiveMessage:(NSData *)messageData;

@end

@interface PMNetworkManager : NSObject <GCDAsyncSocketDelegate>
{
        GCDAsyncSocket *socket;
        NSMutableData *buffer;
        dispatch_queue_t socket_queue;
        NSUInteger bytesReceived;
        uint32_t messageSize;
}

@property (nonatomic, weak) id<PMNetworkManagerDelegate> delegate;

- (void)connect;
- (void)disconnect;
- (void)send:(NSData *)message;

@end
