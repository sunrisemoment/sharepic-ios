//
//  StevenRotateTool.h
//  sharepic
//
//  Created by steven on 19/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenImageToolBase.h"

@interface StevenRotateTool : StevenImageToolBase

/**
 *@param ratate the image by delt * M_PI
 */
- (void)rotate:(CGFloat)delta;
- (void)rotateBy90WithClockwise:(BOOL)clockwise animate_completion:(void(^)(void))completion;
- (void)flip:(BOOL)inVertical;

@end
