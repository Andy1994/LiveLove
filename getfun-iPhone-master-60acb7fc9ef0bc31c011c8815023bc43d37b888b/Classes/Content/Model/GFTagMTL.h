//
//  GFTagMTL.h
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFPictureMTL.h"

@class GFTagInfoMTL;
@class GFTagExMTL;
@class GFContentMTL;
@class GFTagPrologueMTL;
@interface GFTagMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) GFTagInfoMTL *tagInfo;
@property (nonatomic, strong) NSDictionary *pictures;
@property (nonatomic, assign) NSInteger updateCount; //该标签下最近更新的帖子数
@property (nonatomic, assign) BOOL collected;
@property (nonatomic, strong) NSNumber *addTime; //添加时间
@property (nonatomic, strong) GFTagExMTL *interestTagEx;
@property (nonatomic, strong) NSArray<GFContentMTL *> *contents;
@property (nonatomic, strong) NSArray<GFTagPrologueMTL *> *prologues;
@end


@interface GFTagInfoMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *tagId;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, copy) NSString *tagHexColor;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *frontImageUrl;
@property (nonatomic, copy) NSString *tagDescription;
@property (nonatomic, strong) NSNumber *contentCount;
@property (nonatomic, strong) NSNumber *userCount;
@property (nonatomic, strong) NSArray<GFTagInfoMTL *> *children;
@end

@interface GFTagExMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy) NSString *interestImageUrl;
@end

/**
 *  Prologues字段 标签内容
 */
@interface GFTagPrologueMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *tagId;
@property (nonatomic, copy) NSString *prologue;
@end

