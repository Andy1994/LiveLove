//
//  GFUserInfoHeader.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFUserInfoHeader.h"

#import "GFTagMTL.h"
#import "GFAvatarView.h"

static const CGFloat kAvatarWH = 28.0f;

@interface GFUserInfoHeader ()

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) GFAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nickNameLabel;

@property (nonatomic, strong) UIImageView *originPosterIcon;//楼主

@property (nonatomic, strong) UIButton *tagButton;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *funButton;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation GFUserInfoHeader
- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] initWithFrame:CGRectZero];
        _topLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _topLine;
}

- (GFAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[GFAvatarView alloc] initWithFrame:CGRectMake(0, 0, kAvatarWH, kAvatarWH)];
        _avatarView.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [self.avatarView bk_whenTapped:^{
            if (weakSelf.avatarHandler) {
                weakSelf.avatarHandler();
            }
        }];
    }
    return _avatarView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nickNameLabel.font = [UIFont systemFontOfSize:14.0f];
        _nickNameLabel.textColor = [UIColor textColorValue1];
    }
    return _nickNameLabel;
}

- (UIImageView *)originPosterIcon {
    if (!_originPosterIcon) {
        _originPosterIcon = [[UIImageView alloc] init];
        _originPosterIcon.image = [UIImage imageNamed:@"comment_louzhu"];
        [_originPosterIcon sizeToFit];
        _originPosterIcon.hidden = YES;
    }
    return _originPosterIcon;
}

- (UIButton *)tagButton {
    if (!_tagButton) {
        _tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tagButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _tagButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _tagButton.layer.masksToBounds = YES;
        _tagButton.layer.cornerRadius = 2.0f;
        _tagButton.layer.borderWidth = 0.5f;
        _tagButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        __weak typeof(self) weakSelf = self;
        [self.tagButton bk_whenTapped:^{
            if (weakSelf.tagHandler) {
                weakSelf.tagHandler();
            }
        }];
    }
    return _tagButton;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.font = [UIFont systemFontOfSize:12.0f];
        _dateLabel.textColor = [UIColor textColorValue4];
        _dateLabel.textAlignment = NSTextAlignmentRight;
    }
    return _dateLabel;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"content_delete2"];
        [_deleteButton setImage:img forState:UIControlStateNormal];
        [_deleteButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
        __weak typeof(self) weakSelf = self;
        [self.deleteButton bk_whenTapped:^{
            if (weakSelf.deleteHandler) {
                weakSelf.deleteHandler();
            }
        }];
    }
    return _deleteButton;
}

- (UIButton *)funButton {
    if (!_funButton) {
        _funButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _funButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        _funButton.titleLabel.textColor = [UIColor textColorValue1];
        _funButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _funButton.layer.borderWidth = 0.5;
        _funButton.layer.cornerRadius = 3;
        _funButton.clipsToBounds = YES;
        __weak typeof(self) weakSelf = self;
        [self.funButton bk_whenTapped:^{
            if (weakSelf.funHandler) {
                weakSelf.funHandler();
            }
        }];
    }
    return _funButton;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _bottomLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {        
        self.style = GFUserInfoHeaderStyleDefault;
    }
    return self;
}

- (void)dealloc {
    [_avatarView removeFromSuperview];
    _avatarView = nil;
}

- (void)setStyle:(GFUserInfoHeaderStyle)style {
    
    _style = style;
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addSubview:self.topLine];
    
    [self addSubview:self.avatarView];
    
    [self addSubview:self.nickNameLabel];
    [self addSubview:self.originPosterIcon];
    
    if (style == GFUserInfoHeaderStyleDate || style == GFUserInfoHeaderStyleDateAndDelete || style == GFUserInfoHeaderStyleDateAndFun) {
        [self addSubview:self.dateLabel];
    }
    if (style == GFUserInfoHeaderStyleDateAndDelete) {
        [self addSubview:self.deleteButton];
    }
    if (style == GFUserInfoHeaderStyleTag) {
        [self addSubview:self.tagButton];
    }
    if (style == GFUserInfoHeaderStyleDateAndFun) {
        [self addSubview:self.funButton];
    }
    
    [self addSubview:self.bottomLine];
    
    [self setNeedsLayout];
}

