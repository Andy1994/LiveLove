//
//  GFLoginRegisterUpperView.m
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#define GF_ANIMATE_VELOCITY 10.0f // 每秒20pt

#import "GFLoginRegisterUpperView.h"

@interface GFAnimateImageView : UIImageView
@property (nonatomic, assign) BOOL animateDirectionRevert;
@property (nonatomic, assign) CGFloat constrainHeight;
- (void)animateWithConstrainHeight:(CGFloat)height;
@end

@implementation GFAnimateImageView
- (void)animateWithConstrainHeight:(CGFloat)height {
    
    self.constrainHeight = height;
    CGFloat duration = 0;
    if (self.centerY > height/2) { // 偏下，起始向下移动
        self.animateDirectionRevert = NO;
        duration = (0 - self.y) / GF_ANIMATE_VELOCITY;
    } else { // 偏上，起始向上移动
        self.animateDirectionRevert = YES;
        duration = (self.bottom - height) / GF_ANIMATE_VELOCITY;
    }
    
    // test. 不要随机方向，两个向下两个向上
    self.animateDirectionRevert = (self.tag % 2 == 0);
    
    [self doAnimateDuration:duration];
}

- (void)doAnimateDuration:(NSTimeInterval)duration {
    
    __weak typeof(self) weakSelf = self;
    if (self.animateDirectionRevert) {
        // 向上移动
        [UIView animateWithDuration:duration animations:^{
            weakSelf.y = weakSelf.constrainHeight - weakSelf.height;
        } completion:^(BOOL finished) {
            if (finished) {
                weakSelf.animateDirectionRevert = !weakSelf.animateDirectionRevert;
                [weakSelf doAnimateDuration:(weakSelf.height - weakSelf.constrainHeight) / GF_ANIMATE_VELOCITY];
            }
        }];
    } else {
        // 向下移动
        [UIView animateWithDuration:duration animations:^{
            weakSelf.y = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                weakSelf.animateDirectionRevert = !weakSelf.animateDirectionRevert;
                [weakSelf doAnimateDuration:(weakSelf.height - weakSelf.constrainHeight) / GF_ANIMATE_VELOCITY];
            }
        }];
    }
}

@end

@interface GFLoginRegisterUpperView ()

@property (nonatomic, strong) GFAnimateImageView *backgroundImgView1; //背景图1
@property (nonatomic, strong) GFAnimateImageView *backgroundImgView2; //背景图2
@property (nonatomic, strong) GFAnimateImageView *backgroundImgView3; //背景图3
@property (nonatomic, strong) GFAnimateImageView *backgroundImgView4; //背景图4
@property (nonatomic, strong) UIView *maskView;

@end

@implementation GFLoginRegisterUpperView
- (GFAnimateImageView *)backgroundImgView1 {
    if (!_backgroundImgView1) {
        UIImage *image1 = [UIImage imageNamed:@"login_register_bg_1"];
        CGFloat width = self.width / 4;
        CGFloat height = width * (image1.size.height / image1.size.width);
        _backgroundImgView1 = [[GFAnimateImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        
        int maxFloor = floor(height/self.height);
        CGFloat centerY = (arc4random() % (maxFloor + 1)) * self.height - (height / 2.0f);
        _backgroundImgView1.centerY = centerY;
        _backgroundImgView1.image = image1;
        _backgroundImgView1.tag = 1;
    }
    return _backgroundImgView1;
}

- (GFAnimateImageView *)backgroundImgView2 {
    if (!_backgroundImgView2) {
        UIImage *image2 = [UIImage imageNamed:@"login_register_bg_2"];
        CGFloat width = self.width / 4;
        CGFloat height = width * (image2.size.height / image2.size.width);
        _backgroundImgView2 = [[GFAnimateImageView alloc] initWithFrame:CGRectMake(width * 1, 0, width, height)];
        
        int maxFloor = floor(height/self.height);
        CGFloat centerY = (arc4random() % (maxFloor + 1)) * self.height - (height / 2.0f);
        _backgroundImgView2.centerY = centerY;
        _backgroundImgView2.image = image2;
        _backgroundImgView2.tag = 2;
    }
    return _backgroundImgView2;
}

- (GFAnimateImageView *)backgroundImgView3 {
    if (!_backgroundImgView3) {
        UIImage *image3 = [UIImage imageNamed:@"login_register_bg_3"];
        CGFloat width = self.width / 4;
        CGFloat height = width * (image3.size.height / image3.size.width);
        _backgroundImgView3 = [[GFAnimateImageView alloc] initWithFrame:CGRectMake(width * 2, 0, width, height)];
        
        int maxFloor = floor(height/self.height);
        CGFloat centerY = (arc4random() % (maxFloor + 1)) * self.height - (height / 2.0f);
        _backgroundImgView3.centerY = centerY;
        _backgroundImgView3.image = image3;
        _backgroundImgView3.tag = 3;
    }
    return _backgroundImgView3;
}

- (GFAnimateImageView *)backgroundImgView4 {
    if (!_backgroundImgView4) {
        UIImage *image4 = [UIImage imageNamed:@"login_register_bg_4"];
        CGFloat width = self.width / 4;
        CGFloat height = width * (image4.size.height / image4.size.width);
        _backgroundImgView4 = [[GFAnimateImageView alloc] initWithFrame:CGRectMake(width * 3, 0, width, height)];
        
        int maxFloor = floor(height/self.height);
        CGFloat centerY = (arc4random() % (maxFloor + 1)) * self.height - (height / 2.0f);
        _backgroundImgView4.centerY = centerY;
        _backgroundImgView4.image = image4;
        _backgroundImgView4.tag = 4;
    }
    return _backgroundImgView4;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5f);
    }
    return _maskView;
}

- (UIImageView *)sloganImgView {
    if (!_sloganImgView) {
        _sloganImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _sloganImgView.image = [UIImage imageNamed:@"login_slogan"];
        [_sloganImgView sizeToFit];
        _sloganImgView.center = CGPointMake(self.width/2, self.height/2);
    }
    return _sloganImgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundImgView1];
        [self addSubview:self.backgroundImgView2];
        [self addSubview:self.backgroundImgView3];
        [self addSubview:self.backgroundImgView4];
        [self addSubview:self.maskView];
        [self addSubview:self.sloganImgView];
    }
    return self;
}

- (void)dealloc {
    [_backgroundImgView1 removeFromSuperview];
    _backgroundImgView1 = nil;

    [_backgroundImgView2 removeFromSuperview];
    _backgroundImgView2 = nil;
    
    [_backgroundImgView3 removeFromSuperview];
    _backgroundImgView3 = nil;
    
    [_backgroundImgView4 removeFromSuperview];
    _backgroundImgView4 = nil;
}

- (void)didMoveToSuperview {
//    [self.backgroundImgView1 animateWithConstrainHeight:self.height];
//    [self.backgroundImgView2 animateWithConstrainHeight:self.height];
//    [self.backgroundImgView3 animateWithConstrainHeight:self.height];
//    [self.backgroundImgView4 animateWithConstrainHeight:self.height];
    
    self.backgroundImgView1.y = 0;
    self.backgroundImgView3.y = 0;
    self.backgroundImgView2.bottom = self.height;
    self.backgroundImgView4.bottom = self.height;
}
@end
