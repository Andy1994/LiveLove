//
//  GFHomeUserGuideView.m
//  GetFun
//
//  Created by Liu Peng on 16/1/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFHomeUserGuideView.h"

@interface GFHomeUserGuideTipView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *button;

@end

@implementation GFHomeUserGuideTipView



- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (UIButton *)button {
    if(!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setImage:[UIImage imageNamed:@"userguide_home_close"] forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor clearColor];
    }
    return _button;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.button];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.imageView sizeToFit];
    self.button.frame = CGRectMake(self.imageView.right - 40, self.imageView.centerY - 20, 40, 40);
}

@end

@interface GFHomeUserGuideView ()

@property (nonatomic, strong) UIImageView *tipView1;
@property (nonatomic, strong) UIImageView *tipView2;
@property (nonatomic, assign) NSUInteger tapCount;

@end

@implementation GFHomeUserGuideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tipView1];
//        [self addSubview:self.tipView2];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        self.tapCount = 0;
        
        __weak typeof(self) weakSelf = self;
//        [self bk_whenTapped:^{
//            if (weakSelf.tapCount == 0) {
//                weakSelf.tapCount++;
//                weakSelf.tipView1.hidden = YES;
//                weakSelf.tipView2.hidden = NO;
//            } else if(weakSelf.tapCount == 1) {
//                [weakSelf removeFromSuperview];
//            }
//        }];
        [self bk_whenTapped:^{
            [weakSelf removeFromSuperview];
        }];

    }
    return self;
}

- (UIImageView *)tipView1 {
    if (!_tipView1) {
        _tipView1 = [[UIImageView alloc] initWithFrame:CGRectZero];
        _tipView1.image = [UIImage imageNamed:@"userguide_home_fun"];
        _tipView1.hidden = NO;
        [_tipView1 sizeToFit];
        
    }
    return _tipView1;
}

- (UIImageView *)tipView2 {
    if (!_tipView2) {
        _tipView2 = [[UIImageView alloc] initWithFrame:CGRectZero];
        _tipView2.image = [UIImage imageNamed:@"userguide_home_openpic"];
        _tipView2.hidden = YES;
        [_tipView2 sizeToFit];

    }
    return _tipView2;
}

- (void)setFunButtonFrame:(CGRect)frame {
    CGPoint origin = frame.origin;
    //CGSize size = frame.size;
    self.tipView1.origin = CGPointMake(origin.x - self.tipView2.width + 20, origin.y - 10);
    [self setNeedsLayout];
}
- (void)setImageViewFrame:(CGRect)frame {
//    CGPoint origin = frame.origin;
//    //CGSize size = frame.size;
//    self.tipView2.origin = CGPointMake(origin.x, origin.y);
//    [self setNeedsLayout];
}
@end
