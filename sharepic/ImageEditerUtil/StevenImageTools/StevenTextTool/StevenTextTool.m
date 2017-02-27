//
//  StevenTextTool.m
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//
#import "StevenTextTool.h"
#import "../../StevenImageEditor.h"

#import "../AuxiliaryTools/StevenCircleView.h"
#import "StevenTextLabel.h"
#import "StevenInputView.h"

static NSString* const CLTextViewActiveViewDidChangeNotification = @"CLTextViewActiveViewDidChangeNotificationString";
static NSString* const CLTextViewActiveViewDidTapNotification = @"CLTextViewActiveViewDidTapNotificationString";

static NSString* const kCLTextToolDeleteIconName = @"deleteIconAssetsName";
static NSString* const kCLTextToolCloseIconName = @"closeIconAssetsName";
static NSString* const kCLTextToolNewTextIconName = @"newTextIconAssetsName";
static NSString* const kCLTextToolEditTextIconName = @"editTextIconAssetsName";
static NSString* const kCLTextToolFontIconName = @"fontIconAssetsName";
static NSString* const kCLTextToolAlignLeftIconName = @"alignLeftIconAssetsName";
static NSString* const kCLTextToolAlignCenterIconName = @"alignCenterIconAssetsName";
static NSString* const kCLTextToolAlignRightIconName = @"alignRightIconAssetsName";


@interface StevenTextTool()
<UITextViewDelegate, StevenInputViewDelegate>
@property (nonatomic, strong) _StevenTextView *selectedTextView;
@end

@implementation StevenTextTool
{
    UIImage *_originalImage;
    UIView *_workingView;
    
    StevenInputView *_inputView;
}

#pragma mark- implementation

- (void)setup
{
    _originalImage = self.editor.imageView.image;
    
    [self.editor fixZoomScaleWithAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeTextViewDidChange:) name:CLTextViewActiveViewDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeTextViewDidTap:) name:CLTextViewActiveViewDidTapNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.editor.workingview) {
        _workingView = self.editor.workingview;
    }
    else {
        _workingView = [[UIView alloc] initWithFrame:[self.editor.view convertRect:self.editor.imageView.frame fromView:self.editor.imageView.superview]];
        _workingView.clipsToBounds = YES;
        [self.editor.view addSubview:_workingView];
    }
    
    _inputView = [[StevenInputView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, STEVEN_INPUTVIEW_HEIGHT)];
    _inputView.backgroundColor = [UIColor clearColor];
    _inputView.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_inputView];
    
    self.selectedTextView = nil;
}

- (void)cleanup
{
    [self.editor resetZoomScaleWithAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_inputView endEditing:YES];
    [_inputView removeFromSuperview];
    [_workingView removeFromSuperview];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    [_StevenTextView setActiveTextView:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self buildImage:_originalImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image, nil, nil);
        });
    });
}

#pragma mark-

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

- (void)setSelectedTextView:(_StevenTextView *)selectedTextView
{
    if(selectedTextView != _selectedTextView){
        _selectedTextView = selectedTextView;
    }
    
    if(_selectedTextView==nil){
        [self hideInputView];
    }
    else{
        _inputView.selectedText = selectedTextView.text;
    }
}

- (void)deactiveCurrentActivatedTextView {
    [_StevenTextView deactiveCurrentActivatedTextView];
    [self hideInputView];
}

- (void)activeTextViewDidChange:(NSNotification*)notification
{
    self.selectedTextView = notification.object;
}

- (void)activeTextViewDidTap:(NSNotification*)notification
{
    [self beginTextEditting];
}

- (void)addNewText
{
    _StevenTextView *view = [[_StevenTextView alloc] initWithTool:self];
    
    //set default values
    view.fillColor = [UIColor whiteColor];
    view.borderColor = [UIColor blackColor];
    view.borderWidth = 0.0;
    view.font = [UIFont fontWithName:@"Helvetica" size:16];
    view.textAlignment = NSTextAlignmentCenter;
    
    CGFloat ratio = MIN( (0.8 * _workingView.width) / view.width, (0.2 * _workingView.height) / view.height);
    [view setScale:ratio];
    view.center = CGPointMake(_workingView.width/2, view.height/2 + 10);
    
    [_workingView addSubview:view];
    [_StevenTextView setActiveTextView:view];
    
    [self beginTextEditting];
}

