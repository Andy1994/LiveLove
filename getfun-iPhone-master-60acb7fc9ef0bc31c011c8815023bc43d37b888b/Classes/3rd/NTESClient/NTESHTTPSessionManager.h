//
//  NTESHTTPRequestOperationManager.h
//  iOSTemplate
//
//  Created by akin on 15-6-17.
//  Copyright (c) 2015年 akin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "NTESHTTPTask.h"

extern NSString * const NHTRequestMethodGET;
extern NSString * const NHTRequestMethodHEAD;
extern NSString * const NHTRequestMethodPOST;
extern NSString * const NHTRequestMethodPUT;
extern NSString * const NHTRequestMethodDELETE;
extern NSString * const NHTRequestMethodPATCH;

extern NSString * const NHTSessionDefaultKey;

@interface NTESHTTPSessionManager : NSObject

/**
 *  baseURL may be nil
 */
@property (nonatomic, copy) NSURL *baseURL;

/**
 Creates and returns an `NTESHTTPSessionManager` object.
 */
+ (instancetype)manager;

/**
 *  designated initializer
 */
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

/**
 The acceptable HTTP status codes for responses. When non-`nil`, responses with status codes not contained by the set will result in an error during validation.
 See http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 */
- (void)setAcceptableStatusCodes:(NSIndexSet *)acceptableStatusCodes;

/**
 The acceptable MIME types for responses. When non-`nil`, responses with a `Content-Type` with MIME types that do not intersect with the set will result in an error during validation.
 default is
 `[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];`
 */
- (void)setAcceptableContentTypes:(NSSet *)acceptableContentTypes;

- (void)setDefaultHeaderFields:(NSDictionary *)headerFields;

- (NTESHTTPTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NTESHTTPTask *task, id responseObject))success
                                         failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

///---------------------------
/// @name Making HTTP Requests
///---------------------------

/**
 Creates an `NSURLSessionDataTask` with a `GET` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NTESHTTPTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NTESHTTPTask *task, id responseObject))success
                      failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

/**
 Creates an `NSURLSessionDataTask` with a `HEAD` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes a single arguments: the data task.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NTESHTTPTask *)HEAD:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NTESHTTPTask *task))success
                       failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

/**
 Creates an `NSURLSessionDataTask` with a `POST` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NTESHTTPTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NTESHTTPTask *task, id responseObject))success
                       failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

/**
 Creates an `NSURLSessionDataTask` with a multipart `POST` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param data The data to be encoded and appended to the form data.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 @param fileName The filename to be associated with the specified data. This parameter must not be `nil`.
 @param mimeType The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NTESHTTPTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                          data:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType
                       success:(void (^)(NTESHTTPTask *task, id responseObject))success
                       failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

/**
 Creates an `NSURLSessionDataTask` with a `PUT` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NTESHTTPTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NTESHTTPTask *task, id responseObject))success
                      failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

/**
 Creates an `NSURLSessionDataTask` with a `PATCH` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NTESHTTPTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(NTESHTTPTask *task, id responseObject))success
                        failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

/**
 Creates an `NSURLSessionDataTask` with a `DELETE` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (NTESHTTPTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NTESHTTPTask *task, id responseObject))success
                         failure:(void (^)(NTESHTTPTask *task, NSError *error))failure;

@end
