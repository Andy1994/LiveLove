//
//  GFLoginRegisterBottomView.h
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFLoginView.h"
#import "GFRegisterView.h"

#define GF_HEIGHT_SEGMENTED_CONTROL 50.0f

@protocol GFLoginRegisterBottomViewDelegate <NSObject>

// 登录
- (void)didSelectForgetPassword:(NSString *)mobile;
- (void)loginWithMobile:(NSString *)mobile password:(NSString *)password;
- (void)didSelectLoginWithType:(GFLoginType)loginType;

// 注册
- (void)didSelectUserAgreement:(NSURL *)url;
- (void)didCheckRegisterVerifyCodeForMobile:(NSString *)mobile
                                   password:(NSString *)password
                                      token:(NSString *)token;

@end

@interface GFLoginRegisterBottomView : UIView

@property (nonatomic, assign) id<GFLoginRegisterBottomViewDelegate> delegate;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl; //切换按钮

// 切换显示登录或注册视图
- (void)showLoginView;
- (void)showRegisterView;

@end
