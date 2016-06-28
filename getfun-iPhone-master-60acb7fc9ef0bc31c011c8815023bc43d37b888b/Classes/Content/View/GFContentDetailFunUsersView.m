//
//  GFContentDetailFunUsersView.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFContentDetailFunUsersView.h"

static CGFloat kAvatarViewWH = 26.0f;

@interface GFContentDetailFunUsersView ()

@property (nonatomic, strong) UILabel *funTextLabel;
@property (nonatomic, strong) UILabel *funCountLabel;
@property (nonatomic, strong) UIScrollView *avatarScrollView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *rightMaskView;
@end

@implementation GFContentDetailFunUsersView
- (UILabel *)funTextLabel {
    if (!_funTextLabel) {
        _funTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _funTextLabel.font = [UIFont systemFontOfSize:11.0f];
        _funTextLabel.textColor = [UIColor textColorValue4];
        _funTextLabel.text = @"FUN";
    }
    return _funTextLabel;
}

- (UILabel *)funCountLabel {
    if (!_funCountLabel) {
        _funCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _funCountLabel.font = [UIFont systemFontOfSize:16.0f];
        _funCountLabel.textColor = [UIColor textColorValue7];
    }
    return _funCountLabel;
}

- (UIScrollView *)avatarScrollView {
    if (!_avatarScrollView) {
        _avatarScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _avatarScrollView.showsHorizontalScrollIndicator = NO;
        _avatarScrollView.bounces = NO;
    }
    return _avatarScrollView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor themeColorValue15];
    }
    return _lineView;
}

+ (UIView *)maskViewWithLeftColor:(UIColor *)leftColor rightColor:(UIColor *)rightColor {
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAvatarViewWH/2, kAvatarViewWH)];
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    CGColorRef outerColor = leftColor.CGColor;
    CGColorRef innerColor = rightColor.CGColor;
    maskLayer.colors = @[(__bridge id)outerColor, (__bridge id)innerColor];
    maskLayer.frame = maskView.bounds;
    maskLayer.startPoint = CGPointMake(0, 0.5);
    maskLayer.endPoint = CGPointMake(1.0, 0.5);
    [maskView.layer addSublayer:maskLayer];
    return maskView;
}

- (UIView *)leftMaskView {
    if (!_leftMaskView) {
        _leftMaskView = [[self class] maskViewWithLeftColor:[[UIColor whiteColor] colorWithAlphaComponent:1.0] rightColor:[[UIColor whiteColor] colorWithAlphaComponent:0.0]];
    }
    return _leftMaskView;
}

- (UIView *)rightMaskView {
    if (!_rightMaskView) {
        _rightMaskView = [[self class] maskViewWithLeftColor:[[UIColor whiteColor] colorWithAlphaComponent:0.0] rightColor:[[UIColor whiteColor] colorWithAlphaComponent:1.0]];
    }
    return _rightMaskView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.userInteractionEnabled = YES;
    }
    return _containerView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.containerView.userInteractionEnabled = YES;
    [[self.avatarScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.funTextLabel];
        [self.contentView addSubview:self.funCountLabel];
        [self.contentView addSubview:self.containerView];
        [self.containerView addSubview:self.avatarScrollView];
        [self.containerView addSubview:self.leftMaskView];
        [self.containerView addSubview:self.rightMaskView];
        [self.contentView addSubview:self.lineView];
        self.containerView.userInteractionEnabled = YES;
    }
    return self;
}

+ (UIImageView *)avatarImageView {
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAvatarViewWH, kAvatarViewWH)];
    avatar.userInteractionEnabled = YES;
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = kAvatarViewWH/2;
    return avatar;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFContentMTL *content = model;
    
    __weak typeof(self) weakSelf = self;
    self.funCountLabel.text = [NSString stringWithFormat:@"%@", content.contentInfo.funCount];
    [[self.avatarScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (GFUserMTL *user in content.funUsers) {
        UIImageView *avatarImageView = [[self class] avatarImageView];
        avatarImageView.tag = [content.funUsers indexOfObject:user];
        NSString *url = [user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES];
        [avatarImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"default_avatar_1"]];
        [avatarImageView bk_whenTapped:^{
            if (weakSelf.funUserAvatarHandler) {
                weakSelf.funUserAvatarHandler(user);
            }
        }];
        [self.avatarScrollView addSubview:avatarImageView];
    }
    

    [self setNeedsLayout];
}

+ (CGFloat)heightWithModel:(id)model {
    return 50.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.funTextLabel sizeToFit];
    [self.funCountLabel sizeToFit];
    self.funTextLabel.center = CGPointMake(15 + self.funTextLabel.width/2, self.contentView.height/2 - self.funCountLabel.height/2);
    self.funCountLabel.center = CGPointMake(15 + self.funCountLabel.width/2, self.contentView.height/2 + self.funTextLabel.height/2);
    self.containerView.frame = CGRectMake(MAX(self.funCountLabel.right, self.funTextLabel.right)+15, self.height/2-kAvatarViewWH/2, self.contentView.width - 15 - 15 - MAX(self.funCountLabel.right, self.funTextLabel.right), kAvatarViewWH);
    self.avatarScrollView.frame = CGRectMake(0, 0, self.containerView.width, self.containerView.height);
    self.leftMaskView.center = CGPointMake(self.leftMaskView.width/2, self.containerView.height/2);
    self.rightMaskView.center = CGPointMake(self.containerView.width - self.rightMaskView.width/2, self.containerView.height/2);
    CGFloat contentWidth = 0;
    for (UIImageView *avatar in [self.avatarScrollView subviews]) {
        NSInteger index = avatar.tag;
        avatar.frame = CGRectMake(index * (kAvatarViewWH + 6),
                                  0,
                                  kAvatarViewWH,
                                  kAvatarViewWH);
        contentWidth = avatar.right;
    }
    self.avatarScrollView.contentSize = CGSizeMake(contentWidth, self.avatarScrollView.height);
    self.lineView.frame = CGRectMake(0, 0, self.contentView.width, 0.5f);
}

@end
