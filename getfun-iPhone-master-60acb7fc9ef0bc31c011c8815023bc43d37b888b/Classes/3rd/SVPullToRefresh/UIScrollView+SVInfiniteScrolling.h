//
// UIScrollView+SVInfiniteScrolling.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>

@class SVInfiniteScrollingView;
@interface UIScrollView (SVInfiniteScrolling)

@property (nonatomic, strong, readonly) SVInfiniteScrollingView *infiniteScrollingView;
@property (nonatomic, assign) BOOL showsInfiniteScrolling;

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler;

- (void)triggerInfiniteScrolling;
- (void)finishInfiniteScrolling;

@end
