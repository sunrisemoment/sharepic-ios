//
//  UIView+Additions.m
//  Event App
//
//  Created by Addon Web Solutions on 9/25/15.
//  Copyright (c) 2015 Addon Wes Solutions. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)


/**
 * Set Background image.
 */
- (void)setBackgroundImage:(UIImage *)bgImage{
    
    self.backgroundColor   = [UIColor colorWithPatternImage: bgImage];
    self.contentMode       = UIViewContentModeScaleAspectFit;
}


/**
 * Draw Custom Border to label
 */
- (void)drawCustomBorderWithStyle:(VIEWBORDERSTYLE)borderStyle Border_Width:(CGFloat)borderWidth Border_Color:(UIColor *)borderColor{
    
    CALayer *customBorder    = [CALayer layer];
    customBorder.borderColor = borderColor.CGColor;
    customBorder.borderWidth = borderWidth;
    
    if (borderStyle == VIEWBORDERSTYLELEFT){
        customBorder.frame = CGRectMake(0,0, borderWidth,CGRectGetHeight(self.frame));
    }else if (borderStyle == VIEWBORDERSTYLERIGHT){
        customBorder.frame = CGRectMake(CGRectGetWidth(self.frame)-borderWidth,0, borderWidth,CGRectGetHeight(self.frame));
    }else if (borderStyle == VIEWBORDERSTYLETOP){
        customBorder.frame = CGRectMake(0,0,CGRectGetWidth(self.frame),borderWidth);
    }else if (borderStyle == VIEWBORDERSTYLEBOTTOM){
        customBorder.frame = CGRectMake(0,CGRectGetHeight(self.frame)-borderWidth, CGRectGetWidth(self.frame),borderWidth);
    }else if (borderStyle == VIEWBORDERSTYLEALL){
        customBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    
    
    // ADD LAYER
    [self.layer addSublayer:customBorder];
    
    
}

- (void)clearConstraintsOfSubview:(UIView *)subview{
    for (NSLayoutConstraint *constraint in [self constraints]) {
        if ([[constraint firstItem] isEqual:subview] || [[constraint secondItem] isEqual:subview]) {
            [self removeConstraint:constraint];
        }
    }
}

-(void)drawRadiusToSpecificCorner:(UIRectCorner)corners cornerRadii:(CGSize)radi {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:radi];
    
    CAShapeLayer *maskLayer     = [[CAShapeLayer alloc] init];
    maskLayer.frame             = self.bounds;
    maskLayer.path              = maskPath.CGPath;
    self.layer.mask  = maskLayer;
}

@end
