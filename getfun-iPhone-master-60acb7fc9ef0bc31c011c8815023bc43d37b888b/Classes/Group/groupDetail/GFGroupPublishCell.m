//
//  GFGroupPublishCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFGroupPublishCell.h"

@interface GFGroupPublishCell ()

@property (nonatomic, strong) UIButton *publishArticleButton;
@property (nonatomic, strong) UIView *vLine1;
@property (nonatomic, strong) UIButton *publishLinkButton;
@property (nonatomic, strong) UIView *vLine2;
@property (nonatomic, strong) UIButton *publishVoteButton;

@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@end

@implementation GFGroupPublishCell

- (UIButton *)publishArticleButton {
    if (!_publishArticleButton) {
        _publishArticleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishArticleButton setImage:[UIImage imageNamed:@"group_publish_article"] forState:UIControlStateNormal];
        [_publishArticleButton setImage:[[UIImage imageNamed:@"group_publish_article"] opacity:0.5f] forState:UIControlStateHighlighted];
        [_publishArticleButton setTitle:@"发布图文" forState:UIControlStateNormal];
        [_publishArticleButton setTitleColor:[UIColor textColorValue4] forState:UIControlStateNormal];
        _publishArticleButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        __weak typeof(self) weakSelf = self;
        [_publishArticleButton bk_addEventHandler:^(id sender) {
            if (weakSelf.publishHandler) {
                weakSelf.publishHandler(GFContentTypeArticle);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishArticleButton;
}

- (UIView *)vLine1 {
    if (!_vLine1) {
        _vLine1 = [[UIView alloc] initWithFrame:CGRectZero];
        _vLine1.backgroundColor = [UIColor themeColorValue15];
    }
    return _vLine1;
}

- (UIButton *)publishLinkButton {
    if (!_publishLinkButton) {
        _publishLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishLinkButton setImage:[UIImage imageNamed:@"group_publish_link"] forState:UIControlStateNormal];
        [_publishLinkButton setImage:[[UIImage imageNamed:@"group_publish_link"] opacity:0.5f] forState:UIControlStateHighlighted];
        [_publishLinkButton setTitle:@"发布链接" forState:UIControlStateNormal];
        [_publishLinkButton setTitleColor:[UIColor textColorValue4] forState:UIControlStateNormal];
        _publishLinkButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        __weak typeof(self) weakSelf = self;
        [_publishLinkButton bk_addEventHandler:^(id sender) {
            if (weakSelf.publishHandler) {
                weakSelf.publishHandler(GFContentTypeLink);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishLinkButton;
}

- (UIView *)vLine2 {
    if (!_vLine2) {
        _vLine2 = [[UIView alloc] initWithFrame:CGRectZero];
        _vLine2.backgroundColor = [UIColor themeColorValue15];
    }
    return _vLine2;
}

- (UIButton *)publishVoteButton {
    if (!_publishVoteButton) {
        _publishVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishVoteButton setImage:[UIImage imageNamed:@"group_publish_vote"] forState:UIControlStateNormal];
        [_publishVoteButton setImage:[[UIImage imageNamed:@"group_publish_vote"] opacity:0.5f] forState:UIControlStateHighlighted];
        [_publishVoteButton setTitle:@"发布投票" forState:UIControlStateNormal];
        [_publishVoteButton setTitleColor:[UIColor textColorValue4] forState:UIControlStateNormal];
        _publishVoteButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        __weak typeof(self) weakSelf = self;
        [_publishVoteButton bk_addEventHandler:^(id sender) {
            if (weakSelf.publishHandler) {
                weakSelf.publishHandler(GFContentTypeVote);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishVoteButton;
}

- (UIView *)topBorder {
    if (!_topBorder) {
        _topBorder = [[UIView alloc] initWithFrame:CGRectZero];
        _topBorder.backgroundColor = [UIColor themeColorValue15];
    }
    return _topBorder;
}

- (UIView *)bottomBorder {
    if (!_bottomBorder) {
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomBorder.backgroundColor = [UIColor themeColorValue15];
    }
    return _bottomBorder;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.publishArticleButton];
        [self.contentView addSubview:self.publishLinkButton];
        [self.contentView addSubview:self.publishVoteButton];
        [self.contentView addSubview:self.vLine1];
        [self.contentView addSubview:self.vLine2];
        [self.contentView addSubview:self.topBorder];
        [self.contentView addSubview:self.bottomBorder];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return 85.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(-10, 22, 10, -22);
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsMake(16, -16, -16, 16);
    
    self.publishArticleButton.frame = CGRectMake(0, 0, self.contentView.width/3, self.contentView.height);
    self.publishArticleButton.imageEdgeInsets = imageEdgeInsets;
    self.publishArticleButton.titleEdgeInsets = titleEdgeInsets;
    self.publishLinkButton.frame = CGRectMake(self.publishArticleButton.right, 0, self.contentView.width/3, self.contentView.height);
    self.publishLinkButton.imageEdgeInsets = imageEdgeInsets;
    self.publishLinkButton.titleEdgeInsets = titleEdgeInsets;
    self.publishVoteButton.frame = CGRectMake(self.publishLinkButton.right, 0, self.contentView.width/3, self.contentView.height);
    self.publishVoteButton.imageEdgeInsets = imageEdgeInsets;
    self.publishVoteButton.titleEdgeInsets = titleEdgeInsets;
    self.vLine1.frame = CGRectMake(self.publishLinkButton.x-0.5f, 15.0f, 0.5f, self.contentView.height-30.0f);
    self.vLine2.frame = CGRectMake(self.publishLinkButton.right, 15.0f, 0.5f, self.contentView.height-30.0f);
    
    const CGFloat borderWidth = 0.5f;
    self.topBorder.frame = CGRectMake(0, 0, self.contentView.width, borderWidth);
    self.bottomBorder.frame = CGRectMake(0, self.contentView.height - borderWidth, self.contentView.width, borderWidth);
}
@end
