//
//  GFFeedContentCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFUserInfoHeader.h"
#import "GFContentInfoFooter.h"
#import "GFImageGroupView.h"

@interface GFFeedContentCell : GFBaseCollectionViewCell <GFImageGroupDelegate>

@property (nonatomic, strong) GFUserInfoHeader      *userInfoHeader;
@property (nonatomic, strong) GFContentInfoFooter   *contentInfoFooter;
@property (nonatomic, strong, readonly) UIButton *floatFunButton; //悬浮点赞按钮，用于用户引导

@property (nonatomic, copy) void(^floatFunHandler)(GFContentMTL *content);

- (void)beginFunAnimation;
- (void)endFunAnimation;

- (void)markRead;

@end
