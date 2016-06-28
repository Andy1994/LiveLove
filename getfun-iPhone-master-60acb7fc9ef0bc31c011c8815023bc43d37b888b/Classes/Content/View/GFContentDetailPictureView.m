//
//  GFContentDetailPictureView.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFContentDetailPictureView.h"
#import "GFContentDetailTagContainerView.h"

#define kTitleTopSpacing 15.0f
#define kPadding 15.0f

@interface GFContentDetailPictureView ()

@property (nonatomic, strong) GFContentMTL *content;

@property (nonatomic, strong) GFContentDetailUserInfoView *userInfoView;
@property (nonatomic, strong) GFContentDetailTagContainerView *tagContainer;
@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) NSMutableArray *imageViewList;

@end

@implementation GFContentDetailPictureView
- (GFContentDetailUserInfoView *)userInfoView {
    if (!_userInfoView) {
        _userInfoView = [[GFContentDetailUserInfoView alloc] init];
    }
    return _userInfoView;
}

- (GFContentDetailTagContainerView *)tagContainer {
    if (_tagContainer == nil) {
        _tagContainer = [[GFContentDetailTagContainerView alloc] init];
    }
    return _tagContainer;
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

+ (NSAttributedString *)attributedTitleString:(NSString *)title {
    
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

- (NSMutableArray *)imageViewList {
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _imageViewList;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.userInfoView];
        [self addSubview:self.tagContainer];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)dealloc {
    [_userInfoView removeFromSuperview];
    _userInfoView = nil;
    
    [_tagContainer removeFromSuperview];
    _tagContainer = nil;
}

+ (CGFloat)viewHeightWithContent:(GFContentMTL *)content {
    CGFloat height = 64 + kContentDetailUserInfoViewHeight;
    
    height += [GFContentDetailTagContainerView heightWithModel:content] + 5;
    
    CGFloat maxContentWidth = SCREEN_WIDTH - 2 * kPadding;
    //详情页图帖需要使用content作为标题
    if (content.contentDetail.content) {
        NSAttributedString *attributedTitle = [self attributedTitleString:content.contentDetail.content];
        UILabel *contentLabel = [self contentLabel];
        contentLabel.attributedText = attributedTitle;
        CGSize size = [contentLabel sizeThatFits:CGSizeMake(maxContentWidth, MAXFLOAT)];
        height += size.height + kTitleTopSpacing;
    }
    
    GFContentDetailPictureMTL *pictureDetail = (GFContentDetailPictureMTL *)content.contentDetail;
    for (NSString *pictureKey in pictureDetail.pictureSummary) {
        GFPictureMTL *picture = [content.pictures objectForKey:pictureKey];
        CGFloat scaleFactor = MAX(picture.width, maxContentWidth) / maxContentWidth;
        height += picture.height / scaleFactor;
    }
    
    height += kPadding * [pictureDetail.pictureSummary count];
    
    return height;
}

- (void)updateContent:(GFContentMTL *)content {
    _content = content;
    
    [self.imageViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.userInfoView bindModel:content];
    self.tagContainer.content = content;
    
    if (content.contentDetail.content) {
        self.contentLabel.attributedText = [[self class] attributedTitleString:content.contentDetail.content];
    }
    
    CGFloat maxContentWidth = SCREEN_WIDTH - 2 * kPadding;
    GFContentDetailPictureMTL *pictureDetail = (GFContentDetailPictureMTL *)content.contentDetail;
    for (NSString *pictureKey in pictureDetail.pictureSummary) {
        
        NSInteger index = [pictureDetail.pictureSummary indexOfObject:pictureKey];
        
        GFPictureMTL *picture = [content.pictures objectForKey:pictureKey];
        
        CGFloat scaleFactor = MAX(picture.width, maxContentWidth) / maxContentWidth;
        
        CGFloat pictureWidth = picture.width/scaleFactor;
        CGFloat pictureHeight = picture.height/scaleFactor;
        
        AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
        BOOL convertGIF = NO;
        if (status != AFNetworkReachabilityStatusReachableViaWiFi && picture.format == GFPictureFormatGIF) {
            convertGIF = YES;
        }
        NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeContentDetailPicture gifConverted:convertGIF];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pictureWidth, pictureHeight)];
        imageView.userInteractionEnabled = YES;
        imageView.tag = index;
        [imageView setImageURL:[NSURL URLWithString:url]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.imageViewList addObject:imageView];
        __weak typeof(self) weakSelf = self;
        [imageView bk_whenTapped:^{
            if (weakSelf.tapImageHandler) {
                weakSelf.tapImageHandler(index);
            }
        }];
        
        [self addSubview:imageView];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat maxContentWidth = SCREEN_WIDTH - 2 * kPadding;

    self.userInfoView.frame = CGRectMake(0, 64, SCREEN_WIDTH, kContentDetailUserInfoViewHeight);
    self.tagContainer.frame = CGRectMake(0, self.userInfoView.bottom + 5, SCREEN_WIDTH, [GFContentDetailTagContainerView heightWithModel:self.content]);
    
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(maxContentWidth, MAXFLOAT)];
    self.contentLabel.frame = CGRectMake(kPadding, self.tagContainer.bottom + kTitleTopSpacing, size.width, size.height);
    
    CGFloat imageViewY = self.contentLabel.bottom + kPadding;
    for (UIImageView *imageView in self.imageViewList) {
        imageView.origin = CGPointMake(kPadding, imageViewY);
        imageViewY = imageView.bottom + kPadding;
    }
}

#pragma mark - GFImageGroupDelegate
- (NSArray<UIView *> *)pictureViews {
    return self.imageViewList;
}
@end
