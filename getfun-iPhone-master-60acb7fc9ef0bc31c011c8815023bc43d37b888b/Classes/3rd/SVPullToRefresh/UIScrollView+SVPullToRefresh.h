//
// UIScrollView+SVPullToRefresh.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

@class SVPullToRefreshView;
@interface UIScrollView (SVPullToRefresh)

@property (nonatomic, strong, readonly) SVPullToRefreshView *pullToRefreshView;
@property (nonatomic, assign) BOOL showsPullToRefresh;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler;

- (void)triggerPullToRefresh;
- (void)finishPullToRefresh;

@end
