//
//  GFContentTagUserGuideView.m
//  GetFun
//
//  Created by Liu Peng on 16/3/5.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFContentTagUserGuideView.h"

@interface GFContentTagUserGuideView()

@property (nonatomic, strong) UIImageView *tipView;

@end

@implementation GFContentTagUserGuideView

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
        _tipView.image = [UIImage imageNamed:@"userguide_content_tag"];
        [_tipView sizeToFit];
    }
    return _tipView;
}

- (void)setTagLabelFrame:(CGRect)frame {
    self.tipView.origin = CGPointMake(frame.origin.x, frame.origin.y - frame.size.height);
}

@end
