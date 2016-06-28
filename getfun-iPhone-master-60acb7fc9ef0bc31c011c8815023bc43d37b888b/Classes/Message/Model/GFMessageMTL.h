//
//  GFMessageMTL.h
//  GetFun
//
//  Created by zhouxz on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFCommentMTL.h"
#import "GFUserMTL.h"
#import "GFGroupMTL.h"

@interface GFMessageDetailMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *messageId;
@property (nonatomic, strong) NSNumber *sessionId;
@property (nonatomic, strong) NSNumber *sourceUserId;       // 消息来源用户ID, 对应sourceUser
@property (nonatomic, strong) NSNumber *destUserId;
@property (nonatomic, assign) GFMessageType messageType;
@property (nonatomic, strong) NSNumber *sendTime;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *linkUrl;

@property (nonatomic, strong) NSNumber *relatedId;          // 消息涉及的其他对象ID，如评论ID、get帮id，具体对象可在relatedData中找到relatedComment或relatedGroup
@property (nonatomic, strong) NSNumber *relatedUserId;      // 最后一个参与的用户ID，具体对象在relatedData中的relatedUser
@property (nonatomic, strong) NSNumber *relatedUserCount;   // 总共参与的用户数

@end

@interface GFRelatedDataMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) GFCommentInfoMTL *relatedCommentInfo;
@property (nonatomic, strong) GFUserMTL *relatedUser;
@property (nonatomic, strong) GFGroupInfoMTL *relatedGroupInfo;

@end

@interface GFMessageMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) GFMessageDetailMTL *messageDetail;
@property (nonatomic, strong) GFUserMTL *messageSender;
@property (nonatomic, strong) GFRelatedDataMTL *relatedData;

@end
