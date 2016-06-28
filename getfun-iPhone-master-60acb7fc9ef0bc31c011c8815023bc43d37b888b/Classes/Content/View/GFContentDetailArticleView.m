//
//  GFContentDetailArticleView.m
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailArticleView.h"
@implementation GFContentDetailArticleView
- (GFWebView *)articleWebView {
    if (!_articleWebView) {
//        _articleWebView = [GFWebView shareWithFrame:self.bounds];
        _articleWebView =   [[GFWebView alloc] initWithFrame:self.bounds];
        _articleWebView.autoresizesSubviews = YES;
        _articleWebView.scrollView.bounces = NO;
        _articleWebView.scrollView.showsVerticalScrollIndicator = NO;
    }
    return _articleWebView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.articleWebView];
    }
    return self;
}

- (void)dealloc {
    [_articleWebView removeFromSuperview];
    _articleWebView = nil;
}

@end

