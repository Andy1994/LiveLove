//
//  GFTakingPhotoViewController.h
//  GetFun
//
//  Created by zhouxz on 16/1/9.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFTakingPhotoViewController : GFNavigationController

@property (nonatomic, copy) void(^gf_didFinishTakingPhotoBlock)(GFTakingPhotoViewController *controller, UIImage *image);
@property (nonatomic, copy) void(^gf_didCancelTakingPhotoBlock)(GFTakingPhotoViewController *controller);

@property (nonatomic, assign) BOOL isCropAllowed; //是否允许剪裁，默认值为NO

@end
