//
//  FormTextField.h
//  Smart Visitor
//
//  Created by Addon Web Solutions on 10/12/15.
//  Copyright © 2015 Addon Web Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormTextField : UITextField<UITextFieldDelegate>

/**
 *title displaied on IQToolBar
 */
@property (nonatomic, strong) NSString* toolbarTitle;

/**
 *  Set left Image
 *
 *  @param img UIImage
 */
- (void)setLeftImage:(UIImage *)img;


/**
 *  Set right Image
 *
 *  @param img UIImage
 */
- (void)setRightImage:(UIImage *)img;

/**
 *  Set place holder
 *
 *  @param string placeholder text
 */
-(void)setAttributedPlaceholderWithString:(NSString *)placeholder;

/**
 *  Set style
 *
 *  @param
 */
-(void)setStyleWithBorderColor:(UIColor *)color andLeftImage:(UIImage *)left_img andRightImage:(UIImage *)right_img;

/**
 *set textfield editing disabled. when disabled, but the right view can work if ignore is false.
 *useful when work with IQKeybord Manager in which shouldEditingStart doesn't work well
 */
-(void)setEditingDisable:(BOOL)flag disableRightView:(BOOL)disable;

-(void)setEditingDisable:(BOOL)flag;

-(void)removeBorder;
@end
