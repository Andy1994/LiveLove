//
//  GFAssetItemCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFAssetItemCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "GFPhotoUtil.h"

#define kThumbnailLength    78.0f

@interface GFAssetItemCell ()

@property (nonatomic, strong) UILabel *badgeOrderLabel;

@end

@implementation GFAssetItemCell
- (UIImageView *)thumnailImageView {
    if (!_thumnailImageView) {
        _thumnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kThumbnailLength, kThumbnailLength)];
        _thumnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumnailImageView.clipsToBounds = YES;
    }
    return _thumnailImageView;
}

- (UILabel *)badgeOrderLabel {
    if (!_badgeOrderLabel) {
        _badgeOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kThumbnailLength-20, 0, 20.0f, 20.0f)];
        _badgeOrderLabel.backgroundColor = [UIColor purpleColor];
        _badgeOrderLabel.textColor = [UIColor whiteColor];
        _badgeOrderLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _badgeOrderLabel.textAlignment = NSTextAlignmentCenter;
        _badgeOrderLabel.layer.masksToBounds = YES;
        _badgeOrderLabel.layer.cornerRadius = 10.0f;
        _badgeOrderLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _badgeOrderLabel.layer.borderWidth = 2.0f;
        _badgeOrderLabel.hidden = YES;
    }
    return _badgeOrderLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.badgeOrderLabel.hidden = YES;
    self.thumnailImageView.image = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.thumnailImageView];
        [self.contentView addSubview:self.badgeOrderLabel];
    }
    return self;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    [GFPhotoUtil requestThumbnailForAsset:model completion:^(UIImage *thumbnail) {
        self.thumnailImageView.image = thumbnail;
    }];
}

- (void)setBadgeOrder:(NSInteger)badgeOrder {
    self.badgeOrderLabel.hidden = !(badgeOrder > 0);
    self.badgeOrderLabel.text = [NSString stringWithFormat:@"%ld", (long)badgeOrder];
}
@end
