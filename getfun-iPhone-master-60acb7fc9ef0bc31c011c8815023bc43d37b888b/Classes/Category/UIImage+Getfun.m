//
//  UIImage+Getfun.m
//  GetFun
//
//  Created by zhouxz on 15/12/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "UIImage+Getfun.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "GFPhotoUtil.h"

@implementation UIImage (Getfun)

- (UIImage *)gf_autoResizeImageWithNet {
    AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
    CGFloat height = 1920;
    CGFloat width = 1080;
    CGFloat quality = 0.75;
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        quality = 0.5;
        height = 960;
        width = 640;
    }
    UIImage *image = [self gf_imageByScalingAndCroppingForSize:CGSizeMake(width, height)];
    return [UIImage imageWithData:UIImageJPEGRepresentation(image, quality)];
}

- (UIImage *)gf_autoResizeImageWithNetAvatorChange: (BOOL)changeAvator {
    if (changeAvator) {
        //TODO:用户修改头像，尺寸没有必要这么大
        AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
        CGFloat height = 1067;
        CGFloat width = 600;
        CGFloat quality = 0.75;
        if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            quality = 0.5;
            height = 640;
            width = 427;
        }
        UIImage *image = [self gf_imageByScalingAndCroppingForSize:CGSizeMake(width, height)];
        return [UIImage imageWithData:UIImageJPEGRepresentation(image, quality)];
        
    } else {
        
        AFNetworkReachabilityStatus status = [GFNetworkStatusUtil networkStatus];
        CGFloat height = 1920;
        CGFloat width = 1080;
        CGFloat quality = 0.75;
        if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            quality = 0.5;
            height = 960;
            width = 640;
        }
        UIImage *image = [self gf_imageByScalingAndCroppingForSize:CGSizeMake(width, height)];
        return [UIImage imageWithData:UIImageJPEGRepresentation(image, quality)];
    }

}

- (UIImage *)gf_imageByScalingAndCroppingForSize:(CGSize)size {
    
    UIImage *resizedImage = [self copy];
    
    CGFloat imageWidth = resizedImage.size.width;
    CGFloat imageHeight = resizedImage.size.height;
    
    if (imageWidth > size.width) {
        imageHeight = imageHeight / imageWidth * size.width;
        imageWidth = size.width;

        resizedImage = [resizedImage scaleToSize:CGSizeMake(imageWidth*3, imageHeight*3) usingMode:NYXResizeModeAspectFit];
    }
    
    return resizedImage;
}

@end
