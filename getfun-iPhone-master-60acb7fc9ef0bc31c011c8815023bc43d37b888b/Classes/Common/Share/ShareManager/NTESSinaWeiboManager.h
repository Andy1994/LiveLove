//
//  NTESSinaWeiboManager.h
//  ShareDemo
//
//  Created by muhuaxin on 16/7/15.
//  Copyright (c) 2015 NTES. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESSinaWeiboManager : NSObject

+ (BOOL)isSinaWeiboShareSupported;

//分享URL到新浪微博
+ (BOOL)shareURL:(NSString *)url
      thumbImage:(UIImage*)thumbImage
           title:(NSString*)title
     description:(NSString*)description;

//分享图片到新浪微博
+ (BOOL)shareImage:(UIImage *)originalImage
        thumbImage:(UIImage*)thumbImage
             title:(NSString*)title
       description:(NSString*)description;

@end
