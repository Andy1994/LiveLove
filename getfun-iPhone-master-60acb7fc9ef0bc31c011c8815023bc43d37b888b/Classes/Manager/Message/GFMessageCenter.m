//
//  GFMessageCenter.m
//  GetFun
//
//  Created by zhouxz on 16/1/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMessageCenter.h"
#import "GeTuiSdk.h"
#import "GFNetworkManager+Message.h"
#import "GFCacheUtil.h"
#import "AppDelegate.h"
#import "GFAccountManager.h"

#import "GFSoundEffect.h"

// 个推
NSString * const kGeTuiAppId = @"ALrQjnKAuw9gAPQiZCjiU5";
NSString * const kGeTuiAppKey = @"nUn6RyOheX6DKQfYTChyo3";
NSString * const kGeTuiAppSecret = @"KmFkjPhPBTAN5XWLynrKS6";

#define GF_MESSAGE_ACTIVITY_PERSISTENT_FILE @"messageactivitypersistent.file"

// 收到了新消息
NSString * const GFNotificationDidReceiveMessage = @"GFNotificationDidReceiveMessage";
// 删除了消息
NSString * const GFNotificationDidMessageDeleted = @"GFNotificationDidMessageDeleted";
// 消息已读状态改变
NSString * const GFNotificationDidMessageStatusChanged = @"GFNotificationDidMessageStatusChanged";
// 消息数据
NSString * const kMessageNotificationUserInfoKeyMsg = @"kMessageNotificationUserInfoKeyMsg";


@interface GFMessageCenter () <GeTuiSdkDelegate>

@property (nonatomic, strong) NSMutableArray *activityMessages;     // 0x70
@property (nonatomic, assign) NSUInteger unreadActivityMessageCount;

+ (instancetype)defaultCenter;

@end

@implementation GFMessageCenter
+ (instancetype)defaultCenter {
    static GFMessageCenter *defaultCenter;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        defaultCenter = [[GFMessageCenter alloc] init];
        
        [defaultCenter loadActivityMessages];
    });
    return defaultCenter;
}

- (void)loadActivityMessages {
    
    self.activityMessages = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *path = [GFCacheUtil gf_persistentPath];
    if (path) {
        NSString *file = [path stringByAppendingPathComponent:GF_MESSAGE_ACTIVITY_PERSISTENT_FILE];
        NSArray *persistentData = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
        if (persistentData && [persistentData count] > 0) {
            [self.activityMessages addObjectsFromArray:persistentData];
        }
    }
    
    for (GFMessageMTL *message in self.activityMessages) {
        if (message.messageDetail.unread) {
            self.unreadActivityMessageCount ++;
        }
    }
}

- (void)saveActivityMessages {
    NSString *path = [GFCacheUtil gf_persistentPath];
    if (path && [self.activityMessages count] > 0) {
        NSString *file = [path stringByAppendingPathComponent:GF_MESSAGE_ACTIVITY_PERSISTENT_FILE];
        [NSKeyedArchiver archiveRootObject:self.activityMessages toFile:file];
    }
}

+ (void)setup {
    [GeTuiSdk startSdkWithAppId:kGeTuiAppId appKey:kGeTuiAppKey appSecret:kGeTuiAppSecret delegate:[self defaultCenter]];
    [GeTuiSdk runBackgroundEnable:NO];
}

+ (void)markReadMessage:(GFMessageMTL *)message {
    if (!message) {
        return;
    }
    message.messageDetail.unread = NO;
    
    GFBasicMessageType type = message.messageDetail.messageType & 0xF0;
    
    if (type == GFBasicMessageTypeNotify) return;
    if (type == GFBasicMessageTypeActivity) {
        [GFNetworkManager markClickedMessage:message.messageDetail.relatedId];
        [GFMessageCenter defaultCenter].unreadActivityMessageCount --;
    } else {
        [GFNetworkManager markReadMessage:message.messageDetail.messageId];
    }
        [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationDidMessageStatusChanged
                                                            object:nil
                                                          userInfo:@{
                                                                     kMessageNotificationUserInfoKeyMsg : message
                                                                     }];
   
}

