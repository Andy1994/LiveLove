//
//  GFCollectedTagCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFCollectedTagCell.h"
#import "GFTagMTL.h"

@interface GFCollectedTagCell ()
@property (nonatomic, strong) UIImageView *tagImageView;
@property (nonatomic, strong) UILabel *tagNameLabel;
@property (nonatomic, strong) UILabel *contentCountLabel;
@property (nonatomic, strong) UILabel *collectCountLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@end

@implementation GFCollectedTagCell
- (UIImageView *)tagImageView {
    if (!_tagImageView) {
        _tagImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _tagImageView.image = [UIImage imageNamed:@"placeholder_image"];
        _tagImageView.layer.masksToBounds = YES;
        _tagImageView.layer.cornerRadius = 2.0f;
    }
    return _tagImageView;
}

- (UILabel *)tagNameLabel {
    if (!_tagNameLabel) {
        _tagNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagNameLabel.textColor = [UIColor textColorValue1];
        _tagNameLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    return _tagNameLabel;
}

- (UILabel *)contentCountLabel {
    if (!_contentCountLabel) {
        _contentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentCountLabel.textColor = [UIColor textColorValue4];
        _contentCountLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _contentCountLabel;
}

- (UILabel *)collectCountLabel {
    if (!_collectCountLabel) {
        _collectCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _collectCountLabel.textColor = [UIColor textColorValue4];
        _collectCountLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _collectCountLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
    }
    return _accessoryImageView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.tagImageView.image = [UIImage imageNamed:@"placeholder_image"];
    self.tagNameLabel.text = nil;
    self.contentCountLabel.text = nil;
    self.collectCountLabel.text = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.tagImageView];
        [self.contentView addSubview:self.tagNameLabel];
        [self.contentView addSubview:self.contentCountLabel];
        [self.contentView addSubview:self.collectCountLabel];
        [self.contentView addSubview:self.accessoryImageView];
        
        [self gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return self;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFTagMTL *tag = model;
    NSString *imageKey = tag.tagInfo.thumbnail;
    if (imageKey) {
        GFPictureMTL *picture = [tag.pictures objectForKey:imageKey];
        if (picture.url) {
            NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeCollectedTagList gifConverted:YES];
            [self.tagImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
        }
    }
    
    self.tagNameLabel.text = tag.tagInfo.tagName;
    self.contentCountLabel.text = [NSString stringWithFormat:@"%@帖子", tag.tagInfo.contentCount];
    self.collectCountLabel.text = [NSString stringWithFormat:@"%@人关注", tag.tagInfo.userCount];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tagImageView.frame = CGRectMake(15, self.contentView.height/2 - 55.0f/2, 55.0f, 55.0f);
    
    [self.tagNameLabel sizeToFit];
    [self.contentCountLabel sizeToFit];
    
    self.tagNameLabel.center = CGPointMake(self.tagImageView.right + 10 + self.tagNameLabel.width/2,
                                           self.contentView.height/2 - self.contentCountLabel.height/2 - 5);
    self.contentCountLabel.center = CGPointMake(self.tagImageView.right + 10 + self.contentCountLabel.width/2,
                                                self.contentView.height/2 + self.tagNameLabel.height/2 + 5);
    [self.collectCountLabel sizeToFit];
    
    //5s之前微调
    if (SCREEN_WIDTH > 320) {
        self.collectCountLabel.center = CGPointMake(self.contentView.width/2 - 20, self.contentCountLabel.centerY);
    } else {
        self.collectCountLabel.center = CGPointMake(self.contentView.width/2, self.contentCountLabel.centerY);
    }

    
    self.accessoryImageView.center = CGPointMake(self.contentView.width-15-self.accessoryImageView.width/2,
                                                 self.contentView.height/2);
}

@end
