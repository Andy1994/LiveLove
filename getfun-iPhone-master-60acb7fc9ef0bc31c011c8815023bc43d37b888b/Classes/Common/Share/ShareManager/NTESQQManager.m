//
//  NTESQQManager.m
//  ShareDemo
//
//  Created by muhuaxin on 16/7/15.
//  Copyright (c) 2015 NTES. All rights reserved.
//

#import "NTESQQManager.h"
#import <TencentOpenAPI/QQApiInterface.h>

@implementation NTESQQManager

+ (BOOL)isQQShareSupported
{
    return [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi];
}

//分享URL到QQ好友
+ (void)shareToSessionWithURL:(NSString *)url
                   thumbImage:(UIImage*)thumbImage
                        title:(NSString*)title
                  description:(NSString*)description
{
    [NTESQQManager shareURL:url
                 thumbImage:thumbImage
                      title:title
                description:description
                      scene:0];
}

////分享图片到QQ好友
//+ (void)shareToSessionWithImage:(UIImage *)originalImage
//                     thumbImage:(UIImage*)thumbImage
//                          title:(NSString*)title
//                    description:(NSString*)description
//                    staticsType:(Statics_Share)type
//{
//
//}

//分享URL到QQ空间
+ (void)shareToQzoneWithURL:(NSString *)url
                 thumbImage:(UIImage*)thumbImage
                      title:(NSString*)title
                description:(NSString*)description
{
    [NTESQQManager shareURL:url
                 thumbImage:thumbImage
                      title:title
                description:description
                      scene:1];
}

////分享图片到QQ空间
//+ (void)shareToQzoneWithImage:(UIImage *)originalImage
//                   thumbImage:(UIImage*)thumbImage
//                        title:(NSString*)title
//                  description:(NSString*)description
//                  staticsType:(Statics_Share)type
//{
//
//}

#pragma mark - Private Methods

+ (void)shareURL:(NSString *)url
      thumbImage:(UIImage*)thumbImage
           title:(NSString*)title
     description:(NSString*)description
           scene:(NSInteger)scene
{
    if (![QQApiInterface isQQInstalled] || ![QQApiInterface isQQSupportApi]) {
        return;
    }
    
    QQApiNewsObject* newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:title description:description previewImageData:UIImageJPEGRepresentation(thumbImage, 0.7)];
    
    //scene == 0 : QQ //scene = 1 : Qzone
    newsObject.cflag = scene == 0 ? kQQAPICtrlFlagQZoneShareForbid : kQQAPICtrlFlagQZoneShareOnStart;
    
    if (thumbImage == nil) {
        thumbImage = [UIImage imageNamed:@"AppIcon60x60"];
    }
    newsObject.previewImageData = UIImageJPEGRepresentation(thumbImage,0.7);
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:newsObject];
    scene == 0 ? [QQApiInterface sendReq:req] : [QQApiInterface SendReqToQZone:req];
}
@end
