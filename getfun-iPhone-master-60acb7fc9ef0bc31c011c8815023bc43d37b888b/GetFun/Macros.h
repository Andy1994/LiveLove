//
//  Macros.h
//  DuiNiuTanQin
//
//  Created by muhuaxin on 15/11/9.
//  Copyright © 2015年 DNTQ. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

//测试环境
//#define GF_API_BASE_URL @"http://182.92.150.87:8081"
//#define GF_API_BASE_URL @"http://182.92.150.87:9080"
//#define GF_API_BASE_URL @"http://182.92.150.87:8080"
//#define GF_API_BASE_URL @"http://192.168.1.51:8080"

//预发布环境
//#define GF_API_BASE_URL @"http://123.57.77.79:8080"
//#define GF_API_BASE_URL @"http://pre-online.17getfun.com"

//正式环境
#define GF_API_BASE_URL @"https://www.17getfun.com"

#define ApiAddress(x) [GF_API_BASE_URL stringByAppendingPathComponent:x]

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define	APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_BUILD [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define APP_VERSION_EQUAL_TO(v) ([APP_VERSION compare:v options:NSNumericSearch] == NSOrderedSame)
#define APP_VERSION_GREATER_THAN(v) ([APP_VERSION compare:v options:NSNumericSearch] == NSOrderedDescending)
#define APP_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([APP_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
#define APP_VERSION_LESS_THAN(v) ([APP_VERSION compare:v options:NSNumericSearch] == NSOrderedAscending)
#define APP_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([APP_VERSION compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SYSTEM_VERSION [[UIDevice currentDevice] systemVersion]
#define SYSTEM_VERSION_EQUAL_TO(v) ([SYSTEM_VERSION compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) ([SYSTEM_VERSION compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([SYSTEM_VERSION compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedDescending)

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


#endif /* Macros_h */
