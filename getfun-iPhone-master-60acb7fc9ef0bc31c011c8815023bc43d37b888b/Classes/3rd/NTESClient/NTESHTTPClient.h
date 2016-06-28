//
//  NTESHTTPClient.h
//  iOSTemplate
//
//  Created by akin on 15-6-17.
//  Copyright (c) 2015年 akin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTESHTTPConfigProtocol.h"
#import "NTESHTTPTask.h"
#import "NTESHTTPSessionManager.h"

/**
 TODO:client 需要可配置
 结果对外统一暴漏结果的block
 */

@interface NTESHTTPClient : NSObject

@property (nonatomic, strong) NTESHTTPSessionManager *sessionManager;

/**
 *  获取当前client client 为单例
 *
 *  @return NTESHTClient
 */
+ (NTESHTTPClient *)sharedManager;

/**
 *  配置Client
 *
 *  @param config
 */
- (void)setHTTPConfig:(id<NTESHTTPConfigProtocol>)config;

/**
 *  创建一个dataTask，注意这个方法并不立刻执行dataTask，可以调用-beginTask:withKey:unique:方法来执行这个task
 *
 *  @param method     NHTRequestMethodGET等方法
 *  @param URLString  这个URLString如果设置了baseURL，可以不传递baseURL部分
 *  @param parameters 可以为NSDictionary, NSArray, NSSet或者NSString等和其派生类
 *  @param success    完成回调
 *  @param failure    错误回调
 *
 *  @return 返回一个NTESHTTPTask，如果不想使用本类提供的一些方法，可以自己管理这个task，这个task默认并不自动执行，可以调用resume来手动启动，或者调用-beginTask:withKey:unique:方法来执行这个task
 */
- (NTESHTTPTask *)dataTaskWithHTTPMethod:(NSString *)method
                               URLString:(NSString *)URLString
                              parameters:(id)parameters
                                 success:(void (^)(NTESHTTPTask *task, id responseObject))success
                                 failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;
/**
 *  启动task的方法，这个方法可以根据key设置请求唯一（对于当前key，每次请求都会取消前一次请求（如果前一次请求没有完成））
 *
 *  @param task   需要启动的task，如果传递nil，则不会发生任何事
 *  @param key    用来查询task的key
 *  @param unique 是否唯一，如果这个属性设置为YES，那么key不能为nil，否则会报错，如果想取消所有没有key的task，可以调用[self cancelTasksForKey:NHTSessionDefaultKey]来实现
 */
- (void)beginTask:(NTESHTTPTask *)task withKey:(NSString *)key unique:(BOOL)unique;

- (NSArray *)tasksForKey:(NSString *)key;
- (NTESHTTPTask *)taskForId:(NSUInteger)taskId;

/**
 *  取消某个key下的所有task，如果key为nil，则会取消所有请求
 */
- (void)cancelTasksForKey:(NSString *)key;
- (void)cancelTaskForTaskId:(NSUInteger)taskId;

@end

@interface NTESHTTPClient (Conveniences)

/**
 *  get 请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskId 可以用来取消任务
 */
- (NSUInteger)GET:(NSString *)URLString
       parameters:(id)parameters
          success:(void (^)(NSUInteger taskId, id responseObject))success
          failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  header 请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskId 可以用来取消任务
 */
- (NSUInteger)HEAD:(NSString *)URLString
        parameters:(id)parameters
           success:(void (^)(NSUInteger taskId))success
           failure:(void (^)(NSUInteger taskId, NSError *error))failure;
/**
 *  post 请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskId 可以用来取消任务
 */
- (NSUInteger)POST:(NSString *)URLString
        parameters:(id)parameters
           success:(void (^)(NSUInteger taskId, id responseObject))success
           failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 Creates and runs an `NSURLSessionDataTask` with a multipart `POST` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param data The data to be encoded and appended to the form data.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param fileName The filename to be associated with the specified data. This parameter must not be `nil`.
 @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 @return taskId 可以用来取消任务
 */
- (NSUInteger)POST:(NSString *)URLString
        parameters:(id)parameters
              data:(NSData *)data
              name:(NSString *)name
          fileName:(NSString *)fileName
          mimeType:(NSString *)mimeType
           success:(void (^)(NSUInteger taskId, id responseObject))success
           failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  创建一个put 请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskId 可以用来取消任务
 */
- (NSUInteger)PUT:(NSString *)URLString
       parameters:(id)parameters
          success:(void (^)(NSUInteger taskId, id responseObject))success
          failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  创建一个patch 请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskId 可以用来取消任务
 */
- (NSUInteger)PATCH:(NSString *)URLString
         parameters:(id)parameters
            success:(void (^)(NSUInteger taskId, id responseObject))success
            failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  创建一个delete 请求
 *
 *  @param URLString
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskId 可以用来取消任务
 */
- (NSUInteger)DELETE:(NSString *)URLString
          parameters:(id)parameters
             success:(void (^)(NSUInteger taskId, id responseObject))success
             failure:(void (^)(NSUInteger taskId, NSError *error))failure;

@end
