//
//  UINavigationController+TransitionStyle.h
//  FindTalents
//
//  Created by steven on 4/5/2016.
//  Copyright © 2016 steven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (TransitionStyle)

-(void)pushViewControllerWithPresentStyleAnimation:(UIViewController *)viewController;
-(UIViewController *)popViewControllerWithPresentStyleAnimated;
@end
