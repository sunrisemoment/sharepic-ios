//
//  StevenStickerTool.m
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenStickerTool.h"
#import "StevenCircleView.h"
#import "../../StevenImageEditor.h"
#import "../../Utils/UIImage+Additions.h"

static NSString* const kCLStickerToolStickerPathKey = @"stickerPath";
static NSString* const kCLStickerToolDeleteIconName = @"deleteIconAssetsName";

@interface _StevenStickerView : UIView
+ (void)setActiveStickerView:(_StevenStickerView*)view;
+ (void)deactiveCurrentActivatedSticker;
+ (_StevenStickerView*)activedStickerView;
- (NSString*)stickerId;
- (void)setAvtive:(BOOL)active;
- (UIImageView*)imageView;
- (id)initWithImage:(UIImage *)image StickerId:(NSString*)stickerId tool:(StevenStickerTool*)tool;
- (void)setScale:(CGFloat)scale;
@end



@implementation StevenStickerTool
{
    UIImage *_originalImage;
    UIView *_workingView;
}

#pragma mark- implementation

- (void)setup
{
    _originalImage = self.editor.imageView.image;
    
    [self.editor fixZoomScaleWithAnimated:YES];
    
    if (self.editor.workingview) {
        _workingView = self.editor.workingview;
    }
    else {
        _workingView = [[UIView alloc] initWithFrame:[self.editor.view convertRect:self.editor.imageView.frame fromView:self.editor.imageView.superview]];
        _workingView.clipsToBounds = YES;
        [self.editor.view addSubview:_workingView];
    }
}

- (void)cleanup
{
    [self.editor resetZoomScaleWithAnimated:YES];
    
    [_workingView removeFromSuperview];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    [_StevenStickerView setActiveStickerView:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage:_originalImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}

#pragma mark-
- (void)placeStickerOnPanel:(UIImage*)stickerImg stickerId:(NSString*)stickerId
{
    _StevenStickerView *view = [[_StevenStickerView alloc] initWithImage:stickerImg StickerId:stickerId tool:self];
    CGFloat ratio = MIN( (0.5 * _workingView.width) / view.width, (0.5 * _workingView.height) / view.height);
    [view setScale:ratio];
    view.center = CGPointMake(_workingView.width/2, _workingView.height/2);
    
    [_workingView addSubview:view];
    [_StevenStickerView setActiveStickerView:view];
}

- (void)changeActivedStickerColorWith:(UIColor*)color {
    _StevenStickerView* activedStickerView = [_StevenStickerView activedStickerView];
    if (activedStickerView != nil) {
        UIImageView* imgView = activedStickerView.imageView;
        imgView.image = [imgView.image tintedImageWithColor:color];
    }
}

- (void)deactiveCurrentActivatedSticker {
    [_StevenStickerView deactiveCurrentActivatedSticker];
}

- (UIImage*)buildImage:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    [image drawAtPoint:CGPointZero];
    
    CGFloat scale = image.size.width / _workingView.width;
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    [_workingView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (NSArray<NSString*>*)addedStickerId
{
    NSMutableArray* results = [NSMutableArray new];
    for (UIView* view in _workingView.subviews) {
        if([view isKindOfClass:[_StevenStickerView class]]){
            _StevenStickerView* target = (_StevenStickerView*)view;
            [results addObject:target.stickerId];
        }
    }
    return results;
}
@end


@implementation _StevenStickerView
{
    UIImageView *_imageView;
    UIButton *_deleteButton;
    StevenCircleView *_circleView;
    NSString *_stickerId;
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

static _StevenStickerView* activeView = nil;

+ (void)setActiveStickerView:(_StevenStickerView*)view
{
    if(view != activeView){
        [activeView setAvtive:NO];
        activeView = view;
        [activeView setAvtive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_STEVEN_STICKER_ACTIVATED object:nil userInfo:nil];
    }
}

+ (void)deactiveCurrentActivatedSticker {
    if (activeView != nil) {
        [activeView setAvtive:NO];
        activeView = nil;
    }
}

+ (_StevenStickerView*)activedStickerView {
    return activeView;
}

- (NSString*)stickerId {
    return _stickerId;
}


- (id)initWithImage:(UIImage *)image StickerId:(NSString*)stickerId tool:(StevenStickerTool*)tool
{
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width+32, image.size.height+32)];
    if(self){
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.layer.borderColor = [[UIColor blackColor] CGColor];
        _imageView.layer.cornerRadius = 3;
        _imageView.center = self.center;
        [self addSubview:_imageView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_deleteButton setImage:[UIImage imageNamed:@"steven_img_editor_btn_delete.png"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(0, 0, 20, 20);
        _deleteButton.center = _imageView.frame.origin;
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _circleView = [[StevenCircleView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _circleView.center = CGPointMake(_imageView.width + _imageView.frame.origin.x, _imageView.height + _imageView.frame.origin.y);
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _circleView.radius = 0.7;
        _circleView.color = [UIColor whiteColor];
        _circleView.borderColor = [UIColor blackColor];
        _circleView.borderWidth = 2;
        [self addSubview:_circleView];
        _stickerId = stickerId;
        _scale = 1;
        _arg = 0;
        [self initGestures];
    }
    return self;
}

- (void)initGestures
{
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_imageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view= [super hitTest:point withEvent:event];
    if(view==self){
        return nil;
    }
    return view;
}

- (UIImageView*)imageView
{
    return _imageView;
}

- (void)pushedDeleteBtn:(id)sender
{
    _StevenStickerView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[_StevenStickerView class]]){
            nextTarget = (_StevenStickerView*)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[_StevenStickerView class]]){
                nextTarget = (_StevenStickerView*)view;
                break;
            }
        }
    }
    
    [[self class] setActiveStickerView:nextTarget];
    if (nextTarget == nil) {
        NSNotification *n = [NSNotification notificationWithName:kNOTIFICATION_STEVEN_ALLSTICKERITEM_REMOVED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
    }
    [self removeFromSuperview];
}

- (void)setAvtive:(BOOL)active
{
    _deleteButton.hidden = !active;
    _circleView.hidden = !active;
    _imageView.layer.borderWidth = (active) ? 1/_scale : 0;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    _imageView.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_imageView.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (_imageView.height + 32)) / 2;
    rct.size.width  = _imageView.width + 32;
    rct.size.height = _imageView.height + 32;
    self.frame = rct;
    
    _imageView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _imageView.layer.borderWidth = 1/_scale;
    _imageView.layer.cornerRadius = 3/_scale;
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    [[self class] setActiveStickerView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveStickerView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}

- (void)circleViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1;
    static CGFloat tmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        tmpR = sqrt(p.x*p.x + p.y*p.y);
        tmpA = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg   = _initialArg + arg - tmpA;
    [self setScale:MAX(_initialScale * R / tmpR, 0.02)];
}

@end
