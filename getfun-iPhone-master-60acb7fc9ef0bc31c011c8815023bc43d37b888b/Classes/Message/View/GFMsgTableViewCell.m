//
//  GFMsgTableViewCell.m
//  GetFun
//
//  Created by zhouxz on 16/1/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMsgTableViewCell.h"
#import "GFMessageMTL.h"
#import <NSMutableArray+SWUtilityButtons.h>
#import "GFAvatarView.h"

static const CGFloat kAvatarWH = 50.0;

@interface GFMsgTableViewCell ()

@property (nonatomic, strong) GFAvatarView *avatarView;
@property (nonatomic, strong) UIView *badgeView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation GFMsgTableViewCell
- (GFAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[GFAvatarView alloc] initWithFrame:CGRectMake(15, 12, kAvatarWH, kAvatarWH)];
        _avatarView.isShowedInFeedList = NO;
    }
    return _avatarView;
}

- (UIView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _badgeView.backgroundColor = RGBCOLOR(230, 95, 65);
        _badgeView.layer.masksToBounds = YES;
        _badgeView.layer.cornerRadius = 5.0f;
    }
    return _badgeView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[self class] titleLabel];
    }
    return _titleLabel;
}


+ (UILabel *)titleLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    return label;
}

+ (NSAttributedString *)attributedTitle:(NSString *)title {
    
    if (!title) return nil;
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSUInteger textLength = [title length];
    
    //字体
    UIFont *font = [UIFont systemFontOfSize:18.0f];
    [attributedTitle addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textLength)];
    //颜色
    UIColor *color = [UIColor textColorValue1];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, textLength)];
    //行距
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 4.0f;
    style.alignment = NSTextAlignmentLeft;
    [attributedTitle addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textLength)];
    
    return attributedTitle;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[self class] contentLabel];
    }
    return _contentLabel;
}

+ (UILabel *)contentLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 5;
    return label;
}

+ (NSAttributedString *)attributedContent:(NSString *)content {
    if (!content) return nil;
    
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    NSUInteger textLength = [content length];
    
    //字体
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textLength)];
    //颜色
    UIColor *color = [UIColor textColorValue3];
    [attributedContent addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, textLength)];
    //行距
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3.0f;
    style.alignment = NSTextAlignmentLeft;
    [attributedContent addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textLength)];
    
    return attributedContent;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor textColorValue3];
    }
    return _timeLabel;
}

- (void)setEnableDelete:(BOOL)enableDelete {
    if (_enableDelete == enableDelete) {
        return;
    }
    
    _enableDelete = enableDelete;
    
    if (enableDelete) {
        NSMutableArray *rightUtilityButtons = [[NSMutableArray alloc] initWithCapacity:0];
        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor themeColorValue7] title:@"删除"];
        self.rightUtilityButtons = rightUtilityButtons;
    } else {
        self.rightUtilityButtons = nil;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.badgeView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.timeLabel];
        
        __weak typeof(self) weakSelf = self;
        [self.avatarView bk_whenTapped:^{
            if (weakSelf.msgAvatarHandler) {
                weakSelf.msgAvatarHandler(weakSelf);
            }
        }];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    
    CGFloat height = 0;
    NSString *content = @"";
    
    GFMessageMTL *message = model;
    GFBasicMessageType type = message.messageDetail.messageType & 0xF0;
    switch (type) {
        case GFBasicMessageTypeFun: {
            height = 74.0f;
            break;
        }
        case GFBasicMessageTypeParticipate:
        case GFBasicMessageTypeAudit:
        case GFBasicMessageTypeComment:
        case GFBasicMessageTypeActivity: {
            height = 12 + 18 + 8 + 8 + 12 + 12; //18 + 11 + 11 + 12 已经超过头像50的尺寸，不需要考虑头像
            content = message.messageDetail.content;
            break;
        }
        case GFBasicMessageTypeNotify: {
            
            break;
        }
        case GFBasicMessageTypeUnknown:{
            break;
        }
        case GFBasicMessageTypeFollow:{
            height = 74.0f;
            break;
        }
            
    }
    
    // 再加上内容高度
    UILabel *contentLabel = [self contentLabel];
    NSAttributedString *attributedContent = [self attributedContent:content];
    contentLabel.attributedText = attributedContent;
    
    CGSize size = [contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 15 - 50 - 16 - 15, MAXFLOAT)];
    height += size.height;

    return height;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFMessageMTL *message = model;
    GFBasicMessageType type = message.messageDetail.messageType & 0xF0; //获取message基本类型
    
    if (type == GFBasicMessageTypeAudit) { //系统审核通知时需要使用messageSender
        [self.avatarView updateWithUser:message.messageSender];
    } else {
        [self.avatarView updateWithUser:message.relatedData.relatedUser];
    }
    
    NSString *title = message.messageDetail.title; //标题高度固定，无需在转义后计算高度
    self.titleLabel.text = title;
    
    if (type == GFBasicMessageTypeFun) {
        self.contentLabel.hidden = YES;
    } else {
        self.contentLabel.hidden = NO;
        self.contentLabel.attributedText = [[self class] attributedContent:message.messageDetail.content];
    }
    
    NSTimeInterval sendTime = [message.messageDetail.sendTime longLongValue] / 1000;
    self.timeLabel.text = [GFTimeUtil getfunStyleTimeFromTimeInterval:sendTime];
    self.badgeView.hidden = !message.messageDetail.unread;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.badgeView.center = CGPointMake(self.avatarView.right - self.badgeView.width/2,
                                        self.avatarView.y + self.badgeView.height/2);
    
    self.titleLabel.frame = CGRectMake(self.avatarView.right + 16,
                                       self.avatarView.y,
                                       self.contentView.width - 15 - self.avatarView.right - 16,
                                       18);
    
    self.contentLabel.frame = ({
        CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 15 - 50 - 16 - 15, MAXFLOAT)];
        CGRect rect = CGRectMake(self.avatarView.right + 16, self.titleLabel.bottom + 5, size.width, size.height);
        rect;
    });
    
    self.timeLabel.frame = CGRectMake(self.avatarView.right + 16, self.contentLabel.bottom + 5, self.titleLabel.width, 12);
}

@end
