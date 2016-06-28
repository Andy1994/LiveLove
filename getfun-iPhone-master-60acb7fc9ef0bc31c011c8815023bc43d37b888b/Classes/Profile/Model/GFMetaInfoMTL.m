//
//  GFMetaInfoMTL.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/4.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMetaInfoMTL.h"

@implementation GFMetaInfoMTL

- (instancetype)init {
    if (self = [super init]) {
        self.metaId = @(0);
        self.lastLoginTime = @(0);
        self.apnsCount = 0;
        self.allowSound = YES;
        self.allowContentMessage = YES;
        self.allowCommentMessage = YES;
        self.allowFunMessage = YES;
        self.allowParticipateMessage = YES;
        self.allowNotifyMessage = YES;
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"metaId" : @"id",
             @"lastLoginTime" : @"lastLoginTime",
             @"apnsCount" : @"apnsCount",
             @"allowSound" : @"soundSwitch",
             @"allowContentMessage" : @"contentPushSwitch",
             @"allowCommentMessage" : @"commentNotifySwitch",
             @"allowFunMessage" : @"funNotifySwitch",
             @"allowParticipateMessage" : @"participateNotifySwitch",
             @"allowNotifyMessage" : @"systemNotifySwitch"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key rangeOfString:@"allow"].location != NSNotFound) {
        return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                               @"ON" : @(YES),
                                                                               @"OFF" : @(NO)
                                                                               }];
    }
    return nil;
}

@end
