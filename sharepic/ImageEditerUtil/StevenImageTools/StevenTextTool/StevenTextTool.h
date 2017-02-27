//
//  StevenTextTool.h
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//
#import "StevenImageToolBase.h"

static NSString* kNOTIFICATION_STEVEN_TEXTITEM_ACTIVATED = @"STEVEN_TEXTTOOL_ITEM_ACTIVATED";
static NSString* kNOTIFICATION_STEVEN_ALLTEXTITEM_REMOVED = @"STEVEN_ALLTEXTITEM_REMOVED";
static NSString* InitialText = @"Text Here";

@class _StevenTextView;
@class StevenTextLabel;

@interface StevenTextTool : StevenImageToolBase

- (_StevenTextView*)activeTextView;
- (void)addNewText;
- (NSArray<_StevenTextView*>*)addedTextViews;

- (void)setFontForActivatedTextView:(UIFont*)font;
- (void)setTextAlignmentForActivatedTextView:(NSTextAlignment)alignment;
- (void)setFillColorForActivatedTextView:(UIColor*)color;
- (void)setBorderColorForActivatedTextView:(UIColor*)color;
- (void)setBorderWidthForActivatedTextView:(CGFloat)width;

- (void)hideInputView;
- (BOOL)isEditing;

- (void)deactiveCurrentActivatedTextView;
@end

@interface _StevenTextView : UIView

@property (nonatomic, strong) StevenTextLabel *label;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSTextAlignment textAlignment;

+ (_StevenTextView*)activeView;
+ (void)setActiveTextView:(_StevenTextView*)view;
+ (void)deactiveCurrentActivatedTextView;
- (id)initWithTool:(StevenTextTool*)tool;
- (void)setScale:(CGFloat)scale;
- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight;
- (void)remove;

@end