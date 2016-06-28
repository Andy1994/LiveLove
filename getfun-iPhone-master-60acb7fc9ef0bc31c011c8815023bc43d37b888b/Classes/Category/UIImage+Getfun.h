//
//  UIImage+Getfun.h
//  GetFun
//
//  Created by zhouxz on 15/12/28.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Getfun)

- (UIImage *)gf_autoResizeImageWithNet;

- (UIImage *)gf_autoResizeImageWithNetAvatorChange: (BOOL)changeAvator;

- (UIImage *)gf_imageByScalingAndCroppingForSize:(CGSize)size;
@end
