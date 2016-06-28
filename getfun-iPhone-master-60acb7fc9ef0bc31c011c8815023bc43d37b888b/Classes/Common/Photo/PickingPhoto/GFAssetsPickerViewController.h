//
//  GFAssetsPickerViewController.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNavigationController.h"

@interface GFAssetsPickerViewController : GFNavigationController

@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray *selectedThumbnails;

@property (nonatomic, copy) void(^gf_didFinishPickingAssetsBlock)(GFAssetsPickerViewController *picker, NSArray *assets, NSArray *thumbnails);
@property (nonatomic, copy) void(^gf_didFinishPickingImageBlock)(GFAssetsPickerViewController *picker, UIImage *image, UIImage *thumbnail);
@property (nonatomic, copy) void(^gf_didCancelPickingAssetsBlock)(GFAssetsPickerViewController *picker);

@property (nonatomic, assign) NSUInteger maxSelectNumber;
@property (nonatomic, assign) BOOL isCropAllowed; //是否允许剪裁，默认值为NO

@end
