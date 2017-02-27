//
//  StevenFilterTool.m
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenFilterTool.h"
#import "StevenFilterBase.h"
#import "../../StevenImageEditor.h"

@implementation StevenFilterTool
{
    UIImage *_originalImage;
}

- (void)setup
{
    _originalImage = self.editor.imageView.image;
}

- (void)cleanup
{
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    completionBlock(self.editor.imageView.image, nil, nil);
}

#pragma mark-

+ (UIImage*)filteredImage:(UIImage*)image withFilter:(STEVEN_FILTER)filter
{
    @autoreleasepool {
        Class filterClass = NSClassFromString([StevenFilterTool toolNameFrom:filter]);
        if([(Class)filterClass conformsToProtocol:@protocol(StevenFilterBaseProtocol)]){
            return [filterClass applyFilter:image];
        }
        return nil;
    }
}

+ (NSString*)toolNameFrom:(STEVEN_FILTER)filter {
    switch (filter) {
        case None:
            return @"StevenDefaultEmptyFilter";
        case Linear:
            return @"StevenDefaultLinearFilter";
        case Vignette:
            return @"StevenDefaultVignetteFilter";
        case Instant:
            return @"StevenDefaultInstantFilter";
        case Process:
            return @"StevenDefaultProcessFilter";
        case Transfer:
            return @"StevenDefaultTransferFilter";
        case Sepia:
            return @"StevenDefaultSepiaFilter";
        case Chrome:
            return @"StevenDefaultChromeFilter";
        case Fade:
            return @"StevenDefaultFadeFilter";
        case Curve:
            return @"StevenDefaultCurveFilter";
        case Tonal:
            return @"StevenDefaultTonalFilter";
        case Noir:
            return @"StevenDefaultNoirFilter";
        case Mono:
            return @"StevenDefaultMonoFilter";
        case Invert:
            return @"StevenDefaultInvertFilter";
    }
}

-(void)setFilter:(STEVEN_FILTER)filter {
    static BOOL inProgress = NO;

    if(inProgress){ return; }
    inProgress = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [StevenFilterTool filteredImage:_originalImage withFilter:filter];
        [self.editor.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        inProgress = NO;
    });
}

-(UIImage*)originalImage {
    return _originalImage;
}

@end
