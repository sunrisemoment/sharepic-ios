//
//  StevenRotateTool.m
//  sharepic
//
//  Created by steven on 19/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenRotateTool.h"
#import "StevenImageEditor.h"

static NSString* const kCLRotateToolRotateIconName = @"rotateIconAssetsName";
static NSString* const kCLRotateToolFlipHorizontalIconName = @"flipHorizontalIconAssetsName";
static NSString* const kCLRotateToolFlipVerticalIconName = @"flipVerticalIconAssetsName";
static NSString* const kCLRotateToolFineRotationEnabled = @"fineRotationEnabled";
static NSString* const kCLRotateToolCropRotate = @"cropRotateEnabled";

@interface CLRotatePanel : UIView
@property(nonatomic, strong) UIColor *bgColor;
@property(nonatomic, strong) UIColor *gridColor;
@property(nonatomic, assign) CGRect gridRect;
- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame;
@end

@implementation StevenRotateTool
{
    CGRect _initialRect;
    
    BOOL _executed;
    
    CLRotatePanel *_gridView;
    UIImageView *_rotateImageView;
    
    CGFloat _rotationArg;
    CGFloat _orientation;
    NSInteger _flipState1;
    NSInteger _flipState2;
    
    CGFloat _rotateValue;
    
    BOOL _cropRotateEnabled;
}

#pragma mark-

- (void)setup
{
    _executed = NO;
    _cropRotateEnabled = NO;
    
    [self.editor fixZoomScaleWithAnimated:YES];
    
    _initialRect = self.editor.imageView.frame;
    
    _rotationArg = 0;
    _flipState1 = 0;
    _flipState2 = 0;
    
    _gridView = [[CLRotatePanel alloc] initWithSuperview:self.editor.imageView.superview frame:self.editor.imageView.frame];
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.bgColor = [self.editor.view.backgroundColor colorWithAlphaComponent:0.8];
    _gridView.gridColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    _gridView.clipsToBounds = NO;
    
    _rotateImageView = [[UIImageView alloc] initWithFrame:_initialRect];
    _rotateImageView.image = self.editor.imageView.image;
    [_gridView.superview insertSubview:_rotateImageView belowSubview:_gridView];
    self.editor.imageView.hidden = YES;
}

- (void)cleanup
{
    [_gridView removeFromSuperview];
    
    if(_executed){
        [self.editor resetZoomScaleWithAnimated:NO];
        [self.editor fixZoomScaleWithAnimated:NO];
        
        _rotateImageView.transform = CGAffineTransformIdentity;
        _rotateImageView.frame = self.editor.imageView.frame;
        _rotateImageView.image = self.editor.imageView.image;
    }
    [self.editor resetZoomScaleWithAnimated:NO];
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         
                         _rotateImageView.transform = CGAffineTransformIdentity;
                         _rotateImageView.frame = self.editor.imageView.frame;
                     }
                     completion:^(BOOL finished) {
                         [_rotateImageView removeFromSuperview];
                         self.editor.imageView.hidden = NO;
                     }];
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    __block UIActivityIndicatorView *indicator;
    dispatch_async(dispatch_get_main_queue(), ^{
        indicator = [StevenImageToolBase indicatorView];
        indicator.center = CGPointMake(_gridView.width/2, _gridView.height/2);
        [_gridView addSubview:indicator];
        [indicator startAnimating];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage:self.editor.imageView.image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _executed = YES;
            [indicator stopAnimating];
            completionBlock(image, nil, nil);
        });
    });
}

#pragma mark-

- (void)rotate:(CGFloat)delta; {
    _rotateValue = delta;
    [self setRotateImage];
}

- (void)rotateBy90WithClockwise:(BOOL)clockwise animate_completion:(void(^)(void))completion {
    
    if (clockwise) {
        _orientation = (int)floorf((_rotateValue + 1) * 2) + 1;
        
        if(_orientation > 4){ _orientation -= 4; }
        _rotateValue = (_orientation / 2) - 1;
    }
    else {
        _rotateValue = _rotateValue - 0.5;
    }
    
    _gridView.hidden = YES;
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         [self setRotateImage];
                     }
                     completion:^(BOOL finished) {
                         _gridView.hidden = NO;
                         completion();
                     }
     ];
}

