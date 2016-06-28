//
//  GFPhotoUtil.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface GFPhotoUtil : NSObject

+ (void)requestAuthorization;
+ (BOOL)checkAuthorization;
+ (void)checkAuthorizationCompletion:(void (^)(BOOL authorized))completion;

+ (ALAssetsLibrary *)defaultAssetsLibrary;
+ (PHCachingImageManager *)defaultCachingImageManager;

+ (void)requestThumbnailForAsset:(id)asset completion:(void (^)(UIImage *thumbnail))completion;

+ (void)originalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

@end
