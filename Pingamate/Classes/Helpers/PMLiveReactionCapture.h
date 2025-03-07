//
//  PMLiveReactionCapture.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/5/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import AVFoundation;

@interface PMLiveReactionCapture : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
        AVCaptureDevice *camera;
        AVCaptureDeviceInput *cameraInput;
        AVCaptureSession *session;
        AVCaptureVideoDataOutput *videoOutput;
        NSMutableArray<UIImage *> *reactionBuffer;
        NSTimer *timer;
        dispatch_queue_t captureQueue;
        int skip;
}

- (BOOL)startCamera;

/**
 * This is a blocking method. It should be
 * executed on a separate thread.
 */
- (NSArray<UIImage *> *)liveReaction;

- (void)stopCamera;

@end
