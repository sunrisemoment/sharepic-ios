//
//  UIImage+Additions.m
//  Peaceful Pregnancy
//
//  Created by Mahesh on 11/12/15.
//  Copyright © 2015 Addon Web Solutions. All rights reserved.
//

#import "UIImage+Additions.h"


@implementation UIImage (Additions)

/**
 *  Tint Image with color and blend mode
 *
 *  @param tintColor UIColor
 *  @param blendMode CGBlendMode
 *
 *  @return UIImage
 */
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode{
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

/**
 *  Tinted Image with color
 *
 *  @param tint color UIColor
 *
 *  @return UIImage
 */
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor{
    
    return [self tintedImageWithColor:tintColor blendingMode:kCGBlendModeDestinationIn];
}


/**
 *  Overlay Image with color
 *
 *  @param overlayColor UIColor
 *
 *  @return UIImage
 */
- (UIImage *)overlayImageWithColor:(UIColor *)overlayColor{
    
    return [self tintedImageWithColor:overlayColor blendingMode:kCGBlendModeOverlay];
}

/**
 * Create UIImage from color and given size
 *
 * @return UIImage
 */
+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize )size{
    
    CGRect rect = CGRectMake(0.0f, 0.0f,size.width,size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 * Convert base 64 string to UIImage
 *
 * @return UIImage
 */
+ (UIImage *) imageWithBase64:(NSString *)strBase64{
    
    
    // Check if string is availble or not
    if ([strBase64 length] > 0) {
        
        // Decode String
        strBase64           = [[strBase64 componentsSeparatedByString:@"base64,"] lastObject];
        
        // Create image with Decoded data
        return  [UIImage imageWithData:
                 [[NSData alloc] initWithBase64EncodedString:strBase64 options:0]
                 ];
        
        
    }else{
        return [UIImage new];
    }
    
}

/**
 * Encode UIImage to Base 64 string
 * @return NSString
 */
+ (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


/**
 *  Scale and Crop Image
 *
 *  @param targetSize Target Image Size
 *
 *  @return UIImage
 */
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize{
    
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}


/**
 *  Resize Image With Aspect Ratio
 *
 *  @param sourceImage Source Image
 *  @param scaleWidth     New Width
 *
 *  @return Scaled Image
 */
+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) scaleWidth{
    
    float oldWidth      = sourceImage.size.width;
    float scaleFactor   = scaleWidth / oldWidth;
    
    float newHeight     = sourceImage.size.height * scaleFactor;
    float newWidth      = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 * This function scale image as device screen resolution
 */
+ (UIImage *)imageWithImageScaleToResolution:(UIImage *)image{
    
    // get screen resolution
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    if (screenScale > 0) {
        
        image = [UIImage imageWithCGImage:[image CGImage] scale:screenScale orientation:UIImageOrientationUp];
        
    }
    
    return image;
    
}

/**
 * This function will create Image From UIView
 */
+ (UIImage *) imageWithView:(UIView *)view{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

/**
 *  Draw imahe in image
 *
 *  @param fgImage UIImage
 *  @param bgImage UIImage
 *  @param point   UIImage
 *
 *  @return UIImage
 */
+ (UIImage*) drawImage:(UIImage*)fgImage inImage:(UIImage*) bgImage atPoint:(CGPoint) point{
    
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 * This Function will convert hex color code to UIColor
 */
+(UIColor *)colorWithHexaCode:(NSString *)hexaCode{
    
    unsigned int c;
    if ([hexaCode characterAtIndex:0] == '#') {
        [[NSScanner scannerWithString:[hexaCode substringFromIndex:1]] scanHexInt:&c];
    } else {
        [[NSScanner scannerWithString:hexaCode] scanHexInt:&c];
    }
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0
                           green:((c & 0xff00) >> 8)/255.0
                            blue:(c & 0xff)/255.0 alpha:1.0];
    
}



@end
