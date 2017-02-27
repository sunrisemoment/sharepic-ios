//
//  UIImage+Additions.h
//  Peaceful Pregnancy
//
//  Created by Mahesh on 11/12/15.
//  Copyright © 2015 Addon Web Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

/**
 *  Tint Image with color and blend mode
 *
 *  @param tintColor UIColor
 *  @param blendMode CGBlendMode
 *
 *  @return UIImage
 */
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode;


/**
 *  Tinted Image with color
 *
 *  @param tint color UIColor
 *
 *  @return UIImage
 */
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;


/**
 *  Overlay Image with color
 *
 *  @param overlayColor UIColor
 *
 *  @return UIImage
 */
- (UIImage *)overlayImageWithColor:(UIColor *)overlayColor;

/**
 * Create UIImage from color and given size
 *
 * @return UIImage
 */
+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize )size;

/**
 * Convert base 64 string to UIImage
 *
 * @return UIImage
 */
+ (UIImage *)imageWithBase64:(NSString *)strBase64;

/**
 * Encode UIImage to Base 64 string
 * @return NSString
 */
+ (NSString *)encodeToBase64String:(UIImage *)image;

/**
 *  Scale and Crop Image
 *
 *  @param targetSize Target Image Size
 *
 *  @return UIImage
 */
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

/**
 *  Resize Image With Aspect Ratio
 *
 *  @param sourceImage Source Image
 *  @param scaleWidth     New Width
 *
 *  @return Scaled Image
 */
+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) scaleWidth;


/**
 * This function scale image as device screen resolution
 */
+ (UIImage *)imageWithImageScaleToResolution:(UIImage *)image;


/**
 * This function will create Image From UIView
 */
+ (UIImage *) imageWithView:(UIView *)view;

/**
 *  Draw imahe in image
 *
 *  @param fgImage UIImage
 *  @param bgImage UIImage
 *  @param point   UIImage
 *
 *  @return UIImage
 */
+ (UIImage*) drawImage:(UIImage*)fgImage inImage:(UIImage*) bgImage atPoint:(CGPoint) point;

/**
 * This Function will convert hex color code to UIColor
 */
+(UIColor *)colorWithHexaCode:(NSString *)hexaCode;
/**
 * Make Image Circle View
 */
//- (void)makeCircleView;

@end
