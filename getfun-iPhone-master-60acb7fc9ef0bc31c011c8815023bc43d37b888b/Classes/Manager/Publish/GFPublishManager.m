//
//  GFPublishManager.m
//  GetFun
//
//  Created by zhouxz on 15/12/3.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFPublishManager.h"
#import "HTMLParser.h"
#import <QiniuSDK.h>

#import "GFCacheUtil.h"

#import "GFNetworkManager+Publish.h"

NSString * const GFNotificationPublishStateUpdate = @"gf_notification_publish_updated";
NSString * const kPublishNotificationUserInfoKeyData = @"data";
NSString * const kPublishNotificationUserInfoKeyOrigin = @"origin";
NSString * const kPublishNotificationUserInfoKeyMsg = @"msg";

#define GF_PUBLISH_TASK_PERSISTENT_FILE @"publishpersistent"

@interface GFPublishManager ()

+ (instancetype)sharedManager;

/**
 *  七牛上传图片
 */
@property (nonatomic, strong) QNUploadManager *uploadManager;
@property (nonatomic, strong) NSString *qiniuToken;

/**
 *  发布队列
 */
@property (nonatomic, strong) NSMutableArray *publishTaskList;  // 等待发送的
@property (nonatomic, strong) NSMutableArray *unpublishedTaskList; // 未发送且不在等待发送状态的

/**
 *  当前正在发布的MTL
 */
@property (nonatomic, copy) GFPublishMTL *currentPublishMTL;

/**
 *  图片数据
 */
@property (nonatomic, strong) NSMutableArray *imageDataOrFile;
@property (nonatomic, assign) NSInteger imageCount;

@end

@implementation GFPublishManager

+ (instancetype)sharedManager {
    static GFPublishManager *sharedManager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedManager = [[GFPublishManager alloc] init];
        
        NSString *path = [GFCacheUtil gf_persistentPath];
        if (path) {
            NSString *file = [path stringByAppendingPathComponent:GF_PUBLISH_TASK_PERSISTENT_FILE];
            sharedManager.unpublishedTaskList = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
            for (GFPublishMTL *publish in sharedManager.unpublishedTaskList) {
                publish.state = [NSNumber numberWithInteger:GFPublishStateWaiting];
            }
        }
        
        if (!sharedManager.unpublishedTaskList) {
            sharedManager.unpublishedTaskList = [[NSMutableArray alloc] initWithCapacity:0];
        }
        
        sharedManager.publishTaskList = [[NSMutableArray alloc] initWithCapacity:0];

        sharedManager.imageCount = -1;
        sharedManager.currentPublishMTL = nil;
        
        NSError *error = nil;
        QNFileRecorder *file = [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:@"QNGetGun"] error:&error];
        sharedManager.uploadManager = [[QNUploadManager alloc] initWithRecorder:file];
        
        [sharedManager addObserver:sharedManager forKeyPath:@"imageCount" options:NSKeyValueObservingOptionNew context:nil];
        [sharedManager addObserver:sharedManager forKeyPath:@"currentPublishMTL" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedManager selector:@selector(save) name:UIApplicationWillResignActiveNotification object:nil];
        
        [sharedManager processNextPublishTask];
    });
    return sharedManager;
}