- (void)setUserInfo:(GFUserMTL *)user {
    [self.avatarView updateWithUser:user];
    self.nickNameLabel.text = user.nickName;
    [self setNeedsLayout];
}

- (void)setOriginPoster:(BOOL)isOriginPoster {
    self.originPosterIcon.hidden = !isOriginPoster;
}

- (void)setTagInfo:(GFTagInfoMTL *)tagInfo {
    
    if (self.style != GFUserInfoHeaderStyleTag) return;
    
    if (!tagInfo || !tagInfo.tagName || [tagInfo.tagName length] == 0) {
        self.tagButton.hidden = YES;
    } else {
        self.tagButton.hidden = NO;
        [self.tagButton setTitle:tagInfo.tagName forState:UIControlStateNormal];
        [self.tagButton setTitleColor:[UIColor gf_colorWithHex:tagInfo.tagHexColor] forState:UIControlStateNormal];
        self.tagButton.layer.borderColor = [UIColor gf_colorWithHex:tagInfo.tagHexColor].CGColor;
    }
    [self setNeedsLayout];
}

- (void)setDate:(NSTimeInterval)timeInterval {
    if (self.style != GFUserInfoHeaderStyleDate && self.style != GFUserInfoHeaderStyleDateAndDelete && self.style != GFUserInfoHeaderStyleDateAndFun) return;
    
    self.dateLabel.text = [GFTimeUtil getfunStyleTimeFromTimeInterval:timeInterval];
    [self setNeedsLayout];
}

- (void)setFunned:(BOOL)funned count:(NSInteger)count {
    if (self.style != GFUserInfoHeaderStyleDateAndFun) return;
    
    [self.funButton setTitle:[NSString stringWithFormat:@"%ld FUN", (long)count] forState:UIControlStateNormal];
    self.funButton.enabled = !funned;
    if (funned) {
        self.funButton.layer.borderColor = [UIColor themeColorValue10].CGColor;
        [self.funButton setTitleColor:[UIColor themeColorValue10] forState:UIControlStateNormal];
    } else {
        self.funButton.layer.borderColor = [UIColor textColorValue4].CGColor;
        [self.funButton setTitleColor:[UIColor textColorValue4] forState:UIControlStateNormal];
    }
}

- (void)setTopLineHidden:(BOOL)hidden {
    self.topLine.hidden = hidden;
}

- (void)setBottomLineHidden:(BOOL)hidden {
    self.bottomLine.hidden = hidden;
}

