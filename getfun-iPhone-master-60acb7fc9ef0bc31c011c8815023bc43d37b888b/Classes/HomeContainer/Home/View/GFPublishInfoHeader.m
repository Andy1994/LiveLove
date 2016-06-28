//
//  GFPublishInfoHeader.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/4.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFPublishInfoHeader.h"

@interface GFPublishInfoHeader ()
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIButton *deleteButton;
@end


@implementation GFPublishInfoHeader

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.width, self.height - 10)];
        _bgView.backgroundColor = [UIColor whiteColor];
        [_bgView gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return _bgView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _icon.image = [UIImage imageNamed:@"icon_tip_publish"];
        [_icon sizeToFit];
        _icon.center = CGPointMake(12+_icon.width/2, self.bgView.height/2);
    }
    return _icon;
}

- (UILabel *)infoLabel {
    if (!_infoLabel ) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.icon.right+12, 0, self.retryButton.x-12 , self.bgView.height)];
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textColor = [UIColor textColorValue1];
        _infoLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _infoLabel;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryButton setImage:[UIImage imageNamed:@"icon_error_red"] forState:UIControlStateNormal];
        [_retryButton setTitle:@"重发" forState:UIControlStateNormal];
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_retryButton setTitleColor:[UIColor themeColorValue7] forState:UIControlStateNormal];
        _retryButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        [_retryButton sizeToFit];
        _retryButton.center = CGPointMake(self.deleteButton.x - _retryButton.width/2, self.bgView.height/2);
    }
    return _retryButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"icon_cancel_publish"] forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(self.bgView.width-self.bgView.height, 0, self.bgView.height, self.bgView.height);
    }
    return _deleteButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor themeColorValue13];
        [self addSubview:self.bgView];
        
        __weak typeof(self) weakSelf = self;
        [self.bgView addSubview:self.icon];
        [self.bgView addSubview:self.infoLabel];
        [self.bgView addSubview:self.retryButton];
        [self.retryButton bk_addEventHandler:^(id sender) {
            if (weakSelf.retryHandler) {
                weakSelf.retryHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self.bgView addSubview:self.deleteButton];
        [self.deleteButton bk_addEventHandler:^(id sender) {
            if (weakSelf.deleteHandler) {
                weakSelf.deleteHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)setInfoText:(NSString *)text {
    self.infoLabel.text = text;
}

- (void)showRetryAndDeleteButton:(BOOL)show {
    self.retryButton.hidden = !show;
    self.deleteButton.hidden = !show;
}

@end
