//
//  GFProfileUserGuideView.m
//  GetFun
//
//  Created by liupeng on 16/3/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFProfileUserGuideView.h"

@interface GFProfileUserGuideView ()
@property (nonatomic, strong) UIImageView *tipView;
@end

@implementation GFProfileUserGuideView

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
        _tipView.image = [UIImage imageNamed:@"userguide_profile_follow"];
        [_tipView sizeToFit];
        
    }
    return _tipView;
}

- (void)setFollowButtonFrame:(CGRect)frame {
    CGPoint origin = frame.origin;    
    self.tipView.origin = CGPointMake(origin.x - self.tipView.width + 48, origin.y - 25);
    [self setNeedsLayout];
}

@end
