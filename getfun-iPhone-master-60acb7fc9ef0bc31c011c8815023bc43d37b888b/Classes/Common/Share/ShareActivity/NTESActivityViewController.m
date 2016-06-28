//
//  NTESActivityViewController.m
//  JiaoYou
//
//  Created by muhuaxin on 15-2-10.
//  Copyright (c) 2015年 NetEase.com, Inc. All rights reserved.
//

#import "NTESActivityViewController.h"

#import "NTESActivity.h"
#import "NTESWeixinSessionShareActivity.h"
#import "NTESWeixinTimelineShareActivity.h"
#import "NTESSinaWeiboShareActivity.h"
#import "NTESQQSessionShareActivity.h"
#import "NTESQzoneShareActivity.h"

#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface NTESActivityViewController ()

@property (nonatomic, copy) NSDictionary *activityItem;

@property (nonatomic, assign) NSInteger shareActivityCount;
@property (nonatomic, assign) NSInteger actionActivityCount;

@property (nonatomic, assign) NSInteger contentViewHeight;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *shareLabel;
@property (nonatomic, strong) UIScrollView *shareScrollView;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UIScrollView *actionScrollView;

@end

static const NSInteger kDefaultContentViewHeight = 339;
static const NSInteger kCancelButtonHeight = 53;
static const NSInteger kIconWidth = 60;
static const NSInteger kMargin = 15;

@implementation NTESActivityViewController
- (instancetype)initWithActivityItem:(NSDictionary *)activityItem applicationActivities:(NSArray *)applicationActivities {
    self = [super init];
    if (self) {
        [self commonInit];
        self.activityItem = activityItem;
        self.applicationActivities = applicationActivities;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self register3rdShare];
}

- (void)prepare {
    [self initData];
    [self initSubviews];
    [self buildScrollView];
}

- (void)register3rdShare {
    [WXApi registerApp:kWXAppId];
    [WeiboSDK registerApp:kWeiboAppKey];
    __unused TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:kTencentAppId andDelegate:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:.3 animations:^{
        self.backgroundView.alpha = 0.3;
        self.contentView.frame = CGRectMake(0, self.view.bounds.size.height - self.contentViewHeight, self.view.bounds.size.width, self.contentViewHeight);
    }];
}

#pragma mark - Getters
- (UIView *)backgroundView {
    if (nil == _backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0;
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
        [_backgroundView addGestureRecognizer:tapGR];
    }
    return _backgroundView;
}

- (UIView *)contentView {
    if (nil == _contentView) {
        _contentView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.contentViewHeight)];
    }
    return _contentView;
}

- (UIButton *)cancelButton {
    if (nil == _cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.frame = CGRectMake(0, self.contentView.bounds.size.height - kCancelButtonHeight, self.contentView.bounds.size.width, kCancelButtonHeight);
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithRed:26.0/255.0 green:26.0/255.0 blue:26.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithRed:26.0/255.0 green:26.0/255.0 blue:26.0/255.0 alpha:0.4] forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)shareLabel {
    if (nil == _shareLabel) {
        _shareLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shareLabel.text = @"分享到:";
        _shareLabel.backgroundColor = [UIColor clearColor];
        _shareLabel.textColor = [UIColor colorWithRed:14.0/255.0 green:14.0/255.0 blue:14.0/255.0 alpha:1.0];
        _shareLabel.font = [UIFont systemFontOfSize:16];
        [_shareLabel sizeToFit];
        _shareLabel.frame = CGRectMake(17, 18, _shareLabel.frame.size.width, _shareLabel.frame.size.height);
    }
    return _shareLabel;
}