- (void)save {
    NSString *path = [GFCacheUtil gf_persistentPath];
    if (path) {
        NSMutableArray *dataToSave = [[NSMutableArray alloc] initWithCapacity:0];
        [dataToSave addObjectsFromArray:self.publishTaskList];
        [dataToSave addObjectsFromArray:self.unpublishedTaskList];
        
        NSString *file = [path stringByAppendingPathComponent:GF_PUBLISH_TASK_PERSISTENT_FILE];
        [NSKeyedArchiver archiveRootObject:dataToSave toFile:file];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"currentPublishMTL"]) {
        
        if (self.currentPublishMTL) {

            // state -> 发送中
            self.currentPublishMTL.state = [NSNumber numberWithInteger:GFPublishStateSending];
            
            // 每一条发布都取一次七牛token
            __weak typeof(self) weakSelf = self;
            [GFNetworkManager queryQiNiuTokenSuccess:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token) {
                if (code == 1 && [token length] > 0) {
                    weakSelf.qiniuToken = token;
                    if (!weakSelf.imageDataOrFile) {
                        weakSelf.imageDataOrFile = [[NSMutableArray alloc] initWithCapacity:0];
                    }
                    if ([weakSelf.currentPublishMTL isKindOfClass:[GFPublishArticleMTL class]]) {
                        GFPublishArticleMTL *article = (GFPublishArticleMTL *)weakSelf.currentPublishMTL;
                        HTMLParser *parser = [[HTMLParser alloc] initWithString:article.content error:nil];
                        HTMLNode *bodyNode = [parser body];
                        NSArray *inputNodes = [bodyNode findChildTags:@"img"];
                        for (HTMLNode *node in inputNodes) {
                            NSString *value = [node getAttributeNamed:@"src"];
                            [weakSelf.imageDataOrFile addObject:value];
                        }
                    } else if ([weakSelf.currentPublishMTL isKindOfClass:[GFPublishVoteMTL class]]) {
                        GFPublishVoteMTL *publishVote = (GFPublishVoteMTL *)weakSelf.currentPublishMTL;
                        if (publishVote.imageUrl1) {
                            [weakSelf.imageDataOrFile addObject:@{
                                                        @"imageUrl1" : publishVote.imageUrl1
                                                        }];
                        }
                        if (publishVote.imageUrl2) {
                            [weakSelf.imageDataOrFile addObject:@{
                                                        @"imageUrl2" : publishVote.imageUrl2
                                                        }];
                        }
                    } else if ([weakSelf.currentPublishMTL isKindOfClass:[GFPublishPictureMTL class]]) {
                        GFPublishPictureMTL *publishPicture = (GFPublishPictureMTL *)weakSelf.currentPublishMTL;
                        for (NSString *path in publishPicture.pictures) {
                            if ([path hasPrefix:@"file"] || [path hasPrefix:@"/"]) {
                                [weakSelf.imageDataOrFile addObject:path];
                            }
                        }
                    }
                    
                    weakSelf.imageCount = [weakSelf.imageDataOrFile count];
                } else {
                    [weakSelf handleFailedPublish:weakSelf.currentPublishMTL errorMessage:apiErrorMessage];
                }
            } failure:^(NSUInteger taskId, NSError *error) {
                [weakSelf handleFailedPublish:weakSelf.currentPublishMTL errorMessage:@"请检查网络后重试"];
            }];
        } else {
            [self processNextPublishTask];
        }
        
    } else if ([keyPath isEqualToString:@"imageCount"]) {
        
        if (self.imageCount == 0) {

            if ([self.currentPublishMTL isKindOfClass:[GFPublishArticleMTL class]]) {
                [self publishArticle:(GFPublishArticleMTL *)self.currentPublishMTL];
            } else if ([self.currentPublishMTL isKindOfClass:[GFPublishVoteMTL class]]) {
                [self publishVote:(GFPublishVoteMTL *)self.currentPublishMTL];
            } else if ([self.currentPublishMTL isKindOfClass:[GFPublishLinkMTL class]]) {
                [self publishLink:(GFPublishLinkMTL *)self.currentPublishMTL];
            } else if ([self.currentPublishMTL isKindOfClass:[GFPublishPictureMTL class]]) {
                [self publishPicture:(GFPublishPictureMTL *)self.currentPublishMTL];
            }
            
        } else {
            // 继续向七牛上传下一张图片
            __weak typeof(self) weakSelf = self;
            if ([self.currentPublishMTL isKindOfClass:[GFPublishArticleMTL class]]) {
                NSString *imageToUpload = [self.imageDataOrFile objectAtIndex:0];
                if ([imageToUpload hasPrefix:@"file"] || [imageToUpload hasPrefix:@"/"]) {
                    NSString *sandboxFilePath = [imageToUpload stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                    
                    NSString *fixPath = [self fixSandboxFilePath:sandboxFilePath];
                    [self uploadImageFile:fixPath
                               qiniuToken:self.qiniuToken
                                  success:^(NSString *storeKey) {
                                      NSString *content = [weakSelf.currentPublishMTL valueForKey:@"content"];
                                      content = [content stringByReplacingOccurrencesOfString:imageToUpload withString:storeKey];
                                      [weakSelf.currentPublishMTL setValue:content forKey:@"content"];
                                      
                                      [weakSelf.imageDataOrFile removeObjectAtIndex:0];
                                      weakSelf.imageCount --;
                                  } failure:^{
                                      [weakSelf handleFailedPublish:weakSelf.currentPublishMTL errorMessage:@"发布帖子图片上传失败"];
                                  }];
                } else {
                    NSArray *components = [imageToUpload componentsSeparatedByString:@","];
                    if ([components count] > 1) {
                        NSString *base64String = [[imageToUpload componentsSeparatedByString:@","] lastObject];
                        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        [self uploadImageData:imageData
                                   qiniuToken:self.qiniuToken
                                      success:^(NSString *storeKey) {
                                          NSString *content = [weakSelf.currentPublishMTL valueForKey:@"content"];
                                          content = [content stringByReplacingOccurrencesOfString:imageToUpload withString:storeKey];
                                          [weakSelf.currentPublishMTL setValue:content forKey:@"content"];
                                          
                                          [weakSelf.imageDataOrFile removeObjectAtIndex:0];
                                          weakSelf.imageCount --;
                                      } failure:^{
                                          [weakSelf handleFailedPublish:weakSelf.currentPublishMTL errorMessage:@"发布帖子图片上传失败"];
                                      }];
                    } else {
                        [weakSelf.imageDataOrFile removeObjectAtIndex:0];
                        weakSelf.imageCount --;
                    }
                }

                
            } else if ([self.currentPublishMTL isKindOfClass:[GFPublishVoteMTL class]]) {
                
                GFPublishVoteMTL *publishVote = (GFPublishVoteMTL *)self.currentPublishMTL;
                
                NSDictionary *dict = [self.imageDataOrFile objectAtIndex:0];
                NSString *key = [[dict allKeys] objectAtIndex:0];
                
                NSString *path = [dict objectForKey:key];
                NSString *fixPath = [self fixSandboxFilePath:path];
                [self uploadImageFile:fixPath
                           qiniuToken:self.qiniuToken
                              success:^(NSString *storeKey) {
                                  if ([key isEqualToString:@"imageUrl1"]) {
                                      publishVote.imageUrl1 = storeKey;
                                  } else {
                                      publishVote.imageUrl2 = storeKey;
                                  }
                                  
                                  [weakSelf.imageDataOrFile removeObjectAtIndex:0];
                                  weakSelf.imageCount --;
                              } failure:^{
                                  [weakSelf handleFailedPublish:weakSelf.currentPublishMTL errorMessage:@"请检查网络后重试"];
                              }];

            } else if ([self.currentPublishMTL isKindOfClass:[GFPublishPictureMTL class]]) {
                
                GFPublishPictureMTL *publishPicture = (GFPublishPictureMTL *)self.currentPublishMTL;
                NSString *path = [self.imageDataOrFile objectAtIndex:0];
                
                 NSString *fixPath = [self fixSandboxFilePath:path];
                [self uploadImageFile:fixPath
                           qiniuToken:self.qiniuToken
                              success:^(NSString *storeKey) {
                                  
                                  NSInteger index = [publishPicture.pictures indexOfObject:path];
                                  NSMutableArray *mutablePictures = [publishPicture.pictures mutableCopy];
                                  [mutablePictures replaceObjectAtIndex:index withObject:storeKey];
                                  publishPicture.pictures = mutablePictures;
                                  
                                  [weakSelf.imageDataOrFile removeObjectAtIndex:0];
                                  weakSelf.imageCount --;
                                  
                              } failure:^{
                                  [weakSelf handleFailedPublish:weakSelf.currentPublishMTL errorMessage:@"请检查网络后重试"];
                              }];
            }
        }
    }
}

