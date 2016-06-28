//
//  GFUserCommentCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFUserCommentCell.h"
#import "GFCommentMTL.h"

#define kContentTopSpacing 5.0f
#define kPictureTopSpacing 10.0f
#define kPictureGapWidth 5.0f
#define kReplyInfoTopSpacing 12.0f
#define kReplyInfoHeight 29.0f
#define kCellBottomSpacing 10.0f

#define kPaddingWidth 15.0f
#define kIndentWidth 35.0f


#define kAvatarWH 24.0f

@interface GFReplyInfoView : UIView

- (void)updateWithComment:(GFCommentMTL *)comment;

@end


@interface GFReplyInfoView ()

@property (nonatomic, strong) GFCommentMTL *comment;

//@property (nonatomic, strong) UIView *replyerAvatarMaskView;
@property (nonatomic, strong) UIImageView *replyerAvatarImageView;
@property (nonatomic, strong) UILabel *replyerNameLabel;//回复者名字
@property (nonatomic, strong) UILabel *replyerNameSuffixLabel;//“回复了此跟帖”
@property (nonatomic, strong) UILabel *replyCountLabel;//查看xx条回复
@end

@implementation GFReplyInfoView
//- (UIView *)replyerAvatarMaskView {
//    if (_replyerAvatarMaskView == nil) {
//        _replyerAvatarMaskView = [[UIView alloc] init];
//        _replyerAvatarMaskView.layer.borderColor = RGBCOLOR(109, 178, 252).CGColor;
//        _replyerAvatarMaskView.layer.borderWidth = 1;
//        _replyerAvatarMaskView.layer.cornerRadius = 24 / 2;
//        _replyerAvatarMaskView.clipsToBounds = YES;
//    }
//    return _replyerAvatarMaskView;
//}

- (UIImageView *)replyerAvatarImageView {
    if (_replyerAvatarImageView == nil) {
        _replyerAvatarImageView = [[UIImageView alloc] init];
        _replyerAvatarImageView.layer.cornerRadius = 24 / 2;
        _replyerAvatarImageView.clipsToBounds = YES;
    }
    return _replyerAvatarImageView;
}

- (UILabel *)replyerNameLabel {
    if (_replyerNameLabel == nil) {
        _replyerNameLabel = [[UILabel alloc] init];
        _replyerNameLabel.textColor = [UIColor blackColor];
        _replyerNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _replyerNameLabel;
}

- (UILabel *)replyerNameSuffixLabel {
    if (_replyerNameSuffixLabel == nil) {
        _replyerNameSuffixLabel = [[UILabel alloc] init];
        _replyerNameSuffixLabel.textColor = [UIColor blackColor];
        _replyerNameSuffixLabel.font = [UIFont systemFontOfSize:14];
        _replyerNameSuffixLabel.text = @"回复了此帖";
    }
    return _replyerNameSuffixLabel;
}

- (UILabel *)replyCountLabel {
    if (_replyCountLabel == nil) {
        _replyCountLabel = [[UILabel alloc] init];
        _replyCountLabel.textColor = RGBCOLOR(173, 171, 204);
        _replyCountLabel.font = [UIFont systemFontOfSize:14];
    }
    return _replyCountLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = RGBCOLOR(246, 247, 249);
        self.backgroundColor = [UIColor themeColorValue14];
        [self addSubview:self.replyerAvatarImageView];
        [self addSubview:self.replyerNameLabel];
        [self addSubview:self.replyerNameSuffixLabel];
        [self addSubview:self.replyCountLabel];
    }
    return self;
}

- (void)updateWithComment:(GFCommentMTL *)comment {
    _comment = comment;
    
    if (!comment) return;
    
    if ([comment.children count] > 0) {
        GFCommentMTL *subComment = comment.children[0];
        [self.replyerAvatarImageView setImageWithURL:[NSURL URLWithString:[subComment.user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES]] placeholder:[UIImage imageNamed:@"default_avatar_2"]];
        self.replyerNameLabel.text = subComment.user.nickName;
        
        NSString *replyCountString = comment.commentInfo.replyCountTotal.integerValue < 1000 ? [comment.commentInfo.replyCountTotal stringValue] : @"1000+";
        self.replyCountLabel.text = [NSString stringWithFormat:@"查看%@条回复", replyCountString];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.replyerAvatarImageView.frame = ({
        CGRect rect;
        rect.size = CGSizeMake(24, 24);
        rect.origin.x = 9;
        rect.origin.y = (self.height - rect.size.height) / 2.;
        rect;
    });

    [self.replyCountLabel sizeToFit];
    self.replyCountLabel.x = self.width - 5 - self.replyCountLabel.width;
    self.replyCountLabel.centerY = self.height / 2.;
    
    [self.replyerNameLabel sizeToFit];
    [self.replyerNameSuffixLabel sizeToFit];
    self.replyerNameLabel.centerY = self.replyerNameSuffixLabel.centerY = self.replyCountLabel.centerY;
    self.replyerNameLabel.x = self.replyerAvatarImageView.right + 12;
    if (self.replyerNameLabel.x + self.replyerNameLabel.width + self.replyerNameSuffixLabel.width + 30 > self.replyCountLabel.x) {
        self.replyerNameLabel.width = self.replyCountLabel.x - 30 - self.replyerNameSuffixLabel.width - self.replyerNameLabel.x;
    }
    self.replyerNameSuffixLabel.x = self.replyerNameLabel.right;
}

@end


@interface GFUserCommentCell ()
@property (nonatomic, strong, readwrite) GFUserInfoHeader *userInfoHeader;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) NSMutableArray *imageViewList;
@property (nonatomic, strong) GFReplyInfoView *replyInfoView;

