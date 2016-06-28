//
//  UIBarButtonItem+Getfun.m
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "UIBarButtonItem+Getfun.h"

@implementation UIBarButtonItem (Getfun)

+ (UIBarButtonItem *)gf_barButtonItemWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    
    UIImage *highlightedImage = [image opacity:0.5f];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

@end
