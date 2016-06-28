//
//  GFCroppingPhotoViewController.m
//  GetFun
//
//  Created by liupeng on 16/3/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFCroppingPhotoViewController.h"

@interface GFCroppingPhotoViewController ()

@property (nonatomic, strong, readwrite) UIButton *okButton;
@property (nonatomic, strong, readwrite) UIButton *backButton;

@end

@implementation GFCroppingPhotoViewController

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"nav_back_light"] forState:UIControlStateNormal];
        [_backButton sizeToFit];
        [_backButton addTarget:self action:@selector(onCancelButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.opaque = NO;
    }
    return _backButton;
}

- (UIButton *)okButton {
    if (!_okButton) {
        _okButton = [[UIButton alloc] init];
        [_okButton setTitle:@"完成" forState:UIControlStateNormal];
        [_okButton addTarget:self action:@selector(onChooseButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        [_okButton sizeToFit];
        _okButton.opaque = NO;
    }
    return _okButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //隐藏原有三个按钮
    self.moveAndScaleLabel.hidden = YES;
    self.cancelButton.hidden = YES;
    self.chooseButton.hidden = YES;
    
    //自定义新的两个按钮
    self.backButton.origin = CGPointMake(15, 20);
    self.okButton.frame = CGRectMake(SCREEN_WIDTH - 15 - 44, 20, 44, 44);
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.okButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onCancelButtonTouch:(UIBarButtonItem *)sender
{
    [self cancelCrop];
}

- (void)onChooseButtonTouch:(UIBarButtonItem *)sender
{
    [self cropImage];
}

@end
