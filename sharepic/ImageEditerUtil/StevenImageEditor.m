//
//  StevenImageEditor.m
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenImageEditor.h"

@interface StevenImageEditor ()
@property (nonatomic, strong) UIImage* originalImage;
@end

@implementation StevenImageEditor

- (id)initWithImage:(UIImage*)image delegate:(id<StevenImageEditorDelegate>)delegate{
    self = [super init];
    if (self) {
        _originalImage = [image deepCopy];
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tools = [NSMutableArray new];
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self initImageScrollView];
    
    if(_imageView==nil){
        _imageView = [UIImageView new];
        [_scrollView addSubview:_imageView];
        [self refreshImageView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshImageView];
}

- (void)dealloc {
    
}

#pragma mark - Custom Initialize
- (void)initImageScrollView {
    if (_scrollView == nil) {
        UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageScroll.showsHorizontalScrollIndicator = NO;
        imageScroll.showsVerticalScrollIndicator = NO;
        imageScroll.delegate = self;
        imageScroll.clipsToBounds = NO;
        
        [self.view insertSubview:imageScroll atIndex:0];
        _scrollView = imageScroll;
    }
}

#pragma mark -
- (void)showInViewController:(UIViewController*)controller onView:(UIView*)container {
    
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    self.view.frame = container.bounds;
    [container addSubview:self.view];
    [self refreshImageView];
}

- (void)resetImageViewFrame {
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;
        
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);
    }
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated {
    CGFloat minZoomScale = _scrollView.minimumZoomScale;
    _scrollView.maximumZoomScale = 0.95*minZoomScale;
    _scrollView.minimumZoomScale = 0.95*minZoomScale;
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated {
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)refreshImageView {
    _imageView.image = _originalImage;
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

- (void)changeImageWith:(UIImage*)image {
    _originalImage = [image deepCopy];
    _imageView.image = _originalImage;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Tool Actions
- (void)setCurrentTool:(StevenImageToolBase *)currentTool {
    
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
    }
    if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(stevenImageEditor:didSetCurrentTool:)])) {
        [_delegate stevenImageEditor:self didSetCurrentTool:currentTool];
    }
}

- (void)setTools:(NSArray*)tools {
    for (StevenImageToolBase* tool in _tools) {
        [tool cleanup];
    }
    [_tools removeAllObjects];
    for (StevenImageToolBase* tool in tools) {
        [_tools addObject:tool];
        [tool setup];
    }
}

- (void)setWorkingViewForMultipleTools {
    _workingview = [[UIView alloc] initWithFrame:[self.view convertRect:self.imageView.frame fromView:self.imageView.superview]];
    _workingview.clipsToBounds = YES;
    [self.view addSubview:_workingview];
}

#pragma mark -
- (void)done:(void (^)(UIImage *, NSError *))completionBlock {
    self.view.userInteractionEnabled = NO;
    if (_currentTool) {
        [_currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
            if (error) {
                if (completionBlock != nil)
                    completionBlock(nil, error);
            }
            else if (image){
                _originalImage = image;
                _imageView.image = image;
                
                [self resetImageViewFrame];
                self.currentTool = nil;
                
                if (completionBlock != nil)
                    completionBlock(image, nil);
            }
            self.view.userInteractionEnabled = YES;
        }];
    }
    else if (_tools.count > 0) {
        UIGraphicsBeginImageContextWithOptions(self.imageView.image.size, false, self.imageView.image.scale);
        
        [self.imageView.image drawAtPoint:CGPointZero];
        
        CGFloat scale = self.imageView.image.size.width / self.workingview.width;
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
        [self.workingview.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        completionBlock(image, nil);
        self.view.userInteractionEnabled = YES;
    }
}

- (void)doneRetainingCurrentTool:(void (^)(UIImage *, NSError *))completionBlock {
    self.view.userInteractionEnabled = NO;
    
    [_currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if (error) {
            if (completionBlock != nil)
                completionBlock(nil, error);
        }
        else if (image){
            _originalImage = image;
            _imageView.image = image;
            
            [self resetImageViewFrame];
            
            if (completionBlock != nil)
                completionBlock(image, nil);
        }
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)cancel {
    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    
    self.currentTool = nil;
    [_tools removeAllObjects];
}

#pragma mark- ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.frame.size.width;
    CGFloat H = _imageView.frame.size.height;
    
    CGRect rct = _imageView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.frame = rct;
}

@end
