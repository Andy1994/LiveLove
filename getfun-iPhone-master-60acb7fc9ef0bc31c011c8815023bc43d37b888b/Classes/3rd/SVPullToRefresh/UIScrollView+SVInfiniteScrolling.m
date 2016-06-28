//
// UIScrollView+SVInfiniteScrolling.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVInfiniteScrolling.h"

#import <objc/runtime.h>

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

static CGFloat const SVInfiniteScrollingViewHeight = 60;

typedef NS_ENUM(NSInteger, SVInfiniteScrollingState) {
    SVInfiniteScrollingStateStopped     = 0,
    SVInfiniteScrollingStateTriggered   = 1,
    SVInfiniteScrollingStateLoading     = 2
};

@interface SVInfiniteScrollingView : UIView

@property (nonatomic, copy) void (^infiniteScrollingHandler)(void);

@property (nonatomic, readwrite) SVInfiniteScrollingState state;
@property (nonatomic, readwrite) CGFloat originalBottomInset;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL isObserving;

@property (nonatomic, readwrite) BOOL enabled;

- (void)startAnimating;
- (void)stopAnimating;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForInfiniteScrolling;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;

@end

@implementation SVInfiniteScrollingView
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull_to_refresh_1"]];
        [_imageView sizeToFit];
        _imageView.center = CGPointMake(self.width/2, self.height/2);
    }
    
    return _imageView;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SVInfiniteScrollingStateStopped;
        self.enabled = YES;
        
        [self addSubview:self.imageView];
        self.imageView.hidden = YES;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsInfiniteScrolling) {
            if (self.isObserving) {
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                self.isObserving = NO;
            }
        }
    }
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + SVInfiniteScrollingViewHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)edgeInset {
    
    self.scrollView.contentInset = edgeInset;
    
//    [UIView animateWithDuration:0.3f animations:^{
//        self.scrollView.contentInset = edgeInset;
//    }];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.bounds.size.width, SVInfiniteScrollingViewHeight);
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != SVInfiniteScrollingStateLoading && self.enabled) {
        CGFloat scrollViewContentHeight = self.scrollView.contentSize.height;
        CGFloat scrollOffsetThreshold = scrollViewContentHeight-self.scrollView.bounds.size.height;
        
        if(!self.scrollView.isDragging && self.state == SVInfiniteScrollingStateTriggered) {
            self.state = SVInfiniteScrollingStateLoading;
        } else if(contentOffset.y > scrollOffsetThreshold && self.state == SVInfiniteScrollingStateStopped && self.scrollView.isDragging) {
            self.state = SVInfiniteScrollingStateTriggered;
        } else if(contentOffset.y < scrollOffsetThreshold  && self.state != SVInfiniteScrollingStateStopped)
            self.state = SVInfiniteScrollingStateStopped;
    }
}

#pragma mark - Getters
- (void)startAnimating{
    self.state = SVInfiniteScrollingStateLoading;
}

- (void)stopAnimating {
    self.state = SVInfiniteScrollingStateStopped;
}

- (void)setState:(SVInfiniteScrollingState)newState {
    
    if(_state == newState)
        return;
    
    SVInfiniteScrollingState previousState = _state;
    _state = newState;
    
    switch (newState) {
        case SVInfiniteScrollingStateStopped:
            [self stopRotateAnimation];
            self.imageView.hidden = YES;
            [self resetScrollViewContentInset];
            break;
            
        case SVInfiniteScrollingStateTriggered:
            self.imageView.hidden = NO;
            [self startRotateAnimation];
            break;
            
        case SVInfiniteScrollingStateLoading:
            [self startRotateAnimation];
            [self setScrollViewContentInsetForInfiniteScrolling];
            break;
    }
    
    if(previousState == SVInfiniteScrollingStateTriggered && newState == SVInfiniteScrollingStateLoading && self.infiniteScrollingHandler && self.enabled)
        self.infiniteScrollingHandler();
}

- (void)startRotateAnimation {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    [CATransaction setValue:[NSNumber numberWithFloat:0.5] forKey:kCATransactionAnimationDuration];
    
    CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 ];
    rotateAnimation.repeatCount = HUGE_VAL;
    [self.imageView.layer addAnimation:rotateAnimation forKey:@"rotationAnimation"];
    
    [CATransaction commit];
}

- (void)stopRotateAnimation {
    [self.imageView.layer removeAnimationForKey:@"rotationAnimation"];
}

@end

static char UIScrollViewInfiniteScrollingView;

@implementation UIScrollView (SVInfiniteScrolling)

@dynamic infiniteScrollingView;

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler {
    
    if(!self.infiniteScrollingView) {
        SVInfiniteScrollingView *view = [[SVInfiniteScrollingView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, SVInfiniteScrollingViewHeight)];
        view.infiniteScrollingHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalBottomInset = self.contentInset.bottom;
        self.infiniteScrollingView = view;
        self.showsInfiniteScrolling = YES;
    }
}

- (void)triggerInfiniteScrolling {
    self.infiniteScrollingView.state = SVInfiniteScrollingStateTriggered;
    [self.infiniteScrollingView startAnimating];
}

- (void)finishInfiniteScrolling {
    [self.infiniteScrollingView stopAnimating];
}

- (void)setInfiniteScrollingView:(SVInfiniteScrollingView *)infiniteScrollingView {
    [self willChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
    objc_setAssociatedObject(self, &UIScrollViewInfiniteScrollingView,
                             infiniteScrollingView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
}

- (SVInfiniteScrollingView *)infiniteScrollingView {
    return objc_getAssociatedObject(self, &UIScrollViewInfiniteScrollingView);
}

- (void)setShowsInfiniteScrolling:(BOOL)showsInfiniteScrolling {
    self.infiniteScrollingView.hidden = !showsInfiniteScrolling;
    
    if(!showsInfiniteScrolling) {
        if (self.infiniteScrollingView.isObserving) {
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentOffset"];
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentSize"];
            [self.infiniteScrollingView resetScrollViewContentInset];
            self.infiniteScrollingView.isObserving = NO;
        }
    } else {
        if (!self.infiniteScrollingView.isObserving) {
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self.infiniteScrollingView setScrollViewContentInsetForInfiniteScrolling];
            self.infiniteScrollingView.isObserving = YES;
            
            [self.infiniteScrollingView setNeedsLayout];
            self.infiniteScrollingView.frame = CGRectMake(0, self.contentSize.height, self.infiniteScrollingView.bounds.size.width, SVInfiniteScrollingViewHeight);
        }
    }
}

- (BOOL)showsInfiniteScrolling {
    return !self.infiniteScrollingView.hidden;
}

@end