- (UIScrollView *)shareScrollView {
    if (nil == _shareScrollView) {
        _shareScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareLabel.frame), CGRectGetWidth(self.contentView.frame), 114)];
        _shareScrollView.backgroundColor = [UIColor clearColor];
        _shareScrollView.showsHorizontalScrollIndicator = NO;
        _shareScrollView.contentSize = CGSizeMake(self.shareActivityCount * (kMargin + kIconWidth) + kMargin, CGRectGetHeight(_shareScrollView.frame));
        _shareScrollView.alwaysBounceHorizontal = YES;
    }
    return _shareScrollView;
}

- (UIView *)seperatorLine {
    if (nil == _seperatorLine) {
        _seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(kMargin, CGRectGetMaxY(self.shareScrollView.frame), CGRectGetWidth(self.contentView.frame) - 2 * kMargin, .3)];
        _seperatorLine.backgroundColor = [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
    }
    return _seperatorLine;
}

- (UIScrollView *)actionScrollView {
    if (nil == _actionScrollView) {
        _actionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.seperatorLine.frame), CGRectGetWidth(self.contentView.frame), 114)];
        _actionScrollView.backgroundColor = [UIColor clearColor];
        _actionScrollView.showsHorizontalScrollIndicator = NO;
        _actionScrollView.contentSize = CGSizeMake(self.actionActivityCount * (kMargin + kIconWidth) + kMargin, CGRectGetHeight(_actionScrollView.frame));
        _actionScrollView.alwaysBounceHorizontal = YES;
    }
    return _actionScrollView;
}

#pragma mark - Private methods
- (void)initData {
    self.shareActivityCount = self.actionActivityCount = 0;
    
    for (NSInteger i = 0; i < self.applicationActivities.count; i++) {
        if ([self.applicationActivities[i] isKindOfClass:[NTESActivity class]]) {
            NTESActivity *activity = self.applicationActivities[i];
            if (![activity canPerformWithActivityItem:self.activityItem]) {
                continue;
            }
            if ([activity activityCategory] == NTESActivityCategoryShare) {
                self.shareActivityCount++;
            } else if ([activity activityCategory] == NTESActivityCategoryAction) {
                self.actionActivityCount++;
            }
        }
    }
    
    self.contentViewHeight = kDefaultContentViewHeight;
    if (self.shareActivityCount == 0) {
        self.contentViewHeight -= 138;
    }
    
    if (self.actionActivityCount == 0) {
        self.contentViewHeight -= 108;
    }
}

- (void)initSubviews {
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.shareLabel];
    [self.contentView addSubview:self.shareScrollView];
    [self.contentView addSubview:self.seperatorLine];
    [self.contentView addSubview:self.actionScrollView];
    [self.contentView addSubview:self.cancelButton];
    
    if (self.shareActivityCount == 0) {
        self.shareLabel.hidden = self.shareScrollView.hidden = self.seperatorLine.hidden = YES;
        self.actionScrollView.frame = ({
            CGRect frame = self.actionScrollView.frame;
            frame.origin.y = 0;
            frame;
        });
    }
    if (self.actionActivityCount == 0) {
        self.seperatorLine.hidden = self.actionScrollView.hidden = YES;
    }
}

