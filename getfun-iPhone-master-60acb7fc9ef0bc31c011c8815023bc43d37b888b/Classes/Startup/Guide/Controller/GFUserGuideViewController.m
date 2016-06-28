//
//  GFUserGuideViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFUserGuideViewController.h"
#import "UIColor+Getfun.h"
#import "GFUserGuideFirstView.h"
#import "AppDelegate.h"

@interface GFUserGuideViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GFUserGuideFirstView *firstView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) UIImageView *lastImageView;

@property (nonatomic, strong) UIButton *enterButton;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation GFUserGuideViewController

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT);
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIImageView *)secondImageView {
    if (!_secondImageView) {
        _secondImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _secondImageView.x = self.scrollView.width * 1;
        _secondImageView.clipsToBounds = YES;
        _secondImageView.contentMode = UIViewContentModeScaleAspectFill;
        _secondImageView.image = [UIImage imageNamed:@"userguide_second"];
     }
    return _secondImageView;
}

- (UIImageView *)lastImageView {
    if (!_lastImageView) {
        _lastImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _lastImageView.x = self.scrollView.width * 2;
        _lastImageView.clipsToBounds = YES;
        _lastImageView.contentMode = UIViewContentModeScaleAspectFill;
        _lastImageView.image = [UIImage imageNamed:@"userguide_last"];
    }
    return _lastImageView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-59, SCREEN_WIDTH, 9)];
        _pageControl.currentPageIndicatorTintColor = [UIColor themeColorValue7];
        _pageControl.numberOfPages=3;
        _pageControl.pageIndicatorTintColor = [UIColor themeColorValue12];
    }
    return _pageControl;
}

- (UIButton *)enterButton {
    if (!_enterButton) {
        _enterButton = [UIButton gf_purpleButtonWithTitle:@"马上体验"];
        _enterButton.frame = CGRectMake(0, 0, 144, 38);
        _enterButton.center = CGPointMake(self.view.width/2, self.pageControl.origin.y - 20.0f - _enterButton.height / 2);
    }
    _enterButton.alpha = 0.0f;
    return _enterButton;
}

- (instancetype)init {
    if (self = [super init]) {
        self.firstView = [[GFUserGuideFirstView alloc] initWithFrame:CGRectMake(0, 54, SCREEN_WIDTH, SCREEN_WIDTH)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor gf_colorWithHex:@"f9f9f9"];
    [self.view addSubview: self.scrollView];
    [self.view addSubview: self.pageControl];
    [self.view addSubview:self.enterButton];
    
    __weak typeof(self) weakSelf = self;
    [self.enterButton bk_addEventHandler:^(id sender) {
        [MobClick event:@"gf_yd_01_01_01_1"];
        [GFUserDefaultsUtil setObject:APP_VERSION forKey:GFUserDefaultsKeyLastLaunchVersionForUserGuide];
        [GFUserDefaultsUtil setObject:APP_BUILD forKey:GFUserDefaultsKeyLastLaunchBuildForUserGuide];
        [[AppDelegate appDelegate] switchToNextViewController:weakSelf];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self hideFooterImageView:YES];

    [self.scrollView addSubview:self.firstView];
    [self.scrollView addSubview:self.secondImageView];
    [self.scrollView addSubview:self.lastImageView];
    
//    [UIApplication sharedApplication].statusBarHidden = YES;
    self.gf_StatusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.firstView playVideo];
}

- (void)dealloc {
    [_firstView removeFromSuperview];
    _firstView = nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = self.scrollView.contentOffset.x / self.scrollView.width;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat alpha = 0.0f;
    if (offsetX > scrollView.width + scrollView.width/3) {
        alpha = (offsetX - scrollView.width - scrollView.width/3) / (scrollView.width/3 * 2);
    }
    self.enterButton.alpha = alpha;
}

@end
