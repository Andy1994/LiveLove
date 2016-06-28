//
//  GFFunAndCommentRecordCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFunAndCommentRecordCell.h"
#import "GFFunRecordMTL.h"
#import "GFHomeDefine.h"
#import "GFAccountManager.h"

static CGFloat const kContentSummaryHeight = 86.0f;
static CGFloat const kContentSummaryTopSpace = 15.0f;
static CGFloat const kContentSummaryBottomSpace = 10.0f;


@implementation GFFunAndCommentRecordCell
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
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
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

- (GFContentSummaryView *)contentSummaryView {
    if (!_contentSummaryView) {
        _contentSummaryView = [[GFContentSummaryView alloc] initWithFrame:CGRectZero];
    }
    return _contentSummaryView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.userInfoHeader];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentSummaryView];
    }
    return self;
}

- (void)dealloc {
    [_userInfoHeader removeFromSuperview];
    _userInfoHeader = nil;
    
    [_contentSummaryView removeFromSuperview];
    _contentSummaryView = nil;
}

+ (CGFloat)heightWithModel:(id)model {
    
    if (!model) {
        return 0.0f;
    }
    
    CGFloat height = GF_HEIGHT_TOP_SPACE + GF_HEIGHT_USER_INFO;
    NSString *title = @"";
    
    if ([model isKindOfClass:[GFFunRecordMTL class]]) {
        
        GFFunRecordMTL *funRecord = model;
        if (funRecord.extendComment.content.contentInfo.status == GFContentStatusDeleted) {
            height += kContentSummaryBottomSpace;
            title = @"该内容已被删除";
        } else {
            switch (funRecord.funType) {
                case GFFunTypeContent: {
                    title = @"FUN了这篇文章";
                    break;
                }
                case GFFunTypeComment: {
                    title = [NSString stringWithFormat:@"FUN了评论:\"%@\"", funRecord.extendComment.commentInfo.commentContent];
                    break;
                }
                default: {
                    break;
                }
            }
            height += kContentSummaryTopSpace + kContentSummaryHeight + kContentSummaryBottomSpace;
        }
    } else if ([model isKindOfClass:[GFCommentMTL class]]) {
        GFCommentMTL *comment = model;
        if (comment.content.contentInfo.status == GFContentStatusDeleted) {
            height += kContentSummaryBottomSpace;
            title = @"该内容已被删除";
        } else {
            height += kContentSummaryTopSpace + kContentSummaryHeight + kContentSummaryBottomSpace;
            title = [NSString stringWithFormat:@"发表了评论\"%@\"", comment.commentInfo.commentContent];
        }
    }
    
    height += GF_HEIGHT_TITLE_TOPSPACE;
    
    UILabel *label = [self titleLabel];
    label.attributedText = [self attributedTitle:title];
    CGSize size = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT)];
    height += size.height;
    
    return height;
}

- (void)bindWithModel:(id)model user:(GFUserMTL *)user{
    
    [super bindWithModel:model];
    
    [self.userInfoHeader setUserInfo:user];
    
    if ([model isKindOfClass:[GFFunRecordMTL class]]) {
        GFFunRecordMTL *funRecord = model;
        NSString *title = @"";
        if (funRecord.extendComment.content.contentInfo.status == GFContentStatusDeleted) {
            title = @"该内容已被删除";
            [self makeSubViewHidden:YES];
        } else {
            [self makeSubViewHidden:NO];
            switch (funRecord.funType) {
                case GFFunTypeContent: {
                    title = @"Fun了文章";
                    break;
                }
                case GFFunTypeComment: {
                    title = [NSString stringWithFormat:@"Fun了评论:\"%@\"", funRecord.extendComment.commentInfo.commentContent];
                    break;
                }
                default: {
                    break;
                }
            }
            [self.contentSummaryView updateWithContent:funRecord.content];
        }
        self.titleLabel.attributedText = [[self class] attributedTitle:title];
    } else if ([model isKindOfClass:[GFCommentMTL class]]) {
        GFCommentMTL *comment = model;
        NSString *title = @"";
        if (comment.content.contentInfo.status == GFContentStatusDeleted) {
            title = @"该内容已被删除";
            [self makeSubViewHidden:YES];
        } else {
            [self makeSubViewHidden:NO];
            title = [NSString stringWithFormat:@"发布了评论\"%@", comment.commentInfo.commentContent];
            
            NSInteger imageCount = 0;
            if ([comment.pictures count]>0) {
                imageCount = comment.pictures.count;
            } else if([comment.emotions count] > 0) {
                imageCount = comment.emotions.count;
            }
            
            for (NSInteger i = 0; i < imageCount; i++) {
                title = [title stringByAppendingString:@"[图片]"];
            }
            title = [title stringByAppendingString:@"\""];
            [self.contentSummaryView updateWithContent:comment.content];
        }
        
        self.titleLabel.attributedText = [[self class] attributedTitle:title];
    }
    
    [self setNeedsLayout];
}

- (void)makeSubViewHidden:(BOOL)hidden {
    self.contentSummaryView.hidden = hidden;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.userInfoHeader.frame = CGRectMake(0, 0, self.contentView.width, GF_HEIGHT_USER_INFO);
    
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT)];
    self.titleLabel.frame = CGRectMake(15, self.userInfoHeader.bottom + GF_HEIGHT_TITLE_TOPSPACE, size.width, size.height);
    self.contentSummaryView.frame = CGRectMake(15, self.titleLabel.bottom+kContentSummaryTopSpace, SCREEN_WIDTH-30, kContentSummaryHeight);
}

@end
