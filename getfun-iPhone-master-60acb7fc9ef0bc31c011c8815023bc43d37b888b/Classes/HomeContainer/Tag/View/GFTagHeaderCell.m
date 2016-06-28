//
//  GFTagHeaderCell.m
//  GetFun
//
//  Created by 陈霄 on 16/3/15.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#define selectImageName @"publish_camera_photo"
#define publishVoteName @"publish_PK1"
#define kCenterY 25
#define kSeparatorH 26
#define kPublishBtnW 50.0

#import "GFTagHeaderCell.h"
#import "GFTagMTL.h"
//#import "UIColor+Getfun.h"

@interface GFTagCell ()

//@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UIButton *selectImageButton;
@property (nonatomic, strong) UIButton *publishVoteButton;     //PK
//分割线
@property (nonatomic, strong) UIView *separatorView1;
@property (nonatomic, strong) UIView * separatorView2;
@end

@implementation GFTagCell


#pragma mark - 重写父类方法
+ (CGFloat)heightWithModel:(id)model {
    return 50.0f;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFTagMTL *tagMTL = model;
    if (tagMTL.prologues && tagMTL.prologues.count > 0) {
        NSString *title = tagMTL.prologues.firstObject.prologue;
        [self.titleView setText:title];
    } else {
        [self.titleView setText:@"说点和这个标签相关的吧"];
    }
    [self setNeedsLayout];
}

#pragma mark - 其他
///  初始化
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleView];
        [self.contentView addSubview:self.selectImageButton];
        [self.contentView addSubview:self.publishVoteButton];
        
        //添加分割线
        [self.contentView addSubview:self.separatorView1];
        [self.contentView addSubview:self.separatorView2];
        [self.contentView gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        [self.layer setShadowRadius:1];
        [self.layer setShadowOpacity:0.2];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    [self.titleButton sizeToFit];
    self.titleView.bounds = CGRectMake(0, 0, SCREEN_WIDTH - kPublishBtnW * 2 - 15, 50);
    self.titleView.center = CGPointMake(15 + self.titleView.width / 2, kCenterY);
    
    self.separatorView1.frame = CGRectMake(self.contentView.width - kPublishBtnW * 2, (50 - kSeparatorH) * 0.5, 1, kSeparatorH);
    self.separatorView2.frame = CGRectMake(self.contentView.width - kPublishBtnW, (50 - kSeparatorH) * 0.5, 1, kSeparatorH);
    
    self.selectImageButton.frame = CGRectMake(CGRectGetMaxX(self.separatorView1.frame), 0, kPublishBtnW, kPublishBtnW);
    self.publishVoteButton.frame = CGRectMake(CGRectGetMaxX(self.separatorView2.frame), 0, kPublishBtnW, kPublishBtnW);
}
#pragma mark - 懒加载

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] init];
        
        [_titleView setTextColor:[UIColor textColorValue4]];
        _titleView.font = [UIFont systemFontOfSize:14.0];
        _titleView.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        [_titleView bk_whenTapped:^{
            if (weakSelf.publishHandler) {
                [MobClick event:@"gf_bq_02_04_12_1"];
                weakSelf.publishHandler(GFContentTypeTag);
            }
        }];
        
    }
    return _titleView;
}

- (UIButton *)selectImageButton {
    if (!_selectImageButton) {
        _selectImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self _setButton:_selectImageButton imageName:selectImageName];
        
        __weak typeof(self) weakSelf = self;
        [_selectImageButton bk_addEventHandler:^(id sender) {
            if (weakSelf.publishHandler) {
                [MobClick event:@"gf_bq_02_04_13_1"];
                weakSelf.publishHandler(GFContentTypePicture);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectImageButton;
}

- (UIButton *)publishVoteButton {
    if (!_publishVoteButton) {
        _publishVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self _setButton:_publishVoteButton imageName:publishVoteName];
        
        __weak typeof(self) weakSelf = self;
        [_publishVoteButton bk_addEventHandler:^(id sender) {
            if (weakSelf.publishHandler) {
                weakSelf.publishHandler(GFContentTypeVote);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishVoteButton;
}

- (UIView *)separatorView1 {
    if (!_separatorView1) {
        _separatorView1 = [UIView new];
        _separatorView1.backgroundColor = [UIColor themeColorValue15];
    }
    return _separatorView1;
}

- (UIView *)separatorView2 {
    if (!_separatorView2) {
        _separatorView2 = [UIView new];
        _separatorView2.backgroundColor = [UIColor themeColorValue15];
    }
    return _separatorView2;
}
#pragma mark - 私有方法

- (void)_setButton:(UIButton *)button imageName:(NSString *)imageName {
    
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    button.imageView.contentMode = UIViewContentModeCenter;
    //[button sizeToFit];
}
@end