+ (void)markAllMessageRead {
    for (GFMessageMTL *message in [GFMessageCenter defaultCenter].activityMessages) {
        message.messageDetail.unread = NO;
    }
    [GFMessageCenter defaultCenter].unreadActivityMessageCount = 0;
    [GFNetworkManager markReadAllMessageCompletion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationDidMessageStatusChanged
                                                            object:nil
                                                          userInfo:nil];
    }];
}

+ (NSArray *)activityMessages {
    return [GFMessageCenter defaultCenter].activityMessages;
}

+ (NSUInteger)unreadActivityMessageCount {
    return [GFMessageCenter defaultCenter].unreadActivityMessageCount;
}

+ (BOOL)deleteActivityMessage:(GFMessageMTL *)message {
    
    GFBasicMessageType type = message.messageDetail.messageType & 0xF0;
    if (type != GFBasicMessageTypeActivity) return NO;
    if (message.messageDetail.unread == NO) return NO;
    
    message.messageDetail.unread = NO;
    [GFMessageCenter defaultCenter].unreadActivityMessageCount --;
    [[GFMessageCenter defaultCenter].activityMessages removeObject:message];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationDidMessageDeleted
                                                        object:nil
                                                      userInfo:@{
                                                                 kMessageNotificationUserInfoKeyMsg : message
                                                                 }];
    return YES;
}

#pragma mark - 个推
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    
    if (clientId && [clientId length] > 0) {
        [GFAccountManager sharedManager].getuiClientId = clientId;
        
        if ([GFAccountManager sharedManager].accessToken) {
            [GFNetworkManager addGTClientId:clientId];
        }
    }
}

- (void)GeTuiSdkDidOccurError:(NSError *)error {
    
}

- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    
    DDLogInfo(@"GeTuiSdkDidReceivePayload");
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    id obj = [NSJSONSerialization JSONObjectWithData:payload options:NSJSONReadingAllowFragments error:nil];
    GFMessageMTL *message = [MTLJSONAdapter modelOfClass:[GFMessageMTL class] fromJSONDictionary:obj error:nil];
    DDLogVerbose(@"GeTuiSdkDidReceivePayload:\n%@", message);
    [GFMessageCenter handleMessage:message shouldRedirect:NO];
}

// 这里要handle的消息有两个来源:
// 1. 个推在前台接收到的长链接消息 shouldRedirect = NO
// 2. anps收到的消息从后台点击进入前台 shouldRedirect = YES
// 这个时候应用肯定是在前台的
+ (void)handleMessage:(GFMessageMTL *)message shouldRedirect:(BOOL)shouldRedirect {
    if (!message) {
        return;
    }
    GFMessageCenter *messageCenter = [GFMessageCenter defaultCenter];
    GFMessageType messageType = message.messageDetail.messageType;
    GFBasicMessageType type = messageType & 0xF0;
    
    if (type == GFBasicMessageTypeActivity) {

        // 已收到活动，上报服务器已收到，但尚未点击
        [GFNetworkManager markReceivedMessage:message.messageDetail.relatedId];

        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        message.messageDetail.messageId = [NSNumber numberWithLong:timeNow];
        message.messageDetail.unread = YES;
        if ([messageCenter.activityMessages count] > 0) {
            [messageCenter.activityMessages insertObject:message atIndex:0];
        } else {
            [messageCenter.activityMessages addObject:message];
        }
        messageCenter.unreadActivityMessageCount ++;
        [messageCenter saveActivityMessages];
    } else if (type == GFBasicMessageTypeNotify) {
        // 已收到通知，上报服务器已收到且已点击
        [GFNetworkManager markReceivedMessage:message.messageDetail.relatedId];
    }

    if (shouldRedirect) {
        // 对于需要跳转的，默认为用户点击（自动跳转)，标记为已读
        message.messageDetail.unread = NO;
        [self markReadMessage:message];
        [[AppDelegate appDelegate] handleRedirectMessage:message];
    }
        [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationDidReceiveMessage
                                                            object:nil
                                                          userInfo:@{
                                                                     kMessageNotificationUserInfoKeyMsg : message
                                                                     }];
    
}

@end
