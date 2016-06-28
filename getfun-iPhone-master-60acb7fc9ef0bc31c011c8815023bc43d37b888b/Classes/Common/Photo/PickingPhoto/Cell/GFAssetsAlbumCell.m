//
//  GFAssetsAlbumCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFAssetsAlbumCell.h"

@implementation GFAssetsAlbumCell
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 2, 76, 76)];
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.right + 5,
                                                              self.imageView.y+10,
                                                              self.contentView.width - self.imageView.right - 5,
                                                               18)];
    }
    return _textLabel;
}

- (UILabel *)detailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.textLabel.x,
                                                               self.textLabel.bottom + 5,
                                                               self.textLabel.width,
                                                               self.textLabel.height)];
    }
    return _detailTextLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.textLabel];
        [self.contentView addSubview:self.detailTextLabel];
    }
    return self;
}

@end
