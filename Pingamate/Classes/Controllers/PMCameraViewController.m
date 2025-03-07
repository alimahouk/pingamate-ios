//
//  PMCameraViewController.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import MobileCoreServices;

#import "PMCameraViewController.h"

#import "PMAppDelegate.h"
#import "PMChatViewController.h"
#import "PMLiveReaction.h"
#import "PMMessageMedia.h"
#import "PMModelManager.h"
#import "PMUtil.h"

@implementation PMCameraViewController


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                self.tabBarItem.image = [UIImage imageNamed:@"Camera"];
                self.title            = @"Camera";
                
                imagePickerController               = [UIImagePickerController new];
                imagePickerController.allowsEditing = NO;
                imagePickerController.delegate      = self;
                imagePickerController.mediaTypes    = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                
                shouldShowStatusBar = YES;
                systemVersionCheck  = (NSOperatingSystemVersion){10, 0, 0};
                
                if ( [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:systemVersionCheck] )
                        selectionFeedbackGenerator = [UISelectionFeedbackGenerator new];
                
                [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] addDelegate:self];
        }
        
        return self;
}

#pragma mark -

- (BOOL)prefersStatusBarHidden
{
        return !shouldShowStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
        return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
        return UIStatusBarStyleLightContent;
}

- (void)beginAnnotating
{
        [UIView animateWithDuration:0.3 animations:^{
                discardButton.alpha = 0.0;
        } completion:^(BOOL finished){
                discardButton.hidden = YES;
        }];
}

- (void)cameraDidBeginRecordingVideo:(PMCameraView *)cameraView
{
        [self hideStatusBar];
        [UIView animateWithDuration:0.2 animations:^{
                userPickerBackgroundView.frame = CGRectMake(userPickerBackgroundView.frame.origin.x,
                                                            -userPickerBackgroundView.bounds.size.height,
                                                            userPickerBackgroundView.bounds.size.width,
                                                            userPickerBackgroundView.bounds.size.height);
        }];
        
        if ( [_delegate respondsToSelector:@selector(cameraViewDidBeginRecordingVideo:)] )
                [_delegate cameraViewDidBeginRecordingVideo:self];
}

- (void)camera:(PMCameraView *)cameraView didCaptureImage:(UIImage *)image
{
        NSError *error;
        PMMessageMedia *message;
        
        message         = [[PMMessageMedia alloc] initWithMediaType:PMMediaTypePhoto];
        message.fileURL = [PMModelManager pathForImage:message.identifier ofType:@"jpg"];
        
        if ( ![UIImageJPEGRepresentation(image, 1.0) writeToURL:message.fileURL options:NSDataWritingAtomic error:&error] ) {
                NSLog(@"%@", error);
        } else {
                [NSUserDefaults.standardUserDefaults setObject:message.identifier forKey:NSUDKEY_PRELIMINARY_IMAGE];
                [self presentAnnotationInterfaceForMessage:message];
        }
}

- (void)camera:(PMCameraView *)cameraView didFinishRecordingVideoAtURL:(NSURL *)path
{
        NSError *error;
        PMMessageMedia *message;
        
        message         = [[PMMessageMedia alloc] initWithMediaType:PMMediaTypeVideo];
        message.fileURL = [PMModelManager pathForVideo:message.identifier ofType:@"mov"];
        
        [self showStatusBar];
        [UIView animateWithDuration:0.2 animations:^{
                userPickerBackgroundView.frame = CGRectMake(userPickerBackgroundView.frame.origin.x,
                                                            0,
                                                            userPickerBackgroundView.bounds.size.width,
                                                            userPickerBackgroundView.bounds.size.height);
        }];
        
        if ( ![NSFileManager.defaultManager copyItemAtURL:path toURL:message.fileURL error:&error] ) {
                NSLog(@"%@", error);
        } else {
                [NSUserDefaults.standardUserDefaults setObject:message.identifier forKey:NSUDKEY_PRELIMINARY_VIDEO];
                [self presentAnnotationInterfaceForMessage:message];
        }
        
        if ( [_delegate respondsToSelector:@selector(cameraViewDidFinishRecordingVideo:)] )
                [_delegate cameraViewDidFinishRecordingVideo:self];
}

- (void)cameraDidRequestPhotoLibrary:(PMCameraView *)cameraView
{
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)closeViewfinder
{
        [camera closeViewfinder];
        [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] resumeLiveReaction];
}

- (void)dealloc
{
        [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] removeDelegate:self];
}

- (void)didChangeControllerFocus:(BOOL)focused
{
        if ( !focused )
                [self closeViewfinder];
        else
                [self openViewfinder];
}

