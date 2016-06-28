//
//  NTESHTTPRequestOperationManager.m
//  iOSTemplate
//
//  Created by akin on 15-6-17.
//  Copyright (c) 2015年 akin. All rights reserved.
//

#import "NTESHTTPSessionManager.h"

NSString * const NHTRequestMethodGET = @"GET";
NSString * const NHTRequestMethodHEAD = @"HEAD";
NSString * const NHTRequestMethodPOST = @"POST";
NSString * const NHTRequestMethodPUT = @"PUT";
NSString * const NHTRequestMethodDELETE = @"DELETE";
NSString * const NHTRequestMethodPATCH = @"PATCH";

NSString * const NHTSessionDefaultKey = @"NHTSessionDefaultKey";

@interface NTESHTTPSessionManager ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;

@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;

@property (nonatomic, strong) NSURLSessionConfiguration *configuration;

@end

@implementation NTESHTTPSessionManager

+ (instancetype)manager
{
    return [[self alloc] initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _configuration = configuration;
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (AFURLSessionManager *)sessionManager
{
    if (nil == _sessionManager) {
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:self.configuration];
    }
    return _sessionManager;
}

- (void)setAcceptableStatusCodes:(NSIndexSet *)acceptableStatusCodes
{
    ((AFJSONResponseSerializer *)self.sessionManager.responseSerializer).acceptableStatusCodes = acceptableStatusCodes;
}

- (void)setAcceptableContentTypes:(NSSet *)acceptableContentTypes
{
    ((AFJSONResponseSerializer *)self.sessionManager.responseSerializer).acceptableContentTypes = acceptableContentTypes;
}

- (void)setDefaultHeaderFields:(NSDictionary *)headerFields {
    if (![headerFields objectForKey:@"access_token"]) {
        [self.requestSerializer setValue:nil forHTTPHeaderField:@"access_token"];
    }

    [headerFields enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * value, BOOL *stop) {
        if ([key isEqualToString:@"User-Agent"]) {
            NSString *originUserAgent = [[self.requestSerializer HTTPRequestHeaders] objectForKey:key];
            if ([originUserAgent rangeOfString:value].location == NSNotFound) {
                NSString *userAgentString = [NSString stringWithFormat:@"%@ (%@)", originUserAgent, value];
                [self.requestSerializer setValue:userAgentString forHTTPHeaderField:key];
            }
        }
        else {
            [self.requestSerializer setValue:([value isKindOfClass:[NSNull class]])?nil:value forHTTPHeaderField:key];
        }

    }];
}

- (NTESHTTPTask *)dataTaskWithHTTPMethod:(NSString * const)method
                               URLString:(NSString * const)URLString
                              parameters:(id)parameters
                                 success:(void (^)(NTESHTTPTask *, id))success
                                 failure:(void (^)(NTESHTTPTask *, NSError *))failure
{
    NSString *url = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:url parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            dispatch_async(self.sessionManager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        
        return nil;
    }
    
    NSURLSessionTask *dataTask = nil;
    __block NTESHTTPTask *httpTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(httpTask, error);
            }
        } else {
            if (success) {
                success(httpTask, responseObject);
            }
        }
    }];
    
    httpTask = [self httpTaskWithSessionTask:dataTask];
    
    return httpTask;
}

-(NTESHTTPTask *)httpTaskWithSessionTask:(NSURLSessionTask *)task {
    NTESHTTPTask *httpTask = [NTESHTTPTask new];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    //这里有一些tricky，我们不想暴露URLSessionTask出来，所以在NTESHTTPTask内隐藏了一个setTask:方法进行设置
    [httpTask performSelector:@selector(setTask:) withObject:task];
#pragma clang diagnostic pop
    return httpTask;
}

#pragma mark - convenient methods
- (NTESHTTPTask *)GET:(NSString *)URLString
           parameters:(id)parameters
              success:(void (^)(NTESHTTPTask *task, id responseObject))success
              failure:(void (^)(NTESHTTPTask *task, NSError *error))failure
{
    NTESHTTPTask *task = [self dataTaskWithHTTPMethod:NHTRequestMethodGET URLString:URLString parameters:parameters success:success failure:failure];
    
    return task;
}

- (NTESHTTPTask *)HEAD:(NSString *)URLString
            parameters:(id)parameters
               success:(void (^)(NTESHTTPTask *task))success
               failure:(void (^)(NTESHTTPTask *task, NSError *error))failure
{
    NTESHTTPTask *task = [self dataTaskWithHTTPMethod:NHTRequestMethodHEAD URLString:URLString parameters:parameters success:^(NTESHTTPTask *task, id responseObject) {
        success(task);
    } failure:failure];
    
    return task;
}

- (NTESHTTPTask *)POST:(NSString *)URLString
            parameters:(id)parameters
               success:(void (^)(NTESHTTPTask *task, id responseObject))success
               failure:(void (^)(NTESHTTPTask *task, NSError *error))failure
{
    NTESHTTPTask *task = [self dataTaskWithHTTPMethod:NHTRequestMethodPOST URLString:URLString parameters:parameters success:success failure:failure];
    
    return task;
}

- (NTESHTTPTask *)POST:(NSString *)URLString
            parameters:(id)parameters
                  data:(NSData *)data
                  name:(NSString *)name
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
               success:(void (^)(NTESHTTPTask *task, id responseObject))success
               failure:(void (^)(NTESHTTPTask *task, NSError *error))failure
{
    NSString *url = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:NHTRequestMethodPOST URLString:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data
                                    name:name
                                fileName:fileName
                                mimeType:mimeType];
        
    } error:&serializationError];
    
    if (serializationError) {
        if (failure) {
            dispatch_async(self.sessionManager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        
        return nil;
    }
    
    NSURLSessionTask *dataTask = nil;
    __block NTESHTTPTask *httpTask = nil;
    
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(httpTask, error);
            }
        } else {
            if (success) {
                success(httpTask, responseObject);
            }
        }
    }];
    httpTask = [self httpTaskWithSessionTask:dataTask];
    
    return httpTask;
}

- (NTESHTTPTask *)PUT:(NSString *)URLString
           parameters:(id)parameters
              success:(void (^)(NTESHTTPTask *task, id responseObject))success
              failure:(void (^)(NTESHTTPTask *task, NSError *error))failure
{
    NTESHTTPTask *task = [self dataTaskWithHTTPMethod:NHTRequestMethodPUT URLString:URLString parameters:parameters success:success failure:failure];
    
    return task;
}

- (NTESHTTPTask *)PATCH:(NSString *)URLString
             parameters:(id)parameters
                success:(void (^)(NTESHTTPTask *task, id responseObject))success
                failure:(void (^)(NTESHTTPTask *task, NSError *error))failure
{
    NTESHTTPTask *task = [self dataTaskWithHTTPMethod:NHTRequestMethodPATCH URLString:URLString parameters:parameters success:success failure:failure];
    
    return task;
}

- (NTESHTTPTask *)DELETE:(NSString *)URLString
              parameters:(id)parameters
                 success:(void (^)(NTESHTTPTask *task, id responseObject))success
                 failure:(void (^)(NTESHTTPTask *task, NSError *error))failure
{
    NTESHTTPTask *task = [self dataTaskWithHTTPMethod:NHTRequestMethodDELETE URLString:URLString parameters:parameters success:success failure:failure];
    
    return task;
}
@end