- (NSString *)fixSandboxFilePath:(NSString *)fakeSandBoxPath {
    
//    /var/mobile/Containers/Data/Application/33929570-8805-4CC4-8B8F-381519FFE0E8/Library/Caches/com.getfun.GetFun/publishImages/68ab278cd0bf97450dd7c12938c61d6d
    NSArray *components = [fakeSandBoxPath componentsSeparatedByString:@"com.getfun.GetFun"];
    NSString *lastPartPath = [components lastObject];
    NSString *fixPath = [[GFCacheUtil gf_persistentPath] stringByAppendingPathComponent:lastPartPath];
    return fixPath;
}

#pragma mark - 添加发布
+ (BOOL)publish:(GFPublishMTL *)publishMTL {
    
    GFPublishManager *manager = [GFPublishManager sharedManager];
    publishMTL.publishId = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    publishMTL.state = [NSNumber numberWithInteger:GFPublishStateWaiting];
    [manager.publishTaskList addObject:publishMTL];
    
    [manager processNextPublishTask];
    return YES;
}

+ (NSArray *)allWaitingTask {
    return [GFPublishManager sharedManager].publishTaskList;
}

+ (NSArray *)waitingTaskWithGroupId:(NSNumber *)groupId {

    if (!groupId) return nil;
    
    NSMutableArray *taskInGroup = [[NSMutableArray alloc] initWithCapacity:0];
    for (GFPublishMTL *task in [GFPublishManager sharedManager].publishTaskList) {
        if ([task.groupId isEqualToNumber:groupId]) { //上面已经判断groupId不为nil
            [taskInGroup addObject:task];
        }
    }
    
    return taskInGroup;
}

