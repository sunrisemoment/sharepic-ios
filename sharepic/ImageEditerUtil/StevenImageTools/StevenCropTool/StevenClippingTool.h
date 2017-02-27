//
//  StevenClippingTool.h
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenImageToolBase.h"

static NSString* const kCLNotificationTapOnElseClipArea = @"kCLNotificationTapOnElseClipArea";

@interface StevenClippingTool : StevenImageToolBase

-(void)setRatio:(CGFloat)width height:(CGFloat)height;
-(void)setRatioOrientationWithIsLandscape:(BOOL)isLandscape;

@end
