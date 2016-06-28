//
//  GFGroupMemberTableViewCell.m
//  GetFun
//
//  Created by Liu Peng on 15/12/2.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupMemberTableViewCell.h"
#import "GFGroupMemberInfoView.h"
#import "GFGroupMemberMTL.h"
#import "GFAvatarView.h"

static const CGFloat kAvatarWH = 67.0f;

@interface GFGroupMemberTableViewCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) GFAvatarView *avatar;
@property (nonatomic, strong) GFGroupMemberInfoView *memberInfoView;
@property (nonatomic, strong) UILabel *checkinDateTimeLabel;
@property (nonatomic, strong) CALayer *bottomBorderLayer;

@end

@implementation GFGroupMemberTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.avatar];
        [self.bgView addSubview:self.memberInfoView];
        [self.bgView addSubview:self.checkinDateTimeLabel];
        
        [self.layer addSublayer:self.bottomBorderLayer];
        
    }
    return self;
}

- (void)dealloc {
    [_avatar removeFromSuperview];
    _avatar = nil;
    
    [_memberInfoView removeFromSuperview];
    _memberInfoView = nil;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (GFAvatarView *)avatar {
    if (!_avatar) {
        _avatar = [[GFAvatarView alloc] initWithFrame:CGRectMake(0, 0, kAvatarWH, kAvatarWH)];
        _avatar.isShowedInFeedList = NO;
    }
    return _avatar;
}

- (GFGroupMemberInfoView *)memberInfoView {
    if (!_memberInfoView) {
        _memberInfoView = [[GFGroupMemberInfoView alloc] initWithFrame:CGRectZero];
    }
    return _memberInfoView;
}

- (UILabel *)checkinDateTimeLabel {
    if (!_checkinDateTimeLabel) {
        _checkinDateTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _checkinDateTimeLabel.textAlignment = NSTextAlignmentLeft;
        _checkinDateTimeLabel.font = [UIFont systemFontOfSize:13];
        _checkinDateTimeLabel.textColor = [UIColor textColorValue3];
    }
    return _checkinDateTimeLabel;
}

- (CALayer *)bottomBorderLayer {
    if (!_bottomBorderLayer) {
        _bottomBorderLayer = [CALayer layer];
        _bottomBorderLayer.backgroundColor = [UIColor themeColorValue12].CGColor;
    }
    return _bottomBorderLayer;
}

+ (CGFloat)heightWithModel:(id)model {
    return 83.0f;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFGroupMemberMTL *member = (GFGroupMemberMTL *)model;
    
    [self.avatar updateWithUser:member.user];
    self.avatar.centerY = self.contentView.height/2 ;
    [self.memberInfoView updateWithUser:member.user];
    
    long long seconds = [member.state.checkinTime longLongValue];
    if (seconds == 0) { //未签到
        self.checkinDateTimeLabel.text = @"未签到";
    } else {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds/1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [dateFormatter setTimeZone:timeZone];
        NSString *dateStr = [dateFormatter stringFromDate:date];
        self.checkinDateTimeLabel.text = [@"签到时间: " stringByAppendingString:dateStr];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.frame = self.contentView.bounds;
    self.avatar.frame = CGRectMake(17, 9, kAvatarWH, kAvatarWH);
    self.avatar.centerY = self.bgView.height/2;
    self.avatar.layer.cornerRadius = self.avatar.width / 2;
    self.avatar.clipsToBounds = YES;
    
    GFGroupMemberMTL *member = (GFGroupMemberMTL *)self.model;
    
    self.memberInfoView.frame = CGRectMake(self.avatar.right +17, self.avatar.origin.y + 2, self.bgView.width - self.avatar.right - 17, [GFGroupMemberInfoView heightWithModel:member.user]);
    self.checkinDateTimeLabel.frame = CGRectMake(self.memberInfoView.origin.x, self.memberInfoView.bottom + 6, self.memberInfoView.width, 15);
    
    self.bottomBorderLayer.frame = CGRectMake(0, self.contentView.height - 0.5, self.width, 0.5);
}

@end
