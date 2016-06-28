//
//  GFMetaInfoMTL.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/4.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFMetaInfoMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *metaId;
@property (nonatomic, strong) NSNumber *lastLoginTime;
@property (nonatomic, assign) NSInteger apnsCount;
@property (nonatomic, assign) BOOL allowSound;
@property (nonatomic, assign) BOOL allowContentMessage;
@property (nonatomic, assign) BOOL allowCommentMessage;
@property (nonatomic, assign) BOOL allowFunMessage;
@property (nonatomic, assign) BOOL allowParticipateMessage;
@property (nonatomic, assign) BOOL allowNotifyMessage;

@end
