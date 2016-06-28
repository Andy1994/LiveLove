//
//  GFAvatarView.m
//  GetFun
//
//  Created by zhouxz on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

static const CGFloat kAvatarDefaultWH = 84.0f;

#import "GFAvatarView.h"

@interface GFAvatarView ()

@property (nonatomic, strong) UIImageView *avatarImageView; // 头像

@end

@implementation GFAvatarView

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
//        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAvatarDefaultWH, kAvatarDefaultWH)];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.avatarImageView];
        
        _isUserInterestColorShowed = YES;
        _isShowedInFeedList = YES;
    }
    return self;
}

- (void)updateWithUser:(GFUserMTL *)user {
    if (!user.avatar || [user.avatar length] == 0) {
        self.avatarImageView.image = [UIImage imageNamed:@"default_avatar_1"];
    } else {

        NSString *url = self.isShowedInFeedList ? [user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES]:[user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarProfile gifConverted:YES];
        
        UIColor *interestColor;
        CGFloat borderWidth = 0.0f;
        if (self.isUserInterestColorShowed) {
            interestColor = [UIColor gf_colorWithHex:user.color];
            borderWidth = 2.0f;
        }
        @weakify(self)
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"default_avatar_1"] options:kNilOptions completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            @strongify(self)
            //注意：由于绘制圆角和边缘颜色都是对图片操作，而图片大小和实际尺寸存在放缩适应，因此需按照比例计算。
            //初始化时必须指定宽高大小，
            if (self.width > 0) {
                self.avatarImageView.image = [image imageByRoundCornerRadius:MAXFLOAT borderWidth:borderWidth * image.size.width/self.width borderColor:interestColor];
            }
            [self setNeedsLayout];
        }];

    }
    
    [self setNeedsLayout];
}

- (void)setIsUserInterestColorShowed:(BOOL)isUserInterestColorShowed {
    _isUserInterestColorShowed = isUserInterestColorShowed;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.avatarImageView.frame = ({
//        CGFloat width =  self.isUserInterestColorShowed? self.width - 3 : self.width;
        CGFloat width =  self.width;
        CGRect rect = CGRectMake(self.width/2-width/2, self.height/2-width/2, width, width);
        rect;
    });
//    self.avatarImageView.layer.cornerRadius = self.avatarImageView.width/2;
}

@end
