//
//  GFContentDetailVoteView.m
//  GetFun
//
//  Created by muhuaxin on 15/11/26.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFContentDetailVoteView.h"

@interface GFContentDetailVoteView ()

@property (nonatomic, strong) GFContentMTL *content;

@property (nonatomic, strong, readwrite) GFContentDetailUserInfoView *userInfoView;
@property (nonatomic, strong, readwrite) GFContentDetailTagContainerView *tagContainer;
@property (nonatomic, strong, readwrite) GFVoteView *voteView;

@end

@implementation GFContentDetailVoteView
- (GFContentDetailUserInfoView *)userInfoView {
    if (!_userInfoView) {
        _userInfoView = [[GFContentDetailUserInfoView alloc] init];
    }
    return _userInfoView;
}

- (GFContentDetailTagContainerView *)tagContainer {
    if (_tagContainer == nil) {
        _tagContainer = [[GFContentDetailTagContainerView alloc] init];
    }
    return _tagContainer;
}

- (GFVoteView *)voteView {
    if (!_voteView) {
        _voteView = [[GFVoteView alloc] init];
        _voteView.backgroundColor = [UIColor whiteColor];
    }
    return _voteView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.userInfoView];
        [self addSubview:self.tagContainer];
        [self addSubview:self.voteView];
    }
    return self;
}

- (void)dealloc {
    
    [_userInfoView removeFromSuperview];
    _userInfoView = nil;

    [_tagContainer removeFromSuperview];
    _tagContainer = nil;
    
    [_voteView removeFromSuperview];
    _voteView = nil;
}

#pragma mark - Public methods
- (void)updateContent:(GFContentMTL *)content animate:(BOOL)animate {
    
    _content = content;
    
    [self.userInfoView bindModel:content];
    self.tagContainer.content = self.content;
    [self.voteView updateContent:content animate:animate];
    
    [self setNeedsLayout];
}

+ (CGFloat)viewHeightWithContent:(GFContentMTL *)content {

    CGFloat height = 64 + kContentDetailUserInfoViewHeight;
    
    height += [GFContentDetailTagContainerView heightWithModel:content] + 5;
    
    height += [GFVoteView viewHeightWithContent:content] + 5;
    
    return height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.userInfoView.frame = CGRectMake(0, 64, SCREEN_WIDTH, kContentDetailUserInfoViewHeight);

    self.tagContainer.frame = CGRectMake(0, self.userInfoView.bottom + 5, SCREEN_WIDTH, [GFContentDetailTagContainerView heightWithModel: self.content]);
    
    self.voteView.frame = ({
        CGFloat height = [GFVoteView viewHeightWithContent:self.content];
        CGRect rect = CGRectMake(0, self.tagContainer.bottom + 5, SCREEN_WIDTH, height);
        rect;
    });
}
@end
