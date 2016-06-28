//
//  NTESHTTPClient.m
//  iOSTemplate
//
//  Created by akin on 15-6-17.
//  Copyright (c) 2015年 akin. All rights reserved.
//

#import "NTESHTTPClient.h"

@interface NTESHTTPClient ()

@property (nonatomic, strong) id<NTESHTTPConfigProtocol>config;

@property (nonatomic, strong) NSMutableDictionary *sessionDict;


@end

@implementation NTESHTTPClient

+ (NTESHTTPClient *)sharedManager
{
    static NTESHTTPClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

#pragma mark - getter setter
- (NTESHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        if ([self.config respondsToSelector:@selector(sessionConfiguration)]) {
            _sessionManager = [[NTESHTTPSessionManager alloc] initWithSessionConfiguration:[self.config sessionConfiguration]];
        } else {
            _sessionManager = [NTESHTTPSessionManager manager];
        }
        
        if ([self.config respondsToSelector:@selector(baseURL)]) {
            _sessionManager.baseURL = [self.config baseURL];
        }

        if ([self.config respondsToSelector:@selector(acceptableContentTypes)]) {
            NSSet *type = [self.config acceptableContentTypes];
            [_sessionManager setAcceptableContentTypes:type];
        }
        
        if ([self.config respondsToSelector:@selector(sessionHeaderFields)]) {
            [_sessionManager setDefaultHeaderFields:[self.config sessionHeaderFields]];
        }
    }
    return _sessionManager;
    
}

-(NSMutableDictionary *)sessionDict {
    if (!_sessionDict) {
        _sessionDict = [NSMutableDictionary dictionary];
    }
    return _sessionDict;
}

- (void)setHTTPConfig:(id<NTESHTTPConfigProtocol>)config
{
    self.config = config;
}

#pragma mark - Tasks Management

-(void)beginTask:(NTESHTTPTask *)task withKey:(NSString *)key unique:(BOOL)unique {
    
    if (!task) {
        return;
    }
    
    if (unique) {
        [self cancelTasksForKey:key];
    }
    [self addTask:task forKey:key?:NHTSessionDefaultKey];
    
    [task resume];
}

-(void)addTask:(NTESHTTPTask *)task forKey:(NSString *)key {
    
    NSHashTable *hashTable = self.sessionDict[key]?:[NSHashTable weakObjectsHashTable];
    
    [hashTable addObject:task];
    _sessionDict[key] = hashTable;
}

