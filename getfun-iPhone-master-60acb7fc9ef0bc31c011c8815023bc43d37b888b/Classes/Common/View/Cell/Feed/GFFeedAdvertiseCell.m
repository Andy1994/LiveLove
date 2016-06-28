//
//  GFFeedAdvertiseCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/27.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedAdvertiseCell.h"
#import "GFAdvertiseMTL.h"

@interface GFFeedAdvertiseCell ()

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *adImageView;

@end

@implementation GFFeedAdvertiseCell
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"home_ad_close"] forState:UIControlStateNormal];
        [_closeButton sizeToFit];
    }
    return _closeButton;
}

- (UIImageView *)adImageView {
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _adImageView.contentMode = UIViewContentModeScaleAspectFill;
        _adImageView.clipsToBounds = YES;
    }
    return _adImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.adImageView];
        [self.contentView addSubview:self.closeButton];
        
        __weak typeof(self) weakSelf = self;
        [self.closeButton bk_addEventHandler:^(id sender) {
            if (weakSelf.closeHandler) {
                weakSelf.closeHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    //长宽标注为750 * 420
    return SCREEN_WIDTH/25 * 14;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFAdFeedMTL *ad = model;
    [self.adImageView setImageWithURL:[NSURL URLWithString:ad.adImageUrl] placeholder:nil];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.adImageView.frame = self.contentView.bounds;
    self.closeButton.center = CGPointMake(self.contentView.width - self.closeButton.width/2-15, self.closeButton.height/2 + 15);
}

@end
