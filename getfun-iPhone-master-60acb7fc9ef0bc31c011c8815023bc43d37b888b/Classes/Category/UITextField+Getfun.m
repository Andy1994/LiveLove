//
//  UITextField+Getfun.m
//  GetFun
//
//  Created by Liu Peng on 16/1/16.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "UITextField+Getfun.h"

@implementation UITextField (Getfun)

//设置缩进
- (void)gf_makeIndentSpace:(CGFloat)space{
    UIView *indentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, self.height)];
    indentView.backgroundColor = [UIColor clearColor];
    self.leftView = indentView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