- (void)buildScrollView {
    [self.shareScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.actionScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIButton *lastShareIcon = nil;
    UIButton *lastActionIcon = nil;
    
    for (NSInteger i = 0; i < self.applicationActivities.count; i++) {
        if ([self.applicationActivities[i] isKindOfClass:[NTESActivity class]]) {
            NTESActivity *activity = self.applicationActivities[i];
            if (![activity canPerformWithActivityItem:self.activityItem]) {
                continue;
            }
            [activity _setActivityViewController:self];
            
            if ([activity activityCategory] == NTESActivityCategoryShare) {
                UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [shareButton setImage:[activity activityImage] forState:UIControlStateNormal];
                shareButton.frame = CGRectMake(CGRectGetMaxX(lastShareIcon.frame) + kMargin, 20, kIconWidth, kIconWidth);
                shareButton.backgroundColor = [UIColor clearColor];
                shareButton.tag = i;
                [shareButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

                lastShareIcon = shareButton;
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(shareButton.frame.origin.x, CGRectGetMaxY(shareButton.frame)+9, CGRectGetWidth(shareButton.frame), 13)];
                label.text = [activity activityTitle];
                label.textColor = [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0];
                label.font = [UIFont systemFontOfSize:11];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor clearColor];
                
                [self.shareScrollView addSubview:shareButton];
                [self.shareScrollView addSubview:label];
                
                
            } else if ([activity activityCategory] == NTESActivityCategoryAction) {
                UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [actionButton setImage:[activity activityImage] forState:UIControlStateNormal];
                actionButton.frame = CGRectMake(CGRectGetMaxX(lastActionIcon.frame) + kMargin, 20, kIconWidth, kIconWidth);
                actionButton.backgroundColor = [UIColor clearColor];
                actionButton.tag = i;
                [actionButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

                lastActionIcon = actionButton;
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(actionButton.frame.origin.x, CGRectGetMaxY(actionButton.frame)+9, CGRectGetWidth(actionButton.frame), 13)];
                label.text = [activity activityTitle];
                label.textColor = [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0];
                label.font = [UIFont systemFontOfSize:11];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor clearColor];
                
                [self.actionScrollView addSubview:actionButton];
                [self.actionScrollView addSubview:label];
            }
        }
    }
}

- (void)cancelAction {
    //避免该Controller还没有显示出来就被取消操作，导致contentViewHeight为0，从而使懒加载的contentView高度一直为0，取消按钮坐标计算错误显示到最上方
    if (!self.parentViewController) {
        return;
    }
    
    
    [UIView animateWithDuration:.3 animations:^{
        self.backgroundView.alpha = 0;
        self.contentView.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.contentViewHeight);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (self.completionHandler) {
            self.completionHandler(nil, NO);
        }
    }];
}

- (void)buttonAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NTESActivity *activity = self.applicationActivities[tag];
    
    [activity prepareWithActivityItem:self.activityItem];
    [activity performActivity];
    [activity activityDidFinish:YES];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if (self.completionHandler) {
        self.completionHandler(activity.activityType, YES);
    }
}

#pragma mark - Public Methods

- (void)setApplicationActivities:(NSArray *)applicationActivities {
    _applicationActivities = [applicationActivities copy];
    [self prepare];
}

- (void)showIn:(UIViewController *)viewContrller {
    if ([viewContrller.childViewControllers containsObject:self]) {
        return;
    }
    
    [self willMoveToParentViewController:viewContrller];
    [viewContrller addChildViewController:self];
    [self didMoveToParentViewController:viewContrller];
    
    [viewContrller.view addSubview:self.view];
}

+ (NSArray *)getDefaultShareActivitiesWithURL:(NSString *)url
                                        image:(UIImage *)image
                                   thumbImage:(UIImage *)thumbImage
                                        title:(NSString *)title
                                  description:(NSString *)description {
    NTESWeixinSessionShareActivity *weixinSession = [[NTESWeixinSessionShareActivity alloc] initWithURL:url image:image thumbImage:thumbImage title:title description:description];
    NTESWeixinTimelineShareActivity *weixinTimeline = [[NTESWeixinTimelineShareActivity alloc] initWithURL:url image:image thumbImage:thumbImage title:title description:description];
    NTESSinaWeiboShareActivity *sinaWeibo = [[NTESSinaWeiboShareActivity alloc] initWithURL:url image:image thumbImage:thumbImage title:title description:description];
    NTESQQSessionShareActivity *qqSession = [[NTESQQSessionShareActivity alloc] initWithURL:url image:image thumbImage:thumbImage title:title description:description];
    NTESQzoneShareActivity *qzone = [[NTESQzoneShareActivity alloc] initWithURL:url image:image thumbImage:thumbImage title:title description:description];
    
    return @[weixinSession, weixinTimeline, sinaWeibo, qqSession, qzone];
    
}

@end