+ (NSArray *)waitingTaskWithTagId:(NSNumber *)tagId {

    if (!tagId) return nil;
    
    NSMutableArray *taskInTag = [[NSMutableArray alloc] initWithCapacity:0];
    for (GFPublishMTL *task in [GFPublishManager sharedManager].publishTaskList) {
        if ([task.tagId isKindOfClass:[NSNumber class]]) {
            if ([task.tagId isEqualToNumber:tagId]) {
                [taskInTag addObject:task];
            }
        }
    }
    
    return taskInTag;
}

+ (NSArray *)allFailedTask {
    return [GFPublishManager sharedManager].unpublishedTaskList;
}

+ (NSArray *)failedTaskListWithGroupId:(NSNumber *)groupId {
    
    if (!groupId) return nil;
    
    NSMutableArray *taskInGroup = [[NSMutableArray alloc] initWithCapacity:0];
    for (GFPublishMTL *task in [GFPublishManager sharedManager].unpublishedTaskList) {
        if ([task.groupId isEqualToNumber:groupId]) {
            [taskInGroup addObject:task];
        }
    }
    
    return taskInGroup;
}

+ (NSArray *)failedTaskListWithTagId:(NSNumber *)tagId {
    
    if (!tagId) return nil;
    
    NSMutableArray *taskInTag = [[NSMutableArray alloc] initWithCapacity:0];
    for (GFPublishMTL *task in [GFPublishManager sharedManager].unpublishedTaskList) {
        if ([task.tagId isEqualToNumber:tagId]) {
            [taskInTag addObject:task];
        }
    }
    
    return taskInTag;
}

