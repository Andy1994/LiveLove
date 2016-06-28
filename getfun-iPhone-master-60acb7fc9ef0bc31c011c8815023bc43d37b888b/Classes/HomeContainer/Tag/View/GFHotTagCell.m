//
//  GFHotTagCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/16.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFHotTagCell.h"
#import "GFAvatarView.h"
#import "GFTagMTL.h"
#import "GFContentMTL.h"

#define kHotTagContentViewWidth ((SCREEN_WIDTH - 15 - 15 - 10) / 2)
#define kContentImageViewWHRatio (336.0f/192.0f)
static const CGFloat kAvatarWH = 17.0f;

@interface GFHotTagContentView : UIView
+ (CGFloat)heightWithContent:(GFContentMTL *)content;
- (void)updateWithContent:(GFContentMTL *)content;
@end

@interface GFHotTagContentView ()
@property (nonatomic, strong) YYAnimatedImageView *contentImageView;
@property (nonatomic, strong) UILabel *contentTitleLabel;
@property (nonatomic, strong) GFAvatarView *userAvatarImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@end

@implementation GFHotTagContentView
- (YYAnimatedImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _contentImageView.image = [UIImage imageNamed:@"placeholder_image"];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
    }
    return _contentImageView;
}

- (UILabel *)contentTitleLabel {
    if (!_contentTitleLabel) {
        _contentTitleLabel = [[self class] contentTitleLabel];
    }
    return _contentTitleLabel;
}

+ (UILabel *)contentTitleLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    return label;
}

+ (NSAttributedString *)attributedContentTitle:(NSString *)contentTitle {
    if (!contentTitle) return nil;
    
    NSMutableAttributedString *attributedContentTitle = [[NSMutableAttributedString alloc] initWithString:contentTitle];
    NSUInteger textLength = [contentTitle length];
    //字体
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    [attributedContentTitle addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textLength)];
    //颜色
    UIColor *color = [UIColor textColorValue1];
    [attributedContentTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, textLength)];
    //行距
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3.0f;
    style.alignment = NSTextAlignmentLeft;
    [attributedContentTitle addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textLength)];
    
    return attributedContentTitle;
}

- (GFAvatarView *)userAvatarImageView {
    if (!_userAvatarImageView) {
        _userAvatarImageView = [[GFAvatarView alloc] initWithFrame:CGRectMake(0, 0, kAvatarWH, kAvatarWH)];
        _userAvatarImageView.isUserInterestColorShowed = NO;
    }
    return _userAvatarImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNameLabel.textColor = [UIColor textColorValue3];
        _userNameLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _userNameLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.0f;
        self.layer.borderColor = [UIColor themeColorValue15].CGColor;
        self.layer.borderWidth = 0.5f;
        [self addSubview:self.contentImageView];
        [self addSubview:self.contentTitleLabel];
        [self addSubview:self.userAvatarImageView];
        [self addSubview:self.userNameLabel];
    }
    return self;
}

+ (CGFloat)heightWithContent:(GFContentMTL *)content {
    
    CGFloat height = 0;
    CGFloat contentImageHeight = kHotTagContentViewWidth / kContentImageViewWHRatio;
    height += contentImageHeight;
    
    UILabel *contentTitleLabel = [self contentTitleLabel];
    contentTitleLabel.attributedText = [self attributedContentTitle:content.contentSummary.title];
    CGSize size = [contentTitleLabel sizeThatFits:CGSizeMake(kHotTagContentViewWidth-14, MAXFLOAT)];
    height += 8 + size.height + 8 + 17 + 8;
    
    return height;
}

