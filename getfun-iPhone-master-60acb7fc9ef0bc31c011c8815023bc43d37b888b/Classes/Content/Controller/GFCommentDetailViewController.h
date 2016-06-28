//
//  GFCommentDetailViewController.h
//  GetFun
//
//  Created by muhuaxin on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseViewController.h"
@class GFCommentMTL;
@interface GFCommentDetailViewController : GFBaseViewController

- (instancetype)initWithRootCommentId:(NSNumber *)commentId contentId:(NSNumber *)contentId;

// 同步刷新帖子详情页的fun
@property (nonatomic, copy) void (^funHandler)(GFCommentMTL *comment);
// 同步刷新详情页子评论
@property (nonatomic, copy) void (^childCommentHandler)(GFCommentMTL *parentComment, GFCommentMTL *childComment);

@end
