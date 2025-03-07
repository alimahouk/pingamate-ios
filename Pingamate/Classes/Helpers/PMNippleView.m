//
//  PMNippleView.m
//  Pingamate
//
//  Created by Ali Mahouk on 12/19/16.
//  Copyright © 2016 Ali Mahouk. All rights reserved.
//

#import "PMNippleView.h"

@implementation PMNippleView


- (void)resetMasks
{
        if ( borderLayer ) {
                [borderLayer removeFromSuperlayer];
                
                borderLayer = nil;
        }
        
        if ( borderPath )
                borderPath = nil;
        
        if ( maskView )
                maskView = nil;
        
        if ( frameMaskLayer )
                frameMaskLayer = nil;
        
        if ( framePath )
                framePath = nil;
}

- (void)setNeedsDisplay
{
        [super setNeedsDisplay];
        [self resetMasks];
        
        borderPath           = [UIBezierPath bezierPath];
        borderPath.lineWidth = 0;
        
        framePath = [UIBezierPath bezierPath];
        
        switch ( _nippleDirection ) {
                case PMNippleDirectionDownHidden: {
                        [borderPath moveToPoint:CGPointMake(0, self.frame.size.height - 20)];
                        [borderPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - 20)];
                        
                        [framePath moveToPoint:CGPointMake(0, 0)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - 20)];
                        [framePath addLineToPoint:CGPointMake(0, self.frame.size.height - 20)];
                        [framePath closePath];
                        
                        break;
                }
                  
                case PMNippleDirectionUpHidden: {
                        [borderPath moveToPoint:CGPointMake(0, 20)];
                        [borderPath addLineToPoint:CGPointMake(self.frame.size.width, 20)];
                        
                        [framePath moveToPoint:CGPointMake(0, 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
                        [framePath addLineToPoint:CGPointMake(0, self.frame.size.height)];
                        [framePath closePath];
                        
                        break;
                }
                        
                case PMNippleDirectionDown: {
                        [borderPath moveToPoint:CGPointMake(0, self.frame.size.height - 20)];
                        [borderPath addLineToPoint:CGPointMake(17, self.frame.size.height - 20)];
                        [borderPath addLineToPoint:CGPointMake(31, self.frame.size.height)];
                        [borderPath addLineToPoint:CGPointMake(45, self.frame.size.height - 20)];
                        [borderPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - 20)];
                        
                        [framePath moveToPoint:CGPointMake(0, self.frame.size.height - 20)];
                        [framePath addLineToPoint:CGPointMake(17, self.frame.size.height - 20)];
                        [framePath addLineToPoint:CGPointMake(31, self.frame.size.height)];
                        [framePath addLineToPoint:CGPointMake(45, self.frame.size.height - 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height - 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, 0)];
                        [framePath addLineToPoint:CGPointMake(0, 0)];
                        [framePath closePath];
                        
                        break;
                }
                
                case PMNippleDirectionUp: {
                        [borderPath moveToPoint:CGPointMake(0, 20)];
                        [borderPath addLineToPoint:CGPointMake(self.frame.size.width - 45, 20)];
                        [borderPath addLineToPoint:CGPointMake(self.frame.size.width - 31, 0)];
                        [borderPath addLineToPoint:CGPointMake(self.frame.size.width - 17, 20)];
                        [borderPath addLineToPoint:CGPointMake(self.frame.size.width, 20)];
                        
                        [framePath moveToPoint:CGPointMake(0, 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width - 45, 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width - 31, 0)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width - 17, 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, 20)];
                        [framePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
                        [framePath addLineToPoint:CGPointMake(0, self.frame.size.height)];
                        [framePath closePath];
                        
                        break;
                }
                        
                default:
                        break;
        }
        
        
        borderLayer             = [CAShapeLayer layer];
        borderLayer.path        = borderPath.CGPath;
        borderLayer.strokeColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
        borderLayer.fillColor   = UIColor.clearColor.CGColor;
        
        frameMaskLayer      = [CAShapeLayer layer];
        frameMaskLayer.path = framePath.CGPath;
        
        maskView                 = [[UIView alloc] initWithFrame:self.bounds];
        maskView.backgroundColor = UIColor.blackColor;
        maskView.layer.mask      = frameMaskLayer;
        
        self.maskView = maskView;
        
        [self.layer addSublayer:borderLayer];
}


@end
