//
//  GFBaseViewController.m
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"

@interface GFBaseViewController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *footerImageView; //底部插图

@end

@implementation GFBaseViewController

- (UIImageView *)footerImageView {
    if (!_footerImageView) {
        _footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_footer"]];
        [_footerImageView sizeToFit];
        _footerImageView.centerX = self.view.width/2;
        _footerImageView.centerY = self.view.height - _footerImageView.height / 2;
    }
    return _footerImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor themeColorValue13];
    [self.view addSubview:self.footerImageView];
    
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackDark;
    
    self.gf_StatusBarHidden = NO;
    self.gf_StatusBarStyle = UIStatusBarStyleDefault;
    
    [self gf_setNavBarBackgroundTransparent:1.0f];
}

- (void)setGf_StatusBarStyle:(UIStatusBarStyle)gf_StatusBarStyle {
    _gf_StatusBarStyle = gf_StatusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:_gf_StatusBarStyle];
}

- (void)setGf_StatusBarHidden:(BOOL)gf_StatusBarHidden {
    _gf_StatusBarHidden = gf_StatusBarHidden;
    [UIApplication sharedApplication].statusBarHidden = _gf_StatusBarHidden;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = _gf_StatusBarHidden;
    [[UIApplication sharedApplication] setStatusBarStyle:_gf_StatusBarStyle];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = NO;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    
//}

- (void)setBackBarButtonItemStyle:(GFBackBarButtonItemStyle)backBarButtonItemStyle {
    
    UIImage *normalImage = nil;

    switch (backBarButtonItemStyle) {
        case GFBackBarButtonItemStyleNone:
            break;
        case GFBackBarButtonItemStyleBackDark:
            normalImage = [UIImage imageNamed:@"nav_back_dark"];
            break;
        case GFBackBarButtonItemStyleBackLight:
            normalImage = [UIImage imageNamed:@"nav_back_light"];
            break;
        case GFBackBarButtonItemStyleCloseDark:
            normalImage = [UIImage imageNamed:@"nav_close_dark"];
            break;
        case GFBackBarButtonItemStyleCloseLight:
            normalImage = [UIImage imageNamed:@"nav_close_light"];
            break;
        
        default:
            break;
    }
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem gf_barButtonItemWithImage:normalImage target:self selector:@selector(backBarButtonItemSelected)];
}

- (void)hideFooterImageView:(BOOL)hide {
    self.footerImageView.hidden = hide;
}

- (void)backBarButtonItemSelected {
    if ([self.navigationController.viewControllers count] > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)gf_setNavBarBackgroundTransparent:(CGFloat)alpha {
    self.jz_navigationBarBackgroundAlpha = alpha;
}

- (void)gf_setNavBarShrink:(BOOL)shrink {
    
    if (shrink) {
        
        // 隐藏左侧
        UIView *left = self.navigationItem.leftBarButtonItem.customView;
        left.hidden = YES;
        
        // 隐藏右侧
        for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
            UIView *right = item.customView;
            right.hidden = YES;
        }
        
        [self.navigationController setJz_navigationBarSize:CGSizeMake(0, 0.5)];
    } else {
        
        // 隐藏左侧
        UIView *left = self.navigationItem.leftBarButtonItem.customView;
        left.hidden = NO;
        
        // 隐藏右侧
        for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
            UIView *right = item.customView;
            right.hidden = NO;
        }
        
        [self.navigationController setJz_navigationBarSize:CGSizeMake(0, 43.5)];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewDidAppear:animated];
}

@end
