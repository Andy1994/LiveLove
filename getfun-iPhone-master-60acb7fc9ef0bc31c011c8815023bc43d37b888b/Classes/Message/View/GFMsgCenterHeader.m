//
//  GFMsgCenterHeader.m
//  GetFun
//
//  Created by zhouxz on 16/1/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMsgCenterHeader.h"
#import "GFMessageCenter.h"

@interface GFMsgCenterHeaderItem : UIView

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *title;
- (void)showBadgeNumber:(BOOL)show count:(NSUInteger)count;

@end

@interface GFMsgCenterHeaderItem ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;

@end

@implementation GFMsgCenterHeaderItem
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.height/2 - 25, 50, 50)];
    }
    return _iconImageView;
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _badgeLabel.backgroundColor = [UIColor gf_colorWithHex:@"FF6421"];
        _badgeLabel.font = [UIFont systemFontOfSize:10.0f];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.hidden = YES;
        
    }
    return _badgeLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.right + 16,
                                                                self.height/2 - 9,
                                                                self.width/2,
                                                                18)];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textColor = [UIColor textColorValue1];
    }
    return _titleLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
        _accessoryImageView.center = CGPointMake(self.width - 15 - _accessoryImageView.width/2, self.height/2);
    }
    return _accessoryImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.iconImageView];
        [self addSubview:self.badgeLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.accessoryImageView];
        
        [self gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return self;
}

- (void)setIcon:(UIImage *)icon {
    _icon = icon;
    self.iconImageView.image = icon;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)showBadgeNumber:(BOOL)show count:(NSUInteger)count {
    
    if (count == 0) {
        self.badgeLabel.hidden = YES;
        return;
    }
    
    self.badgeLabel.hidden = NO;
    if (show) {
        NSString *text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
        if (count > 99) {
            text = @"99+";
        }
        self.badgeLabel.text = text;
        self.badgeLabel.frame = CGRectMake(0, 0, 20, 20);
        
    } else {
        self.badgeLabel.text = @"";
        self.badgeLabel.frame = CGRectMake(0, 0, 10, 10);
    }
    self.badgeLabel.center = CGPointMake(self.iconImageView.right - self.badgeLabel.width/2, self.iconImageView.y + self.badgeLabel.height/2);
    self.badgeLabel.layer.cornerRadius = self.badgeLabel.width/2;
}
@end

@interface GFMsgCenterHeader ()

@property (nonatomic, strong) GFMsgCenterHeaderItem *funItemView;
@property (nonatomic, strong) GFMsgCenterHeaderItem *participateItemView;
@property (nonatomic, strong) GFMsgCenterHeaderItem *commentItemView;
@property (nonatomic, strong) GFMsgCenterHeaderItem *auditItemView;

@end

@implementation GFMsgCenterHeader
- (GFMsgCenterHeaderItem *)funItemView {
    if (!_funItemView) {
        _funItemView = [[GFMsgCenterHeaderItem alloc] initWithFrame:CGRectMake(0, 10, self.width, (self.height - 20)/4)];
        _funItemView.icon = [UIImage imageNamed:@"icon_msg_fun"];
        _funItemView.title = @"FUN我的";
        [_funItemView gf_AddTopBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return _funItemView;
}

- (GFMsgCenterHeaderItem *)participateItemView {
    if (!_participateItemView) {
        _participateItemView = [[GFMsgCenterHeaderItem alloc] initWithFrame:CGRectMake(0, self.funItemView.bottom, self.width, (self.height - 20)/4)];
        _participateItemView.icon = [UIImage imageNamed:@"icon_msg_particapate"];
        _participateItemView.title = @"参与我的PK";
    }
    return _participateItemView;
}

- (GFMsgCenterHeaderItem *)commentItemView {
    if (!_commentItemView) {
        _commentItemView = [[GFMsgCenterHeaderItem alloc] initWithFrame:CGRectMake(0, self.participateItemView.bottom, self.width, (self.height - 20)/4)];
        _commentItemView.icon = [UIImage imageNamed:@"icon_msg_comment"];
        _commentItemView.title = @"评论我的";
    }
    return _commentItemView;
}

- (GFMsgCenterHeaderItem *)auditItemView {
    if (!_auditItemView) {
        _auditItemView = [[GFMsgCenterHeaderItem alloc] initWithFrame:CGRectMake(0, self.commentItemView.bottom, self.width, (self.height - 20)/4)];
        _auditItemView.icon = [UIImage imageNamed:@"icon_msg_audit"];
        _auditItemView.title = @"系统通知";
    }
    return _auditItemView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.funItemView];
        [self addSubview:self.participateItemView];
        [self addSubview:self.commentItemView];
        [self addSubview:self.auditItemView];
        
        __weak typeof(self) weakSelf = self;
        [self.funItemView bk_whenTapped:^{
            if (weakSelf.msgCenterHeaderHandler) {
                weakSelf.msgCenterHeaderHandler(GFBasicMessageTypeFun);
            }
        }];
        [self.participateItemView bk_whenTapped:^{
            if (weakSelf.msgCenterHeaderHandler) {
                weakSelf.msgCenterHeaderHandler(GFBasicMessageTypeParticipate);
            }
        }];
        [self.commentItemView bk_whenTapped:^{
            if (weakSelf.msgCenterHeaderHandler) {
                weakSelf.msgCenterHeaderHandler(GFBasicMessageTypeComment);
            }
        }];
        [self.auditItemView bk_whenTapped:^{
            if (weakSelf.msgCenterHeaderHandler) {
                weakSelf.msgCenterHeaderHandler(GFBasicMessageTypeAudit);
            }
        }];
    }
    return self;
}

- (void)updateUnreadBadge:(GFUnreadCountMTL *)unreadCount {
    [self.funItemView showBadgeNumber:NO count:unreadCount.fun];
    [self.participateItemView showBadgeNumber:YES count:unreadCount.participate];
    [self.commentItemView showBadgeNumber:YES count:unreadCount.comment];
    [self.auditItemView showBadgeNumber:NO count:unreadCount.audit];
}

@end
