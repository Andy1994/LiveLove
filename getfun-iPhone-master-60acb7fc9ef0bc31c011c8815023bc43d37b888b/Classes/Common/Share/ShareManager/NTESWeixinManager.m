//
//  NTESWeixinManager.m
//  ShareDemo
//
//  Created by muhuaxin on 16/7/15.
//  Copyright (c) 2015 NTES. All rights reserved.
//

#import "NTESWeixinManager.h"

#import "WXApi.h"

@implementation NTESWeixinManager

#pragma mark - Public Methods

+ (BOOL)isWeixinShareSupported
{
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

//分享URL到微信好友
+ (BOOL)shareToSessionWithURL:(NSString *)url
                   thumbImage:(UIImage*)thumbImage
                        title:(NSString*)title
                  description:(NSString*)description
{
    return [NTESWeixinManager shareURL:url
                              thumbImage:thumbImage
                                   title:title
                             description:description
                                   scene:WXSceneSession];
}

//分享图片到微信好友
+ (BOOL)shareToSessionWithImage:(UIImage *)originalImage
                     thumbImage:(UIImage*)thumbImage
                          title:(NSString*)title
                    description:(NSString*)description
{
    return [NTESWeixinManager shareImage:originalImage
                                thumbImage:thumbImage
                                     title:title
                               description:description
                                     scene:WXSceneSession];
}

//分享URL到微信朋友圈
+ (BOOL)shareToTimelineWithURL:(NSString *)url
                    thumbImage:(UIImage*)thumbImage
                         title:(NSString*)title
                   description:(NSString*)description
{
    return [NTESWeixinManager shareURL:url
                              thumbImage:thumbImage
                                   title:title
                             description:description
                                   scene:WXSceneTimeline];
}

//分享图片到微信朋友圈
+ (BOOL)shareToTimelineWithImage:(UIImage *)originalImage
                      thumbImage:(UIImage*)thumbImage
                           title:(NSString*)title
                     description:(NSString*)description
{
    return [NTESWeixinManager shareImage:originalImage
                                thumbImage:thumbImage
                                     title:title
                               description:description
                                     scene:WXSceneTimeline];
}


#pragma mark - Private Methods

+ (BOOL)shareURL:(NSString *)url
      thumbImage:(UIImage*)thumbImage
           title:(NSString*)title
     description:(NSString*)description
           scene:(NSInteger)scene
{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        return NO;
    }
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = url;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = webpageObject;
    
    if (thumbImage == nil) {
        thumbImage = [UIImage imageNamed:@"AppIcon60x60"];
    }
    
    NSData *imageData = UIImageJPEGRepresentation(thumbImage, 0.7);
    if(imageData.length / 1024. > 32){
        imageData = UIImageJPEGRepresentation(thumbImage, 0.5);//如果图片大了，则压缩到0.5，如果还大，则使用默认图片
        if(imageData.length / 1024. > 32){
            UIImage *image = [UIImage imageNamed:@"AppIcon60x60"];
            imageData = UIImageJPEGRepresentation(image,0.7);
        }
    }
    message.thumbData = imageData;
    
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.bText = NO;
    request.message = message;
    request.scene = (int)scene;
    
    BOOL success = [WXApi sendReq:request];
    return success;
}

+ (BOOL)shareImage:(UIImage *)originalImage
        thumbImage:(UIImage*)thumbImage
             title:(NSString*)title
       description:(NSString*)description
             scene:(NSInteger)scene
{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        return NO;
    }
    
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = UIImagePNGRepresentation(originalImage);
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = imageObject;
    message.thumbData = UIImageJPEGRepresentation(thumbImage,0.7);
    
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.bText = NO;
    request.message = message;
    request.scene = (int)scene;
    
    BOOL success = [WXApi sendReq:request];
    return success;
}

@end
