//
//  GFPublishParameterMTL.h
//  GetFun
//
//  Created by zhouxz on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

/**
 *  发布基类 : 通用参数
 */
@interface GFPublishMTL : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *topics;
@property (nonatomic, strong) NSNumber *preview; // YES; NO
@property (nonatomic, strong) NSNumber *groupId; // 当前发布所在的get帮
@property (nonatomic, strong) NSNumber *tagId; // 当前发布所在的tag
@property (nonatomic, strong) NSNumber *publishId;
@property (nonatomic, strong) NSNumber *state; // 发布状态
@end

/**
 *  图文参数
 */
@interface GFPublishArticleMTL : GFPublishMTL <MTLJSONSerializing>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *imageUrl;
@end

/**
 *  投票参数
 */
@interface GFPublishVoteMTL : GFPublishMTL <MTLJSONSerializing>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageTitle1;
@property (nonatomic, copy) NSString *imageUrl1;
@property (nonatomic, copy) NSString *imageTitle2;
@property (nonatomic, copy) NSString *imageUrl2;
@end

/**
 *  链接参数
 */
@interface GFPublishLinkMTL : GFPublishMTL <MTLJSONSerializing>
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@end

@interface GFPublishPictureMTL : GFPublishMTL <MTLJSONSerializing>
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray *pictures;

@end