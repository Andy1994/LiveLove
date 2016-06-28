//
//  GFCommentReplyCell.h
//  GetFun
//
//  Created by muhuaxin on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseTableViewCell.h"
#import "GFImageGroupView.h"

@class GFCommentReplyCell;

@protocol GFCommentReplyCellDelegate <NSObject>
- (void)avatarTapppedInCell:(GFCommentReplyCell *)cell;
- (void)funButtonClickInCell:(GFCommentReplyCell *)cell;
- (void)replyNameInCell:(GFCommentReplyCell *)cell;
- (void)imageTappedInCell:(GFCommentReplyCell *)cell iniImageIndex:(NSUInteger)index;
@end


@class GFCommentMTL;

@interface GFCommentReplyCell : GFBaseTableViewCell <GFImageGroupDelegate>

@property (nonatomic, assign) BOOL isMine;//是否是楼主

@property (nonatomic, weak) id<GFCommentReplyCellDelegate> delegate;
//@property (nonatomic, copy) void (^avatarTappedHandler)(GFCommentReplyCell *cell, GFCommentMTL *model);
//@property (nonatomic, copy) void (^funButtonHandler)(GFCommentReplyCell *cell, GFCommentMTL *model);
//@property (nonatomic, copy) void (^replyerNameHandler)(GFCommentReplyCell *cell, GFCommentMTL *model);
//@property (nonatomic, copy) void (^tapImageHandler)(GFCommentReplyCell *cell, NSUInteger iniImageIndex); //点击大图

- (void)doFunAnimate;

@end
