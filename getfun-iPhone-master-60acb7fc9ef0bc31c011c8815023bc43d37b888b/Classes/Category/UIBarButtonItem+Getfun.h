//
//  UIBarButtonItem+Getfun.h
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Getfun)

+ (UIBarButtonItem *)gf_barButtonItemWithImage:(UIImage *)image
                                        target:(id)target
                                      selector:(SEL)selector;
@end
