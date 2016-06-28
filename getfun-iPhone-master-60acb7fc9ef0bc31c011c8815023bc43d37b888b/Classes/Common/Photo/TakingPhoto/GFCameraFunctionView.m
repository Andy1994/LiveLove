//
//  GFCameraFunctionView.m
//  GetFun
//
//  Created by Meng on 16/1/21.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFCameraFunctionView.h"

@interface GFCameraFunctionView ()

@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) UIView *bottomBarView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *switchButton;

@end

@implementation GFCameraFunctionView

- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
        _topBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:self.height == 480 ? 0.3 : 1.0];
    }
    return _topBarView;
}

- (UIView *)bottomBarView {
    if (!_bottomBarView) {
        CGFloat height = self.height - ceilf(self.width / 3 * 4) - self.topBarView.height;
        if (self.height == 480) {
            height = 200;
        }
        _bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - height, self.width, height)];
        _bottomBarView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:self.height == 480 ? 0.3 : 1.0];
    }
    return _bottomBarView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setFrame:CGRectMake(0, 0, 80, 44)];
        [_cancelButton addTarget:self.delegate action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)flashlightButton {
    if (!_flashlightButton) {
        _flashlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashlightButton setImage:[UIImage imageNamed:@"camera_flashlight_off"] forState:UIControlStateNormal];
        [_flashlightButton sizeToFit];
        _flashlightButton.center = self.topBarView.center;
        [_flashlightButton addTarget:self.delegate action:@selector(flashlightButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightButton;
}

- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
        [_switchButton sizeToFit];
        _switchButton.center = CGPointMake(self.width - self.cancelButton.centerX, self.cancelButton.centerY);
        [_switchButton addTarget:self.delegate action:@selector(switchButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoButton setImage:[UIImage imageNamed:@"camera_take_photo"] forState:UIControlStateNormal];
        [_photoButton sizeToFit];
        _photoButton.center = CGPointMake(self.bottomBarView.centerX, self.bottomBarView.height / 2);
    }
    return _photoButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0f];
        
        [self.topBarView addSubview:self.cancelButton];
        [self.topBarView addSubview:self.flashlightButton];
        [self.topBarView addSubview:self.switchButton];
        
        [self.bottomBarView addSubview:self.photoButton];
        
        [self addSubview:self.topBarView];
        [self addSubview:self.bottomBarView];
    }
    return self;
}

- (void)flashLightModeSwitched:(BOOL)flashModeOn {
    if (flashModeOn) {
        [self.flashlightButton setImage:[UIImage imageNamed:@"camera_flashlight_on"] forState:UIControlStateNormal];
    } else {
        [self.flashlightButton setImage:[UIImage imageNamed:@"camera_flashlight_off"] forState:UIControlStateNormal];
    }
}


@end
