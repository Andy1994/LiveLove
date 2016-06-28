//
//  GFContentTipView.m
//  GetFun
//
//  Created by Liu Peng on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFContentTipView.h"

@interface GFContentTipView ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIButton *retryButton;

@end


static const CGFloat kContentTipViewHeight = 210.0f;
static const CGFloat kContentTipViewImageHeight = 120.0f;

@implementation GFContentTipView

+(instancetype)contentTipViewForType:(GFContentTipType)tipType {
    GFContentTipView *tipView = [[GFContentTipView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kContentTipViewHeight)];
    [tipView setContentTipType:tipType];
    return tipView;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.frame = CGRectMake(self.width/2 - 60/2, self.imageView.bottom + 10, 60, 60);
        [_retryButton setBackgroundImage:[UIImage imageNamed:@"content_reload"] forState:UIControlStateNormal];
    }
    return _retryButton;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.bottom, self.width, kContentTipViewHeight - kContentTipViewImageHeight)];
        _label.textColor = [UIColor textColorValue5];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.width, kContentTipViewImageHeight)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void)setContentTipType:(GFContentTipType)type {
    self.retryButton.hidden = (type!=GFContentTipTypeNetworkError);
    self.label.hidden = (type!=GFContentTipTypeNoContent);
    
    switch (type) {
        case GFContentTipTypeNoContent: {
            [self setTipImage:[UIImage imageNamed:@"placeholder_no_msg"]];
            break;
        }
        case GFContentTipTypeNetworkError: {
            [self setTipImage:[UIImage imageNamed:@"placeholder_content_network_retry"]];
            break;
        }
    }
    
    [self setNeedsLayout];
}

- (void)setTipText:(NSString *)text {
    self.label.text = text;
    [self setNeedsLayout];
}

- (void)setTipImage:(UIImage *)image {
    self.imageView.image = image;
    [self setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.retryButton];
        [self addSubview:self.label];
        
        
        __weak typeof(self) weakSelf = self;
        [weakSelf.retryButton bk_addEventHandler:^(id sender) {
            if (weakSelf.retryHandler) {
                weakSelf.retryHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

@end