+ (void)removeAllFailedTask {
    [[GFPublishManager sharedManager].unpublishedTaskList removeAllObjects];
}

+ (void)removeFailedTaskWithGroupId:(NSNumber *)groupId {
    
    GFPublishManager *manager = [GFPublishManager sharedManager];
    
    NSArray *tasksInGroup = [self failedTaskListWithGroupId:groupId];
    [manager.unpublishedTaskList removeObjectsInArray:tasksInGroup];
    
    [manager processNextPublishTask];
}

+ (void)removeFailedTaskWithTagId:(NSNumber *)tagId {
    
    GFPublishManager *manager = [GFPublishManager sharedManager];
    
    NSArray *tasksInTag = [self failedTaskListWithTagId:tagId];
    [manager.unpublishedTaskList removeObjectsInArray:tasksInTag];
    
    [manager processNextPublishTask];
}

+ (void)retryAllFailedTask {
    
    GFPublishManager *manager = [GFPublishManager sharedManager];
    [manager.publishTaskList addObjectsFromArray:manager.unpublishedTaskList];
    [manager.unpublishedTaskList removeAllObjects];
    [manager processNextPublishTask];
}

+ (void)retryFailedTaskWithGroupId:(NSNumber *)groupId {
    
    GFPublishManager *manager = [GFPublishManager sharedManager];
    
    NSArray *tasksInGroup = [self failedTaskListWithGroupId:groupId];
    if (tasksInGroup && [tasksInGroup count] > 0) {
        [manager.unpublishedTaskList removeObjectsInArray:tasksInGroup];
        [manager.publishTaskList addObjectsFromArray:tasksInGroup];
    }
    [manager processNextPublishTask];
}

+ (void)retryFailedTaskWithTagId:(NSNumber *)tagId {
    
    GFPublishManager *manager = [GFPublishManager sharedManager];
    
    NSArray *tasksInTag = [self failedTaskListWithTagId:tagId];
    if (tasksInTag && [tasksInTag count] > 0) {
        [manager.unpublishedTaskList removeObjectsInArray:tasksInTag];
        [manager.publishTaskList addObjectsFromArray:tasksInTag];
    }
    [manager processNextPublishTask];
}

- (void)processNextPublishTask {
    
    if (self.currentPublishMTL == nil && [self.publishTaskList count] > 0) {
        self.currentPublishMTL = [self.publishTaskList firstObject];
        self.currentPublishMTL.state = [NSNumber numberWithInteger:GFPublishStateSending];
        //发送通知，提示开始发送，处于发送状态中
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
        [userInfo setObject:self.currentPublishMTL forKey:kPublishNotificationUserInfoKeyData];
        [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationPublishStateUpdate
                                                            object:nil
                                                          userInfo:userInfo];
        
    }
}

#pragma mark - 实际发布逻辑
- (void)publishArticle:(GFPublishArticleMTL *)publishArticle {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager publishArticle:publishArticle
                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content) {
                                 [weakSelf handleSuccessPublish:publishArticle
                                                           code:code
                                                   errorMessage:apiErrorMessage
                                                        content:content];
                             } failure:^(NSUInteger taskId, NSError *error) {
                                 [weakSelf handleFailedPublish:publishArticle errorMessage:@"请检查网络后重试"];
                             }];
}

- (void)publishLink:(GFPublishLinkMTL *)publishLink {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager publishLink:publishLink
                          success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content) {
                              [weakSelf handleSuccessPublish:publishLink
                                                        code:code
                                                errorMessage:apiErrorMessage
                                                     content:content];
                          } failure:^(NSUInteger taskId, NSError *error) {
                              [weakSelf handleFailedPublish:publishLink errorMessage:@"请检查网络后重试"];
                          }];
}

