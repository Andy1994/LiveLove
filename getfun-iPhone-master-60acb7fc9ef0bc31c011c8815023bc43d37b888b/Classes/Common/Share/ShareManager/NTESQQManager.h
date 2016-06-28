//
//  NTESQQManager.h
//  ShareDemo
//
//  Created by muhuaxin on 16/7/15.
//  Copyright (c) 2015 NTES. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESQQManager : NSObject

+ (BOOL)isQQShareSupported;

//分享URL到QQ好友
+ (void)shareToSessionWithURL:(NSString *)url
                   thumbImage:(UIImage*)thumbImage
                        title:(NSString*)title
                  description:(NSString*)description;

////分享图片到QQ好友
//+ (void)shareToSessionWithImage:(UIImage *)originalImage
//                     thumbImage:(UIImage*)thumbImage
//                          title:(NSString*)title
//                    description:(NSString*)description;

//分享URL到QQ空间
+ (void)shareToQzoneWithURL:(NSString *)url
                 thumbImage:(UIImage*)thumbImage
                      title:(NSString*)title
                description:(NSString*)description;

////分享图片到QQ空间
//+ (void)shareToQzoneWithImage:(UIImage *)originalImage
//                      thumbImage:(UIImage*)thumbImage
//                           title:(NSString*)title
//                     description:(NSString*)description;

@end