@end

@implementation GFUserCommentCell
- (GFUserInfoHeader *)userInfoHeader {
    if (!_userInfoHeader) {
        _userInfoHeader = [[GFUserInfoHeader alloc] initWithFrame:CGRectZero];
        [_userInfoHeader setBottomLineHidden:YES];
    }
    return _userInfoHeader;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[self class] contentLabel];
    }
    return _contentLabel;
}

+ (UILabel *)contentLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    return label;
}

+ (NSAttributedString *)attributedContentString:(NSString *)content withParentUserName:(NSString *)name {
    
    if (!content) return nil;
    if ([content length] == 0) return nil;
    
    NSString *replyString = @"";
    if (name && [name length] > 0) {
        replyString = @"回复";
        content = [NSString stringWithFormat:@"：%@", content];
    } else {
        name = @"";
    }
    
    NSUInteger replyLength = [replyString length];
    NSUInteger nameLength = [name length];
    NSUInteger contentLength = [content length];
    NSString *fullText = [NSString stringWithFormat:@"%@%@%@", replyString, name, content];
    
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:fullText];
    //字体
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, replyLength + nameLength + contentLength)];
    //颜色
    UIColor *color1 = [UIColor textColorValue8];
    [attributedContent addAttribute:NSForegroundColorAttributeName value:color1 range:NSMakeRange(replyLength, nameLength)];
    UIColor *color2 = [UIColor textColorValue1];
    [attributedContent addAttribute:NSForegroundColorAttributeName value:color2 range:NSMakeRange(replyLength + nameLength, contentLength)];
    [attributedContent addAttribute:NSForegroundColorAttributeName value:color2 range:NSMakeRange(0, replyLength)];
    //行距
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3.0f;
    style.alignment = NSTextAlignmentLeft;
    [attributedContent addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, nameLength + contentLength)];
    
    return attributedContent;
}

- (NSMutableArray *)imageViewList {
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _imageViewList;
}

- (GFReplyInfoView *)replyInfoView {
    if (!_replyInfoView) {
        _replyInfoView = [[GFReplyInfoView alloc] initWithFrame:CGRectZero];
    }
    return _replyInfoView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.contentLabel.attributedText = nil;
    [self.imageViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewList removeAllObjects];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.userInfoHeader];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.replyInfoView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return [self heightWithModel:model indent:NO shouldShowReplyInfo:YES];
}

