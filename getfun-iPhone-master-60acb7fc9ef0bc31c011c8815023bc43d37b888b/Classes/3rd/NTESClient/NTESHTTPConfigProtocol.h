//
//  NTESHTTPConfigDelegate.h
//  iOSTemplate
//
//  Created by akin on 15-6-18.
//  Copyright (c) 2015年 akin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTESHTTPConfigProtocol <NSObject>

@optional

@property(readonly, nonatomic) NSURLSessionConfiguration *sessionConfiguration;

@property(readonly, nonatomic) NSURL *baseURL;

/**
 *  设置请求头，如果想删除其中某个值，可以设置其value为[NSNull null]
 */
@property(readonly, nonatomic) NSDictionary *sessionHeaderFields;


@property(readonly, nonatomic) NSSet *acceptableContentTypes;

@end

