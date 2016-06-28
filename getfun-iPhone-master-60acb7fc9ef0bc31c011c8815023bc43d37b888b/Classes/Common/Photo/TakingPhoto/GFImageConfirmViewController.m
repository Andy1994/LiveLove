//
//  GFImageConfirmViewController.m
//  GetFun
//
//  Created by Meng on 16/1/21.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFImageConfirmViewController.h"
#import "GFTakingPhotoViewController.h"

@interface GFImageConfirmViewController ()

@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) UIView *bottomBarView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIImage *photoImage;

@end

@implementation GFImageConfirmViewController


- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _topBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:self.view.height == 480 ? 0.3 : 1.0];
    }
    return _topBarView;
}

- (UIView *)bottomBarView {
    if (!_bottomBarView) {
        CGFloat height = self.view.height - ceilf(self.view.width / 3 * 4) - self.topBarView.height;
        if (self.view.height == 480) {
            height = 200;
        }
        _bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - height, self.view.width, height)];
        _bottomBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:self.view.height == 480 ? 0.3 : 1.0];
    }
    return _bottomBarView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"重拍" forState:UIControlStateNormal];
        [_cancelButton setFrame:CGRectMake(0, 0, 80, 44)];
        [_cancelButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setImage:[UIImage imageNamed:@"camera_confirm_photo"] forState:UIControlStateNormal];
        [_confirmButton sizeToFit];
        _confirmButton.center = CGPointMake(self.bottomBarView.centerX, self.bottomBarView.height / 2);
        [_confirmButton addTarget:self action:@selector(confirmButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.height == 480 ? 0 : 44, self.view.width, self.view.height == 480 ? self.view.height : ceilf(self.view.width / 3 * 4))];
    }
    return _photoImageView;
}

#pragma mark - Life Cycle

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.photoImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.photoImageView];
    [self.photoImageView setImage:self.photoImage];
    
    [self.topBarView addSubview:self.cancelButton];
    [self.bottomBarView addSubview:self.confirmButton];
    
    [self.view addSubview:self.topBarView];
    [self.view addSubview:self.bottomBarView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - Button Action

- (void)cancelButtonTouched {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmButtonTouched {
    
    if ([self.navigationController isKindOfClass:[GFTakingPhotoViewController class]]) {
        GFTakingPhotoViewController *nav = (GFTakingPhotoViewController *)self.navigationController;
        if (nav.gf_didFinishTakingPhotoBlock) {
            nav.gf_didFinishTakingPhotoBlock(nav, self.photoImage);
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:NO];
        if (nav.presentingViewController) {
            [nav.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

@end
