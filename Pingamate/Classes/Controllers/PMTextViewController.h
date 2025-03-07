//
//  PMTextViewController.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMViewController.h"

#import "PMDirector.h"
#import "PMUserPicker.h"

@interface PMTextViewController : PMViewController <PMDirectorDelegate, PMUserPickerDelegate, UITextViewDelegate>
{
        PMUserPicker *userPicker;
        UINavigationBar *navigationBar;
        UITextView *editor;
        BOOL isShowingKeyboard;
        CGFloat keyboardAnimationDuration;
        CGSize keyboardSize;
        UIViewAnimationOptions keyboardAnimationCurve;
}

@end
