//
//  NTESWeixinManager.h
//  ShareDemo
//
//  Created by muhuaxin on 16/7/15.
//  Copyright (c) 2015 NTES. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESWeixinManager : NSObject

+ (BOOL)isWeixinShareSupported;

//分享URL到微信好友
+ (BOOL)shareToSessionWithURL:(NSString *)url
                   thumbImage:(UIImage*)thumbImage
                        title:(NSString*)title
                  description:(NSString*)description;

//分享图片到微信好友
+ (BOOL)shareToSessionWithImage:(UIImage *)originalImage
                     thumbImage:(UIImage*)thumbImage
                          title:(NSString*)title
                    description:(NSString*)description;

//分享URL到微信朋友圈
+ (BOOL)shareToTimelineWithURL:(NSString *)url
                    thumbImage:(UIImage*)thumbImage
                         title:(NSString*)title
                   description:(NSString*)description;

//分享图片到微信朋友圈
+ (BOOL)shareToTimelineWithImage:(UIImage *)originalImage
                      thumbImage:(UIImage*)thumbImage
                           title:(NSString*)title
                     description:(NSString*)description;

@end
