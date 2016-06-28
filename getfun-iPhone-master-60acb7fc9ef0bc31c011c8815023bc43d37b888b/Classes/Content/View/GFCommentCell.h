//
//  GFCommentCell.h
//  GetFun
//
//  Created by muhuaxin on 15/11/16.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFCommentMTL.h"
#import "GFImageGroupView.h"

@interface GFCommentCell : GFBaseTableViewCell <GFImageGroupDelegate>

@property (nonatomic, assign) BOOL isMine;//是否是楼主
@property (nonatomic, assign) CGFloat bottomSpace;//底部间距

@property (nonatomic, copy) void (^avatarTappedHandler)(GFCommentCell *cell, GFCommentMTL *model); //点击头像
@property (nonatomic, copy) void (^funButtonHandler)(GFCommentCell *cell, GFCommentMTL *model); //点击fun
@property (nonatomic, copy) void (^tapImageHandler)(GFCommentCell *cell, NSUInteger iniImageIndex); //点击大图
- (void)doFunAnimate;

@end