+ (CGFloat)heightWithModel:(id)model indent:(BOOL)indent shouldShowReplyInfo:(BOOL)show {
    
    GFCommentMTL *comment = model;
    
    CGFloat maxWidth = indent ? SCREEN_WIDTH - kPaddingWidth*2 - kIndentWidth*2 : SCREEN_WIDTH - kPaddingWidth*2 - kIndentWidth;
    
    CGFloat height = kUserInfoHeaderHeight; // userInfoHeader
    if (comment.commentInfo.commentContent) {
        
        GFCommentMTL *parentComment = comment.parent;
        NSString *parentName = parentComment ? parentComment.user.nickName : nil;
        NSAttributedString *attributedComment = [self attributedContentString:comment.commentInfo.commentContent withParentUserName:parentName];
        UILabel *contentLabel = [self contentLabel];
        contentLabel.attributedText = attributedComment;
        
        CGSize size = [contentLabel sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
        height += size.height + kContentTopSpacing;
    }
    
    if ([comment.commentInfo.pictureKeys count] > 0) {
        NSInteger numberOfRows = ([comment.commentInfo.pictureKeys count] + 2) / 3;
        CGFloat pictureWH = (maxWidth - kPictureGapWidth * 2) / 3;
        height += pictureWH * numberOfRows + kPictureGapWidth * (numberOfRows - 1) + kPictureTopSpacing;
    } else if ([comment.commentInfo.emotionIds count] > 0) {
        NSInteger numberOfRows = ([comment.commentInfo.emotionIds count] + 2) / 3;
        CGFloat pictureWH = (maxWidth - kPictureGapWidth * 2) / 3;
        height += pictureWH * numberOfRows + kPictureGapWidth * (numberOfRows - 1) + kPictureTopSpacing;
    }
    
    if (show) {
        if ([comment.children count] > 0) {
            height += kReplyInfoTopSpacing + kReplyInfoHeight;
        }
    }
    
    return height += kCellBottomSpacing;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    [self bindWithModel:model contentUserId:nil];
}

- (void)bindWithModel:(id)model contentUserId:(NSNumber *)userId {
    
    [super bindWithModel:model];
    
    [self.imageViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewList removeAllObjects];
    
    GFCommentMTL *comment = model;
    
    [self.userInfoHeader setUserInfo:comment.user];
    [self.userInfoHeader setDate:[comment.commentInfo.createTime longLongValue]/1000];
    
    // 判断是否楼主，显示楼主图标
    if (userId && comment.user.userId && [userId isEqualToNumber:comment.user.userId]) {
        [self.userInfoHeader setOriginPoster:YES];
    } else {
        [self.userInfoHeader setOriginPoster:NO];
    }
    [self.userInfoHeader setFunned:comment.loginUserHasFuned count:[comment.commentInfo.funCount integerValue]];
    
    GFCommentMTL *parentComment = comment.parent;
    NSString *parentName = parentComment ? parentComment.user.nickName : nil;
    
    NSAttributedString *attributedContent = [[self class] attributedContentString:comment.commentInfo.commentContent
                                                               withParentUserName:parentName];
    
    self.contentLabel.attributedText = attributedContent;
    if ([comment.commentInfo.pictureKeys count] > 0) {

        for (NSString *pictureKey in comment.commentInfo.pictureKeys) {

            NSInteger index = [comment.commentInfo.pictureKeys indexOfObject:pictureKey];
                        
            GFPictureMTL *picture = [comment.pictures objectForKey:pictureKey];
            NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeFeedThreePictures gifConverted:YES];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.userInteractionEnabled = YES;
            [imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.tag = index;
            [self.imageViewList addObject:imageView];
            __weak typeof(self) weakSelf = self;
            [imageView bk_whenTapped:^{
                if (weakSelf.tapImageHandler) {
                    weakSelf.tapImageHandler(weakSelf, index);
                }
            }];
            
            [self.contentView addSubview:imageView];
        }
    } else if ([comment.commentInfo.emotionIds count] > 0) {
        for (NSString *emotionId in comment.commentInfo.emotionIds) {
            
            NSInteger index = [comment.commentInfo.emotionIds indexOfObject:emotionId];
            
            GFEmotionMTL *emotion = [comment.emotions objectForKey:[NSString stringWithFormat:@"%@", emotionId]];
            NSString *url = [emotion.imgUrl gf_urlStandardizedWithType:GFImageStandardizedTypeFeedThreePictures gifConverted:YES];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.userInteractionEnabled = YES;
            [imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.tag = index;
            [self.imageViewList addObject:imageView];
            [self.contentView addSubview:imageView];
        }
    }
    
    if (self.shouldShowReplyInfo && [comment.children count] > 0) {
        self.replyInfoView.hidden = NO;
        [self.replyInfoView updateWithComment:comment];
    } else {
        self.replyInfoView.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat userInfoHeaderX = self.shouldIndent ? kIndentWidth : 0;
    self.userInfoHeader.frame = CGRectMake(userInfoHeaderX, 0, self.contentView.width - userInfoHeaderX, kUserInfoHeaderHeight);
    
    CGFloat maxWidth = self.shouldIndent ? SCREEN_WIDTH - kPaddingWidth*2 - kIndentWidth*2 : SCREEN_WIDTH - kPaddingWidth*2 - kIndentWidth;
    CGFloat pictureWH = (maxWidth - kPictureGapWidth * 2) / 3;
    CGFloat contentX = self.shouldIndent ? kPaddingWidth + kIndentWidth*2 : kPaddingWidth + kIndentWidth;
    
    GFCommentMTL *comment = self.model;
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
    self.contentLabel.frame = CGRectMake(contentX, self.userInfoHeader.bottom + kContentTopSpacing, maxWidth, size.height);

    CGFloat replyInfoViewY = self.contentLabel.bottom + kReplyInfoTopSpacing;
    for (UIImageView *imageView in self.imageViewList) {
        NSInteger index = [self.imageViewList indexOfObject:imageView];
        NSInteger row = index / 3;
        NSInteger column = index % 3;
        
        CGFloat x = contentX + column * (pictureWH + kPictureGapWidth);
        CGFloat y = row * (pictureWH + kPictureGapWidth) + self.contentLabel.bottom + kPictureTopSpacing;
        imageView.frame = CGRectMake(x, y, pictureWH, pictureWH);
        replyInfoViewY = imageView.bottom + kReplyInfoTopSpacing;
    }
    
    if (self.shouldShowReplyInfo && [comment.children count] > 0) {
        self.replyInfoView.frame = CGRectMake(contentX - 9, replyInfoViewY, maxWidth + 9, kReplyInfoHeight); //9为头像距边缘距离，要求使头像和上面文字左对齐，同时右侧边距保持不变
    }
}

#pragma mark - GFImageGroupDelegate
- (NSArray<UIView *> *)pictureViews {
    return self.imageViewList;
}

@end
