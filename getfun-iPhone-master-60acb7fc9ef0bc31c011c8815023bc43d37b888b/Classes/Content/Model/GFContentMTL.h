//
//  GFContentMTL.h
//  GetFun
//
//  Created by muhuaxin on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"
#import "GFContentInfoMTL.h"
#import "GFContentSummaryMTL.h"
#import "GFContentDetailMTL.h"
#import "GFPictureMTL.h"
#import "GFTagMTL.h"
#import "GFCommentMTL.h"

@class GFTagInfoMTL;

// 副帖（用于盖范第一课堂)
@interface GFSubContentMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *subContentId;
@property (nonatomic, strong) NSNumber *contentId;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, strong) NSNumber *updateTime;
@end

@interface GFContentActionStatus : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *relatedId;
@end

@interface GFContentMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) GFContentInfoMTL *contentInfo;
@property (nonatomic, strong) GFUserMTL *user;
@property (nonatomic, strong) NSArray *funUsers;
@property (nonatomic, copy)   NSArray<GFTagInfoMTL *> *tags;
@property (nonatomic, copy)   NSArray<GFCommentMTL *> *comments;
@property (nonatomic, copy)   NSArray *topics;
@property (nonatomic, copy)   NSDictionary<NSString *, GFPictureMTL *> *pictures;
@property (nonatomic, copy)   NSDictionary<NSString *, GFContentActionStatus *> *actionStatuses;
@property (nonatomic, strong) GFContentSummaryMTL *contentSummary;  // 用于一般的信息流等
@property (nonatomic, strong) GFContentDetailMTL *contentDetail;    // 用于帖子详情页

// 这个字段需要注意:
// [subContents count] > 0 表示是盖范课堂
// 内部的item是GFSubContentMTL类型，需要判断是否有.content值, 没有的话不显示副帖(广播),只是后台为了标识"盖范课堂"而new出来的对象
@property (nonatomic, strong) NSArray<GFSubContentMTL *> *subContents;
// 是否盖范第一课堂
- (BOOL)isGetfunLesson;
- (BOOL)isFunned;

@end

