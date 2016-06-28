//
//  GFResetPasswordViewController.h
//  GetFun
//
//  Created by liupeng on 15/11/20.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFBaseViewController.h"

@interface GFResetPasswordViewController : GFBaseViewController

- (instancetype)initWithMobile:(NSString *)mobile token:(NSString *)token;

@end
