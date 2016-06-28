//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVPullToRefresh.h"

#import <objc/runtime.h>

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

static CGFloat const SVPullToRefreshViewHeight = 60;

typedef NS_ENUM(NSUInteger, SVPullToRefreshState) {
    SVPullToRefreshStateStopped     = 0,
    SVPullToRefreshStateTriggered   = 1,
    SVPullToRefreshStateLoading     = 2
};

@interface SVPullToRefreshView : UIView

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@property (nonatomic, assign) SVPullToRefreshState state;
@property (nonatomic, readwrite) CGFloat originalTopInset;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property(nonatomic, assign) BOOL isObserving;

- (void)startAnimating;
- (void)stopAnimating;

@end

@implementation SVPullToRefreshView
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 16)];
        _titleLabel.text = @"下拉刷新";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = [UIColor textColorValue4];
        _titleLabel.center = CGPointMake(self.width/2, self.height - 10 - _titleLabel.height/2);
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull_to_refresh_1"]];
        [_imageView sizeToFit];
        _imageView.center = CGPointMake(self.width/2, self.titleLabel.y - 10 - _imageView.height/2);
    }
    
    return _imageView;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SVPullToRefreshStateStopped;
        self.wasTriggeredByUser = YES;
        
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}

#pragma mark - Scroll View
- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height);
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets )edgeInset {
    
//    self.scrollView.contentInset = edgeInset;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentInset = edgeInset;
    }];
}

#pragma mark - Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        
        CGFloat yOrigin;
        yOrigin = -SVPullToRefreshViewHeight;
        self.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
    }
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
    
}

- (void)startAnimating{
    if(fequalzero(self.scrollView.contentOffset.y)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height) animated:YES];
        self.wasTriggeredByUser = NO;
    } else {
        self.wasTriggeredByUser = YES;
    }
    
    self.state = SVPullToRefreshStateLoading;
}

- (void)stopAnimating {
    self.state = SVPullToRefreshStateStopped;
    
    if(!self.wasTriggeredByUser) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
    }
}

- (void)setState:(SVPullToRefreshState)newState {
    
    if(_state == newState) return;
    
    SVPullToRefreshState previousState = _state;
    _state = newState;
    
    switch (newState) {
        case SVPullToRefreshStateStopped:
            [self resetScrollViewContentInset];
            [self stopRotateAnimation];
            self.titleLabel.text = @"下拉刷新";
            break;
            
        case SVPullToRefreshStateTriggered:
            [self startRotateAnimation];
            self.titleLabel.text = @"松开加载";
            break;
            
        case SVPullToRefreshStateLoading:
            [self startRotateAnimation];
            self.titleLabel.text = @"正在加载...";
            [self setScrollViewContentInsetForLoading];
            
            if(previousState == SVPullToRefreshStateTriggered && self.pullToRefreshActionHandler) {
                self.pullToRefreshActionHandler();
            }
            
            break;
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state == SVPullToRefreshStateLoading) {
        CGFloat offsetY;
        offsetY = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offsetY = MIN(offsetY, self.originalTopInset + self.bounds.size.height);
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offsetY, contentInset.left, contentInset.bottom, contentInset.right);
    } else {
        CGFloat scrollOffsetThreshold = 0;
        scrollOffsetThreshold = self.frame.origin.y - self.originalTopInset;
        
        if(!self.scrollView.isDragging && self.state == SVPullToRefreshStateTriggered)
            self.state = SVPullToRefreshStateLoading;
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateTriggered;
        else if(contentOffset.y >= scrollOffsetThreshold && self.state != SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateStopped;
    }
    
    if (self.state == SVPullToRefreshStateStopped) {
        CGFloat offsetY = self.scrollView.contentOffset.y;
        if (offsetY < 0) {
            CGFloat angle = fabs(offsetY) / 120.0f * (-M_PI * 2);
            self.imageView.transform = CGAffineTransformMakeRotation(angle);
        }
    }
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


static char UIScrollViewPullToRefreshView;
@implementation UIScrollView (SVPullToRefresh)

@dynamic pullToRefreshView, showsPullToRefresh;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    
    if(!self.pullToRefreshView) {

        SVPullToRefreshView *view = [[SVPullToRefreshView alloc] initWithFrame:CGRectMake(0, -SVPullToRefreshViewHeight, self.bounds.size.width, SVPullToRefreshViewHeight)];
        view.pullToRefreshActionHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalTopInset = self.contentInset.top;
        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
    }
}

- (void)triggerPullToRefresh {
    self.pullToRefreshView.state = SVPullToRefreshStateTriggered;
    [self.pullToRefreshView startAnimating];
}

- (void)finishPullToRefresh {
    [self.pullToRefreshView stopAnimating];
}

- (void)setPullToRefreshView:(SVPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"SVPullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"SVPullToRefreshView"];
}

- (SVPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
    
    if(showsPullToRefresh) {
        if (!self.pullToRefreshView.isObserving) {
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.pullToRefreshView.isObserving = YES;
            
            CGFloat yOrigin = 0;
            yOrigin = -SVPullToRefreshViewHeight;
            
            self.pullToRefreshView.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
        }
    } else {
        if (self.pullToRefreshView.isObserving) {
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentSize"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
            [self.pullToRefreshView resetScrollViewContentInset];
            self.pullToRefreshView.isObserving = NO;
        }
    }
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}

@end
