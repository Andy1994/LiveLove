//
//  GFContentDetailLinkView.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/12.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFContentDetailLinkView.h"
@implementation GFContentDetailLinkView
- (GFWebView *)linkWebView {
    if (_linkWebView == nil) {
        _linkWebView = [[GFWebView alloc] initWithFrame:self.bounds];
        _linkWebView.autoresizesSubviews = NO;
        _linkWebView.backgroundColor = [UIColor whiteColor];
        _linkWebView.scrollView.bounces = NO;
        _linkWebView.scrollView.showsVerticalScrollIndicator = NO;
    }
    return _linkWebView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.linkWebView];
    }
    return self;
}

- (void)dealloc {
    [_linkWebView removeFromSuperview];
    _linkWebView = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.linkWebView.frame = self.bounds;
}

@end