- (void)didLongPressCameraView:(UILongPressGestureRecognizer *)gestureRecognizer
{
        if ( gestureRecognizer.state == UIGestureRecognizerStateBegan ) { // Paste image (if available).
                NSData *GIFData;
                NSData *pasteBMPData;
                NSData *pasteGIFData;
                NSData *pasteICOData;
                NSData *pasteJPEGData;
                NSData *pastePNGData;
                NSData *pasteTIFFData;
                UIImage *image;
                UIImage *pasteImage;
                
                GIFData       = [UIPasteboard.generalPasteboard dataForPasteboardType:@"com.compuserve.gif"];
                pasteImage    = UIPasteboard.generalPasteboard.image;
                pasteBMPData  = [UIPasteboard.generalPasteboard dataForPasteboardType:(NSString*)kUTTypeBMP];
                pasteGIFData  = [UIPasteboard.generalPasteboard dataForPasteboardType:(NSString*)kUTTypeGIF];
                pasteICOData  = [UIPasteboard.generalPasteboard dataForPasteboardType:(NSString*)kUTTypeICO];
                pasteJPEGData = [UIPasteboard.generalPasteboard dataForPasteboardType:(NSString*)kUTTypeJPEG];
                pastePNGData  = [UIPasteboard.generalPasteboard dataForPasteboardType:(NSString*)kUTTypePNG];
                pasteTIFFData = [UIPasteboard.generalPasteboard dataForPasteboardType:(NSString*)kUTTypeTIFF];
                
                // Paste as a new item at this point.
                if ( GIFData )
                        image = [UIImage imageWithData:GIFData];
                else if ( pasteImage )
                        image = pasteImage;
                else if ( pasteBMPData )
                        image = [UIImage imageWithData:pasteBMPData];
                else if ( pasteGIFData )
                        image = [UIImage imageWithData:pasteGIFData];
                else if ( pasteICOData )
                        image = [UIImage imageWithData:pasteICOData];
                else if ( pasteJPEGData )
                        image = [UIImage imageWithData:pasteJPEGData];
                else if ( pastePNGData )
                        image = [UIImage imageWithData:pastePNGData];
                else if ( pasteTIFFData )
                        image = [UIImage imageWithData:pasteTIFFData];
                
                if ( image ) {
                        PMMessageMedia *message;
                        
                        [self presentAnnotationInterfaceForMessage:message];
                }
        }
}

- (void)didReceiveMemoryWarning
{
        [super didReceiveMemoryWarning];
}

- (void)dismissAnnotationInterface
{
        NSError *error;
        
        annotationView.hidden = YES;
        imagePreview.image    = nil;
        
        if ( workingItem.mediaType == PMMediaTypeVideo ) {
                [moviePlayer pause];
                [playerLayer removeFromSuperlayer];
                [NSNotificationCenter.defaultCenter removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:moviePlayer.currentItem];
                
                moviePlayer = nil;
                playerLayer = nil;
        }
        
        if ( ![NSFileManager.defaultManager removeItemAtURL:workingItem.fileURL error:&error] ) {
                NSLog(@"%@", error);
        } else {
                [NSUserDefaults.standardUserDefaults removeObjectForKey:NSUDKEY_PRELIMINARY_IMAGE];
                [NSUserDefaults.standardUserDefaults removeObjectForKey:NSUDKEY_PRELIMINARY_VIDEO];
        }
        
        workingItem = nil; // Clear out before opening viewfinder!
        
        [self openViewfinder];
}

- (void)endAnnotating
{
        discardButton.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
                discardButton.alpha = 1.0;
        }];
}

- (void)hideStatusBar
{
        shouldShowStatusBar = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
        }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
        [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
        [picker dismissViewControllerAnimated:YES completion:^{
                
        }];
}

- (void)loadView
{
        UIBlurEffect *userPickerBackgroundBlurEffect;
        
        [super loadView];
        
        self.view.backgroundColor = UIColor.blackColor;
        
        annotationView        = [[UIView alloc] initWithFrame:self.view.bounds];
        annotationView.hidden = YES;
        
        camera          = [[PMCameraView alloc] initWithFrame:self.view.bounds];
        camera.delegate = self;
        
        discardButton                     = [UIButton buttonWithType:UIButtonTypeSystem];
        discardButton.layer.shadowColor   = UIColor.blackColor.CGColor;
        discardButton.layer.shadowOffset  = CGSizeMake(0, 1);
        discardButton.layer.shadowOpacity = 0.7;
        discardButton.layer.shadowRadius  = 1;
        discardButton.titleLabel.font     = [UIFont systemFontOfSize:32];
        
        imagePreview                 = [UIImageView new];
        imagePreview.backgroundColor = UIColor.blackColor;
        imagePreview.contentMode     = UIViewContentModeScaleAspectFit;
        
        userPicker                  = [[PMUserPicker alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 89)];
        userPicker.darkThemeEnabled = YES;
        userPicker.delegate         = self;
        userPicker.source           = [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] userContacts];
        
        userPickerBackgroundBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        userPickerBackgroundView       = [[UIVisualEffectView alloc] initWithEffect:userPickerBackgroundBlurEffect];
        userPickerBackgroundView.frame = CGRectMake(0, 0, userPicker.bounds.size.width, userPicker.frame.origin.y + userPicker.bounds.size.height);
        
        videoLayer       = [CALayer layer];
        videoLayer.frame = annotationView.bounds;
        
        [discardButton addTarget:self action:@selector(dismissAnnotationInterface) forControlEvents:UIControlEventTouchUpInside];
        [discardButton setTitle:@"×" forState:UIControlStateNormal];
        [discardButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [discardButton setTitleEdgeInsets:UIEdgeInsetsMake(-7, 0, 0, 0)];
        
        discardButton.frame = CGRectMake(15, userPickerBackgroundView.frame.origin.y + userPickerBackgroundView.bounds.size.height + 20, 32, 32);
        imagePreview.frame  = camera.viewfinder.frame;
        
        liveReactionPreview = [[UIImageView alloc] initWithFrame:CGRectMake(100, userPickerBackgroundView.frame.origin.y + userPickerBackgroundView.bounds.size.height + 20, 100, 100)];
        liveReactionPreview.backgroundColor = UIColor.blackColor;
        liveReactionPreview.clipsToBounds = YES;
        liveReactionPreview.contentMode = UIViewContentModeScaleAspectFit;
        liveReactionPreview.layer.cornerRadius = 50;
        
        [annotationView.layer addSublayer:videoLayer];
        [annotationView addSubview:imagePreview];
        [annotationView addSubview:discardButton];
        [annotationView addSubview:liveReactionPreview];
        
        [userPickerBackgroundView.contentView addSubview:userPicker];
        
        [self.view addSubview:camera];
        [self.view addSubview:annotationView];
        [self.view addSubview:userPickerBackgroundView];
}