- (void)flip:(BOOL)inVertical {
    if (inVertical) {
        _flipState2 = (_flipState2==0) ? 1 : 0;
    }
    else {
        _flipState1 = (_flipState1==0) ? 1 : 0;
    }
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         [self setRotateImage];
                     }
                     completion:^(BOOL finished) {
                         _gridView.hidden = NO;
                     }
     ];
}

- (void)tappedMenu:(UITapGestureRecognizer*)sender
{
    switch (sender.view.tag) {
        case 0:
        {
            _orientation = (int)floorf((_rotateValue + 1) * 2) + 1;
            
            
            if(_orientation > 4){ _orientation -= 4; }
            _rotateValue = (_orientation / 2) - 1;
            
            _gridView.hidden = YES;
            break;
        }
        case 1:
            _flipState1 = (_flipState1==0) ? 1 : 0;
            break;
        case 2:
            _flipState2 = (_flipState2==0) ? 1 : 0;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         [self setRotateImage];
                     }
                     completion:^(BOOL finished) {
                         _gridView.hidden = NO;
                     }
     ];
}

- (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise
{
    CGFloat orientationOffset = 0;
    _rotationArg = orientationOffset + _rotateValue*M_PI;
    if(!clockwise){
        _rotationArg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, _rotationArg, 0, 0, 1);
    transform = CATransform3DRotate(transform, _flipState1*M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, _flipState2*M_PI, 1, 0, 0);
    
    return transform;
}

- (void)setRotateImage
{
    CATransform3D transform = [self rotateTransform:CATransform3DIdentity clockwise:YES];
    
    CGFloat orientationOffset = 0;
    _rotationArg = orientationOffset + _rotateValue*M_PI;
    CGFloat Wnew = fabs(_initialRect.size.width * cos(_rotationArg)) + fabs(_initialRect.size.height * sin(_rotationArg));
    CGFloat Hnew = fabs(_initialRect.size.width * sin(_rotationArg)) + fabs(_initialRect.size.height * cos(_rotationArg));
    
    CGFloat Rw = _gridView.width / Wnew;
    CGFloat Rh = _gridView.height / Hnew;
    CGFloat scale = MIN(Rw, Rh) * 0.95;
    if (_cropRotateEnabled) {
        Rw = _initialRect.size.width / Wnew;
        Rh = _initialRect.size.height / Hnew;
        scale = 1 / MIN(Rw, Rh);
    }
    
    
    transform = CATransform3DScale(transform, scale, scale, 1);
    _rotateImageView.layer.transform = transform;
    
    if (!_cropRotateEnabled) {
        _gridView.gridRect = _rotateImageView.frame;
    }
}

- (UIImage*)buildImage:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    CGAffineTransform transform = CATransform3DGetAffineTransform([self rotateTransform:CATransform3DIdentity clockwise:NO]);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    if (_cropRotateEnabled) {
        result = [self cropAdjustImage:result];
    }
    
    return result;
}

- (UIImage *)cropAdjustImage:(UIImage *)image
{
    CGFloat Wnew = fabs(_initialRect.size.width * cos(_rotationArg)) + fabs(_initialRect.size.height * sin(_rotationArg));
    CGFloat Hnew = fabs(_initialRect.size.width * sin(_rotationArg)) + fabs(_initialRect.size.height * cos(_rotationArg));
    
    CGFloat Rw = _initialRect.size.width / Wnew;
    CGFloat Rh = _initialRect.size.height / Hnew;
    CGFloat scale = MIN(Rw, Rh);
    
    CGSize originalFrame = self.editor.imageView.image.size;
    CGFloat finalW = originalFrame.width * scale;
    CGFloat finalH = originalFrame.height * scale;
    
    CGFloat deltaX = (image.size.width - finalW) / 2.0;
    CGFloat deltaY = (image.size.height - finalH) / 2.0;
    CGRect newFrame = CGRectMake(deltaX, deltaY, finalW, finalH);
    UIImage *croppedImage = [image crop:newFrame];
    
    return croppedImage;
}

@end

@implementation CLRotatePanel

- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame
{
    self = [super initWithFrame:superview.bounds];
    if(self){
        self.gridRect = frame;
        [superview addSubview:self];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.gridRect;
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextStrokeRect(context, rct);
}

- (void)setGridRect:(CGRect)gridRect
{
    _gridRect = gridRect;
    [self setNeedsDisplay];
}
@end
