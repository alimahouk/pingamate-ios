//
//  PMProfileViewController.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/30/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMProfileViewController.h"

#import "PMAppDelegate.h"
#import "PMDirector.h"
#import "PMMessageHandleAvailabilityResponse.h"
#import "PMUser.h"
#import "PMUserBubble.h"

@implementation PMProfileViewController


- (instancetype)initWithUser:(PMUser *)user
{
        self = [super init];
        
        if ( self ) {
                activeUser      = user;
                handleAvailable = NO;
        }
        
        return self;
}

#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
        [textField resignFirstResponder];
        
        return NO;
}

- (PMUser *)user
{
        return activeUser;
}

- (void)checkAvailability:(void (^)(BOOL available))completionHandler forHandle:(NSString *)handle
{
        [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] checkAvailability:^(PMMessageHandleAvailabilityResponse *response){
                if ( response.error ) {
                        
                }
        } forHandle:handle];
}

- (void)dealloc
{
        [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)dismissView
{
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadView
{
        UILabel *warningLabel;
        
        [super loadView];
        
        self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
        
        displayPhoto       = [[PMUserBubble alloc] initWithUser:activeUser];
        displayPhoto.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width / 2 - 50, 50, 100, 100);
        
        doneButton                 = [UIButton buttonWithType:UIButtonTypeSystem];
        doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:UIFont.buttonFontSize];
        
        nameField                               = [[UITextField alloc] initWithFrame:CGRectMake(20,
                                                                                                displayPhoto.frame.origin.y + displayPhoto.bounds.size.height + 20,
                                                                                                UIScreen.mainScreen.bounds.size.width - 40,
                                                                                                25)];
        nameField.autocapitalizationType        = UITextAutocapitalizationTypeWords;
        nameField.autocorrectionType            = UITextAutocorrectionTypeNo;
        nameField.delegate                      = self;
        nameField.enablesReturnKeyAutomatically = YES;
        nameField.font                          = [UIFont boldSystemFontOfSize:20];
        nameField.placeholder                   = @"Full Name";
        nameField.returnKeyType                 = UIReturnKeyDone;
        nameField.textAlignment                 = NSTextAlignmentCenter;
        
        usernameField                               = [[UITextField alloc] initWithFrame:CGRectMake(20,
                                                                                                    nameField.frame.origin.y + nameField.bounds.size.height + 20,
                                                                                                    UIScreen.mainScreen.bounds.size.width - 40,
                                                                                                    25)];
        usernameField.autocapitalizationType        = UITextAutocapitalizationTypeNone;
        usernameField.autocorrectionType            = UITextAutocorrectionTypeNo;
        usernameField.delegate                      = self;
        usernameField.enablesReturnKeyAutomatically = YES;
        usernameField.placeholder                   = @"Username";
        usernameField.returnKeyType                 = UIReturnKeyDone;
        usernameField.textAlignment                 = NSTextAlignmentCenter;
        
        [displayPhoto addTarget:self action:@selector(presentDisplayPhotoOptions) forControlEvents:UIControlEventTouchUpInside];
        [displayPhoto setNeedsDisplay];
        
        [doneButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton sizeToFit];
        
        doneButton.frame = CGRectMake(15, 20, doneButton.bounds.size.width, 44);
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(textFieldDidChange)
                                                   name:UITextFieldTextDidChangeNotification
                                                 object:nil];
        
        if ( !activeUser ) {
                CGSize labelSize;
                
                warningLabel               = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                                                       usernameField.frame.origin.y + usernameField.bounds.size.height + 20,
                                                                                       0,
                                                                                       0)];
                warningLabel.font          = [UIFont systemFontOfSize:12];
                warningLabel.numberOfLines = 0;
                warningLabel.text          = @"Your username appears in notifications. People can also add you by your username. Note that you can't change it later on.";
                warningLabel.textColor     = UIColor.grayColor;
                
                labelSize          = [warningLabel sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 40, FLT_MAX)];
                warningLabel.frame = CGRectMake(warningLabel.frame.origin.x, warningLabel.frame.origin.y, labelSize.width, labelSize.height);
                
                [self.view addSubview:warningLabel];
        }
        
        [self.view addSubview:doneButton];
        [self.view addSubview:displayPhoto];
        [self.view addSubview:nameField];
        [self.view addSubview:usernameField];
}

- (void)presentDisplayPhotoOptions
{
        UIAlertAction *cancel;
        UIAlertAction *camera;
        UIAlertAction *library;
        UIAlertController *prompt;
        
        cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
                if ( !activeUser ) {
                        if ( nameField.text.length == 0 )
                                [nameField becomeFirstResponder];
                        else if ( usernameField.text.length == 0 )
                                [usernameField becomeFirstResponder];
                }
        }];
        camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                
        }];
        library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                
        }];
        prompt = [UIAlertController alertControllerWithTitle:@"Change Display Photo" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [prompt addAction:cancel];
        [prompt addAction:camera];
        [prompt addAction:library];
        [nameField resignFirstResponder];
        [usernameField resignFirstResponder];
        [self presentViewController:prompt animated:YES completion:nil];
}

- (void)textFieldDidChange
{
        NSString *name;
        NSString *username;
        
        name     = nameField.text;
        username = usernameField.text;
        
        if ( name.length > 0 &&
             username.length > 0 )
                doneButton.enabled = YES;
        else
                doneButton.enabled = NO;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        
        if ( !activeUser ) {
                doneButton.enabled = NO;
                
                [nameField becomeFirstResponder];
        }
}


@end
