//
//  GFCacheUtil.m
//  IfengFM
//
//  Created by zhouxz on 15/2/17.
//  Copyright (c) 2015年 IfengFM. All rights reserved.
//

#import "GFCacheUtil.h"
#import <sys/param.h>
#import <sys/mount.h>

@implementation GFCacheUtil

+ (double)cacheSizeInPath:(NSString *)path {
    // 1.获得文件夹管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 2.检测路径的合理性
    BOOL dir = NO;
    BOOL exits = [mgr fileExistsAtPath:path isDirectory:&dir];
    if (!exits) return 0;
    
    // 3.判断是否为文件夹
    if (dir) { // 文件夹, 遍历文件夹里面的所有文件
        // 这个方法能获得这个文件夹下面的所有子路径(直接\间接子路径)
        NSArray *subpaths = [mgr subpathsAtPath:path];
        int totalSize = 0;
        for (NSString *subpath in subpaths) {
            NSString *fullsubpath = [path stringByAppendingPathComponent:subpath];
            
            BOOL dir = NO;
            [mgr fileExistsAtPath:fullsubpath isDirectory:&dir];
            if (!dir) { // 子路径是个文件
                NSDictionary *attrs = [mgr attributesOfItemAtPath:fullsubpath error:nil];
                totalSize += [attrs[NSFileSize] intValue];
            }
        }
        return totalSize / (1024.0f * 1024.0f);
    } else { // 文件
        NSDictionary *attrs = [mgr attributesOfItemAtPath:path error:nil];
        return [attrs[NSFileSize] intValue] / (1024.0f * 1024.0f);
    }
}

+ (void)cleanCacheInPath:(NSString *)path {
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 这个方法能获得这个文件夹下面的所有子路径(直接\间接子路径)
    NSArray *subpaths = [mgr subpathsAtPath:path];
    for (NSString *subpath in subpaths) {
        NSString *fullSubPath = [path stringByAppendingPathComponent:subpath];
        NSError *error;
        [mgr removeItemAtPath:fullSubPath error:&error];
        if (error) {

        } else {

        }
    }
}

+ (double)usableSpaceInDevice {
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace/ (1024.0f * 1024.0f);
}

+ (NSString *)gf_persistentPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"com.getfun.GetFun"];
    
    NSError *error;
    if ([[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:path] withIntermediateDirectories:YES attributes:nil error:&error]) {
        return path;
    } else {
        return nil;
    }
}
@end
