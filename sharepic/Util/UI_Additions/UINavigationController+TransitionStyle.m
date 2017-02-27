//
//  UINavigationController+TransitionStyle.m
//  FindTalents
//
//  Created by steven on 4/5/2016.
//  Copyright © 2016 steven. All rights reserved.
//

#import "UINavigationController+TransitionStyle.h"

@implementation UINavigationController (TransitionStyle)
-(void)pushViewControllerWithPresentStyleAnimation:(UIViewController *)viewController{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.fillMode = kCAFillModeForwards;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    [self pushViewController:viewController animated:NO];
}
-(UIViewController *)popViewControllerWithPresentStyleAnimated{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    transition.fillMode = kCAFillModeForwards;
    [self.navigationController.view.layer addAnimation:transition
                                                forKey:kCATransition];
    return [self popViewControllerAnimated:NO];
}
@end
