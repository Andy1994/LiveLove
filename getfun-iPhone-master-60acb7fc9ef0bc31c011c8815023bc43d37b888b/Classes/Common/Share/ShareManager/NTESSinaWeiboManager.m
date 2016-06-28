//
//  NTESSinaWeiboManager.m
//  ShareDemo
//
//  Created by muhuaxin on 16/7/15.
//  Copyright (c) 2015 NTES. All rights reserved.
//

#import "NTESSinaWeiboManager.h"

#import "WeiboSDK.h"

@implementation NTESSinaWeiboManager

+ (BOOL)isSinaWeiboShareSupported
{
    return YES;
}

//分享URL到新浪微博
+ (BOOL)shareURL:(NSString *)url
      thumbImage:(UIImage*)thumbImage
           title:(NSString*)title
     description:(NSString*)description
{
    WBMessageObject *message = [WBMessageObject message];
    
    if (thumbImage == nil) {
        thumbImage = [UIImage imageNamed:@"AppIcon60x60"];
    }
    
    NSData *imageData = UIImageJPEGRepresentation(thumbImage,0.7);
    if(imageData.length / 1024. > 32){
        imageData = UIImageJPEGRepresentation(thumbImage,0.5);//如果图片大了，则压缩到0.5，如果还大，则使用默认图片
        if(imageData.length / 1024. > 32){
            UIImage *image = [UIImage imageNamed:@"AppIcon60x60"];
            imageData = UIImageJPEGRepresentation(image,0.7);
        }
    }
    
//    message.text = description;
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = imageData;
    webpage.webpageUrl = url;
    message.mediaObject = webpage;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"follow_app_official_microblog";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
//    request.userInfo = @{@"staticsType": @(type)};
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    return [WeiboSDK sendRequest:request];
}


//分享图片到新浪微博
+ (BOOL)shareImage:(UIImage *)originalImage
        thumbImage:(UIImage*)thumbImage
             title:(NSString*)title
       description:(NSString*)description
{
    WBMessageObject *message = [WBMessageObject message];
    
    message.text = description;
    
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImageJPEGRepresentation(thumbImage, 1);
    message.imageObject = image;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"follow_app_official_microblog";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
//    request.userInfo = @{@"staticsType": @(type)};
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    return [WeiboSDK sendRequest:request];
}

@end
