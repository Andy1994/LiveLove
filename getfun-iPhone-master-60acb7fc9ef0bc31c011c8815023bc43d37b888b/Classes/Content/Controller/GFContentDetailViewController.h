//
//  GFContentDetailViewController.h
//  GetFun
//
//  Created by muhuaxin on 15/11/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
#import "GFContentMTL.h"
#import "GFContentInfoMTL.h"
#import "GFNetworkManager+Content.h"
#import "GFImageGroupView.h"

@interface GFContentDetailViewController : GFBaseViewController <GFImageGroupDelegate>

// 投票状态更新回调
@property (nonatomic, copy) void(^voteHandler)(GFContentMTL *content, BOOL left);

// 帖子评论、fun数目状态更新回调
@property (nonatomic, copy) void(^commentAndFunHandler)(GFContentMTL *content);

// 删除帖子更新回调
@property (nonatomic, copy) void(^deleteContentHandler)(GFContentMTL *content);

@property (nonatomic, copy) void(^contentUpdateHandler)(GFContentMTL *content);

@property (nonatomic, assign, readonly) GFKeyFrom keyFrom; // 记录页面来源

//- (instancetype)initWithContentId:(NSNumber *)contentId preview:(BOOL)preview;
//- (instancetype)initWithContentId:(NSNumber *)contentId preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom;
//- (instancetype)initWithContentId:(NSNumber *)contentId contentType: (GFContentType)contentType preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom;

- (instancetype)initWithContent:(GFContentMTL *)content preview:(BOOL)preview;
- (instancetype)initWithContent:(GFContentMTL *)content preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom;
- (instancetype)initWithContent:(GFContentMTL *)content contentType: (GFContentType)contentType preview:(BOOL)preview keyFrom:(GFKeyFrom)keyFrom;


@end