- (void)openViewfinder
{
        if ( !workingItem ) {
                [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] pauseLiveReaction];
                [camera openViewfinder];
        }
}

- (void)presentAnnotationInterfaceForMessage:(PMMessageMedia *)message
{
        if ( message ) {
                [self closeViewfinder];
                
                annotationView.hidden = NO;
                workingItem           = message;
                
                [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] liveReaction:^(PMLiveReaction *liveReaction){
                        liveReactionPreview.image = liveReaction.reaction;
                }];
                
                if ( message.mediaType == PMMediaTypePhoto ) {
                        imagePreview.hidden = NO;
                        imagePreview.image  = [UIImage imageWithData:[NSData dataWithContentsOfURL:message.fileURL]];
                } else if ( message.mediaType == PMMediaTypeVideo ) {
                        imagePreview.hidden = YES;
                        
                        moviePlayer                 = [AVPlayer playerWithURL:message.fileURL];
                        moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                        
                        playerLayer                            = [AVPlayerLayer playerLayerWithPlayer:moviePlayer];
                        playerLayer.frame                      = annotationView.bounds;
                        playerLayer.videoGravity               = AVLayerVideoGravityResizeAspectFill;
                        playerLayer.needsDisplayOnBoundsChange = YES;
                        
                        [videoLayer addSublayer:playerLayer];
                        [NSNotificationCenter.defaultCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                                        object:moviePlayer.currentItem
                                                                         queue:[NSOperationQueue currentQueue]
                                                                    usingBlock:^(NSNotification *notification){
                                                                            [moviePlayer seekToTime:kCMTimeZero];
                                                                    }];
                        [moviePlayer play];
                }
        }
}

- (void)showStatusBar
{
        shouldShowStatusBar = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
        }];
}

- (void)userPicker:(PMUserPicker *)picker didSelectUser:(PMUser *)user
{
        
}

- (void)userPicker:(PMUserPicker *)picker didLongPressUser:(PMUser *)user
{
        PMChatViewController *chatController;
        
        chatController                        = [[PMChatViewController alloc] initWithUser:user];
        chatController.darkThemeEnabled       = YES;
        chatController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        chatController.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
        
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:chatController animated:YES completion:nil];
}

- (void)viewDidLoad
{
        PMMessageMedia *preliminaryMessage;
        UILongPressGestureRecognizer *cameraViewLongPressRecognizer;
        
        [super viewDidLoad];
        
        cameraViewLongPressRecognizer                      = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCameraView:)];
        cameraViewLongPressRecognizer.minimumPressDuration = 0.5;
        
        [camera.viewfinder addGestureRecognizer:cameraViewLongPressRecognizer];
        [userPicker reloadData];
        
        // Check if the user has a preliminary message pending.
        if ( [NSUserDefaults.standardUserDefaults stringForKey:NSUDKEY_PRELIMINARY_IMAGE] ) {
                preliminaryMessage         = [[PMMessageMedia alloc] initWithMediaType:PMMediaTypePhoto];
                preliminaryMessage.fileURL = [PMModelManager pathForImage:[NSUserDefaults.standardUserDefaults objectForKey:NSUDKEY_PRELIMINARY_IMAGE] ofType:@"jpg"];
        } else if ( [NSUserDefaults.standardUserDefaults stringForKey:NSUDKEY_PRELIMINARY_VIDEO] ) {
                preliminaryMessage         = [[PMMessageMedia alloc] initWithMediaType:PMMediaTypeVideo];
                preliminaryMessage.fileURL = [PMModelManager pathForVideo:[NSUserDefaults.standardUserDefaults objectForKey:NSUDKEY_PRELIMINARY_VIDEO] ofType:@"mov"];
        }
        
        if ( preliminaryMessage )
                [self presentAnnotationInterfaceForMessage:preliminaryMessage];
}


@end
