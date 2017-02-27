//
//  StevenImageEditor.h
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StevenImageTools/StevenImageToolBase.h"
#import "StevenImageEditorCore.h"

@protocol StevenImageEditorDelegate <NSObject>
@optional
-(void)stevenImageEditor:(StevenImageEditor*)editor didSetCurrentTool:(StevenImageToolBase*)tool;
@end

@interface StevenImageEditor : UIViewController<UIScrollViewDelegate>

//To use only one tool on one stevenImageEditor
@property (nonatomic, strong) StevenImageToolBase* currentTool;
//To allow multiple tools on one stevenImageEditor, in this case the tools functions should not be conflicted each other, and in this case must set the workingview property in which the tools works on, and by default, call the setWorkingViewForMultipleTools method to set the workingView
@property (nonatomic, strong) NSMutableArray* tools;
@property (nonatomic, strong, readonly) UIView* workingview;

@property (nonatomic, weak) id<StevenImageEditorDelegate> delegate;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong, readonly) UIScrollView* scrollView;

- (void)showInViewController:(UIViewController*)controller onView:(UIView*)container;

- (void)done:(void (^)(UIImage *, NSError *))completionBlock;
- (void)doneRetainingCurrentTool:(void (^)(UIImage *, NSError *))completionBlock;

- (void)cancel;

- (id)initWithImage:(UIImage*)image delegate:(id<StevenImageEditorDelegate>)delegate;

- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

- (void)changeImageWith:(UIImage*)image;

- (void)setWorkingViewForMultipleTools;

@end
