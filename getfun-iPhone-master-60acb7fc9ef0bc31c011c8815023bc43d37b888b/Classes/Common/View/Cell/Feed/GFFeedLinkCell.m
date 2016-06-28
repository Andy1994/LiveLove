//
//  GFFeedLinkCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedLinkCell.h"

#define kTitleTopSpacing        15.0f
#define kTitleCharactersMaxCount 67 //后面还会有三个省略号，一共是70个
#define kLinkSummaryTopSpacing  10.0f
#define kLinkSummaryHeight      83.0f
#define kLinkFooterTopSpacing 0.0f

@interface GFFeedLinkSummaryView : UIView
- (void)updateWithContent:(GFContentMTL *)content;
@end

@interface GFFeedLinkSummaryView ()

@property (nonatomic, strong) GFContentMTL *content;

@property (nonatomic, strong) UIImageView *picImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation GFFeedLinkSummaryView

- (UIImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _picImageView.clipsToBounds = YES;
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _picImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor textColorValue1];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.textColor = [UIColor textColorValue3];
    }
    return _subtitleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2.0f;
        self.backgroundColor = [UIColor themeColorValue14];
        
        [self addSubview:self.picImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)updateWithContent:(GFContentMTL *)content {
    
    if (content.contentInfo.type != GFContentTypeLink) return;
    
    GFContentSummaryLinkMTL *linkSummary = (GFContentSummaryLinkMTL *)content.contentSummary;
    GFPictureMTL *picture = [content.pictures objectForKey:linkSummary.urlImageUrl];
    
    NSString *urlTitle = linkSummary.urlTitle;
    if ([urlTitle length] == 0) {
        if (linkSummary.hasVideo){
            urlTitle = @"分享一条有意思的视频";
        }else{
            urlTitle = @"分享一条有意思的内容";
        }
    }
    //视频帖单独显示占位图
    UIImage *placeholderImage = linkSummary.hasVideo ? [UIImage imageNamed:@"placeholder_link_video"] : [UIImage imageNamed:@"placeholder_link_image"];
    [self.picImageView setImageWithURL:[NSURL URLWithString:[picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeFeedLink gifConverted:YES]] placeholder:placeholderImage];
    self.titleLabel.text = urlTitle;
    
    NSString *urlSummary = linkSummary.urlSummary;
    if ([urlSummary length] == 0) {
        urlSummary = linkSummary.url;
    }
    self.subtitleLabel.text = urlSummary;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.picImageView.frame = CGRectMake(0, 0, self.height, self.height);
    
    CGFloat width = self.width-22-83-13;
    
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    CGSize subTitleSize = [self.subtitleLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    
    self.titleLabel.frame = CGRectMake(self.picImageView.right + 13.0f,
                                       self.height/2 - subTitleSize.height/2 - titleSize.height/2 - 4,
                                       width,
                                       titleSize.height);
    self.subtitleLabel.frame = CGRectMake(self.picImageView.right + 13.0f,
                                          self.height/2 + titleSize.height/2 - subTitleSize.height/2 + 4,
                                          width,
                                          subTitleSize.height);
}
@end


@interface GFFeedLinkCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) GFFeedLinkSummaryView *linkSummaryView;

@end

@implementation GFFeedLinkCell

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor textColorValue1];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

+ (NSString *)textForTitle:(NSString *)text {
    if (!text || [text length] == 0) {
        return nil;
    }
    
    NSString *title = text;
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([title length] > kTitleCharactersMaxCount + 3) { //显示三个省略号
        title = [[title substringWithRange:NSMakeRange(0, kTitleCharactersMaxCount)] stringByAppendingString:@"..."];
    }
    return title;
}

- (GFFeedLinkSummaryView *)linkSummaryView {
    if (!_linkSummaryView) {
        _linkSummaryView = [[GFFeedLinkSummaryView alloc] initWithFrame:CGRectZero];
    }
    return _linkSummaryView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.linkSummaryView];
    }
    return self;
}

- (void)dealloc {
    [_linkSummaryView removeFromSuperview];
    _linkSummaryView = nil;
}

- (void)hideContentView:(BOOL)hide {
    self.titleLabel.hidden = hide;
    self.linkSummaryView.hidden = hide;
}

+ (CGFloat)heightWithModel:(id)model {
    
    if (!model || ![model isKindOfClass:[GFContentMTL class]]) {
        return 0.0f;
    }
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypeLink) {
        return 0.0f;
    }
    
    CGFloat height = kUserInfoHeaderHeight;
    
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        GFContentSummaryLinkMTL *linkSummary = (GFContentSummaryLinkMTL *)contentMTL.contentSummary;
        if ([linkSummary.title length] > 0) {
            UILabel *tmpLabel = [[UILabel alloc] init];
            tmpLabel.font = [UIFont systemFontOfSize:18.0f];
            tmpLabel.numberOfLines = 0;
            tmpLabel.text = [[self class] textForTitle:linkSummary.title];
            CGSize size = [tmpLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-34, MAXFLOAT)];
            height += kTitleTopSpacing + size.height;
        }
        
        height += kLinkSummaryTopSpacing + kLinkSummaryHeight;
    }
    
    height += kLinkFooterTopSpacing + [GFContentInfoFooter heightWithContent:contentMTL];
    
    return height;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypeLink) {
        return;
    }
    
    [self.userInfoHeader setUserInfo:contentMTL.user];
    if ([contentMTL.tags count] > 0) {
        [self.userInfoHeader setTagInfo:[contentMTL.tags objectAtIndex:0]];
    } else {
        [self.userInfoHeader setTagInfo:nil];
    }
    
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted){
        [self hideContentView:NO];
        GFContentSummaryLinkMTL *linkSummary = (GFContentSummaryLinkMTL *)contentMTL.contentSummary;
        self.titleLabel.text = [[self class] textForTitle:linkSummary.title];
        [self.linkSummaryView updateWithContent:contentMTL];
        
    } else {
        [self hideContentView:YES];
    }
    
    [self.contentInfoFooter updateWithContent:contentMTL];
}

- (void)markRead {
    [super markRead];
    self.titleLabel.textColor = [UIColor textColorValue3];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.textColor = [UIColor textColorValue1];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    GFContentMTL *contentMTL = self.model;
    
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        GFContentSummaryLinkMTL *linkSummary = (GFContentSummaryLinkMTL *)contentMTL.contentSummary;
        self.titleLabel.frame = ({
            CGFloat y = self.userInfoHeader.bottom + ([linkSummary.title length] > 0 ? kTitleTopSpacing : 0);
            CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-34, MAXFLOAT)];
            CGRect rect = CGRectMake(17, y, SCREEN_WIDTH-34, size.height);
            rect;
        });
        
        self.linkSummaryView.frame = CGRectMake(17, self.titleLabel.bottom + kLinkSummaryTopSpacing, self.contentView.width-34, kLinkSummaryHeight);
        
        self.contentInfoFooter.frame = CGRectMake(0, self.linkSummaryView.bottom + kLinkFooterTopSpacing, self.contentView.width, [GFContentInfoFooter heightWithContent:contentMTL]);
        
    } else {
        self.contentInfoFooter.frame = CGRectMake(0, self.userInfoHeader.bottom + kLinkFooterTopSpacing, self.contentView.width, [GFContentInfoFooter heightWithContent:contentMTL]);
    }
}
@end
