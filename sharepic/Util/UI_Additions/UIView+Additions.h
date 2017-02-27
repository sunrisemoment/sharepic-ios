//
//  UIView+Additions.h
//  Event App
//
//  Created by Addon Web Solutions on 9/25/15.
//  Copyright (c) 2015 Addon Wes Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

typedef NS_ENUM(NSInteger, VIEWBORDERSTYLE){
    VIEWBORDERSTYLELEFT              = 0,
    VIEWBORDERSTYLERIGHT             = 1,
    VIEWBORDERSTYLETOP               = 2,
    VIEWBORDERSTYLEBOTTOM            = 3,
    VIEWBORDERSTYLEALL               = 4,
    
};

typedef NS_ENUM(NSInteger, VIEWCORNERSTYLE){
    VIEWCORNERSTYLELEFT              = 0,
    VIEWCORNERSTYLERIGHT             = 1,
    VIEWCORNERSTYLETOP               = 2,
    VIEWCORNERSTYLEBOTTOM            = 3,
    VIEWCORNERSTYLEALL               = 4,
    
};

/**
 * Set Background image.
 */
- (void)setBackgroundImage:(UIImage *)bgImage;

/**
 * Draw Custom Border to label
 */
- (void)drawCustomBorderWithStyle:(VIEWBORDERSTYLE)borderStyle Border_Width:(CGFloat)borderWidth Border_Color:(UIColor *)borderColor;

- (void)clearConstraintsOfSubview:(UIView *)subview;

/**
 *Draw radius to the specific Corner
 */
-(void)drawRadiusToSpecificCorner:(UIRectCorner)corners cornerRadii:(CGSize)radi;

@end
