//
//  StevenFilterBase.m
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenFilterBase.h"

@implementation StevenFilterBase

#pragma mark-

+ (UIImage*)applyFilter:(UIImage*)image
{
    return image;
}
@end




#pragma mark- Default Filters


@interface StevenDefaultEmptyFilter : StevenFilterBase

@end

@implementation StevenDefaultEmptyFilter

+ (NSDictionary*)defaultFilterInfo
{
    NSDictionary *defaultFilterInfo = nil;
    if(defaultFilterInfo==nil){
        defaultFilterInfo =
        @{
            @"StevenDefaultEmptyFilter"     : @{@"name":@"StevenDefaultEmptyFilter", @"title":@"None",       @"version":@(0.0), @"dockedNum":@(0.0)},
            @"StevenDefaultLinearFilter"    : @{@"name":@"CISRGBToneCurveToLinear",  @"title":@"Linear",     @"version":@(7.0), @"dockedNum":@(1.0)},
            @"StevenDefaultVignetteFilter"  : @{@"name":@"CIVignetteEffect",         @"title":@"Vignette",   @"version":@(7.0), @"dockedNum":@(2.0)},
            @"StevenDefaultInstantFilter"   : @{@"name":@"CIPhotoEffectInstant",     @"title":@"Instant",    @"version":@(7.0), @"dockedNum":@(3.0)},
            @"StevenDefaultProcessFilter"   : @{@"name":@"CIPhotoEffectProcess",     @"title":@"Process",    @"version":@(7.0), @"dockedNum":@(4.0)},
            @"StevenDefaultTransferFilter"  : @{@"name":@"CIPhotoEffectTransfer",    @"title":@"Transfer",   @"version":@(7.0), @"dockedNum":@(5.0)},
            @"StevenDefaultSepiaFilter"     : @{@"name":@"CISepiaTone",              @"title":@"Sepia",      @"version":@(5.0), @"dockedNum":@(6.0)},
            @"StevenDefaultChromeFilter"    : @{@"name":@"CIPhotoEffectChrome",      @"title":@"Chrome",     @"version":@(7.0), @"dockedNum":@(7.0)},
            @"StevenDefaultFadeFilter"      : @{@"name":@"CIPhotoEffectFade",        @"title":@"Fade",       @"version":@(7.0), @"dockedNum":@(8.0)},
            @"StevenDefaultCurveFilter"     : @{@"name":@"CILinearToSRGBToneCurve",  @"title":@"Curve",      @"version":@(7.0), @"dockedNum":@(9.0)},
            @"StevenDefaultTonalFilter"     : @{@"name":@"CIPhotoEffectTonal",       @"title":@"Tonal",      @"version":@(7.0), @"dockedNum":@(10.0)},
            @"StevenDefaultNoirFilter"      : @{@"name":@"CIPhotoEffectNoir",        @"title":@"Noir",       @"version":@(7.0), @"dockedNum":@(11.0)},
            @"StevenDefaultMonoFilter"      : @{@"name":@"CIPhotoEffectMono",        @"title":@"Mono",       @"version":@(7.0), @"dockedNum":@(12.0)},
            @"StevenDefaultInvertFilter"    : @{@"name":@"CIColorInvert",            @"title":@"Invert",     @"version":@(6.0), @"dockedNum":@(13.0)},
        };
    }
    return defaultFilterInfo;
}

+ (id)defaultInfoForKey:(NSString*)key
{
    return self.defaultFilterInfo[NSStringFromClass(self)][key];
}

+ (NSString*)filterName
{
    return [self defaultInfoForKey:@"name"];
}

#pragma mark- 

+ (NSString*)defaultTitle
{
    return [self defaultInfoForKey:@"title"];
}

#pragma mark- 

+ (UIImage*)applyFilter:(UIImage *)image
{
    return [self filteredImage:image withFilterName:self.filterName];
}

+ (UIImage*)filteredImage:(UIImage*)image withFilterName:(NSString*)filterName
{
    if([filterName isEqualToString:@"StevenDefaultEmptyFilter"]){
        return image;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    
    if([filterName isEqualToString:@"CIVignetteEffect"]){
        // parameters for CIVignetteEffect
        CGFloat R = MIN(image.size.width, image.size.height)*image.scale/2;
        CIVector *vct = [[CIVector alloc] initWithX:image.size.width*image.scale/2 Y:image.size.height*image.scale/2];
        [filter setValue:vct forKey:@"inputCenter"];
        [filter setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
        [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    }
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

@end


@interface StevenDefaultLinearFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultLinearFilter
@end

@interface StevenDefaultVignetteFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultVignetteFilter
@end

@interface StevenDefaultInstantFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultInstantFilter
@end

@interface StevenDefaultProcessFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultProcessFilter
@end

@interface StevenDefaultTransferFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultTransferFilter
@end

@interface StevenDefaultSepiaFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultSepiaFilter
@end

@interface StevenDefaultChromeFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultChromeFilter
@end

@interface StevenDefaultFadeFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultFadeFilter
@end

@interface StevenDefaultCurveFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultCurveFilter
@end

@interface StevenDefaultTonalFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultTonalFilter
@end

@interface StevenDefaultNoirFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultNoirFilter
@end

@interface StevenDefaultMonoFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultMonoFilter
@end

@interface StevenDefaultInvertFilter : StevenDefaultEmptyFilter
@end
@implementation StevenDefaultInvertFilter
@end
