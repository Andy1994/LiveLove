//
//  GFContainerViewController.m
//  GetFun
//
//  Created by Liu Peng on 16/1/20.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFContainerViewController.h"

@implementation GFContainerAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}

@end

/** A private UIViewControllerContextTransitioning class to be provided transitioning delegates.
 @discussion Because we are a custom UIVievController class, with our own containment implementation, we have to provide an object conforming to the UIViewControllerContextTransitioning protocol. The system view controllers use one provided by the framework, which we cannot configure, let alone create. This class will be used even if the developer provides their own transitioning objects.
 @note The only methods that will be called on objects of this class are the ones defined in the UIViewControllerContextTransitioning protocol. The rest is our own private implementation.
 */
@interface PrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.
@end

/** Instances of this private class perform the default transition animation which is to slide child views horizontally.
 @note The class only supports UIViewControllerAnimatedTransitioning at this point. Not UIViewControllerInteractiveTransitioning.
 */
@interface PrivateAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

#pragma mark -

@interface GFContainerViewController ()
@property (nonatomic, copy, readwrite) NSArray *viewControllers;
@property (nonatomic, strong) UIView *privateContainerView; /// The view hosting the child view controllers views.
@end

@implementation GFContainerViewController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    NSParameterAssert ([viewControllers count] > 0);
    if ((self = [super init])) {
        self.viewControllers = [viewControllers copy];
    }
    return self;
}

- (void)switchToViewController:(NSUInteger)index {
    UIViewController *selectedViewController = self.viewControllers[index];
    self.selectedViewController = selectedViewController;
    
    if ([self.delegate respondsToSelector:@selector (containerViewController:didSelectViewController:)]) {
        [self.delegate containerViewController:self didSelectViewController:selectedViewController];
    }
}

- (void)loadView {
    
    // Add  container and buttons views.
    
    UIView *rootView = [[UIView alloc] init];
    rootView.backgroundColor = [UIColor blackColor];
    rootView.opaque = YES;
    
    self.privateContainerView = [[UIView alloc] init];
    self.privateContainerView.backgroundColor = [UIColor blackColor];
    self.privateContainerView.opaque = YES;
    
    
    [self.privateContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rootView addSubview:self.privateContainerView];
    
    // Container view fills out entire root view.
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    
    self.view = rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedViewController = (self.selectedViewController ?: self.viewControllers[0]);
}

-(void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSParameterAssert (selectedViewController);
    [self _transitionToChildViewController:selectedViewController];
    _selectedViewController = selectedViewController;
}

#pragma mark Private Methods
- (void)_transitionToChildViewController:(UIViewController *)toViewController {
    
    UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }
    
    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.privateContainerView.bounds;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    // If this is the initial presentation, add the new child with no animation.
    if (!fromViewController) {
        [self.privateContainerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        return;
    }
    
    // Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    if ([self.delegate respondsToSelector:@selector (containerViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
        animator = [self.delegate containerViewController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
    }
    animator = (animator ?: [[PrivateAnimatedTransition alloc] init]);
    
    // Because of the nature of our view controller, with horizontally arranged buttons, we instantiate our private transition context with information about whether this is a left-to-right or right-to-left transition. The animator can use this information if it wants.
    NSUInteger fromIndex = [self.viewControllers indexOfObject:fromViewController];
    NSUInteger toIndex = [self.viewControllers indexOfObject:toViewController];
    PrivateTransitionContext *transitionContext = [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController goingRight:toIndex > fromIndex];
    
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
    };
    
    [animator animateTransition:transitionContext];
}

@end

#pragma mark - Private Transitioning Classes

@interface PrivateTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation PrivateTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight {
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.privateViewControllers = @{
                                        UITransitionContextFromViewControllerKey:fromViewController,
                                        UITransitionContextToViewControllerKey:toViewController,
                                        };
        
        // Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
        CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }
    
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingFromRect;
    } else {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingToRect;
    } else {
        return self.privateAppearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end

@implementation PrivateAnimatedTransition

static CGFloat const kChildViewPadding = 16;
static CGFloat const kDamping = 0.75;
static CGFloat const kInitialSpringVelocity = 0.5;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // When sliding the views horizontally in and out, figure out whether we are going left or right.
    BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x < [transitionContext finalFrameForViewController:toViewController].origin.x);
    CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
    CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    toViewController.view.transform = CGAffineTransformInvert (travel);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
        fromViewController.view.transform = travel;
        fromViewController.view.alpha = 0;
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end