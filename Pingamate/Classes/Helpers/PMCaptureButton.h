//
//  PMCaptureButton.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import UIKit;

@class PMCaptureButton;

@protocol PMCaptureButtonDelegate<NSObject>
@optional

- (void)captureButtonWasPressed:(PMCaptureButton *)button;
- (void)captureButtonWasReleased:(PMCaptureButton *)button;
- (void)captureButtonWasTapped:(PMCaptureButton *)button;

@end

@interface PMCaptureButton : UIVisualEffectView
{
        NSTimer *contactTimer;
        UIVisualEffectView *button;
        BOOL isPress;
}

@property (nonatomic, weak) id <PMCaptureButtonDelegate> delegate;

@end
