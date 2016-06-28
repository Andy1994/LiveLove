//
//  GFCacheUtil.h
//  IfengFM
//
//  Created by zhouxz on 15/2/17.
//  Copyright (c) 2015年 IfengFM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPathLibraryDirectory         ([NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject])
#define kPathDocumentDirectory        ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject])
#define kPathPreferencePanesDirectory ([NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) lastObject])
#define kPathLibraryCacheDirectory    ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject])


@interface GFCacheUtil : NSObject

/**
 *  返回path路径下文件的文件大小, 单位 M
 */
+ (double)cacheSizeInPath:(NSString *)path;

/**
 *  删除path路径下的文件
 */
+ (void)cleanCacheInPath:(NSString *)path;

/**
 *  获取设备剩余空间
 *
 *  @return 剩余空间, 单位 M
 */
+ (double)usableSpaceInDevice;

+ (NSString *)gf_persistentPath;

@end