- (void)updateWithContent:(GFContentMTL *)content {
    
    if (content.contentInfo.type != GFContentTypeArticle) {
        DDLogVerbose(@"%s%s, GFContentMTL should be article type : %@", __FILE__, __PRETTY_FUNCTION__, content);
    } else {
        
        GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)content.contentSummary;

        NSString *imageKey = nil;
        if ([articleSummary.pictureSummary count] > 0) {
            imageKey = [articleSummary.pictureSummary firstObject];
        }
        if (imageKey) {
            GFPictureMTL *picture = [content.pictures objectForKey:imageKey];
            if (picture.url) {
                AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
                BOOL convertGIF = NO;
                if (status != AFNetworkReachabilityStatusReachableViaWiFi && picture.format == GFPictureFormatGIF) {
                    convertGIF = YES;
                }
                NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeHotTag gifConverted:convertGIF];
                [self.contentImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
            } else {
                self.contentImageView.image = [UIImage imageNamed:@"placeholder_image"];
            }
        }
        
        self.contentTitleLabel.attributedText = [[self class] attributedContentTitle:content.contentSummary.title];
        
        [self.userAvatarImageView updateWithUser:content.user];
        self.userNameLabel.text = content.user.nickName;
        [self.userNameLabel sizeToFit];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentImageView.frame = CGRectMake(0, 0, self.width, kHotTagContentViewWidth / kContentImageViewWHRatio);
    
    CGFloat maxWidth = kHotTagContentViewWidth - 14;
    CGSize size = [self.contentTitleLabel sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
    self.contentTitleLabel.frame = CGRectMake(7, self.contentImageView.bottom + 8, size.width, size.height);
    
    self.userAvatarImageView.frame = CGRectMake(7, self.height-8-17, kAvatarWH, kAvatarWH);
    
    CGFloat maxNameWidth = maxWidth - self.userAvatarImageView.right - 6;
    CGSize nameSize = [self.userNameLabel sizeThatFits:CGSizeMake(maxNameWidth, MAXFLOAT)];
    self.userNameLabel.size = CGSizeMake(MIN(maxNameWidth, nameSize.width), nameSize.height);

    self.userNameLabel.center = CGPointMake(self.userAvatarImageView.right + 6 + self.userNameLabel.width/2, self.userAvatarImageView.centerY);
}

@end

@interface GFHotTagCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *collectionLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@property (nonatomic, strong) GFHotTagContentView *leftContentView;
@property (nonatomic, strong) GFHotTagContentView *rightContentView;

@end

@implementation GFHotTagCell
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _titleLabel.textColor = [UIColor textColorValue1];
    }
    return _titleLabel;
}

- (UILabel *)collectionLabel {
    if (!_collectionLabel) {
        _collectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _collectionLabel.font = [UIFont systemFontOfSize:14.0f];
        _collectionLabel.textColor = [UIColor textColorValue4];
    }
    return _collectionLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
    }
    return _accessoryImageView;
}

- (GFHotTagContentView *)leftContentView {
    if (!_leftContentView) {
        _leftContentView = [[GFHotTagContentView alloc] initWithFrame:CGRectZero];
    }
    return _leftContentView;
}

- (GFHotTagContentView *)rightContentView {
    if (!_rightContentView) {
        _rightContentView = [[GFHotTagContentView alloc] initWithFrame:CGRectZero];
    }
    return _rightContentView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.collectionLabel];
        [self.contentView addSubview:self.accessoryImageView];
        [self.contentView addSubview:self.leftContentView];
        [self.contentView addSubview:self.rightContentView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    CGFloat height = 0.0f;
    height += 40; // header
    
    CGFloat contentViewHeight = 0;
    for (GFContentMTL *content in [(GFTagMTL *)model contents]) {
        CGFloat tmpHeight = [GFHotTagContentView heightWithContent:content];
        if (tmpHeight > contentViewHeight) {
            contentViewHeight = tmpHeight;
        }
    }
    height += contentViewHeight;
    height += 15.0f;
    
    return height;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFTagMTL *tag = (GFTagMTL *)model;
    
    self.titleLabel.text = tag.tagInfo.tagName;
    
    NSInteger collectUserCount = [tag.tagInfo.userCount integerValue];
    self.collectionLabel.hidden = self.accessoryImageView.hidden = (collectUserCount == 0);
    
    NSString *collectionText = [NSString stringWithFormat:@"%@关注", tag.tagInfo.userCount];
    self.collectionLabel.text = collectionText;
    
    self.leftContentView.hidden = [tag.contents count] < 1;
    self.rightContentView.hidden = [tag.contents count] < 2;
    
    if ([tag.contents count] > 0) {
        [self.leftContentView updateWithContent:[tag.contents objectAtIndex:0]];
    }
    
    if ([tag.contents count] > 1) {
        [self.rightContentView updateWithContent:[tag.contents objectAtIndex:1]];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(15 + self.titleLabel.width/2, 20);
    
    self.accessoryImageView.center = CGPointMake(self.contentView.width-15-self.accessoryImageView.width/2, self.titleLabel.centerY);
    
    [self.collectionLabel sizeToFit];
    self.collectionLabel.center = CGPointMake(self.accessoryImageView.x - self.collectionLabel.width/2, self.titleLabel.centerY);
    
    CGFloat leftContentViewHeight = 0;
    CGFloat rightContentViewHeight = 0;
    GFTagMTL *tag = self.model;
    if ([tag.contents count] > 0) {
        GFContentMTL *content = [tag.contents objectAtIndex:0];
        leftContentViewHeight = [GFHotTagContentView heightWithContent:content];
    }
    if ([tag.contents count] > 1) {
        GFContentMTL *content = [tag.contents objectAtIndex:1];
        rightContentViewHeight = [GFHotTagContentView heightWithContent:content];
    }
    
    CGFloat contentViewHeight = MAX(leftContentViewHeight, rightContentViewHeight);
    self.leftContentView.frame = CGRectMake(15, 40, kHotTagContentViewWidth, contentViewHeight);
    self.rightContentView.frame = CGRectMake(self.leftContentView.right + 10, 40, kHotTagContentViewWidth, contentViewHeight);
}
@end
