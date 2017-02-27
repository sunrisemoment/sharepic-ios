//
//  FormTextField.m
//  Smart Visitor
//
//  Created by Addon Web Solutions on 10/12/15.
//  Copyright © 2015 Addon Web Solutions. All rights reserved.
//

#import "FormTextField.h"
#import "MacroUtil.h"

static NSString* FONT_NAME = @"Helvetica-Regular";

@interface FormTextField ()

@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *minHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *maxHeightConstraint;

@property (nonatomic) BOOL isEditingDisable;

@end

@implementation FormTextField


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)associateConstraints{
    
    // iterate through all text view's constraints and identify
    // height, max height and min height constraints.
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            
            if (constraint.relation == NSLayoutRelationEqual) {
                self.heightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationLessThanOrEqual) {
                self.maxHeightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationGreaterThanOrEqual) {
                self.minHeightConstraint = constraint;
            }
        }
    }
    
}

/**
 *  Default Initialization
 */
- (void)initialize{
    
    [self associateConstraints];
    
    //    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    self.borderStyle        = UITextBorderStyleRoundedRect;
    self.leftViewMode       = UITextFieldViewModeAlways;
    self.rightViewMode      = UITextFieldViewModeUnlessEditing;
    self.clearButtonMode    = UITextFieldViewModeWhileEditing;
    
    UIColor *txtColor = [UIColor lightGrayColor];
    
    self.textColor          = [UIColor lightGrayColor];
    self.tintColor          = txtColor;
    self.layer.borderColor  = txtColor.CGColor;
    self.layer.borderWidth  = 1;
    self.layer.cornerRadius = 4;

    //    self.textAlignment = NSTextAlignmentCenter;
    [self setAttributedPlaceholderWithString:self.placeholder];
    
    int minHeight = self.frame.size.height;
    
    self.font = [UIFont fontWithName:FONT_NAME size:13];
    
    if (_heightConstraint) {
        
    }else{
        
        _heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.0f
                                                          constant:minHeight
                             ];
        
        [self addConstraint:_heightConstraint];
        
    }

    _isEditingDisable = NO;
    _toolbarTitle = self.placeholder;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    
    CGRect textRect = [super rightViewRectForBounds:bounds];
//    textRect.origin.x += (DEVICE_IS_IPAD)?10:5;
    return textRect;
    
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    
    CGRect textRect = [super leftViewRectForBounds:bounds];
    textRect.origin.x += (DEVICE_IS_IPAD)?10:5;
    return textRect;
    
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds{
    
    CGRect textRect = [super clearButtonRectForBounds:bounds];
    textRect.origin.x -= (DEVICE_IS_IPAD)?10:5;
    return textRect;

}

- (CGRect)textRectForBounds:(CGRect)bounds{
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x += 4;
    textRect.size.width -= 10;
    
    return textRect;
    
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    
    CGRect textRect = [super editingRectForBounds:bounds];
    textRect.origin.x += 4;
    textRect.size.width -= 10;
    return textRect;
    
}

- (void)setAttributedPlaceholderWithString:(NSString *)placeholder{
    
    if (![placeholder isEqualToString:@""] && !(placeholder == nil)) {
        NSAttributedString *str = [[NSAttributedString alloc]
                                   initWithString:[NSString stringWithFormat:@"%@",placeholder]
                                   attributes:@{
                                                NSForegroundColorAttributeName : colorFromRGBA(170,170,170, 1),
                                                NSFontAttributeName: FONT_NAME
                                                }];
        self.attributedPlaceholder = str;
    }
}

- (void)layoutSubviews{
  
    [super layoutSubviews];

}

/**
 *  Set left Image
 *
 *  @param img UIImage
 */
