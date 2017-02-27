//
//  StevenInputView.h
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StevenInputViewDelegate;

static const CGFloat STEVEN_INPUTVIEW_HEIGHT = 60.0;

@interface StevenInputView : UIView

@property (nonatomic, weak) id<StevenInputViewDelegate> delegate;
@property (nonatomic, strong) NSString *selectedText;
- (void)setTextColor:(UIColor*)textColor;
@end

@protocol StevenInputViewDelegate <NSObject>
@optional
- (void)stevenInputView:(StevenInputView*)settingView didChangeText:(NSString*)text;
@end