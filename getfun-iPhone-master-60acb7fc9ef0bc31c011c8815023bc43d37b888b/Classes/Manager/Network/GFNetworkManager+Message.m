//
//  GFNetworkManager+Message.m
//  GetFun
//
//  Created by zhouxz on 16/1/26.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNetworkManager+Message.h"

#define GF_API_ADD_GT_CLIENTID          ApiAddress(@"/api/push/addGtPushToken")
#define GF_API_ADD_APNS_DEVICE_TOKEN    ApiAddress(@"/api/push/addApnsPushToken")
#define GF_API_CLEAR_APNS_MESSAGE_COUNT ApiAddress(@"/api/push/clearApnsCount")

#define GF_API_MARK_RECEIVED_MESSAGE    ApiAddress(@"/api/message/markAsReceivedForActivity")
#define GF_API_MARK_CLICKED_MESSAGE     ApiAddress(@"/api/message/markAsClickedForActivity")
#define GF_API_MARK_READ_MESSAGE        ApiAddress(@"/api/message/markAsRead")
#define GF_API_MARK_READ_ALL_MESSAGE    ApiAddress(@"/api/message/flushAllUnread")
#define GF_API_GET_UNREAD_MESSAGE_COUNT ApiAddress(@"/api/message/getUnreadCount")
#define GF_API_GET_SPECIFIC_MESSAGE     ApiAddress(@"/api/message/getMessage")
#define GF_API_GET_MESSAGE_LIST         ApiAddress(@"/api/message/messageList")

@implementation GFNetworkManager (Message)

+ (NSUInteger)addGTClientId:(NSString *)clientId {
    if (!clientId) {
        return 0;
    }
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_ADD_GT_CLIENTID
                                                    parameters:@{
                                                                 @"clientId" : clientId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {

                                                       } failure:^(NSUInteger taskId, NSError *error) {

                                                       }];
    return taskId;
}

+ (NSUInteger)addAPNsDeviceToken:(NSString *)deviceToken {
    if (!deviceToken) {
        return 0;
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_ADD_APNS_DEVICE_TOKEN
                                                    parameters:@{
                                                                 @"token" : deviceToken
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           //
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                       }];
    return taskId;
}

+ (NSUInteger)clearAPNsMessageCount {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_CLEAR_APNS_MESSAGE_COUNT
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           //
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                       }];
    return taskId;
}

+ (NSUInteger)markReceivedMessage:(NSNumber *)relatedId {
    if (!relatedId) {
        return 0;
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_MARK_RECEIVED_MESSAGE
                                                    parameters:@{
                                                                 @"relatedId" : relatedId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           //
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                       }];
    return taskId;
}

+ (NSUInteger)markClickedMessage:(NSNumber *)relatedId {
    if (!relatedId) {
        return 0;
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_MARK_CLICKED_MESSAGE
                                                    parameters:@{
                                                                 @"relatedId" : relatedId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           //
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                       }];
    return taskId;
}

+ (NSUInteger)markReadMessage:(NSNumber *)messageId {
    if (!messageId) {
        return 0;
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_MARK_READ_MESSAGE
                                                    parameters:@{
                                                                 @"messageId" : messageId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           //
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           //
                                                       }];
    return taskId;
}

+ (NSUInteger)markReadAllMessageCompletion:(void (^)())completion {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_MARK_READ_ALL_MESSAGE
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           if (completion) {
                                                               completion();
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (completion) {
                                                               completion();
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getUnreadMessageCountSuccess:(void (^)(NSUInteger, NSInteger, GFUnreadCountMTL *))success
                                   failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_GET_UNREAD_MESSAGE_COUNT
                                                    parameters:nil
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSDictionary *countDict = [responseObject objectForKey:@"unreadCountMap"];
                                                           GFUnreadCountMTL *unread = [MTLJSONAdapter modelOfClass:[GFUnreadCountMTL class] fromJSONDictionary:countDict error:nil];
                                                           if (success) {
                                                               success(taskId, code, unread);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           failure(taskId, error);
                                                       }];
    return taskId;
}

+ (NSUInteger)getMessageWithRelatedId:(NSNumber *)relatedId
                                 type:(GFMessageType)type
                              success:(void (^)(NSUInteger, NSInteger, NSString *, GFMessageMTL *))success
                              failure:(void (^)(NSUInteger, NSError *))failure {
    if (!relatedId) {
        return 0;
    }
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_GET_SPECIFIC_MESSAGE
                                                    parameters:@{
                                                                 @"messageType" : messageTypeKey(type),
                                                                 @"relatedId" : relatedId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];

                                                           GFMessageMTL *message = nil;
                                                           NSDictionary *messageDict = [responseObject objectForKey:@"extendMessage"];
                                                           if (messageDict && [messageDict isKindOfClass:[NSDictionary class]]) {
                                                               message = [MTLJSONAdapter modelOfClass:[GFMessageMTL class] fromJSONDictionary:messageDict error:nil];
                                                           }
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, message);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)getMessageListWithBasicType:(GFBasicMessageType)type
                        refQueryTime:(NSNumber *)refQueryTime
                                size:(NSInteger)size
                             success:(void (^)(NSUInteger, NSInteger, NSString *, NSNumber *, NSArray *))success
                             failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSMutableDictionary *params = [@{
                                    @"messageTypeForDisplay" : basicMessageTypeKey(type),
                                    @"size" : [NSNumber numberWithInteger:size]
                                    } mutableCopy];
    if (refQueryTime) {
        [params setObject:refQueryTime forKey:@"queryTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_GET_MESSAGE_LIST
                                                    parameters:params
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSNumber *refTime = [responseObject objectForKey:@"queryTime"];

                                                           NSArray *messages = nil;
                                                           
                                                           NSArray *messageDataList = [responseObject objectForKey:@"dataList"];
                                                           if (messageDataList && [messageDataList isKindOfClass:[NSArray class]]) {
                                                               messages = [MTLJSONAdapter modelsOfClass:[GFMessageMTL class] fromJSONArray:messageDataList error:nil];
                                                           }
                                                           
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, refTime, messages);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

@end