- (void)doFunAnimation {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_fun_disabled"]];
    [imageView sizeToFit];
    imageView.center = self.funButton.center;
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"+1";
    [imageView addSubview:label];
    
    [UIView animateWithDuration:.3 animations:^{
        imageView.y -= 10;
    } completion:^(BOOL finished) {
        [imageView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.2];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topLine.frame = CGRectMake(0, 0, self.width, 0.5f);
    self.avatarView.frame = CGRectMake(15.0f, self.height/2-14.0f, kAvatarWH, kAvatarWH);

    [self.nickNameLabel sizeToFit];
    if (self.style == GFUserInfoHeaderStyleDefault) {
        CGFloat maxNameWidth = self.width - 15 - 5 - self.originPosterIcon.width - 5 - self.avatarView.right - 5;
        CGFloat width = MIN(maxNameWidth, self.nickNameLabel.width);
        self.nickNameLabel.frame = CGRectMake(self.avatarView.right + 5,
                                              self.height/2 - self.nickNameLabel.height/2,
                                              width,
                                              self.nickNameLabel.height);
        self.originPosterIcon.center = CGPointMake(self.nickNameLabel.right + 5 + self.originPosterIcon.width/2, self.nickNameLabel.centerY);
        
    } else if (self.style == GFUserInfoHeaderStyleTag) {
        self.tagButton.frame = ({
            [self.tagButton sizeToFit];
            CGFloat width = MIN(12.0f * 11 + 10, self.tagButton.width + 10);
            CGRect frame = CGRectMake(self.width - 15 - width,
                                      self.height/2 - self.tagButton.height/2,
                                      width,
                                      self.tagButton.height - 2);
            frame;
        });
        
        CGFloat maxNameWidth = self.tagButton.x - 5 - self.originPosterIcon.width - 5 - self.avatarView.right - 5;
        CGFloat width = MIN(maxNameWidth, self.nickNameLabel.width);
        self.nickNameLabel.frame = CGRectMake(self.avatarView.right + 5,
                                              self.height/2 - self.nickNameLabel.height/2,
                                              width,
                                              self.nickNameLabel.height);
        self.originPosterIcon.center = CGPointMake(self.nickNameLabel.right + 5 + self.originPosterIcon.width/2, self.nickNameLabel.centerY);
    } else if (self.style == GFUserInfoHeaderStyleDate) {
    
        self.dateLabel.frame = ({
            [self.dateLabel sizeToFit];
            CGRect frame = CGRectMake(self.width - 15 - self.dateLabel.width,
                                      self.height/2 - self.dateLabel.height/2,
                                      self.dateLabel.width,
                                      self.dateLabel.height);
            frame;
        });
        
        CGFloat maxNameWidth = self.dateLabel.x - 5 - self.originPosterIcon.width - 5 - self.avatarView.right - 5;
        CGFloat width = MIN(maxNameWidth, self.nickNameLabel.width);
        self.nickNameLabel.frame = CGRectMake(self.avatarView.right + 5,
                                              self.height/2 - self.nickNameLabel.height/2,
                                              width,
                                              self.nickNameLabel.height);
        self.originPosterIcon.center = CGPointMake(self.nickNameLabel.right + 5 + self.originPosterIcon.width/2, self.nickNameLabel.centerY);
    } else if (self.style == GFUserInfoHeaderStyleDateAndDelete) {
        self.deleteButton.frame = CGRectMake(self.width-27-15, 0, 27, self.height);
        self.dateLabel.frame = ({
            [self.dateLabel sizeToFit];
            CGRect frame = CGRectMake(self.deleteButton.x - 5 - self.dateLabel.width,
                                      self.height/2 - self.dateLabel.height/2,
                                      self.dateLabel.width,
                                      self.dateLabel.height);
            frame;
        });
        CGFloat maxNameWidth = self.dateLabel.x - 5 - self.originPosterIcon.width - 5 - self.avatarView.right - 5;
        CGFloat width = MIN(maxNameWidth, self.nickNameLabel.width);
        self.nickNameLabel.frame = CGRectMake(self.avatarView.right + 5,
                                              self.height/2 - self.nickNameLabel.height/2,
                                              width,
                                              self.nickNameLabel.height);
        self.originPosterIcon.center = CGPointMake(self.nickNameLabel.right + 5 + self.originPosterIcon.width/2, self.nickNameLabel.centerY);
    } else if (self.style == GFUserInfoHeaderStyleDateAndFun) {
        self.funButton.frame = CGRectMake(self.width - 15 - 48, self.height/2 - 11, 48, 22);

        CGFloat maxNameWidth = self.funButton.x - 5 - self.originPosterIcon.width - 5 - self.avatarView.right - 5;
        CGFloat width = MIN(maxNameWidth, self.nickNameLabel.width);
        
        [self.dateLabel sizeToFit];
        self.nickNameLabel.frame = CGRectMake(self.avatarView.right + 5,
                                              self.height/2 - self.dateLabel.height/2 - self.nickNameLabel.height/2,
                                              width,
                                              self.nickNameLabel.height);
        self.originPosterIcon.center = CGPointMake(self.nickNameLabel.right + 5 + self.originPosterIcon.width/2, self.nickNameLabel.centerY);
        self.dateLabel.frame = CGRectMake(self.nickNameLabel.x,
                                          self.height/2 + self.nickNameLabel.height/2 - self.dateLabel.height/2,
                                          self.dateLabel.width,
                                          self.dateLabel.height);
    }
    
    self.bottomLine.frame = CGRectMake(0, self.height - 0.5f, self.width, 0.5f);
}

@end
