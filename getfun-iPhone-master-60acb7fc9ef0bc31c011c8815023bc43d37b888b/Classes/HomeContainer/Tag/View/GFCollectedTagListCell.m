//
//  GFCollectedTagListCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/15.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFCollectedTagListCell.h"

@interface GFCollectTagView : UIView
@property (nonatomic, strong) UIImageView *tagImageView;
@property (nonatomic, strong) UILabel *updateCountLabel;
@property (nonatomic, strong) UILabel *tagNameLabel;
@property (nonatomic, strong) UIView *maskView; //蒙层遮罩
@end

@implementation GFCollectTagView
- (UIImageView *)tagImageView {
    if (!_tagImageView) {
        _tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 78)];
        _tagImageView.image = [UIImage imageNamed:@"placeholder_image"];
        _tagImageView.contentMode = UIViewContentModeScaleAspectFill;
        _tagImageView.layer.masksToBounds = YES;
        _tagImageView.layer.cornerRadius = 3.0f;
    }
    return _tagImageView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.tagImageView.frame];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _maskView.layer.masksToBounds = YES;
        _maskView.layer.cornerRadius = 3.0f;
    }
    return _maskView;
}

- (UILabel *)updateCountLabel {
    if (!_updateCountLabel) {
        _updateCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.tagImageView.bottom-5-12, self.width-10, 12)];
        _updateCountLabel.textColor = [UIColor whiteColor];
        _updateCountLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    return _updateCountLabel;
}

- (UILabel *)tagNameLabel {
    if (!_tagNameLabel) {
        _tagNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tagImageView.bottom + 10.0f, self.width, 12.0f)];
        _tagNameLabel.textColor = [UIColor textColorValue1];
        _tagNameLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _tagNameLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tagImageView];
        [self addSubview:self.maskView];
        [self addSubview:self.updateCountLabel];
        [self addSubview:self.tagNameLabel];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    CGFloat height = 0.0f;
    
    height += 78.0f; //图片
    height += 10.0f; //间距
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tmpLabel.font = [UIFont systemFontOfSize:13.0f];
    tmpLabel.text = [(GFTagMTL*)model tagInfo].tagName;
    tmpLabel.size = [tmpLabel sizeThatFits:CGSizeMake(78, MAXFLOAT)];
    height += tmpLabel.height; //动态计算标签名高度
    
    return height;
}

@end

@interface GFCollectedTagListCell ()

@property (nonatomic, strong) UIScrollView *containerScrollView;

@end

@implementation GFCollectedTagListCell
- (UIScrollView *)containerScrollView {
    if (!_containerScrollView) {
        _containerScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _containerScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _containerScrollView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [[self.containerScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.containerScrollView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    CGFloat height = 0.0f;
    
    height += 10.0f; //上方空白
    
    NSArray *tags = model;
    CGFloat maxTagViewHeight = 200.0f;
    for (GFTagMTL *tag in tags) {
        if ([GFCollectTagView heightWithModel:tag] < maxTagViewHeight) {
            maxTagViewHeight = [GFCollectTagView heightWithModel:tag];
        }
    }
    
    height += maxTagViewHeight; //中间CollectTagView高度
    
    height += 15.0f; //底部留白
    return height;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];

    __weak typeof(self) weakSelf = self;
    NSArray *tags = model;
    for (GFTagMTL *tag in tags) {
        GFCollectTagView *tagView = [[GFCollectTagView alloc] initWithFrame:CGRectMake(0, 0, 80, kCollectedTagListCellHeight)];
        [tagView bk_whenTapped:^{
            if (weakSelf.selectTagHandler) {
                weakSelf.selectTagHandler(tag);
            }
        }];
        
        NSString *imgKey = tag.tagInfo.thumbnail;
        if (imgKey) {
            GFPictureMTL *picture = [tag.pictures objectForKey:imgKey];
            if (picture.url) {
                [tagView.tagImageView setImageWithURL:[NSURL URLWithString:picture.url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
            }
        }
        if (tag.updateCount > 0) {
            tagView.updateCountLabel.hidden = NO;
            tagView.updateCountLabel.text = [NSString stringWithFormat:@"%ld条更新", (long)tag.updateCount];
        } else {
            tagView.updateCountLabel.hidden = YES;
        }
        
        tagView.tagNameLabel.text = tag.tagInfo.tagName;
        
        [self.containerScrollView addSubview:tagView];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray *tags = self.model;
    CGFloat height = [GFCollectedTagListCell heightWithModel:self.model];
    self.containerScrollView.frame = CGRectMake(0, 10, self.contentView.width, height-10-15);
    CGFloat contentViewWidth = 15 + 15 + 80 * [tags count] + 20 * ([tags count] - 1);
    self.containerScrollView.contentSize = CGSizeMake(contentViewWidth, self.containerScrollView.height);
    
    CGFloat x = 15.0f;
    for (GFCollectTagView *tagView in [self.containerScrollView subviews]) {
        tagView.x = x;
        x += tagView.width + 20.0f;
    }
}
@end
