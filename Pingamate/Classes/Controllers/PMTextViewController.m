//
//  PMTextViewController.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/1/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMTextViewController.h"

#import "PMAppDelegate.h"
#import "PMChatViewController.h"

@implementation PMTextViewController


- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                self.tabBarItem.image = [UIImage imageNamed:@"Text"];
                self.title            = @"Text";
                
                isShowingKeyboard = NO;
                
                [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] addDelegate:self];
        }
        
        return self;
}

#pragma mark -

- (UIStatusBarStyle)preferredStatusBarStyle
{
        return UIStatusBarStyleDefault;
}

- (void)clearEditor
{
        editor.attributedText = [[NSAttributedString alloc] initWithString:@""];
}

- (void)dealloc
{
        [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] removeDelegate:self];
}

- (void)deregisterForKeyboard
{
        if ( self.isFocusedController ) {
                [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
                [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        }
}

- (void)didChangeControllerFocus:(BOOL)focused
{
        if ( focused ) {
                [self registerForKeyboard]; // Register for keyboard notifications.
                [editor becomeFirstResponder];
        } else {
                [self deregisterForKeyboard];
        }
        
        [super didChangeControllerFocus:focused];
}

- (void)didPinchEditor:(UIPinchGestureRecognizer *)gestureRecognizer
{
        if ( gestureRecognizer.state == UIGestureRecognizerStateBegan ||
             gestureRecognizer.state == UIGestureRecognizerStateChanged ) {
                [self scaleFontSize:gestureRecognizer.scale];
                
                gestureRecognizer.scale = 1;
        }
}

- (void)didSwipeEditor:(UISwipeGestureRecognizer *)gestureRecognizer
{
        [editor resignFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
        if ( isShowingKeyboard ) {
                [self moveUIDown];
                
                isShowingKeyboard = NO;
        }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
        if ( !isShowingKeyboard ) {
                keyboardAnimationCurve    = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
                keyboardAnimationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                keyboardSize              = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
                
                [self moveUIUp];
                
                isShowingKeyboard = YES;
        }
}

- (void)loadView
{
        [super loadView];
        
        self.view.backgroundColor = UIColor.whiteColor;
        
        editor                              = [[UITextView alloc] initWithFrame:self.view.bounds];
        editor.allowsEditingTextAttributes  = YES;
        editor.backgroundColor              = UIColor.clearColor;
        editor.delegate                     = self;
        editor.keyboardDismissMode          = UIScrollViewKeyboardDismissModeInteractive;
        editor.showsVerticalScrollIndicator = NO;
        
        navigationBar = [UINavigationBar new];
        
        userPicker          = [[PMUserPicker alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 89)];
        userPicker.delegate = self;
        userPicker.source   = [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] userContacts];
        
        navigationBar.frame       = CGRectMake(0, 0, self.view.bounds.size.width, userPicker.frame.origin.y + userPicker.bounds.size.height + 5);
        editor.textContainerInset = UIEdgeInsetsMake(navigationBar.bounds.size.height + 35, 35, 84, 35);
        
        [self resetEditorAttributes];
        [self.view addSubview:editor];
        [self.view addSubview:navigationBar];
        [self.view addSubview:userPicker];
}

- (void)moveUIDown
{
        if ( isShowingKeyboard ) {
                [UIView animateWithDuration:keyboardAnimationDuration delay:0 options:keyboardAnimationCurve animations:^{
                        editor.textContainerInset = UIEdgeInsetsMake(editor.textContainerInset.top,
                                                                     editor.textContainerInset.left,
                                                                     84,
                                                                     editor.textContainerInset.right);
                } completion:nil];
        }
}

- (void)moveUIUp
{
        if ( !isShowingKeyboard ) {
                [UIView animateWithDuration:keyboardAnimationDuration delay:0 options:keyboardAnimationCurve animations:^{
                        editor.textContainerInset = UIEdgeInsetsMake(editor.textContainerInset.top,
                                                                     editor.textContainerInset.left,
                                                                     keyboardSize.height + 35,
                                                                     editor.textContainerInset.right);
                } completion:^(BOOL finished){
                        UITextRange *caretPosition;
                        CGRect caretRect;
                        
                        caretPosition = [editor selectedTextRange];
                        caretRect     = [editor caretRectForPosition:caretPosition.end];
                        caretRect.size.height += editor.textContainerInset.bottom;
                        
                        [editor scrollRectToVisible:caretRect animated:YES];
                }];
        }
}

- (void)registerForKeyboard
{
        if ( !self.isFocusedController ) {
                [NSNotificationCenter.defaultCenter addObserver:self
                                                       selector:@selector(keyboardWillShow:)
                                                           name:UIKeyboardWillShowNotification
                                                         object:nil];
                [NSNotificationCenter.defaultCenter addObserver:self
                                                       selector:@selector(keyboardWillHide:)
                                                           name:UIKeyboardWillHideNotification
                                                         object:nil];
                [NSNotificationCenter.defaultCenter addObserver:self
                                                       selector:@selector(keyboardWillShow:)
                                                           name:UIKeyboardWillChangeFrameNotification
                                                         object:nil];
        }
}

- (void)resetEditorAttributes
{
        NSMutableParagraphStyle *paragraphStyle;
        
        paragraphStyle           = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        editor.attributedText = [[NSAttributedString alloc] initWithString:@" "
                                                                attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:18],
                                                                             NSParagraphStyleAttributeName: paragraphStyle}];
        editor.text           = @"";
}

