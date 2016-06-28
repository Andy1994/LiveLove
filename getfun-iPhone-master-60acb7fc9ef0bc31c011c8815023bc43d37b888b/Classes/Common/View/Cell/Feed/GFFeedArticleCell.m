//
//  GFFeedArticleCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedArticleCell.h"

#define kImageSpacing       4.0f
#define kBannerHeight       188.0f
#define kTitleTopSpacing    15.0f
#define kSummaryTopSpacing  8.0f
#define kImageTopSpacing    15.0f
#define kImageHeight        110.0f
#define kImageBottomSpacing 0.0f 

@interface GFFeedArticleCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *bannerImageView; // 大幅图片(通常为编辑上传)
@property (nonatomic, strong) UILabel *titleLabel; // 标题
@property (nonatomic, strong) UILabel *summaryLabel; // 摘要
@property (nonatomic, strong) UIScrollView *pictureScrollView;

@end

@implementation GFFeedArticleCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    if ([self.pictureScrollView superview]) {
        for (UIView *view in [self.pictureScrollView subviews]) {
            if ([view isKindOfClass:[YYAnimatedImageView class]]) {
                [((YYAnimatedImageView *)view) cancelCurrentImageRequest];
            }
        }
    }

    [[self.pictureScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.titleLabel.textColor = [UIColor textColorValue1];
}

- (UIImageView *)bannerImageView {
    if (!_bannerImageView) {
        _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _bannerImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[self class] titleLabel];
    }
    return _titleLabel;
}

+ (UILabel *)titleLabel {
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    lable.backgroundColor = [UIColor clearColor];
    lable.numberOfLines = 2;
    return lable;
}

+ (NSAttributedString *)attributedTitle:(NSString *)title {
    
    if (!title) return nil;
    
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
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

- (UILabel *)summaryLabel {
    if (!_summaryLabel) {
        _summaryLabel = [[self class] summaryLabel];
    }
    return _summaryLabel;
}

+ (UILabel *)summaryLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 2;
    return label;
}

+ (NSAttributedString *)attributedSummary:(NSString *)summary {
    
    if (!summary) return nil;
    
    NSMutableAttributedString *attributedSummary = [[NSMutableAttributedString alloc] initWithString:summary];
    NSUInteger textLength = [summary length];
    
    //字体
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    [attributedSummary addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textLength)];
    //颜色
    UIColor *color = [UIColor textColorValue3];
    [attributedSummary addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, textLength)];
    //行距
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3.0f;
    style.alignment = NSTextAlignmentLeft;
    [attributedSummary addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, textLength)];
    
    return attributedSummary;
}

- (UIScrollView *)pictureScrollView {
    if (!_pictureScrollView) {
        _pictureScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _pictureScrollView.showsHorizontalScrollIndicator = NO;
        _pictureScrollView.showsVerticalScrollIndicator = NO;
        _pictureScrollView.delegate = self;
    }
    return _pictureScrollView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.bannerImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.summaryLabel];
        [self.contentView addSubview:self.pictureScrollView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    if (!model || ![model isKindOfClass:[GFContentMTL class]]) {
        return 0.0f;
    }
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypeArticle) {
        return 0.0f;
    }
    
    CGFloat height = kUserInfoHeaderHeight;
    
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
        height += [articleSummary.imageUrl length] > 0 ? kBannerHeight : 0;
        
        if ([articleSummary.title length] > 0) {
            height += kTitleTopSpacing;
            
            UILabel *tmpLabel = [self titleLabel];
            tmpLabel.attributedText = [self attributedTitle:articleSummary.title];
            CGSize size = [tmpLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT)];
            height += size.height;
        }
        
        if ([articleSummary.summary length] > 0) {
            height += kSummaryTopSpacing;
            
            UILabel *tmpLabel = [self summaryLabel];
            tmpLabel.attributedText = [self attributedSummary:articleSummary.summary];
            CGSize size = [tmpLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT)];
            height += size.height;
        }
        
        CGSize imageSize = [self imageSizeForContent:contentMTL];
        height += imageSize.height > 0 ? kImageTopSpacing+imageSize.height : 0;
    }
    
    height += kImageBottomSpacing + [GFContentInfoFooter heightWithContent:contentMTL];
    
    return height;
}

