//
//  GFTagUserGuideView.m
//  GetFun
//
//  Created by Liu Peng on 16/3/5.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFTagUserGuideView.h"

@interface GFTagUserGuideView ()

@property (nonatomic, strong) UIImageView *tipView;

@end

@implementation GFTagUserGuideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tipView];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        __weak typeof(self) weakSelf = self;
        [self bk_whenTapped:^{
            [weakSelf removeFromSuperview];
        }];
    }
    return self;
}

- (UIImageView *)tipView {
    if (!_tipView) {
        _tipView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _tipView.image = [UIImage imageNamed:@"userguide_tag_publishPhoto"];
        [_tipView sizeToFit];
        
    }
    return _tipView;
}

- (void)setPublishPhotoViewFrame:(CGRect)frame {
    CGPoint origin = frame.origin;
//    CGSize size = frame.size;
    self.tipView.origin = CGPointMake(origin.x, origin.y - self.tipView.height + 6);
    [self setNeedsLayout];
}

@end