- (void)scaleFontSize:(CGFloat)scale
{
        /*
         * If no text is selected, we resize all the
         * text, otherwise we resize the text that the
         * user selected.
         */
        NSMutableAttributedString *mutableCopy;
        UITextPosition *beginning;
        UITextPosition *selectionEnd;
        UITextPosition *selectionStart;
        UITextRange *selectedRange;
        NSInteger location;
        NSInteger length;
        NSRange textRange;
        
        mutableCopy    = [editor.attributedText mutableCopy];
        beginning      = editor.beginningOfDocument;
        selectedRange  = editor.selectedTextRange;
        selectionStart = selectedRange.start;
        selectionEnd   = selectedRange.end;
        location       = [editor offsetFromPosition:beginning toPosition:selectionStart];
        length         = [editor offsetFromPosition:selectionStart toPosition:selectionEnd];
        textRange      = NSMakeRange(location, length);
        
        if ( textRange.length == 0 )
                textRange = NSMakeRange(0, mutableCopy.length);
        
        [mutableCopy beginEditing];
        [mutableCopy enumerateAttribute:NSFontAttributeName
                                inRange:textRange
                                options:0
                             usingBlock:^(id value, NSRange range, BOOL *stop) {
                                     if ( value ) {
                                             UIFont *newFont;
                                             UIFont *oldFont;
                                             
                                             oldFont = (UIFont *)value;
                                             newFont = [oldFont fontWithSize:oldFont.pointSize * scale];
                                             
                                             [mutableCopy removeAttribute:NSFontAttributeName range:range];
                                             [mutableCopy addAttribute:NSFontAttributeName value:newFont range:range];
                                             
                                             editor.attributedText    = mutableCopy;
                                             editor.selectedTextRange = selectedRange; // Selection gets lost when we edit the text, set it again.
                                     }
                             }];
        [mutableCopy endEditing];
}

- (void)textViewDidChange:(UITextView *)textView
{
        if ( [textView isEqual:editor] ) {
                if ( editor.attributedText.length == 0 ) // Clear out stale attributes.
                        [self resetEditorAttributes];
        }
}

- (void)userPicker:(PMUserPicker *)picker didSelectUser:(PMUser *)user
{
        
}

- (void)userPicker:(PMUserPicker *)picker didLongPressUser:(PMUser *)user
{
        PMChatViewController *chatController;
        
        chatController                        = [[PMChatViewController alloc] initWithUser:user];
        chatController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        chatController.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
        
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:chatController animated:YES completion:nil];
}

- (void)viewDidLoad
{
        UIPinchGestureRecognizer *editorPinchRecognizer;
        UISwipeGestureRecognizer *editorSwipeRecognizer;
        
        [super viewDidLoad];
        [userPicker reloadData];
        
        editorPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchEditor:)];
        
        editorSwipeRecognizer           = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeEditor:)];
        editorSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        
        [editor addGestureRecognizer:editorPinchRecognizer];
        [editor addGestureRecognizer:editorSwipeRecognizer];
}


@end
