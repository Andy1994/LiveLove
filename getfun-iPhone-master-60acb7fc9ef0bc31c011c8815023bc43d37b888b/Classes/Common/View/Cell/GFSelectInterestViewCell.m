//
//  GFSelectInterestViewCell.m
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFSelectInterestViewCell.h"
#import "GFTagMTL.h"

@interface GFSelectInterestViewCell ()

@property (strong, nonatomic) UIImageView *bgImageView; //背景图
@property (strong, nonatomic) UIView *borderView; //描边视图
@property (strong, nonatomic) UILabel *nameLabel; //名称
@property (strong, nonatomic) UIView *titleBGView; //变色的背景视图
@property (assign, nonatomic) GFSelectInterestViewCellStyle style;

@end

@implementation GFSelectInterestViewCell

#pragma mark - 属性

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        _bgImageView.clipsToBounds = YES;
    }
    
    return _bgImageView;
}

- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _borderView.clipsToBounds = YES;
        _borderView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    return _borderView;
}

-(UIView *)titleBGView {
    if (!_titleBGView) {
        _titleBGView = [[UIView alloc] initWithFrame: CGRectZero];
        _titleBGView.backgroundColor = [UIColor clearColor];
    }
    return _titleBGView;
}

-(UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}


- (void)setTitleBackgoundColor: (UIColor *)color {
    [self.titleBGView setBackgroundColor:color];
}




- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.borderView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height);
    self.borderView.layer.cornerRadius = self.contentView.width / 2;
    self.borderView.clipsToBounds = YES;
    self.borderView.backgroundColor = [UIColor clearColor];
    
    self.bgImageView.frame = CGRectMake(0, 0, self.contentView.width -2, self.contentView.height - 2);
    self.bgImageView.center = self.borderView.center;
    self.bgImageView.layer.cornerRadius = self.bgImageView.width / 2;
    self.bgImageView.clipsToBounds = YES;
    
    self.titleBGView.frame = self.borderView.bounds;
    self.titleBGView.layer.cornerRadius = self.contentView.width / 2;
    self.titleBGView.clipsToBounds = YES;
    
    self.nameLabel.frame = CGRectMake(0, self.titleBGView.height / 2 - 10, self.titleBGView.width, 20);
    
    GFTagMTL *tag = (GFTagMTL *)self.model;
    switch (self.style) {
        case GFSelectInterestViewCellUserGuide:
        {
            if (self.selected) {
                self.titleBGView.backgroundColor = [UIColor gf_colorWithHex:tag.tagInfo.tagHexColor alpha:0.95];
            } else {
                //没有选中时，加一层蒙版使文字显示清晰
                self.titleBGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            }
            break;
        }
        case GFSelectInterestViewCellCreateGroup:
        {
            self.titleBGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            break;
        }
        case GFSelectInterestViewCellCreateGroupAll:
        {
            self.titleBGView.backgroundColor = [UIColor gf_colorWithHex:tag.tagInfo.tagHexColor alpha:0.95];
            break;
        }
    }
    
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.borderView];
        [self.contentView addSubview:self.bgImageView];
        [self.contentView addSubview:self.titleBGView];
        
        [self.titleBGView addSubview:self.nameLabel];        
    }
    return self;
}

#pragma mark - 绑定数据
- (void)bindWithModel:(id)model withStyle:(GFSelectInterestViewCellStyle)style{
    _model = model;
    _style = style;

    GFTagMTL *tag = model;
    self.nameLabel.text = tag.tagInfo.tagName;
    
    if (tag.interestTagEx.interestImageUrl) {
        NSString *url = ((GFPictureMTL*)[tag.pictures objectForKey:tag.interestTagEx.interestImageUrl]).url;
        NSUInteger width = (NSUInteger)self.contentView.width;
        NSUInteger height = (NSUInteger)self.contentView.height;
#warning 图片剪裁标准未确定
        [self.bgImageView setImageWithURL:[NSURL URLWithString:[url gf_urlAppendWithHorizontalEdge:width verticalEdge:height mode:GFImageProcessModeMinWidthMinHeightCut]] placeholder:nil];
        self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        //显示“全部”的按钮
        self.titleBGView.backgroundColor = [UIColor gf_colorWithHex:tag.tagInfo.tagHexColor];
    }
    
    [self setNeedsLayout];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    // 重置image
    self.bgImageView.image = nil;
    // 更新位置
    self.bgImageView.frame = self.contentView.bounds;
}

@end
