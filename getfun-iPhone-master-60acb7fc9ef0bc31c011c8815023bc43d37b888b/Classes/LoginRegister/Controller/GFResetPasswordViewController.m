//
//  GFResetPasswordViewController.m
//  GetFun
//
//  Created by liupeng on 15/11/20.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFResetPasswordViewController.h"
#import "GFNetworkManager+User.h"
#import "GFAccountManager.h"

@interface GFResetPasswordViewController () <UITextFieldDelegate>

@property (nonatomic, copy) NSString *iniMobile;
@property (nonatomic, copy) NSString *token;

@property (strong, nonatomic, readwrite) UITextField *passwordTextField;
@property (strong, nonatomic, readwrite) UITextField *ensurePasswordTextField;
@property (strong, nonatomic, readwrite) UIButton *loginButton;

@end

@implementation GFResetPasswordViewController
- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(56.0f,
                                                                                     12.0f + 64.0f,
                                                                                     self.view.width - 56.0f * 2,
                                                                                     40.0f)];
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
        _passwordTextField.placeholder = @"请输入新密码";
        _passwordTextField.font = [UIFont systemFontOfSize:17.0f];
        _passwordTextField.delegate = self;
        [_passwordTextField gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return _passwordTextField;
}

- (UITextField *)ensurePasswordTextField {
    if (!_ensurePasswordTextField) {
        _ensurePasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.passwordTextField.x,
                                                                                           self.passwordTextField.bottom + 12.0f,
                                                                                           self.passwordTextField.width,
                                                                                           self.passwordTextField.height)];
        _ensurePasswordTextField.secureTextEntry = YES;
        _ensurePasswordTextField.keyboardType = UIKeyboardTypeAlphabet;
        _ensurePasswordTextField.placeholder = @"请再次输入新密码";
        _ensurePasswordTextField.font = [UIFont systemFontOfSize:17.0f];
        _ensurePasswordTextField.delegate = self;
        [_ensurePasswordTextField gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return _ensurePasswordTextField;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton gf_purpleButtonWithTitle:@"完成并登录"];
        _loginButton.frame = CGRectMake(self.ensurePasswordTextField.x,
                                        self.ensurePasswordTextField.bottom + 12.0f,
                                        self.ensurePasswordTextField.width,
                                        self.ensurePasswordTextField.height);
        _loginButton.enabled = NO;
        
        __weak typeof(self) weakSelf = self;
        [_loginButton bk_addEventHandler:^(id sender) {
            
            [MobClick event:@"gf_wj_02_01_01_1"];
            
            [weakSelf loginButtonSelected];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (instancetype)initWithMobile:(NSString *)mobile token:(NSString *)token {
    if (self = [super init]) {
        _iniMobile = mobile;
        _token = token;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"找回密码";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.ensurePasswordTextField];
    [self.view addSubview:self.loginButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_wj_02_01_02_1"];
    [super backBarButtonItemSelected];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *password = self.passwordTextField.text;
    if (textField == self.passwordTextField) {
        password = [password stringByReplacingCharactersInRange:range withString:string];
    }
    
    NSString *ensurePassword = self.ensurePasswordTextField.text;
    if (textField == self.ensurePasswordTextField) {
        ensurePassword = [ensurePassword stringByReplacingCharactersInRange:range withString:string];
    }
    
    self.loginButton.enabled = [password gf_isValidType:GFValidateTypeCharacter] && [ensurePassword gf_isValidType:GFValidateTypeCharacter];
    
    self.loginButton.backgroundColor = self.loginButton.enabled ? [UIColor themeColorValue7]:[[UIColor themeColorValue7] colorWithAlphaComponent:0.5];
    
    return YES;
}

- (void)loginButtonSelected {
    //验证两次密码是否一致
    NSString *password = self.passwordTextField.text;
    NSString *ensurePassword = self.ensurePasswordTextField.text;
    if (![password isEqualToString:ensurePassword]) {
        [MBProgressHUD showHUDWithTitle:@"输入的两次密码不一致" duration:kCommonHudDuration inView:self.view];
        return;
    }
    
    if ([password length] < 6 || [password length] > 20) {
        [MBProgressHUD showHUDWithTitle:@"请输入6-20位字符" duration:kCommonHudDuration inView:self.view];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager resetPassword:self.iniMobile
                              token:self.token
                           password:self.passwordTextField.text
                            success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                if (code == 1) {
                                    [MBProgressHUD showHUDWithTitle:@"重置密码成功" duration:kCommonHudDuration inView:self.view];
                                    [weakSelf doLogin];
                                } else {
                                    [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                }
                            } failure:^(NSUInteger taskId, NSError *error) {
                                //
                            }];
}

- (void)doLogin {
    
    __weak typeof(self) weakSelf = self;
    
    
    [GFAccountManager loginUser:self.iniMobile
                       password:self.passwordTextField.text
                        success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                            if (code == 1) {
                                [MBProgressHUD showHUDWithTitle:@"密码已重置并登录" duration:kCommonHudDuration inView:self.view];
                                [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                            } else {
                                [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            }
                        } failure:^(NSUInteger taskId, NSError *error) {
                            [MBProgressHUD showHUDWithTitle:@"登录失败" duration:kCommonHudDuration inView:self.view];
                        }];
}
@end
