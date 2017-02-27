//
//  StevenStickerTool.h
//  sharepic
//
//  Created by steven on 17/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

#import "StevenImageToolBase.h"

static NSString* kNOTIFICATION_STEVEN_STICKER_ACTIVATED = @"STEVEN_STICKER_ACTIVATED";
static NSString* kNOTIFICATION_STEVEN_ALLSTICKERITEM_REMOVED = @"STEVEN_ALLSTICKERITEM_REMOVED";

@class _StevenStickerView;

@interface StevenStickerTool : StevenImageToolBase

- (void)placeStickerOnPanel:(UIImage*)stickerImg stickerId:(NSString*)stickerId;
- (void)changeActivedStickerColorWith:(UIColor*)color;
- (void)deactiveCurrentActivatedSticker;
- (NSArray<NSString*>*)addedStickerId;
@end
