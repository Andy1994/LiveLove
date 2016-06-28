//
//  GFFeedVoteCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFFeedVoteCell.h"
#import "GFVoteView.h"
#import "GFAccountManager.h"
#import "GFNetworkManager+Content.h"

#define kVoteItemTopSpacing 10.0f
#define kVoteItemBottomSpacing 0.0f

@interface GFFeedVoteCell ()
@property (nonatomic, strong) GFVoteView *voteView;
@end

@implementation GFFeedVoteCell
- (GFVoteView *)voteView {
    if (!_voteView) {
        _voteView = [[GFVoteView alloc] init];
        __weak typeof(self) weakSelf = self;
        _voteView.voteItemHandler = ^(GFVoteItemMTL *vote) {
            [GFAccountManager checkLoginStatus:YES
                               loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                                   if (user) {
                                       [weakSelf chooseVoteItem:vote];
                                   } else {
                                       [MBProgressHUD showHUDWithTitle:@"登录后才能投票" duration:kCommonHudDuration];
                                   }
                               }];
            
        };
    }
    return _voteView;
}

- (void)chooseVoteItem:(GFVoteItemMTL *)voteItem {
    GFContentMTL *content = self.model;
    NSArray *voteItems = [(GFContentSummaryVoteMTL *)content.contentSummary voteItems];
    
    if ([voteItems count] < 2) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    GFVoteItemMTL *leftItem = voteItems[0];
    GFVoteItemMTL *rightItem = voteItems[1];
    BOOL left = leftItem.voteItemId && [voteItem.voteItemId isEqualToNumber:leftItem.voteItemId];
    
    [GFNetworkManager voteWithContentId:content.contentInfo.contentId
                             voteItemId:voteItem.voteItemId
                                success:^(NSUInteger taskId, NSInteger code, NSString * errorMessage) {
                                    if (code == 1) {
                                        GFContentActionStatus *voteActionStatus = content.actionStatuses[GFContentMTLActionStatusesKeySpecial];
                                        voteActionStatus.count = @1;
                                        if (left) {
                                            leftItem.supportCount = @([leftItem.supportCount integerValue] + 1);
                                            voteActionStatus.relatedId = leftItem.voteItemId;
                                        } else {
                                            rightItem.supportCount = @([rightItem.supportCount integerValue] + 1);
                                            voteActionStatus.relatedId = rightItem.voteItemId;
                                        }
                                        [weakSelf bindWithModel:content];
                                        
                                        // 做投票动画. 下面的首页回调只处理数据不更新cell；voteView负责更新
                                        [weakSelf.voteView updateContent:content animate:YES];
                                    } else {
                                        [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration];
                                    }
                                } failure:^(NSUInteger taskId, NSError * error) {
                                }];
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.voteView];
    }
    return self;
}

- (void)dealloc {
    [_voteView removeFromSuperview];
    _voteView = nil;
}

- (void)setAllowVote:(BOOL)allow {
    self.voteView.userInteractionEnabled = allow;
}

+ (CGFloat)heightWithModel:(id)model {
    if (!model || ![model isKindOfClass:[GFContentMTL class]]) {
        return 0.0f;
    }
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypeVote) {
        return 0.0f;
    }
    
    CGFloat height = kUserInfoHeaderHeight;
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        height += kVoteItemTopSpacing;
        height += [GFVoteView viewHeightWithContent:contentMTL];
    }
    height += kVoteItemBottomSpacing;
    height += [GFContentInfoFooter heightWithContent:contentMTL];
    
    return height;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFContentMTL *contentMTL = model;
    if (contentMTL.contentInfo.type != GFContentTypeVote) {
        return;
    }
    
    [self.userInfoHeader setUserInfo:contentMTL.user];
    if ([contentMTL.tags count] > 0) {
        [self.userInfoHeader setTagInfo:[contentMTL.tags objectAtIndex:0]];
    } else {
        [self.userInfoHeader setTagInfo:nil];
    }
    if (contentMTL.contentInfo.status!=GFContentStatusDeleted) {
        [self.voteView updateContent:contentMTL animate:NO];
        self.voteView.hidden = NO;
    } else {
        self.voteView.hidden = YES;
    }
    [self.contentInfoFooter updateWithContent:contentMTL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    GFContentMTL *contentMTL = self.model;
    if (contentMTL.contentInfo.status==GFContentStatusDeleted) {
        self.contentInfoFooter.frame = CGRectMake(0, self.userInfoHeader.bottom + kVoteItemTopSpacing, self.contentView.width, [GFContentInfoFooter heightWithContent:contentMTL]);
    } else {
        self.voteView.frame = CGRectMake(0, self.userInfoHeader.bottom + kVoteItemTopSpacing, self.contentView.width, [GFVoteView viewHeightWithContent:contentMTL]);
        self.contentInfoFooter.frame = CGRectMake(0, self.voteView.bottom + kVoteItemBottomSpacing, self.contentView.width, [GFContentInfoFooter heightWithContent:contentMTL]);
    }
}

- (void)markRead {
    [super markRead];
    self.voteView.titleLabel.textColor = [UIColor textColorValue3];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.voteView.titleLabel.textColor = [UIColor textColorValue1];
}
@end
