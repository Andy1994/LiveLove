//
//  GFUserCommentCell.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"
#import "GFUserInfoHeader.h"
#import "GFCommentMTL.h"
#import "GFImageGroupView.h"

@interface GFUserCommentCell : GFBaseCollectionViewCell <GFImageGroupDelegate>

@property (nonatomic, strong, readonly) GFUserInfoHeader *userInfoHeader;

@property (nonatomic, assign) BOOL shouldIndent;
@property (nonatomic, assign) BOOL shouldShowReplyInfo;

@property (nonatomic, copy) void (^tapImageHandler)(GFUserCommentCell *cell, NSUInteger iniImageIndex);

+ (CGFloat)heightWithModel:(id)model
                    indent:(BOOL)indent
       shouldShowReplyInfo:(BOOL)show;

- (void)bindWithModel:(id)model contentUserId:(NSNumber *)userId;

@end
