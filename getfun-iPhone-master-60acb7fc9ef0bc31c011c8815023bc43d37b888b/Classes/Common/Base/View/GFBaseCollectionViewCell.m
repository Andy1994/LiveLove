//
//  GFBaseCollectionViewCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/15.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"

@implementation GFBaseCollectionViewCell

+ (CGFloat)heightWithModel:(id)model {
    return 80.0f;
}

- (void)bindWithModel:(id)model {
    _model = model;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