- (void)publishVote:(GFPublishVoteMTL *)publishVote {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager publishVote:publishVote
                          success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content) {
                              [weakSelf handleSuccessPublish:publishVote
                                                        code:code
                                                errorMessage:apiErrorMessage
                                                     content:content];
                          } failure:^(NSUInteger taskId, NSError *error) {
                              [weakSelf handleFailedPublish:publishVote errorMessage:@"请检查网络后重试"];
                          }];
}

- (void)publishPicture:(GFPublishPictureMTL *)publishPicture {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager publishPicture:publishPicture
                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFContentMTL *content) {
                                 [weakSelf handleSuccessPublish:publishPicture
                                                           code:code
                                                   errorMessage:apiErrorMessage
                                                        content:content];
                             } failure:^(NSUInteger taskId, NSError *error) {
                                 [weakSelf handleFailedPublish:publishPicture errorMessage:@"请检查网络后重试"];
                             }];
}

- (void)handleSuccessPublish:(GFPublishMTL *)publishMTL
                        code:(NSInteger)code
                errorMessage:(NSString *)errorMessage
                     content:(GFContentMTL *)content {
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if (code == 1) {
        
        [self.publishTaskList removeObjectAtIndex:0];
        
        if (content) {
            [userInfo setObject:content forKey:kPublishNotificationUserInfoKeyData];
            [userInfo setObject:publishMTL forKey:kPublishNotificationUserInfoKeyOrigin];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationPublishStateUpdate
                                                            object:nil
                                                          userInfo:userInfo];
    } else {
        
        publishMTL.state = [NSNumber numberWithInteger:GFPublishStateFailed];
        [self.publishTaskList removeObjectAtIndex:0];
        [self.unpublishedTaskList addObject:publishMTL];
        
        [userInfo setObject:publishMTL forKey:kPublishNotificationUserInfoKeyData];
        if (errorMessage) {
            [userInfo setObject:errorMessage forKey:kPublishNotificationUserInfoKeyMsg];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationPublishStateUpdate
                                                            object:nil
                                                          userInfo:userInfo];
    }
    
    self.currentPublishMTL = nil;
}

- (void)handleFailedPublish:(GFPublishMTL *)publishMTL errorMessage:(NSString *)errorMessage {
    
    publishMTL.state = [NSNumber numberWithInteger:GFPublishStateFailed];
    [self.publishTaskList removeObjectAtIndex:0];
    [self.unpublishedTaskList addObject:publishMTL];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    [userInfo setObject:publishMTL forKey:kPublishNotificationUserInfoKeyData];
    if (errorMessage) {
        [userInfo setObject:errorMessage forKey:kPublishNotificationUserInfoKeyMsg];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:GFNotificationPublishStateUpdate
                                                        object:nil
                                                      userInfo:userInfo];
    
    self.currentPublishMTL = nil;
}

#pragma mark 通用图片上传
- (void)uploadImageData:(NSData *)data
             qiniuToken:(NSString *)token
                success:(void (^)(NSString *storeKey))success
                failure:(void(^)())failure {
    [self.uploadManager putData:data
                            key:nil
                          token:token
                       complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {

                           if (resp) {
                               NSDictionary *picture = [resp objectForKey:@"picture"];
                               NSString *storeKey = [picture objectForKey:@"storeKey"];
                               if (success) {
                                   success(storeKey);
                               }
                           } else {
                               if (failure) {
                                   failure();
                               }
                           }
                       } option:nil];
}

- (void)uploadImageFile:(NSString *)filePath
             qiniuToken:(NSString *)token
                success:(void (^)(NSString *storeKey))success
                failure:(void(^)())failure {
    [self.uploadManager putFile:filePath
                            key:nil
                          token:token
                       complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                           if (resp) {
                               NSDictionary *picture = [resp objectForKey:@"picture"];
                               NSString *storeKey = [picture objectForKey:@"storeKey"];
                               if (success) {
                                   success(storeKey);
                               }
                           } else {
                               if (failure) {
                                   failure();
                               }
                           }
                       } option:nil];
}

@end
