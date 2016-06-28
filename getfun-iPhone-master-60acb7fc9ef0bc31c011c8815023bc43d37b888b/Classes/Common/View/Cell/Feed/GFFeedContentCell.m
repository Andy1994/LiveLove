//
//  GFFeedContentCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedContentCell.h"
#import "GFAccountManager.h"
#import "GFNetworkManager+Content.h"
#import "GFSoundEffect.h"

@interface GFFeedContentCell ()

@property (nonatomic, strong) UIButton              *floatFunButton;
@property (nonatomic, strong) UIImageView           *animationImageView;

@end

@implementation GFFeedContentCell
- (GFUserInfoHeader *)userInfoHeader {
    if (!_userInfoHeader) {
        _userInfoHeader = [[GFUserInfoHeader alloc] initWithFrame:CGRectZero];
        [_userInfoHeader setTopLineHidden:YES];
    }
    return _userInfoHeader;
}

- (GFContentInfoFooter *)contentInfoFooter {
    if (!_contentInfoFooter) {
        _contentInfoFooter = [[GFContentInfoFooter alloc] initWithFrame:CGRectZero];
    }
    return _contentInfoFooter;
}

- (UIButton *)floatFunButton {
    if (!_floatFunButton) {
        _floatFunButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_floatFunButton setImage:[UIImage imageNamed:@"home_fun_float_normal"] forState:UIControlStateNormal];
        [_floatFunButton setImage:[UIImage imageNamed:@"home_fun_float_disabled"] forState:UIControlStateDisabled];
        [_floatFunButton sizeToFit];
    }
    return _floatFunButton;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.floatFunButton.enabled = YES;
    self.floatFunButton.hidden = NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.userInfoHeader];
        [self.contentView addSubview:self.contentInfoFooter];
        [self.contentView addSubview:self.floatFunButton];
        
        __weak typeof(self) weakSelf = self;
        [self.floatFunButton bk_addEventHandler:^(id sender) {
            
            [GFAccountManager checkLoginStatus:YES
                               loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                                   if (user) {
                                       GFContentMTL *content = weakSelf.model;
                                       
                                       [GFSoundEffect playSoundEffect:GFSoundEffectTypeFun];
                                       [weakSelf beginFunAnimation];
                                       [GFNetworkManager changeFunStatusWithContentId:content.contentInfo.contentId
                                                                                isFun:NO
                                                                              success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage) {

                                                                              } failure:^(NSUInteger taskId, NSError *error) {

                                                                              }];
                                   }
                               }];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc {
    [_userInfoHeader removeFromSuperview];
    _userInfoHeader = nil;
    
    [_contentInfoFooter removeFromSuperview];
    _contentInfoFooter = nil;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFContentMTL *content = model;
    
    self.floatFunButton.enabled = ![content isFunned];
    self.floatFunButton.hidden = content.contentInfo.status==GFContentStatusDeleted;
}

- (void)markRead {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView bringSubviewToFront:self.userInfoHeader];
    [self.contentView bringSubviewToFront:self.contentInfoFooter];
    [self.contentView bringSubviewToFront:self.floatFunButton];
    
    self.userInfoHeader.frame = CGRectMake(0, 0, self.contentView.width, kUserInfoHeaderHeight);

    
    GFContentMTL *content = self.model;
    GFCommentMTL *comment = [content.comments count] > 0 ? [content.comments objectAtIndex:0] : nil;
    CGFloat footerHeight = [GFContentInfoFooter heightWithContent:content];
    if (comment) {
        self.floatFunButton.center = CGPointMake(self.contentView.width-15-self.floatFunButton.width/2,
                                                 self.contentView.height - footerHeight/2 - self.floatFunButton.height/2 - 5);
    } else {
        self.floatFunButton.center = CGPointMake(self.contentView.width-15-self.floatFunButton.width/2,
                                                 self.contentView.height - self.floatFunButton.height/2 - 5);
    }
}

- (void)setContentFunned {
    
    GFContentMTL *content = self.model;
    
    self.floatFunButton.enabled = NO;
    NSInteger funCount = [content.contentInfo.funCount integerValue] + 1;
    content.contentInfo.funCount = [NSNumber numberWithInteger:funCount];
    
    GFContentActionStatus *funActionStatus = content.actionStatuses[GFContentMTLActionStatusesKeyFun];
    funActionStatus.count = @1;
}

- (void)beginFunAnimation {
    
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:23];
    for (NSInteger index = 1; index < 24; index ++) {
        NSString *imageName = [NSString stringWithFormat:@"heart_animation_detail_%ld", (long)index];
        UIImage *image = [UIImage imageNamed:imageName];
        [images addObject:image];
    }
    
    self.animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 53, 53)];
    self.animationImageView.center = self.floatFunButton.center;
    [self addSubview:self.animationImageView];
    
    self.animationImageView.animationImages = images;
    self.animationImageView.animationDuration = 1.0f;
    self.animationImageView.animationRepeatCount = 1;
    [self.animationImageView startAnimating];
    
    [self performSelector:@selector(endFunAnimation) withObject:nil afterDelay:self.animationImageView.animationDuration];
}

- (void)endFunAnimation {
    [self setContentFunned];
    [self.animationImageView removeFromSuperview];
    self.animationImageView = nil;
    
    if (self.floatFunHandler) {
        self.floatFunHandler(self.model);
    }
}

- (NSArray<UIView *> *)pictureViews {
    return nil;
}
@end
