//
//  PMNippleView.h
//  Pingamate
//
//  Created by Ali Mahouk on 12/19/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

@import UIKit;

#import "constants.h"

@interface PMNippleView : UIVisualEffectView
{
        CAShapeLayer *borderLayer;
        CAShapeLayer *frameMaskLayer;
        UIBezierPath *borderPath;
        UIBezierPath *framePath;
        UIView *maskView;
}

@property (nonatomic) PMNippleDirection nippleDirection;

@end
