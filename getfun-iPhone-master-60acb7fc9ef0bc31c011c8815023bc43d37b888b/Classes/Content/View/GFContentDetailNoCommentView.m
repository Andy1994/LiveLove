//
//  GFContentDetailNoCommentView.m
//  GetFun
//
//  Created by muhuaxin on 15/12/2.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailNoCommentView.h"

@interface GFContentDetailNoCommentView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel     *label;

@end

@implementation GFContentDetailNoCommentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Private methods

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_no_comment"]];
        imageView;
    });
    
    self.label = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = RGBCOLOR(153, 153, 153);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"暂无评论，来抢个沙发吧～";
        label;
    });
    
    [self addSubview:self.imageView];
    [self addSubview:self.label];
    
    [self.imageView sizeToFit];
    self.imageView.y = 65;
    self.imageView.centerX = SCREEN_WIDTH / 2;
    
    [self.label sizeToFit];
    self.label.y = self.imageView.bottom + 18;
    self.label.centerX = SCREEN_WIDTH / 2;
}

@end
