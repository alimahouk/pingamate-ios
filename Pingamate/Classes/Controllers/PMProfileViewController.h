//
//  PMProfileViewController.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/30/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

@class PMUser;
@class PMUserBubble;

@interface PMProfileViewController : UIViewController <UITextFieldDelegate>
{
        PMUser *activeUser;
        PMUserBubble *displayPhoto;
        UIButton *doneButton;
        UITextField *nameField;
        UITextField *usernameField;
        BOOL handleAvailable;
}

@property (nonatomic, readonly) PMUser *user;

- (instancetype)initWithUser:(PMUser *)user;

@end
