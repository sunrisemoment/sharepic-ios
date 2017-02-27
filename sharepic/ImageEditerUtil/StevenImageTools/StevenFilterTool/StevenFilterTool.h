//
//  StevenFilterTool.h
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenImageToolBase.h"

typedef enum: NSUInteger {
    None = 0,
    Linear,
    Vignette,
    Instant,
    Process,
    Transfer,
    Sepia,
    Chrome,
    Fade,
    Curve,
    Tonal,
    Noir,
    Mono,
    Invert
}STEVEN_FILTER;

@interface StevenFilterTool : StevenImageToolBase

-(void)setFilter:(STEVEN_FILTER)filter;

/**
 May takes some time to apply filter to the image, so should be called not on the main thread
 @param image image to which filter is applied
 @return image filtered image
 */
+(UIImage*)filteredImage:(UIImage*)image withFilter:(STEVEN_FILTER)filter;
-(UIImage*)originalImage;

@end
