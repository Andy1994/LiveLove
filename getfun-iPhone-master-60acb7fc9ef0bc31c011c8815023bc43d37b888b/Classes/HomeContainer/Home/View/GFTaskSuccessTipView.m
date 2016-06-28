//
//  GFTaskSuccessTipView.m
//  GetFun
//
//  Created by zhouxz on 16/1/18.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFTaskSuccessTipView.h"

@interface GFTaskSuccessTipView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GFTaskSuccessTipView
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull_to_refresh_success"]];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor themeColorValue10];
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

+ (instancetype)tipViewWithTitle:(NSString *)title {
    GFTaskSuccessTipView *tipView = [[GFTaskSuccessTipView alloc] init];
    tipView.titleLabel.text = title;
    
    [tipView resetFrame];

    return tipView;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    
    [self resetFrame];
}

#define EDGE_SPACE 5.0f
#define IMAGE_TITLE_GAP 13.0f

- (void)resetFrame {
    
    [self.imageView sizeToFit];
    [self.titleLabel sizeToFit];
    
    self.frame = CGRectMake(0,
                            0,
                            5 + self.imageView.width + 8 + self.titleLabel.width + 13,
                            32);
    self.imageView.center = CGPointMake(5 + self.imageView.width/2, self.height/2);
    self.titleLabel.center = CGPointMake(self.width - 13 - self.titleLabel.width/2, self.height/2);
    
    self.layer.cornerRadius = self.height/2;
}

@end
