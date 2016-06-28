//
//  GFStartupAdViewController.m
//  GetFun
//
//  Created by zhouxz on 16/1/15.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFStartupAdViewController.h"
#import "GFAdvertiseMTL.h"
#import "GFNetworkManager+Common.h"
#import "AppDelegate.h"
#import "GFLocationManager.h"

@interface GFStartupAdViewController ()

@property (nonatomic, strong) UIImageView *adImageView;
@property (nonatomic, strong) GFAdImageMTL *adImage;

@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) NSTimer *hideTimer;

@end

@implementation GFStartupAdViewController
- (UIImageView *)adImageView {
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        NSString *imageName = [NSString stringWithFormat:@"Default%ldh", (long)SCREEN_HEIGHT];
        _adImageView.image = [UIImage imageNamed:imageName];
        _adImageView.contentMode = UIViewContentModeScaleAspectFill;
        _adImageView.userInteractionEnabled = YES;
        
        __weak typeof(self) weakSelf = self;
        [_adImageView bk_whenTapped:^{
            [MobClick event:@"gf_sp_01_01_01_1"];
            [weakSelf userTappedAction];
        }];
    }
    return _adImageView;
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_skipButton setImage:[UIImage imageNamed:@"skip_normal"] forState:UIControlStateNormal];
        [_skipButton sizeToFit];
        _skipButton.center = CGPointMake(self.view.width-10-_skipButton.width/2, 20+_skipButton.height/2);
    }
    return _skipButton;
}

- (instancetype)init {
    if (self = [super init]) {
        [self queryAdImage];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.adImageView];
    [self.view addSubview:self.skipButton];
    
    __weak typeof(self) weakSelf = self;
    [self.skipButton bk_addEventHandler:^(id sender) {
        [MobClick event:@"gf_sp_01_02_01_1"];
        if (weakSelf.hideTimer) {
            [weakSelf.hideTimer invalidate];
            weakSelf.hideTimer = nil;
        }
        [weakSelf hide];
    } forControlEvents:UIControlEventTouchUpInside];
    //开启定位服务，和第一次启动时首页动画选兴趣互斥
    [GFLocationManager initManager];
    
    self.gf_StatusBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:weakSelf selector:@selector(hide) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.hideTimer forMode:NSRunLoopCommonModes];
}

- (void)queryAdImage {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getStartupImageSuccess:^(NSUInteger taskId, NSInteger code, GFAdImageMTL *image, NSString *versionInAppStore) {
        
        if (image) {
            weakSelf.adImage = image;
#warning 图片剪裁标准未确定
            [weakSelf.adImageView setImageURL:[NSURL URLWithString:[image.imageUrl gf_urlAppendWithHorizontalEdge:SCREEN_WIDTH verticalEdge:SCREEN_HEIGHT mode:GFImageProcessModeMaxWidthAdaptiveHeightAspect]]];
        } else {
            [weakSelf hide];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [weakSelf hide];
    }];
}

- (void)userTappedAction {
    
    if (self.adImage) {
        
        [self hide];        
        [[AppDelegate appDelegate] performSelector:@selector(handleGetfunLinkUrl:) withObject:self.adImage.linkUrl afterDelay:1.0f];
    }
}

- (void)hide{
    [[AppDelegate appDelegate] switchToNextViewController:self];
}

@end
