//
//  GFContentDetailUserInfoView.m
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailUserInfoView.h"
#import "GFAvatarView.h"
#import "GFContentDetailMTL.h"

static const CGFloat kAvatarWH = 38.0f;

@interface GFContentDetailUserInfoView()

@property (nonatomic, strong) GFContentMTL *content;
@property (nonatomic, strong) GFAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UILabel *locationLabel;

@end

@implementation GFContentDetailUserInfoView
- (GFAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[GFAvatarView alloc] initWithFrame:CGRectMake(15, 6, kAvatarWH, kAvatarWH)];
        _avatarView.isShowedInFeedList = NO;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = RGBCOLOR(34, 34, 34);
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (UILabel *)dateLabel {
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.textColor = RGBCOLOR(173, 173, 173);
        _dateLabel.font = [UIFont systemFontOfSize:12];
    }
    return _dateLabel;
}

- (UIImageView *)locationIcon {
    if (!_locationIcon) {
        _locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location5"]];
        [_locationIcon sizeToFit];
    }
    return _locationIcon;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationLabel.font = [UIFont italicSystemFontOfSize:12];
        _locationLabel.textColor = [UIColor textColorValue4];
    }
    return _locationLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.dateLabel];
        [self addSubview:self.locationIcon];
        [self addSubview:self.locationLabel];
        
        __weak typeof(self) weakSelf = self;
        [self.avatarView bk_whenTapped:^{
            if (weakSelf.avatarTappedHandler) {
                weakSelf.avatarTappedHandler(weakSelf.content.user);
            }
        }];
    }
    return self;
}

#pragma mark - Public methods

- (void)bindModel:(GFContentMTL *)content {
    
    self.content = content;
    [self.avatarView updateWithUser:content.user];
    self.nameLabel.text = content.user.nickName;
    self.dateLabel.text = [GFTimeUtil getfunStyleTimeFromTimeInterval:[content.contentInfo.createTime longLongValue] / 1000];
    
    NSString *address = content.contentInfo.address;
    self.locationLabel.text = (address && [address length] > 0) ? address : @"";
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarView.frame = CGRectMake(15, 6, kAvatarWH, kAvatarWH);
    
    NSString *address = self.content.contentInfo.address;

    [self.nameLabel sizeToFit];
    [self.dateLabel sizeToFit];
    
    if (address && [address length] > 0) {
        
        self.locationIcon.hidden = NO;
        self.locationLabel.hidden = NO;
        
        self.dateLabel.frame = CGRectMake(self.width - 15 - self.dateLabel.width,
                                          self.avatarView.y,
                                          self.dateLabel.width,
                                          MAX(self.nameLabel.height, self.dateLabel.height));
        
        self.nameLabel.frame = CGRectMake(self.avatarView.right + 12,
                                          self.avatarView.y,
                                          MIN(self.nameLabel.width, self.dateLabel.x - 12 - self.avatarView.right - 12),
                                          MAX(self.nameLabel.height, self.dateLabel.height));
        
        [self.locationLabel sizeToFit];
        self.locationIcon.center = CGPointMake(self.avatarView.right + 12 + self.locationIcon.width/2,
                                               self.nameLabel.bottom + 2 + MAX(self.locationIcon.height, self.locationLabel.height)/2);
        self.locationLabel.frame = CGRectMake(self.locationIcon.right + 5,
                                              self.locationIcon.centerY - self.locationLabel.height/2,
                                              MIN(self.locationLabel.width, self.width - 15 - self.locationIcon.right - 5),
                                              MAX(self.locationIcon.height, self.locationLabel.height));
    } else {
        
        self.locationIcon.hidden = YES;
        self.locationLabel.hidden = YES;
        
        CGFloat height = MAX(self.nameLabel.height, self.dateLabel.height);
        
        self.dateLabel.frame = CGRectMake(self.width - 15 - self.dateLabel.width,
                                          self.avatarView.centerY - self.dateLabel.height/2,
                                          self.dateLabel.width,
                                          height);
        
        self.nameLabel.frame = CGRectMake(self.avatarView.right + 12,
                                          self.avatarView.centerY - height/2,
                                          MIN(self.nameLabel.width, self.dateLabel.x - 12 - self.avatarView.right - 12),
                                          height);
    }
}

@end