+ (CGSize)imageSizeForContent:(GFContentMTL *)content {
    
    CGSize size = CGSizeZero;
    GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)content.contentSummary;
    if ([articleSummary.pictureSummary count] == 1) {
        CGFloat width = SCREEN_WIDTH - 30;
        size  = CGSizeMake(width, width * 3 / 4);
    } else if ([articleSummary.pictureSummary count] == 2) {
        CGFloat width = (SCREEN_WIDTH - 30 - kImageSpacing)/2;
        size = CGSizeMake(width, width * 3 / 4);
    } else if ([articleSummary.pictureSummary count] >= 3) {
        size = CGSizeMake(kImageHeight, kImageHeight);
    }
    return size;
}

+ (GFImageStandardizedType)imageStandardizeTypeForContent:(GFContentMTL *)content {
    GFImageStandardizedType type = GFImageStandardizedTypeFeedOnePicture;
    GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)content.contentSummary;
    if ([articleSummary.pictureSummary count] == 1) {
        type = GFImageStandardizedTypeFeedOnePicture;
    } else if ([articleSummary.pictureSummary count] == 2) {
        type = GFImageStandardizedTypeFeedTwoPictures;
    } else if ([articleSummary.pictureSummary count] >= 3) {
        type = GFImageStandardizedTypeFeedThreePictures;
    }
    return type;
}

