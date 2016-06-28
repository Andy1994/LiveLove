//
//  GFRegisterView.h
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFVerifyButton.h"

@interface GFRegisterView : UIView

@property (nonatomic, copy) void (^didCheckVerifyCodeSuccessHandler)(NSString *mobile, NSString *password, NSString *token);

@property (strong, nonatomic, readwrite) UITextField *phoneNumberTextField;
@property (strong, nonatomic, readwrite) UITextField *passwordTextField;
@property (strong, nonatomic, readwrite) UITextField *verifyCodeTextField;
@property (strong, nonatomic, readwrite) GFVerifyButton *verifyButton;
@property (strong, nonatomic, readwrite) TTTAttributedLabel *userProtocolLabel;

@property (strong, nonatomic, readwrite) UIButton *nextStepButton;

@end
