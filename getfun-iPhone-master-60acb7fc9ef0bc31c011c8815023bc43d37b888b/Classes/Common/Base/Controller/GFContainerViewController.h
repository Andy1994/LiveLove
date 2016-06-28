//
//  GFContainerViewController.h
//  GetFun
//
//  Created by Liu Peng on 16/1/20.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFContainerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@protocol GFContainerViewControllerDelegate;


@interface GFContainerViewController : UIViewController

/// The container view controller delegate receiving the protocol callbacks.
@property (nonatomic, weak) id<GFContainerViewControllerDelegate>delegate;

/// The view controllers currently managed by the container view controller.
@property (nonatomic, copy, readonly) NSArray<__kindof UIViewController *> *viewControllers;

/// The currently selected and visible child view controller.
@property (nonatomic, assign) UIViewController *selectedViewController;

/** Designated initializer.
 @note The view controllers array cannot be changed after initialization.
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

- (void)switchToViewController:(NSUInteger)index;

@end

@protocol GFContainerViewControllerDelegate <NSObject>
@optional
/** Informs the delegate that the user selected view controller by tapping the corresponding icon.
 @note The method is called regardless of whether the selected view controller changed or not and only as a result of the user tapped a button. The method is not called when the view controller is changed programmatically. This is the same pattern as UITabBarController uses.
 */
- (void)containerViewController:(GFContainerViewController *)containerViewController didSelectViewController:(UIViewController *)viewController;

/// Called on the delegate to obtain a UIViewControllerAnimatedTransitioning object which can be used to animate a non-interactive transition.
- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(GFContainerViewController *)containerViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;
@end
