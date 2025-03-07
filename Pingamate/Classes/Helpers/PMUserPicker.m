//
//  PMUserPicker.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/2/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMUserPicker.h"

#import "PMUserBubble.h"

@implementation PMUserPicker


- (instancetype)init
{
        self = [super init];
        
        if ( self )
                [self setup];
        
        return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
        self = [super initWithFrame:frame];
        
        if ( self )
                [self setup];
        
        return self;
}

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return dataSource.count;
}

- (NSOrderedSet *)source
{
        return dataSource;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *identifier;
        PMUserBubble *userBubble;
        UICollectionViewCell *cell;
        UILongPressGestureRecognizer *longPressRecognizer;
        
        identifier          = PM_USER_PICKER_CELL_ID;
        cell                = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressUser:)];
        
        userBubble                        = [[PMUserBubble alloc] initWithUser:dataSource[indexPath.row]];
        userBubble.darkThemeEnabled       = _darkThemeEnabled;
        userBubble.frame                  = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
        userBubble.userInteractionEnabled = NO;
        userBubble.showsName              = YES;
        userBubble.tag                    = 1;
        
        [userBubble setNeedsDisplay];
        
        [cell.contentView addGestureRecognizer:longPressRecognizer];
        [cell.contentView addSubview:userBubble];
        
        return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        PMUser *selectedUser;
        PMUserBubble *bubble;
        UICollectionViewCell *selectedCell;
        
        selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
        selectedUser = dataSource[indexPath.row];
        
        bubble          = (PMUserBubble *)[selectedCell.contentView viewWithTag:1];
        bubble.selected = !bubble.selected;
        
        [bubble setNeedsDisplay];
        
        if ( selectionFeedbackGenerator ) // Play some haptic feedback.
                [selectionFeedbackGenerator selectionChanged];
        
        if ( [_delegate respondsToSelector:@selector(userPicker:didSelectUser:)] )
                [_delegate userPicker:self didSelectUser:selectedUser];
}

- (void)didLongPressUser:(UILongPressGestureRecognizer *)gestureRecognizer
{
        NSIndexPath *indexPath;
        CGPoint location;
        
        location  = [gestureRecognizer locationInView:list];
        indexPath = [list indexPathForItemAtPoint:location];
        
        if ( gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
                if ( indexPath )
                        if ( [_delegate respondsToSelector:@selector(userPicker:didLongPressUser:)] )
                                [_delegate userPicker:self didLongPressUser:dataSource[indexPath.row]];
        }
}

- (void)reloadData
{
        [list reloadData];
}

- (void)setFrame:(CGRect)frame
{
        [super setFrame:frame];
        
        list.frame          = CGRectMake(0, 0, frame.size.width, frame.size.height);
        listLayout.itemSize = CGSizeMake(frame.size.height, frame.size.height);
        
        [list setNeedsDisplay];
}

- (void)setSource:(NSOrderedSet *)source
{
        dataSource = source;
}

- (void)setup
{
        static NSString *identifier;
        
        self.backgroundColor = UIColor.clearColor;
        self.opaque          = NO;
        
        _darkThemeEnabled = NO;
        identifier        = PM_USER_PICKER_CELL_ID;
        
        listLayout                         = [UICollectionViewFlowLayout new];
        listLayout.itemSize                = CGSizeMake(self.bounds.size.height, self.bounds.size.height);
        listLayout.minimumInteritemSpacing = 0.0;
        listLayout.minimumLineSpacing      = 0.0;
        listLayout.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
        listLayout.sectionInset            = UIEdgeInsetsZero;
        
        list                                = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:listLayout];
        list.backgroundColor                = UIColor.clearColor;
        list.dataSource                     = self;
        list.delegate                       = self;
        list.scrollsToTop                   = NO;
        list.showsHorizontalScrollIndicator = NO;
        
        [list registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:identifier];
        
        [self addSubview:list];
        
        systemVersionCheck = (NSOperatingSystemVersion){10, 0, 0};
        
        if ( [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:systemVersionCheck] )
                selectionFeedbackGenerator = [UISelectionFeedbackGenerator new];
}


@end
