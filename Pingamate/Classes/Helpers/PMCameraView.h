//
//  PMCameraView.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import AVFoundation;
@import CoreMotion;
@import UIKit;

#import "constants.h"
#import "PMCaptureButton.h"

@class PMCameraView;

@protocol PMCameraDelegate<NSObject>
@optional

- (void)cameraDidBeginRecordingVideo:(PMCameraView *)cameraView;
- (void)camera:(PMCameraView *)cameraView didCaptureImage:(UIImage *)image;
- (void)camera:(PMCameraView *)cameraView didFinishRecordingVideoAtURL:(NSURL *)path;
- (void)cameraDidRequestPhotoLibrary:(PMCameraView *)cameraView;

@end

@interface PMCameraView : UIView <AVCaptureFileOutputRecordingDelegate, PMCaptureButtonDelegate>
{
        AVCaptureDevice *inputDevice;
        AVCaptureDeviceInput *videoInput;
        AVCaptureDeviceInput *audioInput;
        AVCaptureMovieFileOutput *movieOutput;
        AVCaptureSession *session;
        AVCaptureStillImageOutput *stillImageOutput;
        AVCaptureVideoOrientation orientation;
        AVCaptureVideoPreviewLayer *videoPreviewLayer;
        PMCaptureButton *captureButton;
        CMMotionManager *motionManager;
        NSTimer *recordingTimer;
        UIButton *flashToggleButton;
        UIButton *gridToggleButton;
        UIButton *photoLibraryButton;
        UIView *gridView;
        UIView *recordingLengthIndicator;
        BOOL isRecording;
        BOOL isShowingGrid;
        BOOL isUsingFrontCamera;
        PMFlashMode flashMode;
        NSInteger clipCount;
        UIDeviceOrientation deviceOrientation;
}

@property (nonatomic, weak) id <PMCameraDelegate> delegate;
@property (strong, nonatomic) UIView *viewfinder;

- (void)closeViewfinder;
- (void)openViewfinder;

@end
