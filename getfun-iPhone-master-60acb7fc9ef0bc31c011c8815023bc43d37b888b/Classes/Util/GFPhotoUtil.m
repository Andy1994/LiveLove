//
//  GFPhotoUtil.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/28.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFPhotoUtil.h"

@implementation GFPhotoUtil

+ (void)requestAuthorization {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self defaultAssetsLibrary];
    } else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                //
            }];
        });
    }
}

+ (BOOL)checkAuthorization {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        return status == ALAuthorizationStatusAuthorized;
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        return status == PHAuthorizationStatusAuthorized;
    }
}

+ (void)checkAuthorizationCompletion:(void (^)(BOOL))completion {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status != ALAuthorizationStatusAuthorized) {
            [self showAuthorizeAlertView];
        } else if (completion) {
            completion(YES);
        }
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status != PHAuthorizationStatusAuthorized) {
            [self showAuthorizeAlertView];
        } else if (completion) {
            completion(YES);
        }
    }
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static ALAssetsLibrary *library;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

+ (PHCachingImageManager *)defaultCachingImageManager {
    static PHCachingImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PHCachingImageManager alloc] init];
    });
    return manager;
}

+ (void)requestThumbnailForAsset:(id)asset completion:(void (^)(UIImage *))completion {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if (completion) {
            completion([UIImage imageWithCGImage:((ALAsset *)asset).thumbnail]);
        }
    } else {
        
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat width = phAsset.pixelWidth;
        CGFloat height = phAsset.pixelHeight;
        CGFloat expectWidth = 100;
        CGSize size = CGSizeMake(expectWidth, height/width * expectWidth);
        [[GFPhotoUtil defaultCachingImageManager] requestImageForAsset:asset
                                                            targetSize:size
                                                           contentMode:PHImageContentModeAspectFill
                                                               options:nil
                                                         resultHandler:^(UIImage *result, NSDictionary *info) {
                                                             if (completion) {
                                                                 completion(result);
                                                             }
                                                         }];
    }
}

+ (void)originalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {

        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        PHAsset *phAsset = asset;
        CGFloat width = phAsset.pixelWidth;
        CGFloat height = phAsset.pixelHeight;
        CGFloat expectWidth = SCREEN_WIDTH * 3;
        CGSize size = CGSizeMake(expectWidth, height/width * expectWidth);
        [[GFPhotoUtil defaultCachingImageManager] requestImageForAsset:phAsset
                                                            targetSize:size
                                                           contentMode:PHImageContentModeAspectFit
                                                               options:options
                                                         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                             BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                                                             if (downloadFinined && result && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                                                                 if (completion) {
                                                                     completion(result,info);
                                                                 }
                                                             }
                                                         }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            CGImageRef originalImageRef = [assetRep fullResolutionImage];
            UIImage *originalImage = [UIImage imageWithCGImage:originalImageRef scale:1.0 orientation:UIImageOrientationUp];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(originalImage,nil);
                }
            });
        });
    }
}

+ (void)showAuthorizeAlertView {
    
    [UIAlertView bk_showAlertViewWithTitle:@"提示"
                                   message:@"请先在\"设置\"－\"隐私\"中的\"照片\"中允许\"盖范\"使用照片"
                         cancelButtonTitle:@"暂不允许"
                         otherButtonTitles:@[@"马上设置"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 1) {
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
                                       }
                                   }];
    
}
@end
