//
//  GFContentDetailPictureView.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFContentDetailUserInfoView.h"
#import "GFContentMTL.h"
#import "GFContentDetailTagContainerView.h"
#import "GFImageGroupView.h"

@interface GFContentDetailPictureView : UIView <GFImageGroupDelegate>

@property (nonatomic, strong, readonly) GFContentDetailUserInfoView *userInfoView;
@property (nonatomic, strong, readonly) GFContentDetailTagContainerView *tagContainer;

@property (nonatomic, copy) void (^tapImageHandler)(NSInteger iniPictureIndex);

+ (CGFloat)viewHeightWithContent:(GFContentMTL *)content;
- (void)updateContent:(GFContentMTL *)content;

@end
