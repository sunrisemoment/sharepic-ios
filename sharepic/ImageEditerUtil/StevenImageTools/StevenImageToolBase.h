//
//  StevenImageToolBase.h
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class StevenImageEditor;

static const CGFloat kCLImageToolAnimationDuration = 0.3;
static const CGFloat kCLImageToolFadeoutDuration   = 0.2;

@interface StevenImageToolBase : NSObject

@property (nonatomic, weak) StevenImageEditor* editor;

-(id)initWithImageEditor:(StevenImageEditor*)editor;

-(void)cleanup;
-(void)setup;
-(void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock;

+ (UIActivityIndicatorView*)indicatorView;

@end
