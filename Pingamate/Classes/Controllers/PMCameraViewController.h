//
//  PMCameraViewController.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import AVKit;

#import "PMViewController.h"

#import "PMCameraView.h"
#import "PMDirector.h"
#import "PMUserPicker.h"

@class PMCameraViewController;
@class PMMessageMedia;

@protocol PMCameraViewControllerDelegate<NSObject>
@optional

- (void)cameraViewDidBeginRecordingVideo:(PMCameraViewController *)cameraView;
- (void)cameraViewDidFinishRecordingVideo:(PMCameraViewController *)cameraView;

@end

@interface PMCameraViewController : PMViewController <PMCameraDelegate, PMDirectorDelegate, PMUserPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
        AVPlayer *moviePlayer;
        AVPlayerLayer *playerLayer;
        CALayer *videoLayer;
        PMCameraView *camera;
        PMMessageMedia *workingItem;
        PMUserPicker *userPicker;
        UIButton *discardButton;
        UIImagePickerController *imagePickerController;
        UIImageView *imagePreview;
        UIImageView *liveReactionPreview;
        UISelectionFeedbackGenerator *selectionFeedbackGenerator;
        UIView *annotationView;
        UIVisualEffectView *userPickerBackgroundView;
        BOOL shouldShowStatusBar;
        NSOperatingSystemVersion systemVersionCheck;
}

@property (nonatomic, weak) id <PMCameraViewControllerDelegate> delegate;

- (void)closeViewfinder;
- (void)openViewfinder;

@end