- (_StevenTextView*)activeTextView {
    return [_StevenTextView activeView];
}

- (void)hideInputView
{
    if (([_StevenTextView activeView] != nil) && ([[_StevenTextView activeView].text isEqualToString:@""])) {
        
        [[_StevenTextView activeView] remove];
    }
    
    [_inputView resignFirstResponder];
    [_inputView endEditing:YES];
    _inputView.hidden = YES;
}

- (void)beginTextEditting
{
    _inputView.hidden = NO;
    [_inputView becomeFirstResponder];
}

- (BOOL)isEditing {
    return !_inputView.hidden;
}

- (void)setTextAlignmentForActivatedTextView:(NSTextAlignment)alignment;
{
    self.selectedTextView.textAlignment = alignment;
}

- (void)keyboardWillShown:(NSNotification*)notification {
    if ([_inputView isFirstResponder]) {
        CGSize keyboardSize = [[UIApplication sharedApplication].keyWindow convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromWindow:nil].size;
        
        CGSize size = [UIApplication sharedApplication].keyWindow.bounds.size;
        CGFloat height = STEVEN_INPUTVIEW_HEIGHT;
        CGFloat y =  size.height - (keyboardSize.height + height);
        
        CGRect frame = _inputView.frame;
        frame.origin.y = y;
        
        [_inputView setFrame:frame];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    if ([self isEditing]) {
        [self hideInputView];
    }
}

#pragma mark- Setting view delegate
- (void)stevenInputView:(StevenInputView *)settingView didChangeText:(NSString *)text {
    self.selectedTextView.text = text;
    [self.selectedTextView sizeToFitWithMaxWidth:0.8*_workingView.width lineHeight:0.2*_workingView.height];
}

#pragma mark - 
- (void)setFillColorForActivatedTextView:(UIColor*)color
{
    self.selectedTextView.fillColor = color;
}

- (void)setBorderColorForActivatedTextView:(UIColor*)color
{
    self.selectedTextView.borderColor = color;
}

- (void)setBorderWidthForActivatedTextView:(CGFloat)width
{
    self.selectedTextView.borderWidth = width;
}

- (void)setFontForActivatedTextView:(UIFont*)font
{
    self.selectedTextView.font = font;
    [self.selectedTextView sizeToFitWithMaxWidth:0.8*_workingView.width lineHeight:0.2*_workingView.height];
}

#pragma mark - 
- (NSArray<_StevenTextView*>*)addedTextViews
{
    NSMutableArray* results = [NSMutableArray new];
    
    for (UIView* view in _workingView.subviews) {
        if([view isKindOfClass:[_StevenTextView class]]){
            _StevenTextView* target = (_StevenTextView*)view;
            [results addObject:target];
        }
    }
    
    return results;
}

@end

const CGFloat MAX_FONT_SIZE = 50.0;

#pragma mark- _CLTextView

@implementation _StevenTextView
{
    UIButton *_deleteButton;
    StevenCircleView *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

static _StevenTextView *activeView = nil;

+ (void)setActiveTextView:(_StevenTextView*)view
{
    if(view != activeView){
        [activeView setAvtive:NO];
        activeView = view;
        [activeView setAvtive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
        
        NSNotification *n = [NSNotification notificationWithName:CLTextViewActiveViewDidChangeNotification object:view userInfo:nil];
        NSNotification *n1 = [NSNotification notificationWithName:kNOTIFICATION_STEVEN_TEXTITEM_ACTIVATED object:view userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n1 waitUntilDone:NO];
        
    }
}

+ (_StevenTextView*)activeView {
    return activeView;
}

+ (void)deactiveCurrentActivatedTextView {
    if (activeView != nil) {
        
        if ([activeView.text isEqualToString:@""]) {
            [activeView pushedDeleteBtn:nil];
        }
        else {
            [activeView setAvtive:NO];
            activeView = nil;
            
            NSNotification *n = [NSNotification notificationWithName:CLTextViewActiveViewDidChangeNotification object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
        }
    }
}

- (id)initWithTool:(StevenTextTool*)tool
{
    self = [super initWithFrame:CGRectMake(0, 0, 132, 132)];
    if(self){
        _label = [[StevenTextLabel alloc] init];
        [_label setTextColor:[UIColor whiteColor]];
        _label.numberOfLines = 0;
        _label.backgroundColor = [UIColor clearColor];
        _label.layer.borderColor = [[UIColor blackColor] CGColor];
        _label.layer.cornerRadius = 3;
        _label.font = [UIFont systemFontOfSize:MAX_FONT_SIZE];
        _label.minimumScaleFactor = 1/MAX_FONT_SIZE;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        self.text = @"";
        [self addSubview:_label];
        
        CGSize size = [_label sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)];
        _label.frame = CGRectMake(16, 16, size.width, size.height);
        self.frame = CGRectMake(0, 0, size.width + 32, size.height + 32);
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"steven_img_editor_btn_delete.png"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(0, 0, 20, 20);
        _deleteButton.center = _label.frame.origin;
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _circleView = [[StevenCircleView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _circleView.center = CGPointMake(_label.width + _label.left, _label.height + _label.top);
        _circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _circleView.radius = 0.7;
        _circleView.color = [UIColor whiteColor];
        _circleView.borderColor = [UIColor blackColor];
        _circleView.borderWidth = 2;
        [self addSubview:_circleView];
        
        _arg = 0;
        [self setScale:1];
        
        [self initGestures];
    }
    return self;
}

- (void)initGestures
{
    _label.userInteractionEnabled = YES;
    [_label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_label addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
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

#pragma mark- Properties

- (void)setAvtive:(BOOL)active
{
    _deleteButton.hidden = !active;
    _circleView.hidden = !active;
    _label.layer.borderWidth = (active) ? 1/_scale : 0;
}

- (BOOL)active
{
    return !_deleteButton.hidden;
}

- (void)sizeToFitWithMaxWidth:(CGFloat)width lineHeight:(CGFloat)lineHeight
{
    self.transform = CGAffineTransformIdentity;
    _label.transform = CGAffineTransformIdentity;
    
    CGSize size = [_label sizeThatFits:CGSizeMake(width / (15/MAX_FONT_SIZE), FLT_MAX)];
    //@ 40, 20 means the padding of the text and its area, can be edited as proper value to aviod the text cropped...
    _label.frame = CGRectMake(16, 16, size.width + 40, size.height + 20);
    
    CGFloat viewW = (_label.width + 32);
    CGFloat viewH = _label.font.lineHeight;
    
    CGFloat ratio = MIN(width / viewW, lineHeight / viewH);
    [self setScale:ratio];
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    _label.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_label.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (_label.height + 32)) / 2;
    rct.size.width  = _label.width + 32;
    rct.size.height = _label.height + 32;
    self.frame = rct;
    
    _label.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);
    
    _label.layer.borderWidth = 1/_scale;
    _label.layer.cornerRadius = 3/_scale;
}

- (void)setFillColor:(UIColor *)fillColor
{
    _label.textColor = fillColor;
}

- (UIColor*)fillColor
{
    return _label.textColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _label.outlineColor = borderColor;
}

- (UIColor*)borderColor
{
    return _label.outlineColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _label.outlineWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return _label.outlineWidth;
}

- (void)setFont:(UIFont *)font
{
    _label.font = [font fontWithSize:MAX_FONT_SIZE];
}

- (UIFont*)font
{
    return _label.font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _label.textAlignment = textAlignment;
}

- (NSTextAlignment)textAlignment
{
    return _label.textAlignment;
}

- (void)setText:(NSString *)text
{
    if(![text isEqualToString:_text]){
        _text = text;
        _label.text = (_text.length>0) ? _text : InitialText;
    }
}

#pragma mark- gesture events

- (void)remove {
    [self pushedDeleteBtn:nil];
}

- (void)pushedDeleteBtn:(id)sender
{
    _StevenTextView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[_StevenTextView class]]){
            nextTarget = (_StevenTextView*)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[_StevenTextView class]]){
                nextTarget = (_StevenTextView*)view;
                break;
            }
        }
    }
    
    [[self class] setActiveTextView:nextTarget];
    if (nextTarget == nil) {
        NSNotification *n = [NSNotification notificationWithName:kNOTIFICATION_STEVEN_ALLTEXTITEM_REMOVED object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
    }
    [self removeFromSuperview];
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    if(self.active){
        NSNotification *n = [NSNotification notificationWithName:CLTextViewActiveViewDidTapNotification object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
    }
    [[self class] setActiveTextView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveTextView:self];
    
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
    [self setScale:MAX(_initialScale * R / tmpR, 15/MAX_FONT_SIZE)];
}

@end


