//
//  GFForgetPwdViewController.h
//  GetFun
//
//  Created by liupeng on 15/11/20.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFBaseViewController.h"

@interface GFForgetPwdViewController : GFBaseViewController

@property (nonatomic, copy) void(^registerHandler)();

- (instancetype)initWithMobile:(NSString *)mobile;

@end