- (void)hideContent:(BOOL)hide {
    self.bannerImageView.hidden = hide;
    self.titleLabel.hidden = hide;
    self.summaryLabel.hidden = hide;
    self.pictureScrollView.hidden = hide;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypeArticle) {
        return;
    }
    
    [self.userInfoHeader setUserInfo:contentMTL.user];
    if ([contentMTL.tags count] > 0) {
        [self.userInfoHeader setTagInfo:[contentMTL.tags objectAtIndex:0]];
    } else {
        [self.userInfoHeader setTagInfo:nil];
    }
    
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        //控制可见性
        [self hideContent:NO];
        
        GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
        if(articleSummary) {
            [self.bannerImageView setImageWithURL:[NSURL URLWithString:articleSummary.imageUrl] placeholder:nil];

            self.titleLabel.attributedText = [[self class] attributedTitle:articleSummary.title];
            self.summaryLabel.attributedText = [[self class] attributedSummary:articleSummary.summary];
            
            for (NSString *urlKey in articleSummary.pictureSummary) {
                
                NSInteger index = [articleSummary.pictureSummary indexOfObject:urlKey];
                
                YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
                imageView.userInteractionEnabled = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                imageView.tag = index;
                imageView.image = [UIImage imageNamed:@"placeholder_image"];
                __weak typeof(self) weakSelf = self;
                [imageView bk_whenTapped:^{
                    if (weakSelf.tapImageHandler) {
                        weakSelf.tapImageHandler(weakSelf, index);
                    }
                }];
                
                GFPictureMTL *pictureMTL = [contentMTL.pictures objectForKey:urlKey];
                AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
                BOOL convertGIF = NO;
                if (status != AFNetworkReachabilityStatusReachableViaWiFi && pictureMTL.format == GFPictureFormatGIF) {
                    convertGIF = YES;
                }
                
                NSString *url = [pictureMTL.url gf_urlStandardizedWithType:[[self class] imageStandardizeTypeForContent:contentMTL] gifConverted:convertGIF];
                
                //lazy load 只有存在缓存时才设置，否则交由startLoadingImages方法处理
                NSString *cacheKey = [[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
                if ([[YYWebImageManager sharedManager].cache.memoryCache containsObjectForKey:cacheKey]) {
                     [imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
                }
                [self.pictureScrollView addSubview:imageView];
            }
        }
        
    } else {
        //控制可见性
        [self hideContent:YES];
    }
    
    [self.contentInfoFooter updateWithContent:contentMTL];
    
    [self setNeedsLayout];
}

- (void)startLoadingImages {
    
    GFContentMTL *contentMTL = self.model;    
    GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
    
    for (YYAnimatedImageView *imageView in [self.pictureScrollView subviews]) {
        
        NSInteger index = imageView.tag;
        CGRect rect = [self.pictureScrollView convertRect:imageView.frame toView:[UIApplication sharedApplication].keyWindow];
        
        if (CGRectGetMinX(rect) < SCREEN_WIDTH && CGRectGetMaxX(rect) > 0) {
            NSString *urlKey = [articleSummary.pictureSummary objectAtIndex:index];
            GFPictureMTL *pictureMTL = [contentMTL.pictures objectForKey:urlKey];
            
            AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
            BOOL convertGIF = NO;
            if (status != AFNetworkReachabilityStatusReachableViaWiFi && pictureMTL.format == GFPictureFormatGIF) {
                convertGIF = YES;
            }
            NSString *url = [pictureMTL.url gf_urlStandardizedWithType:[[self class] imageStandardizeTypeForContent:contentMTL] gifConverted:convertGIF];
            [imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    GFContentMTL *contentMTL = self.model;
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
        self.bannerImageView.frame = CGRectMake(0,
                                                self.userInfoHeader.bottom,
                                                self.contentView.width,
                                                [articleSummary.imageUrl length] > 0 ? kBannerHeight : 0);
        
        {
            CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT)];
            self.titleLabel.frame = CGRectMake(15,
                                               self.bannerImageView.bottom+([articleSummary.title length] > 0 ? kTitleTopSpacing : 0),
                                               self.contentView.width-30,
                                               size.height);
        }
        
        {
            CGSize size = [self.summaryLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT)];
            self.summaryLabel.frame = CGRectMake(15,
                                                 self.titleLabel.bottom+([articleSummary.summary length] > 0 ? kSummaryTopSpacing : 0),
                                                 self.contentView.width-30,
                                                 size.height);
        }
        
        CGSize size = [[self class] imageSizeForContent:self.model];
        self.pictureScrollView.frame = CGRectMake(15,
                                                  self.summaryLabel.bottom+(size.height > 0 ? kImageTopSpacing : 0),
                                                  self.contentView.width-30,
                                                  size.height);
        CGFloat contentWidth = 0.0f;
        for (YYAnimatedImageView *imageView in [self.pictureScrollView subviews]) {
            NSUInteger index = [[self.pictureScrollView subviews] indexOfObject:imageView];
            imageView.frame = CGRectMake(index * (size.width+kImageSpacing), 0, size.width, size.height);
            contentWidth = imageView.right;
        }
        self.pictureScrollView.contentSize = CGSizeMake(contentWidth, self.pictureScrollView.height);
        self.pictureScrollView.contentOffset = CGPointZero;
        
        self.contentInfoFooter.frame = CGRectMake(0, self.pictureScrollView.bottom + kImageBottomSpacing, self.contentView.width, [GFContentInfoFooter heightWithContent:contentMTL]);
    } else {
        self.contentInfoFooter.frame = CGRectMake(0, self.userInfoHeader.bottom + kImageBottomSpacing, self.contentView.width, [GFContentInfoFooter heightWithContent:contentMTL]);
    }
    
    [self startLoadingImages];
}

- (void)markRead {
    [super markRead];
    self.titleLabel.textColor = [UIColor textColorValue3];
}

#pragma mark - GFImageGroupDelegate
- (NSArray<UIView *> *)pictureViews {
    return [self.pictureScrollView subviews];
}

#pragma mark - UISCrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self startLoadingImages];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self startLoadingImages];
}
@end
