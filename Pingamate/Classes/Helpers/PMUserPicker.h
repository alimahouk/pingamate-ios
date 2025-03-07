//
//  PMUserPicker.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/2/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import UIKit;

@class PMUser;
@class PMUserPicker;

#define PM_USER_PICKER_CELL_ID  @"PMUserPickerCell"

@protocol PMUserPickerDelegate <NSObject>

- (void)userPicker:(PMUserPicker *)picker didLongPressUser:(PMUser *)user;
- (void)userPicker:(PMUserPicker *)picker didSelectUser:(PMUser *)user;

@end

@interface PMUserPicker : UIView <UICollectionViewDataSource, UICollectionViewDelegate>
{
        NSOrderedSet *dataSource;
        UICollectionView *list;
        UICollectionViewFlowLayout *listLayout;
        UISelectionFeedbackGenerator *selectionFeedbackGenerator;
        NSOperatingSystemVersion systemVersionCheck;
}

@property (nonatomic) BOOL darkThemeEnabled;
@property (nonatomic, weak) id<PMUserPickerDelegate> delegate;
@property (nonatomic) NSOrderedSet *source;

- (void)reloadData;

@end
