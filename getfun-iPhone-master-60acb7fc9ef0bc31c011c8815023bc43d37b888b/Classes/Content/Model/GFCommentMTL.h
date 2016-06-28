//
//  GFCommentMTL.h
//  GetFun
//
//  Created by muhuaxin on 15/11/17.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"
#import "GFPictureMTL.h"
#import "GFEmotionMTL.h"

@class GFContentMTL;

@interface GFCommentInfoMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *commentId;
@property (nonatomic, copy) NSString *commentContent;
@property (nonatomic, strong) NSNumber *replyCountTotal;
@property (nonatomic, strong) NSNumber *funCount;
@property (nonatomic, strong) NSNumber *createTime;

@property (nonatomic, strong) NSNumber *parentId;
@property (nonatomic, strong) NSNumber *relatedId;
@property (nonatomic, strong) NSNumber *rootCommentId;

@property (nonatomic, strong) NSArray *pictureKeys;
@property (nonatomic, strong) NSArray *emotionIds;

@end

@interface GFCommentMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) GFCommentInfoMTL *commentInfo;
@property (nonatomic, strong) GFUserMTL *user;
@property (nonatomic, strong) GFCommentMTL *parent;
@property (nonatomic, copy) NSArray<GFCommentMTL *> *children;
@property (nonatomic, assign) BOOL hasMoreChildren;
@property (nonatomic, assign) BOOL loginUserHasFuned;
@property (nonatomic, strong) GFContentMTL *content;
@property (nonatomic, strong) NSDictionary<NSString *, GFPictureMTL *> *pictures;
@property (nonatomic, strong) NSDictionary<NSString *, GFEmotionMTL *> *emotions;

@end

