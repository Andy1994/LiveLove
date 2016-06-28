//
//  GFContentDetailShareView.m
//  GetFun
//
//  Created by muhuaxin on 15/11/22.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailShareView.h"
#import "WXApi.h"

static NSInteger const kButtonWidth = 28.0f;
static CGFloat const kCellHeight = 50.0f;
static CGFloat const kPadding = 15.0f; //上下边缘空白

@interface GFContentDetailShareView()

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIButton *timeLineButton;
@property (nonatomic, strong) UIButton *wechatButton;
@property (nonatomic, strong) UIButton *qzoneButton;
@property (nonatomic, strong) UIButton *qqButton;
@property (nonatomic, strong) UIButton *weiboButton;

@end

@implementation GFContentDetailShareView
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:13.0f];
        _textLabel.textColor = [UIColor textColorValue4];
        _textLabel.text = @"分享到：";
        [_textLabel sizeToFit];
    }
    return _textLabel;
}

- (UIButton *)timeLineButton {
    if (_timeLineButton == nil) {
        _timeLineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeLineButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
        _timeLineButton.layer.cornerRadius = kButtonWidth / 2.;
        _timeLineButton.clipsToBounds = YES;
        UIImage *img = [UIImage imageNamed:@"icon_wechat_timeline"];
        [_timeLineButton setImage:img forState:UIControlStateNormal];
        [_timeLineButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _timeLineButton;
}

- (UIButton *)wechatButton {
    if (_wechatButton == nil) {
        _wechatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _wechatButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
        _wechatButton.layer.cornerRadius = kButtonWidth / 2.;
        _wechatButton.clipsToBounds = YES;
        UIImage *img = [UIImage imageNamed:@"icon_wechat"];
        [_wechatButton setImage:img forState:UIControlStateNormal];
        [_wechatButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _wechatButton;
}

- (UIButton *)qzoneButton {
    if (_qzoneButton == nil) {
        _qzoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _qzoneButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
        _qzoneButton.layer.cornerRadius = kButtonWidth / 2.;
        _qzoneButton.clipsToBounds = YES;
        UIImage *img = [UIImage imageNamed:@"icon_qzone"];
        [_qzoneButton setImage:img forState:UIControlStateNormal];
        [_qzoneButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _qzoneButton;
}

- (UIButton *)qqButton {
    if (_qqButton == nil) {
        _qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _qqButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
        _qqButton.layer.cornerRadius = kButtonWidth / 2.;
        _qqButton.clipsToBounds = YES;
        UIImage *img = [UIImage imageNamed:@"icon_qq"];
        [_qqButton setImage:img forState:UIControlStateNormal];
        [_qqButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _qqButton;
}

- (UIButton *)weiboButton {
    if (_weiboButton == nil) {
        _weiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _weiboButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
        _weiboButton.layer.cornerRadius = kButtonWidth / 2.;
        _weiboButton.clipsToBounds = YES;
        UIImage *img = [UIImage imageNamed:@"icon_sina"];
        [_weiboButton setImage:img forState:UIControlStateNormal];
        [_weiboButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _weiboButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.textLabel];
        
        [self.contentView addSubview:self.timeLineButton];
        [self.timeLineButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.wechatButton];
        [self.wechatButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.qzoneButton];
        [self.qzoneButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.qqButton];
        [self.qqButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.weiboButton];
        [self.weiboButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [WXApi registerApp:kWXAppId];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return kCellHeight + kPadding * 2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.center = CGPointMake(15 + self.textLabel.width/2, self.contentView.height/2);
    NSArray *buttons = nil;
    self.timeLineButton.hidden = self.wechatButton.hidden = ![WXApi isWXAppInstalled];
    if ([WXApi isWXAppInstalled]) {
        buttons = @[self.timeLineButton, self.wechatButton, self.qzoneButton, self.qqButton, self.weiboButton];
    } else {
        buttons = @[self.qzoneButton, self.qqButton, self.weiboButton];
    }
    
    CGFloat buttonSpace = 20.0f;
    for (UIButton *button in buttons) {
        NSInteger index = [buttons indexOfObject:button];
        
        button.center = CGPointMake(self.textLabel.width + buttonSpace + index * (kButtonWidth + buttonSpace) + kButtonWidth/2,
                                    self.contentView.height/2);
    }
}

#pragma mark - Private methods
- (void)buttonAction:(UIButton *)button {
    GFShareType type = 0;
    
    if (button == self.timeLineButton) {
        type = GFShareTypeTimeline;
    } else if (button == self.wechatButton) {
        type = GFShareTypeWeChat;
    } else if (button == self.qzoneButton) {
        type = GFShareTypeQZone;
    } else if (button == self.qqButton) {
        type = GFShareTypeQQ;
    } else if (button == self.weiboButton) {
        type = GFShareTypeWeibo;
    }
    
    if (type != 0 && self.shareHandler) {
        self.shareHandler(type);
    }
}

@end
