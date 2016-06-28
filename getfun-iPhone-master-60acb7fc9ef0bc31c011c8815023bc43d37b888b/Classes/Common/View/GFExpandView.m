//
//  GFExpandView.m
//  GetFun
//
//  Created by zhouxz on 16/1/19.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFExpandView.h"

@interface GFExpandView ()

@property (nonatomic, strong) UIView *maskView;

@end

@implementation GFExpandView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.maskView];
    }
    return self;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
    return _maskView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.maskView.frame = self.bounds;
}

@end