- (void)setLeftImage:(UIImage *)img{
    
    UIImageView *imageView = [[ UIImageView alloc] init];

    imageView.frame = CGRectMake(5, 0, self.frame.size.height, self.frame.size.height);

    imageView.image  = img;
    imageView.contentMode = UIViewContentModeCenter;
    
    self.leftView = imageView;

    //addborder
    CGFloat borderWidth         = 1;
    CALayer *customBorder       = [CALayer layer];
    customBorder.borderColor    = colorFromRGB(170 , 170, 170).CGColor;
    customBorder.borderWidth    = borderWidth;
    customBorder.frame          = CGRectMake(CGRectGetWidth(imageView.frame)-borderWidth,5, borderWidth,CGRectGetHeight(imageView.frame)- 10);
    
    [imageView.layer addSublayer:customBorder];
    
    imageView.contentMode = UIViewContentModeCenter;
    self.leftViewMode  = UITextFieldViewModeAlways;
    self.leftView      = imageView;
}

/**
 *  Set right Image
 *
 *  @param img UIImage
 */
- (void)setRightImage:(UIImage *)img{
    
    UIImageView *imageView = [[ UIImageView alloc] init];
    
    imageView.frame = CGRectMake(5, 0, self.frame.size.height, self.frame.size.height);

    imageView.image  = img;
    imageView.contentMode = UIViewContentModeCenter;
    
    self.rightView = imageView;

}

-(void)setStyleWithBorderColor:(UIColor *)color andLeftImage:(UIImage *)left_img andRightImage:(UIImage *)right_img{
    self.textColor          = color;
    self.tintColor          = color;
    self.layer.borderColor  = color.CGColor;
    self.layer.borderWidth  = 1;
    self.layer.cornerRadius = 4;
    
    //set leftImage
    if (left_img != nil) {
        UIImageView *imageView = [[ UIImageView alloc] init];
        
        imageView.frame = CGRectMake(5, 0, self.frame.size.height, self.frame.size.height);
        
        imageView.image  = left_img;
        imageView.contentMode = UIViewContentModeCenter;
        
        self.leftView = imageView;
        
        CGFloat borderWidth         = 1;
        CALayer *customBorder       = [CALayer layer];
        customBorder.borderColor    = color.CGColor;
        customBorder.borderWidth    = borderWidth;
        customBorder.frame          = CGRectMake(CGRectGetWidth(imageView.frame)-borderWidth,5, borderWidth,CGRectGetHeight(imageView.frame)- 10);
        
        [imageView.layer addSublayer:customBorder];
        
        imageView.contentMode = UIViewContentModeCenter;
        self.leftViewMode  = UITextFieldViewModeAlways;
        self.leftView      = imageView;
    }
    
    //set rightImage
    if (right_img != nil) {
        UIImageView *imageView = [[ UIImageView alloc] init];
        
        imageView.frame = CGRectMake(5, 0, self.frame.size.height, self.frame.size.height);
        
        imageView.image  = right_img;
        imageView.contentMode = UIViewContentModeCenter;
        
        self.rightView = imageView;
    }
}

-(void)setEditingDisable:(BOOL)flag disableRightView:(BOOL)disable{
    if (flag) {
        if ((self.rightView == nil) || disable) {
            [self setEnabled:NO];
            return;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        view.backgroundColor = [UIColor lightGrayColor];
        view.userInteractionEnabled = YES;
        view.tag = 999;
        view.alpha = 0.1;
        view.exclusiveTouch = YES;
        [self addSubview:view];
    }
    else {
        [self setEnabled:YES];
        [[self viewWithTag:999] removeFromSuperview];
    }
    
}

-(void)setEditingDisable:(BOOL)flag {
    if (flag) {
        if (self.rightView == nil) {
            [self setEnabled:NO];
            return;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        view.backgroundColor = [UIColor lightGrayColor];
        view.userInteractionEnabled = YES;
        view.tag = 999;
        view.alpha = 0.1;
        view.exclusiveTouch = YES;
        [self addSubview:view];
        self.delegate = self;
    }
    else {
        [self setEnabled:YES];
        [[self viewWithTag:999] removeFromSuperview];
        self.delegate = nil;
    }
    
    _isEditingDisable = flag;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (_isEditingDisable) {
        return NO;
    }
    else {
        return YES;
    }
}

-(void)removeBorder {
    self.layer.borderWidth = 0.0;
    self.borderStyle = UITextBorderStyleNone;
}

@end
