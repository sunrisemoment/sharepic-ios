//
//  MacroUtil.h
//  findtalents
//
//  Created by steven on 14/4/2016.
//  Copyright © 2016 steven. All rights reserved.
//

#ifndef MacroUtil_h
#define MacroUtil_h

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


/** UIColor: Color from RGB **/
#define colorFromRGB( r , g , b ) ( [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1 ] )

/** UIColor: Color from RGBA **/
#define colorFromRGBA(r , g , b , a ) ( [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a ] )



///---------------------------
/// @name Device Checks
///---------------------------

#define DEVICE_SCREEN_HAS_LENGTH(_frame, _length) ( fabs( MAX(CGRectGetHeight(_frame), CGRectGetWidth(_frame)) - _length) < DBL_EPSILON )

/**
 Runtime check for the current device.
 checks if the current device is an iPhone 4 or an Device with 480 Screen height
 */
#define DEVICE_IS_IPHONE_4 DEVICE_SCREEN_HAS_LENGTH([UIScreen mainScreen].bounds, 480.)

/**
 Runtime check for the current device.
 checks if the current device is an iPhone 5 or iPod Touch 5 Gen, or an Device with 1136 Screen height
 */
#define DEVICE_IS_IPHONE_5 DEVICE_SCREEN_HAS_LENGTH([UIScreen mainScreen].bounds, 568.)

/**
 Runtime check for the current device.
 checks if the current device is an iPhone 6
 */
#define DEVICE_IS_IPHONE_6 DEVICE_SCREEN_HAS_LENGTH([UIScreen mainScreen].bounds, 667.)

/**
 Runtime check for the current device.
 checks if the current device is an iPhone 6 Plus
 */
#define DEVICE_IS_IPHONE_6_PLUS DEVICE_SCREEN_HAS_LENGTH([UIScreen mainScreen].bounds, 736.)

/**
 Runtime check for the current device.
 checks if the current device is an iPhone or iPod Touch
 */
#define DEVICE_IS_IPHONE ( UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM() )

/**
 Runtime check for the current device.
 checks if the current device is an iPad
 */
#define DEVICE_IS_IPAD ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())

/**
 *  Runtime get current device screen scale
 */
#define DEVICE_SCREEN_SCALE [[UIScreen mainScreen] scale]

#define DEVICE_SCREEN_SIZE  [UIScreen mainScreen].bounds.size

#define DEVICE_HAS_ORIENTATION(orientation) ([[UIApplication sharedApplication] statusBarOrientation] == orientation)

#define DEVICE_ORIENTATION_POTRAIT    (  DEVICE_HAS_ORIENTATION(UIInterfaceOrientationPortrait) ||  DEVICE_HAS_ORIENTATION(UIInterfaceOrientationPortraitUpsideDown))

#define DEVICE_ORIENTATION_LANDSCAPE    (  DEVICE_HAS_ORIENTATION(UIInterfaceOrientationLandscapeLeft) ||  DEVICE_HAS_ORIENTATION(UIInterfaceOrientationLandscapeRight))

#endif /* MacroUtil_h */
