//
//  GFFollowTableViewCell.m
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFollowTableViewCell.h"
#import "GFAvatarView.h"
#import "GFFollowerMTL.h"

static const CGFloat kCellHeight = 68.0f;
static const CGFloat kAvatarWH = 50.0f;

@interface GFFollowTableViewCell ()

@property (nonatomic, strong) GFAvatarView *avatar;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *updatedContentCountLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) CALayer *bottomBorder;

@end

@implementation GFFollowTableViewCell

- (GFAvatarView *)avatar {
    if (!_avatar) {
        _avatar = [[GFAvatarView alloc] initWithFrame:CGRectMake(0, 0, kAvatarWH, kAvatarWH)];
        _avatar.isShowedInFeedList = NO;
    }
    return _avatar;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = [UIColor textColorValue1];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel *)updatedContentCountLabel {
    if (!_updatedContentCountLabel) {
        _updatedContentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _updatedContentCountLabel.font = [UIFont systemFontOfSize:14];
        _updatedContentCountLabel.textColor = [UIColor textColorValue3];
        _updatedContentCountLabel.textAlignment = NSTextAlignmentLeft;
        _updatedContentCountLabel.hidden = YES;
    }
    return _updatedContentCountLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.frame = CGRectMake(0, 0, 38, 27);
        _followButton.layer.cornerRadius = 5.0f;
        _followButton.clipsToBounds = YES;
    }
    return _followButton;
}

- (CALayer *)bottomBorder {
    if (!_bottomBorder) {
        _bottomBorder = [CALayer layer];
        _bottomBorder.backgroundColor = [UIColor themeColorValue12].CGColor;
    }
    return _bottomBorder;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.updatedContentCountLabel];
        [self.contentView addSubview:self.followButton];
        [self.contentView.layer addSublayer:self.bottomBorder];
        
        __weak typeof(self) weakSelf = self;
        [self.followButton bk_addEventHandler:^(id sender) {
            if ([weakSelf.delegate respondsToSelector:@selector(followActionWithButton:InCell:)]) {
                [weakSelf.delegate followActionWithButton:weakSelf.followButton InCell:weakSelf];
            }
        } forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

/**
 *  根据状态设置背景图和是否选中
 */
- (void)setFollowButtonImage{
    
    GFFollowerMTL *followerMTL = self.model;
    
    switch ([followerMTL followState]) {
        case GFFollowStateNo: {
            [self.followButton setImage:[UIImage imageNamed:@"profile_not_follow"] forState:UIControlStateNormal];
            break;
        }
        case GFFollowStateFollowing: {
            [self.followButton setImage:[UIImage imageNamed:@"profile_follow"] forState:UIControlStateNormal];
            break;
        }
        case GFFollowStateFollowingEachOther: {
            [self.followButton setImage:[UIImage imageNamed:@"profile_follow_eachother"] forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)bindWithModel:(id)model {
    
    [super bindWithModel:model];

    GFFollowerMTL *followerMTL = self.model;
    
    [self.avatar updateWithUser:followerMTL.user];
    [self setFollowButtonImage];
    
    switch (self.style) {
        case GFFollowTableViewCellStyleMyFollowee: {
            self.nameLabel.text = followerMTL.user.nickName;
            self.updatedContentCountLabel.text = [NSString stringWithFormat:@"更新了%@条内容", followerMTL.contentUnreadCount];
            break;
        }
        case GFFollowTableViewCellStyleMyFollower:
        case GFFollowTableViewCellStyleOtherFollower:
        case GFFollowTableViewCellStyleOtherFollowee:{
            self.nameLabel.text = followerMTL.user.nickName;
            break;
        }
        default:
            break;
    }
    
    self.followButton.selected = !([followerMTL followState] == GFFollowStateNo);
}

+ (CGFloat)heightWithModel:(id)model {
    return kCellHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatar.frame = CGRectMake(12,
                                   self.contentView.height/2-kAvatarWH/2,
                                   kAvatarWH,
                                   kAvatarWH);
    
    self.followButton.origin = CGPointMake(self.contentView.width-12-self.followButton.width,
                                         self.contentView.height/2-self.followButton.height/2);
    const CGFloat kSpace = 5.0f;
    const CGFloat kNameLabelHeight = 22.0f;
    const CGFloat kUpdatedContentCountLabelHeight = 16.0f;
    CGFloat y = (self.contentView.height - kNameLabelHeight - kSpace - kUpdatedContentCountLabelHeight)/2;
    
    switch (self.style) {
        case GFFollowTableViewCellStyleMyFollowee: {
            self.nameLabel.frame = CGRectMake(self.avatar.right + 15, y, self.followButton.left - self.avatar.right-12 , kNameLabelHeight);
            self.updatedContentCountLabel.frame = CGRectMake(self.nameLabel.x, self.nameLabel.bottom + kSpace, self.nameLabel.width, kUpdatedContentCountLabelHeight);
            self.updatedContentCountLabel.hidden = NO;
            break;
        }
        case GFFollowTableViewCellStyleMyFollower:
        case GFFollowTableViewCellStyleOtherFollower:
        case GFFollowTableViewCellStyleOtherFollowee:{
            self.nameLabel.frame = CGRectMake(self.avatar.right + 15, self.contentView.height/2 - kNameLabelHeight/2, self.followButton.left - self.avatar.right - 12, kNameLabelHeight);
            self.updatedContentCountLabel.hidden = YES;
            break;
        }
        default:
            break;
    }
    
    self.bottomBorder.frame = CGRectMake(0, self.height - 1, self.width, 1.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.followButton.selected = NO;
    self.updatedContentCountLabel.hidden = NO;
}
@end
