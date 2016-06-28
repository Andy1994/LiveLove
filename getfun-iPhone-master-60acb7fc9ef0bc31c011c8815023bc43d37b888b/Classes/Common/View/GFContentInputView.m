//
//  GFContentInputView.m
//  GetFun
//
//  Created by muhuaxin on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentInputView.h"

@interface GFContentInputView ()

@property (nonatomic, strong) CALayer *topBorder;
@property (nonatomic, strong) HPGrowingTextView *textView;

@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UIButton *funButton;
@property (nonatomic, strong, readwrite) UILabel *funCountLabel;

@end

@implementation GFContentInputView
- (CALayer *)topBorder {
    if (!_topBorder) {
        _topBorder = [CALayer layer];
        _topBorder.backgroundColor = [UIColor themeColorValue12].CGColor;
    }
    return _topBorder;
}

- (HPGrowingTextView*)textView {
    if( nil == _textView ){
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(12, 8, SCREEN_WIDTH - 72 - 12, 36)];
        _textView.isScrollable = NO;
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 3;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.layer.borderColor = [UIColor themeColorValue12].CGColor;
        _textView.layer.borderWidth = 0.5f;
        _textView.layer.cornerRadius = 4;
        _textView.internalTextView.layer.borderColor = [UIColor themeColorValue12].CGColor;
        _textView.internalTextView.layer.borderWidth = 0.5f;
        _textView.internalTextView.layer.cornerRadius = 4;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.placeholder = @"说点什么...";
    }
    return _textView;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"nav_share_dark"] forState:UIControlStateNormal];
        [_shareButton sizeToFit];
        _shareButton.hidden = YES;
    }
    return _shareButton;
}

- (UIButton *)funButton {
    if (_funButton == nil) {
        _funButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _funButton.size = CGSizeMake(30, 30);
        UIImage *normalImage = [UIImage imageNamed:@"content_fun_normal"];
        [_funButton setImage:normalImage forState:UIControlStateNormal];
        [_funButton setImage:[normalImage opacity:0.5f] forState:UIControlStateHighlighted];
        [_funButton setImage:[UIImage imageNamed:@"content_fun_disabled"] forState:UIControlStateDisabled];
    }
    return _funButton;
}

- (UILabel *)funCountLabel {
    if (_funCountLabel == nil) {
        _funCountLabel = [[UILabel alloc] init];
        _funCountLabel.font = [UIFont systemFontOfSize:12];
        _funCountLabel.textColor = [UIColor textColorValue4];
        _funCountLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _funCountLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor themeColorValue14];
        [self.layer addSublayer:self.topBorder];
        [self addSubview:self.textView];
        [self addSubview:self.funButton];
        
        __weak typeof(self) weakSelf = self;
        [self.funButton bk_addEventHandler:^(id sender) {
            if (weakSelf.funButtonHandler) {
                weakSelf.funButtonHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.funCountLabel];
        [self addSubview:self.shareButton];
        [self.shareButton bk_addEventHandler:^(id sender) {
            if (weakSelf.shareButtonHandler) {
                weakSelf.shareButtonHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        self.funCount = 0;
        self.funned = NO;
    }
    return self;
}

- (void)dealloc {
    [_textView removeFromSuperview];
    _textView = nil;
}

#pragma mark - Setters
- (void)setStyle:(GFInputViewStyle)style {
    _style = style;
    self.funButton.hidden = (style != GFInputViewStyleFun);
    self.funCountLabel.hidden = (style != GFInputViewStyleFun);
    self.shareButton.hidden = (style != GFInputViewStyleShare);
}

- (void)setFunCount:(NSInteger)funCount {
    _funCount = funCount;
    self.funCountLabel.text = [NSString stringWithFormat:@"%@", @(funCount)];
}

- (void)setFunned:(BOOL)funned {
    _funned = funned;
    self.funButton.enabled = !funned;
}

#pragma mark - Private methods
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topBorder.frame = CGRectMake(0, 0, self.width, 0.5);
    
    [self.funButton sizeToFit];
    
    [self.funButton sizeToFit];
    [self.funCountLabel sizeToFit];
    self.funButton.center = CGPointMake(self.width - 36, self.height/2 - self.funCountLabel.height/2);
    self.funCountLabel.center = CGPointMake(self.width - 36, self.height/2 + self.funButton.height/2);
    
    self.shareButton.center = CGPointMake(self.width - self.shareButton.width/2 - 15, self.height/2);
}

@end
