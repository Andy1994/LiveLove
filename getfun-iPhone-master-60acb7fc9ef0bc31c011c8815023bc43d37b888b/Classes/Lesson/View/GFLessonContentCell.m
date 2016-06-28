//
//  GFLessonContentCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/25.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFLessonContentCell.h"
#import "GFContentMTL.h"

#define kPaddingWidth 15.0f
#define kTitleTopSpacing 15.0f
#define kContentTopSpacing 15.0f
#define kShowAllButtonHeight 60.0f
#define kSubContentBottomSpacing 15.0f

@interface GFLessonContentCell ()

@property (nonatomic, strong, readwrite) GFUserInfoHeader *userInfoHeader;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *showAllButton;

@end

@implementation GFLessonContentCell
- (GFUserInfoHeader *)userInfoHeader {
    if (!_userInfoHeader) {
        _userInfoHeader = [[GFUserInfoHeader alloc] initWithFrame:CGRectZero];
    }
    return _userInfoHeader;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[self class] titleLabel];
    }
    return _titleLabel;
}

+ (UILabel *)titleLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 5;
    return label;
}

+ (NSAttributedString *)attributedTitleString:(NSString *)title {
    if (!title) return nil;
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSUInteger textLength = [title length];
    
    //字体
    UIFont *font = [UIFont systemFontOfSize:17.0f];
    [attributedTitle addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textLength)];
    //颜色
    UIColor *color = [UIColor textColorValue1];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, textLength)];
    //行距
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3.0f;
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
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.numberOfLines = 5;
    return contentLabel;
}

+ (NSAttributedString *)attributedContentString:(NSString *)content {
    if (!content) return nil;
    
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    NSUInteger textLength = [content length];
    
    //字体
    UIFont *font = [UIFont systemFontOfSize:17.0f];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textLength)];
    //颜色
    UIColor *color = [UIColor textColorValue1];
    [attributedContent addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, textLength)];
    //行距
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3.0f;
    style.alignment = NSTextAlignmentLeft;
    [attributedContent addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textLength)];
    
    return attributedContent;
}

- (UIButton *)showAllButton {
    if (!_showAllButton) {
        _showAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showAllButton setTitle:@"点击查看全部内容" forState:UIControlStateNormal];
        [_showAllButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        _showAllButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_showAllButton gf_AddTopBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return _showAllButton;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.attributedText = nil;
    self.contentLabel.attributedText = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.userInfoHeader];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.showAllButton];
        
        __weak typeof(self) weakSelf = self;
        [self.showAllButton bk_addEventHandler:^(id sender) {
            if (weakSelf.showAllButtonHandler) {
                weakSelf.showAllButtonHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    
    BOOL isSubContent = [model isKindOfClass:[GFSubContentMTL class]];
    
    CGFloat height = 2 * kSubContentBottomSpacing + 28; //用户信息区距上边距和评论距底边距保持一致
    if (isSubContent) {
        GFSubContentMTL *subContent = model;
        UILabel *contentLabel = [self contentLabel];
        contentLabel.attributedText = [self attributedContentString:subContent.content];
        CGSize size = [contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - kPaddingWidth * 2, MAXFLOAT)];
        height += size.height + kContentTopSpacing + kSubContentBottomSpacing;
    } else {
        GFContentMTL *contentMTL = model;
        
        NSString *title = nil;
        NSString *content = nil;
        if (contentMTL.contentSummary) {
            title = contentMTL.contentSummary.title;
            content = [(GFContentSummaryArticleMTL *)contentMTL.contentSummary summary];
        }
        if (!title) {
            title = contentMTL.contentDetail.title;
        }
        if (!content) {
            content = [(GFContentDetailArticleMTL *)contentMTL.contentDetail summary];
        }
        
        if (title) {
            UILabel *titleLabel = [self titleLabel];
            titleLabel.attributedText = [self attributedTitleString:title];
            CGSize size = [titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - kPaddingWidth * 2, MAXFLOAT)];
            height += size.height + kTitleTopSpacing;
        }
        if (content) {
            UILabel *contentLabel = [self contentLabel];
            contentLabel.attributedText = [self attributedContentString:content];
            CGSize size = [contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - kPaddingWidth * 2, MAXFLOAT)];
            height += size.height + kContentTopSpacing;
        }
        
        height += kShowAllButtonHeight;
    }
    
    return height;
}

- (void)bindWithModel:(id)model userInfo:(GFUserMTL *)user {
    [super bindWithModel:model];
    
    BOOL isSubContent = [model isKindOfClass:[GFSubContentMTL class]];
    
    self.titleLabel.hidden = isSubContent;
    self.showAllButton.hidden = isSubContent;

    [self.userInfoHeader setStyle:GFUserInfoHeaderStyleDate];
    [self.userInfoHeader setUserInfo:user];
    
    if (isSubContent) {
        GFSubContentMTL *subContent = model;
        NSNumber *updateTime = subContent.updateTime;
        if (!updateTime) {
            updateTime = subContent.createTime;
        }
        [self.userInfoHeader setDate:[updateTime longLongValue]/1000];
        self.contentLabel.attributedText = [[self class] attributedContentString:subContent.content];
    } else {
        GFContentMTL *contentMTL = model;
        [self.userInfoHeader setDate:[contentMTL.contentInfo.createTime longLongValue]/1000];
        
        NSString *title = nil;
        NSString *content = nil;
        if (contentMTL.contentSummary) {
            title = contentMTL.contentSummary.title;
            content = [(GFContentSummaryArticleMTL *)contentMTL.contentSummary summary];
        }
        if (!title) {
            title = contentMTL.contentDetail.title;
        }
        if (!content) {
            content = [(GFContentDetailArticleMTL *)contentMTL.contentDetail summary];
        }

        self.titleLabel.attributedText = [[self class] attributedTitleString:title];
        self.contentLabel.attributedText = [[self class] attributedContentString:content];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL isSubContent = [self.model isKindOfClass:[GFSubContentMTL class]];
    
    self.userInfoHeader.frame = CGRectMake(0, 0, self.contentView.width, kUserInfoHeaderHeight);
    
    if (isSubContent) {
        self.contentLabel.frame = ({
            CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 2 * kPaddingWidth, MAXFLOAT)];
            CGRect rect = CGRectMake(kPaddingWidth, self.userInfoHeader.bottom + kContentTopSpacing, size.width, size.height);
            rect;
        });
    } else {
        self.titleLabel.frame = ({
            CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 2 * kPaddingWidth, MAXFLOAT)];
            CGRect rect = CGRectMake(kPaddingWidth, self.userInfoHeader.bottom + kTitleTopSpacing, size.width, size.height);
            rect;
        });
        
        self.contentLabel.frame = ({
            CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 2 * kPaddingWidth, MAXFLOAT)];
            CGRect rect = CGRectMake(kPaddingWidth, self.titleLabel.bottom + kContentTopSpacing, size.width, size.height);
            rect;
        });
        
        self.showAllButton.frame = CGRectMake(0, self.contentLabel.bottom, self.contentView.width, kShowAllButtonHeight);
    }
}


@end
