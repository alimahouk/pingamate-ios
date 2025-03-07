//
//  PMNetworkManager.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/26/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMNetworkManager.h"

#import "constants.h"
#import "PMProtocol.h"

@implementation PMNetworkManager


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                buffer        = [NSMutableData dataWithData:[NSData data]];
                bytesReceived = 0;
                messageSize   = 0;
                socket_queue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                socket        = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socket_queue];
        }
        
        return self;
}

#pragma mark -

- (void)connect
{
        NSError *error;
        
        if ( ![socket connectToHost:PM_SERVER_ADDRESS onPort:PM_SERVER_PORT withTimeout:PM_SERVER_CONNECTION_TIMEOUT error:&error] ) {
                NSLog(@"%@", error);
        }
}

- (void)disconnect
{
        [socket disconnectAfterWriting];
}

- (void)send:(NSData *)message
{
        [socket writeData:message withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
        NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
        
        [sock readDataWithTimeout:-1 tag:0];
        
        if ( [_delegate respondsToSelector:@selector(networkManagerDidConnect:)] )
                [_delegate networkManagerDidConnect:self];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
        NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
        
        if ( [_delegate respondsToSelector:@selector(networkManagerDidDisconnect:)] )
                [_delegate networkManagerDidDisconnect:self];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
        NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
        
        [buffer appendData:data];
        
        bytesReceived += data.length;
        
        if ( messageSize == 0 ) {
                messageSize = [PMProtocol messageSize:data];
        } else if ( messageSize == bytesReceived ) { // Full message received; pass to delegate.
                if ( [_delegate respondsToSelector:@selector(networkManager:didReceiveMessage:)] )
                        [_delegate networkManager:self didReceiveMessage:buffer];
                
                buffer.data   = [NSData data];  // Clear out.
                bytesReceived = 0;              // Reset these.
                messageSize   = 0;
        }
        
        [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
        NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}


@end
