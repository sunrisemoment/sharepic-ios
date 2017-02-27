//
//  StevenImageToolBase.m
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenImageToolBase.h"
#import "../StevenImageEditor.h"

@implementation StevenImageToolBase

-(id)initWithImageEditor:(StevenImageEditor*)editor {
    self = [super init];
    if (self) {
        self.editor = editor;
    }
    return self;
}

#pragma mark-

- (void)setup
{
    
}

- (void)cleanup
{
    
}

- (void)executeWithCompletionBlock:(void(^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    completionBlock(self.editor.imageView.image, nil, nil);
}

+ (UIActivityIndicatorView*)indicatorView
{
    // default indicator view
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    indicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    indicatorView.layer.cornerRadius = 5;
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    return indicatorView;
}

@end
