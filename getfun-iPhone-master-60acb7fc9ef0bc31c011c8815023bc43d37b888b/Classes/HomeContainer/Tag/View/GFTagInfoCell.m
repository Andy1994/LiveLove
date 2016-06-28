//
//  GFTagInfoCell.m
//  GetFun
//
//  Created by liupeng on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFTagInfoCell.h"
#import "GFTagMTL.h"

@interface GFTagInfoCell ()

@property (strong, nonatomic) UILabel *tagNameLabel;
@property (strong, nonatomic) UIImageView *separatorImageView;
@property (strong, nonatomic) UILabel *tagDescriptionLabel;

@end

@implementation GFTagInfoCell


//绘制间隔线
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //指定直线样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    
    //直线宽度
    CGContextSetLineWidth(context, 1.0f);
    
    //设置颜色
    CGContextSetStrokeColorWithColor(context, RGBCOLOR(47, 213, 156).CGColor);
    //绘制
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.right, 0);
    CGContextStrokePath(context);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.tagNameLabel];
        [self.contentView addSubview:self.separatorImageView];
        [self.contentView addSubview:self.tagDescriptionLabel];
    }
    return self;
}

- (UILabel *)tagNameLabel {
    if (!_tagNameLabel) {
        _tagNameLabel = [[self class] tagNameLabel];
    }
    return _tagNameLabel;
}

+ (UILabel *)tagNameLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor textColorValue1];
    label.font = [UIFont systemFontOfSize:19.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 1;
    return label;
}

- (UIImageView *)separatorImageView {
    if (!_separatorImageView) {
        _separatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag_separator"]];
        [_separatorImageView sizeToFit];
    }
    return _separatorImageView;
}

- (UILabel*)tagDescriptionLabel {
    if (!_tagDescriptionLabel) {
        _tagDescriptionLabel = [[self class] tagDescriptionLabel];
    }
    return _tagDescriptionLabel;
}

+ (UILabel *)tagDescriptionLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor textColorValue2];
    label.font = [UIFont systemFontOfSize:13.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

+ (CGFloat)heightWithModel:(id)model {
    
    CGFloat height = 0;
    
    GFTagMTL *tagMTL = model;
    
    UILabel *tagNameLabel = [self tagNameLabel];
    tagNameLabel.text = tagMTL.tagInfo.tagName;
    [tagNameLabel sizeToFit];
    height += (15 + tagNameLabel.height);
    
    UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag_separator"]];
    [separatorImageView sizeToFit];
    height += (9 + separatorImageView.height);
    
    UILabel *tagDescriptionLabel = [self tagDescriptionLabel];
    tagDescriptionLabel.text = tagMTL.tagInfo.tagDescription;
    CGSize size = [tagDescriptionLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT)];
    height += (9 + size.height + 15);
    
    return height;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFTagMTL *tagMTL = model;
    self.tagNameLabel.text = tagMTL.tagInfo.tagName;
    
    self.tagDescriptionLabel.text = tagMTL.tagInfo.tagDescription;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.tagNameLabel sizeToFit];
    self.tagNameLabel.center = CGPointMake(self.contentView.width/2, 15 + self.tagNameLabel.height/2);
    
    self.separatorImageView.center = CGPointMake(self.contentView.width / 2, self.tagNameLabel.bottom + 9 + self.separatorImageView.height / 2);

    CGSize size = [self.tagDescriptionLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT)];
    self.tagDescriptionLabel.frame = CGRectMake(self.contentView.width/2 - size.width/2, self.separatorImageView.bottom + 9, size.width, size.height);
}

@end