-(NTESHTTPTask *)taskForId:(NSUInteger)taskId {
    __block NTESHTTPTask *task;
    [_sessionDict enumerateKeysAndObjectsUsingBlock:^(id key, NSHashTable* hashTable, BOOL *stop) {
        [[[hashTable objectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NTESHTTPTask* obj, NSUInteger idx, BOOL *stop) {
            if (obj.identifier == taskId) {
                task = obj;
                *stop = YES;
            }
        }];
    }];
    return task;
}

-(NSArray *)tasksForKey:(NSString *)key {
    return [_sessionDict[key] allObjects];
}

-(void)cancelTasksForKey:(NSString *)key {
    if (key) {
        NSHashTable *hashTable = _sessionDict[key];
        [[[hashTable objectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NTESHTTPTask* obj, NSUInteger idx, BOOL *stop) {
            [obj cancel];
        }];
    } else {
        [_sessionDict enumerateKeysAndObjectsUsingBlock:^(id key, NSHashTable* hashTable, BOOL *stop) {
            [[[hashTable objectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NTESHTTPTask* obj, NSUInteger idx, BOOL *stop) {
                [obj cancel];
            }];
        }];
    }
}

-(void)cancelTaskForTaskId:(NSUInteger)taskId {
    [_sessionDict enumerateKeysAndObjectsUsingBlock:^(id key, NSHashTable* hashTable, BOOL *stop) {
        [[[hashTable objectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NTESHTTPTask* obj, NSUInteger idx, BOOL *stop) {
            if (obj.identifier == taskId) {
                [obj cancel];
            }
        }];
    }];
}

#pragma mark - task creation
- (NTESHTTPTask *)dataTaskWithHTTPMethod:(NSString * const)method
                               URLString:(NSString * const)URLString
                              parameters:(id)parameters
                                 success:(void (^)(NTESHTTPTask *, id))success
                                 failure:(void (^)(NTESHTTPTask *, NSError *))failure {
    
    NTESHTTPTask *task = [self.sessionManager dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
    return task;
}
@end


@implementation NTESHTTPClient (Conveniences)

- (NSUInteger)GET:(NSString *)URLString
       parameters:(id)parameters
          success:(void (^)(NSUInteger taskId, id responseObject))success
          failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NTESHTTPTask *dataTask = [self.sessionManager GET:URLString parameters:parameters success:^(NTESHTTPTask *task, id responseObject) {
        success(task.identifier, responseObject);
    } failure:^(NTESHTTPTask *task, NSError *error) {
        failure(task.identifier, error);
    }];
    [self beginTask:dataTask withKey:NHTSessionDefaultKey unique:NO];
    return dataTask.identifier;
}

-(NSUInteger)HEAD:(NSString *)URLString
       parameters:(id)parameters
          success:(void (^)(NSUInteger taskId))success
          failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NTESHTTPTask *dataTask = [self.sessionManager HEAD:URLString parameters:parameters success:^(NTESHTTPTask *task) {
        success(task.identifier);
    } failure:^(NTESHTTPTask *task, NSError *error) {
        failure(task.identifier, error);
    }];
    [self beginTask:dataTask withKey:NHTSessionDefaultKey unique:NO];
    return dataTask.identifier;
}

- (NSUInteger)POST:(NSString *)URLString
        parameters:(id)parameters
           success:(void (^)(NSUInteger taskId, id responseObject))success
           failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NTESHTTPTask *dataTask = [self.sessionManager POST:URLString parameters:parameters success:^(NTESHTTPTask *task, id responseObject) {
        success(task.identifier, responseObject);
    } failure:^(NTESHTTPTask *task, NSError *error) {
        failure(task.identifier, error);
    }];
    [self beginTask:dataTask withKey:NHTSessionDefaultKey unique:NO];
    return dataTask.identifier;
}

- (NSUInteger)POST:(NSString *)URLString
        parameters:(id)parameters
              data:(NSData *)data
              name:(NSString *)name
          fileName:(NSString *)fileName
          mimeType:(NSString *)mimeType
           success:(void (^)(NSUInteger taskId, id responseObject))success
           failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NTESHTTPTask *dataTask = [self.sessionManager POST:URLString parameters:parameters data:data name:name fileName:fileName mimeType:mimeType success:^(NTESHTTPTask *task, id responseObject) {
        success(task.identifier, responseObject);
    } failure:^(NTESHTTPTask *task, NSError *error) {
        failure(task.identifier, error);
    }];
    [self beginTask:dataTask withKey:NHTSessionDefaultKey unique:NO];
    return dataTask.identifier;
}

- (NSUInteger)PUT:(NSString *)URLString
       parameters:(id)parameters
          success:(void (^)(NSUInteger taskId, id responseObject))success
          failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NTESHTTPTask *dataTask = [self.sessionManager PUT:URLString parameters:parameters success:^(NTESHTTPTask *task, id responseObject) {
        success(task.identifier, responseObject);
    } failure:^(NTESHTTPTask *task, NSError *error) {
        failure(task.identifier, error);
    }];
    [self beginTask:dataTask withKey:NHTSessionDefaultKey unique:NO];
    return dataTask.identifier;
}

- (NSUInteger)PATCH:(NSString *)URLString
         parameters:(id)parameters
            success:(void (^)(NSUInteger taskId, id responseObject))success
            failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NTESHTTPTask *dataTask = [self.sessionManager PATCH:URLString parameters:parameters success:^(NTESHTTPTask *task, id responseObject) {
        success(task.identifier, responseObject);
    } failure:^(NTESHTTPTask *task, NSError *error) {
        failure(task.identifier, error);
    }];
    [self beginTask:dataTask withKey:NHTSessionDefaultKey unique:NO];
    return dataTask.identifier;
}

- (NSUInteger)DELETE:(NSString *)URLString
          parameters:(id)parameters
             success:(void (^)(NSUInteger taskId, id responseObject))success
             failure:(void (^)(NSUInteger taskId, NSError *error))failure
{
    NTESHTTPTask *dataTask = [self.sessionManager DELETE:URLString parameters:parameters success:^(NTESHTTPTask *task, id responseObject) {
        success(task.identifier, responseObject);
    } failure:^(NTESHTTPTask *task, NSError *error) {
        failure(task.identifier, error);
    }];
    [self beginTask:dataTask withKey:NHTSessionDefaultKey unique:NO];
    return dataTask.identifier;
}


@end
