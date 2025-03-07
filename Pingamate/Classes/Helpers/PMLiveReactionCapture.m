//
//  PMLiveReactionCapture.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/5/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import UIKit;

#import "PMLiveReactionCapture.h"

#import "constants.h"
#import "PMModelManager.h"

@implementation PMLiveReactionCapture


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                reactionBuffer = [NSMutableArray array];
        }
        
        return self;
}

#pragma mark -

- (AVCaptureDevice *)frontCamera
{
        NSArray *devices;
        
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        for ( AVCaptureDevice *device in devices )
                if ( device.position == AVCaptureDevicePositionFront )
                        return device;
        
        return nil;
}

- (BOOL)attachCameraToCaptureSession
{
        NSError *error;
        
        assert(camera != nil);
        assert(session != nil);
        
        cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
        
        if ( error ) {
                NSLog(@"%@", error);
                
                return false;
        }
        
        if ( [session canAddInput:cameraInput] )
                [session addInput:cameraInput];
        else
                return false;
        
        return true;
}

- (BOOL)startCamera
{
        if ( !session.isRunning ) {
                NSError *error;
                NSString *cameraResolutionPreset;
                CGPoint pointOfInterest;
                
                camera                 = [self frontCamera];
                cameraResolutionPreset = AVCaptureSessionPresetMedium;
                pointOfInterest        = CGPointMake(0.5, 0.5);
                skip                   = 0;
                
                if ( !camera )
                        return false;
                
                if ( !session )
                        session = [AVCaptureSession new];
                
                if ( ![session canSetSessionPreset:cameraResolutionPreset] )
                        return false;
                
                [session setSessionPreset:cameraResolutionPreset];
                
                if ( [camera lockForConfiguration:&error] ) {
                        if ( [camera isExposurePointOfInterestSupported] )
                                [camera setExposurePointOfInterest:pointOfInterest];
                        
                        if ( [camera isFocusPointOfInterestSupported] )
                                [camera setFocusPointOfInterest:pointOfInterest];
                        
                        if ( [camera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] )
                                [camera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                        else if ( [camera isExposureModeSupported:AVCaptureExposureModeAutoExpose] )
                                [camera setExposureMode:AVCaptureExposureModeAutoExpose];
                        
                        if ( [camera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] )
                                [camera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                        else if ( [camera isFocusModeSupported:AVCaptureFocusModeAutoFocus] )
                                [camera setFocusMode:AVCaptureFocusModeAutoFocus];
                        
                        if ( [camera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance] )
                                [camera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                        else if ( [camera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance] )
                                [camera setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
                        
                        [camera unlockForConfiguration];
                }
                
                if ( error )
                        NSLog(@"%@", error);
                
                [self attachCameraToCaptureSession];
                [self setupVideoOutput];
                [NSNotificationCenter.defaultCenter addObserver:self
                                                       selector:@selector(videoCameraStarted:)
                                                           name:AVCaptureSessionDidStartRunningNotification
                                                         object:session];
                
                [session startRunning];
        }
        
        return true;
}

- (NSArray<UIImage *> *)liveReaction
{
        while ( session.isRunning &&
                reactionBuffer.count < PM_LIVE_REACTION_FRAMES ); // Wait for a bit till the buffer fills up.
        
        return [NSArray arrayWithArray:reactionBuffer];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
        if ( !CMSampleBufferDataIsReady(sampleBuffer) )
                return;
        
        if ( [captureOutput isEqual:videoOutput] ) {
                /*
                 * Skip the first few frames when the camera
                 * initializes till it adjusts the exposure.
                 */
                if ( skip < 5 )
                        skip++;
                else
                        [self copyVideoFrame:sampleBuffer];
        }
}

- (void)copyVideoFrame:(CMSampleBufferRef)sampleBuffer
{
        /*
         * Note to self: do not store the buffers themselves.
         * The system seems to reuse them, so retaining them
         * will kill the video feed after 13 frame buffers.
         */
        UIImage *frame;
        
        frame = [self imageFromSampleBuffer:sampleBuffer];
        
        @synchronized ( self ) {
                [reactionBuffer addObject:frame];
                
                if ( reactionBuffer.count > PM_LIVE_REACTION_FRAMES )
                        [reactionBuffer removeObjectAtIndex:0];
        }
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
        UIImage *image;
        void *baseAddress;
        CGColorSpaceRef colorSpace;
        CGContextRef context;
        CGImageRef quartzImage;
        CVImageBufferRef imageBuffer;
        size_t bytesPerRow;
        size_t height;
        size_t width;
        
        imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        height      = CVPixelBufferGetHeight(imageBuffer);
        width       = CVPixelBufferGetWidth(imageBuffer);
        
        // Create a device-dependent RGB color space.
        colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create a bitmap graphics context with the sample buffer data.
        context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        // Create a Quartz image from the pixel data in the bitmap graphics context.
        quartzImage = CGBitmapContextCreateImage(context);
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
        
        CGImageRelease(quartzImage);
        
        return image;
}

- (void)setupVideoOutput
{
        NSNumber *framePixelFormat;
        
        if ( videoOutput ) {
                [session removeOutput:videoOutput];
                
                videoOutput = nil;
        }
        
        framePixelFormat = [NSNumber numberWithInt:kCVPixelFormatType_32BGRA];
        
        videoOutput                               = [AVCaptureVideoDataOutput new];
        videoOutput.alwaysDiscardsLateVideoFrames = NO;
        videoOutput.videoSettings                 = @{(id)kCVPixelBufferPixelFormatTypeKey: framePixelFormat};
        
        captureQueue = dispatch_queue_create("captureQueue", DISPATCH_QUEUE_SERIAL);
        
        [videoOutput setSampleBufferDelegate:self queue:captureQueue];
        [session addOutput:videoOutput];
}

- (void)stopCamera
{
        if ( !session )
                return;
        
        @synchronized( self ) {
                [reactionBuffer removeAllObjects];
                
                if ( session.isRunning ) {
                        [session stopRunning];
                        
                        assert(videoOutput != nil);
                        [session removeOutput:videoOutput];
                        
                        assert(cameraInput != nil);
                        [session removeInput:cameraInput];
                        
                        // Allow the garbage collector to tidy up.
                        camera            = nil;
                        cameraInput       = nil;
                        session           = nil;
                        videoOutput       = nil;
                }
        }
}

- (void)videoCameraStarted:(NSNotification *)notification
{
        // This callback has done its job, now disconnect it.
        [NSNotificationCenter.defaultCenter removeObserver:self
                                                      name:AVCaptureSessionDidStartRunningNotification
                                                    object:session];
}


@end
