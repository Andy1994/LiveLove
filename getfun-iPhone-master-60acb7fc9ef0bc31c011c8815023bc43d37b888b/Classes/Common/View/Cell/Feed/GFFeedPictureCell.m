//
//  GFFeedPictureCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedPictureCell.h"

#define kImageSpacing       4.0f
#define kTitleTopSpacing    15.0f
#define kImageTopSpacing    15.0f
#define kImageHeight        110.0f
#define kImageBottomSpacing 0.0f

@interface GFFeedPictureCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel; // 标题
@property (nonatomic, strong) UIScrollView *pictureScrollView;

@end

@implementation GFFeedPictureCell

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

+ (NSAttributedString *)attributedTitle:(NSString *)title{
    if (!title || [title length] == 0) {
        return nil;
    }

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
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.pictureScrollView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    if (!model || ![model isKindOfClass:[GFContentMTL class]]) {
        return 0.0f;
    }
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypePicture) {
        return 0.0f;
    }
    
    CGFloat height = kUserInfoHeaderHeight;
    
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        GFContentSummaryPictureMTL *pictureSummary = (GFContentSummaryPictureMTL *)contentMTL.contentSummary;
        //标题为空时默认显示图片张数，因此标题一定存在
        if ([pictureSummary.title length] > 0) {
            height += kTitleTopSpacing;
            UILabel *tmpLabel = [self titleLabel];
            tmpLabel.attributedText = [self attributedTitle:pictureSummary.title];
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
    GFContentSummaryPictureMTL *pictureSummary = (GFContentSummaryPictureMTL *)content.contentSummary;
    if ([pictureSummary.pictureSummary count] == 1) {
        CGFloat width = SCREEN_WIDTH - 30;
        size  = CGSizeMake(width, width * 3 / 4);
    } else if ([pictureSummary.pictureSummary count] == 2) {
        CGFloat width = (SCREEN_WIDTH - 30 - kImageSpacing)/2;
        size = CGSizeMake(width, width * 3 / 4);
    } else if ([pictureSummary.pictureSummary count] >= 3) {
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
    self.titleLabel.hidden = hide;
    self.pictureScrollView.hidden = hide;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypePicture) {
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
        
        GFContentSummaryPictureMTL *pictureSummary = (GFContentSummaryPictureMTL *)contentMTL.contentSummary;
        if(pictureSummary) {
            self.titleLabel.attributedText = [[self class] attributedTitle:pictureSummary.title];
            for (NSString *urlKey in pictureSummary.pictureSummary) {
                
                NSInteger index = [pictureSummary.pictureSummary indexOfObject:urlKey];
                
                YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
                imageView.userInteractionEnabled = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                imageView.tag = index;
                imageView.image = [UIImage imageNamed:@"placeholder_picPost_image"];
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
    GFContentSummaryPictureMTL *pictureSummary = (GFContentSummaryPictureMTL *)contentMTL.contentSummary;
    
    for (YYAnimatedImageView *imageView in [self.pictureScrollView subviews]) {
        
        NSInteger index = imageView.tag;
        CGRect rect = [self.pictureScrollView convertRect:imageView.frame toView:[UIApplication sharedApplication].keyWindow];
        
        if (CGRectGetMinX(rect) < SCREEN_WIDTH && CGRectGetMaxX(rect) > 0) {
            NSString *urlKey = [pictureSummary.pictureSummary objectAtIndex:index];
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

- (void)markRead {
    [super markRead];
    self.titleLabel.textColor = [UIColor textColorValue3];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    GFContentMTL *contentMTL = self.model;
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        {
            GFContentSummaryPictureMTL *pictureSummary = (GFContentSummaryPictureMTL *)contentMTL.contentSummary;
            CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT)];
            self.titleLabel.frame = CGRectMake(15,
                                               self.userInfoHeader.bottom+([pictureSummary.title length] > 0 ? kTitleTopSpacing : 0),
                                               self.contentView.width-30,
                                               size.height);
        }
        
        CGSize size = [[self class] imageSizeForContent:self.model];
        self.pictureScrollView.frame = CGRectMake(15,
                                                  self.titleLabel.bottom+(size.height > 0 ? kImageTopSpacing : 0),
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
