//
//  GFChangePasswordViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFChangePasswordViewController.h"
#import "GFNetworkManager+User.h"

#define GF_CHANGEPWD_TEXT_HEIGHT 44.0f

@interface GFChangePasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *originPasswordTextField;
@property (nonatomic, strong) UITextField *inputPasswordTextField;
@property (nonatomic, strong) UITextField *confirmPasswordTextField;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation GFChangePasswordViewController

- (UITextField *)originPasswordTextField {
    if (!_originPasswordTextField) {
        _originPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 64.0f + 20.0f, self.view.width, GF_CHANGEPWD_TEXT_HEIGHT)];
        _originPasswordTextField.secureTextEntry = YES;
        _originPasswordTextField.keyboardType = UIKeyboardTypeAlphabet;
        _originPasswordTextField.placeholder = @"请输入原密码";
        _originPasswordTextField.backgroundColor = [UIColor whiteColor];
        [_originPasswordTextField gf_AddBottomBorderWithColor:[UIColor textColorValue5] andWidth:0.5];
        [self makeIndentSpace:20 forTextField:_originPasswordTextField];
    }
    return _originPasswordTextField;
}

- (UITextField *)inputPasswordTextField {
    if (!_inputPasswordTextField) {
        _inputPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.originPasswordTextField.bottom, self.view.width, GF_CHANGEPWD_TEXT_HEIGHT)];
        _inputPasswordTextField.secureTextEntry = YES;
        _inputPasswordTextField.keyboardType = UIKeyboardTypeAlphabet;
        _inputPasswordTextField.placeholder = @"请输入新密码";
        _inputPasswordTextField.backgroundColor = [UIColor whiteColor];
        [_inputPasswordTextField gf_AddBottomBorderWithColor:[UIColor textColorValue5] andWidth:0.5];
        [self makeIndentSpace:20 forTextField:_inputPasswordTextField];
    }
    return _inputPasswordTextField;
}

- (UITextField *)confirmPasswordTextField {
    if (!_confirmPasswordTextField) {
        _confirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.inputPasswordTextField.bottom, self.view.width, GF_CHANGEPWD_TEXT_HEIGHT)];
        _confirmPasswordTextField.secureTextEntry = YES;
        _confirmPasswordTextField.keyboardType = UIKeyboardTypeAlphabet;
        _confirmPasswordTextField.placeholder = @"请再次输入新密码";
        _confirmPasswordTextField.backgroundColor = [UIColor whiteColor];
        [self makeIndentSpace:20 forTextField:_confirmPasswordTextField];
    }
    return _confirmPasswordTextField;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(0, 0, 40, 40);
        _confirmButton.centerX = self.view.width/2;
        _confirmButton.backgroundColor = [UIColor clearColor];
        [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_confirmButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_sz_02_01_01_1"];
            [weakSelf confirmChangePassword];

        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"修改密码";
    
    [self.view addSubview:self.originPasswordTextField];
    [self.view addSubview:self.inputPasswordTextField];
    [self.view addSubview:self.confirmPasswordTextField];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    
    self.inputPasswordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    self.originPasswordTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_sz_02_01_02_1"];
    [super backBarButtonItemSelected];
}

# pragma mark - Methods
//设置缩进
- (void)makeIndentSpace:(CGFloat)space forTextField:(UITextField *)textField{
    UIView *indentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, textField.height)];
    indentView.backgroundColor = [UIColor clearColor];
    textField.leftView = indentView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)confirmChangePassword {
    [MobClick event:@"gf_sz_02_01_01_1"];
    
    NSString *originPassword = self.originPasswordTextField.text;
    NSString *currentPassword = self.inputPasswordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    if (![currentPassword isEqualToString:confirmPassword]) {
        [MBProgressHUD showHUDWithTitle:@"密码输入不一致" duration:kCommonHudDuration inView:self.view];
        
        return;
    }
    
    if ([currentPassword length] < 6 || [currentPassword length] > 20) {
        [MBProgressHUD showHUDWithTitle:@"请输入6-20位字符" duration:kCommonHudDuration inView:self.view];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager changeOriginPassword:originPassword
                                toPassword:currentPassword
                                   success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                       if (code == 1) {
                                           [MBProgressHUD showHUDWithTitle:@"修改成功" duration:kCommonHudDuration inView:self.view];
                                           weakSelf.originPasswordTextField.text = @"";
                                           weakSelf.inputPasswordTextField.text = @"";
                                           weakSelf.confirmPasswordTextField.text = @"";
                                           [weakSelf.navigationController popViewControllerAnimated:YES];
                                       } else {
                                           [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                       }
                                   } failure:^(NSUInteger taskId, NSError *error) {
                                       
                                   }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
//    NSString *originPassword = self.originPasswordTextField.text;
//    if (textField == self.originPasswordTextField) {
//        originPassword = [originPassword stringByReplacingCharactersInRange:range withString:string];
//    }
    
    
    NSString *inputPassword = self.inputPasswordTextField.text;
    if (textField == self.inputPasswordTextField) {
        inputPassword = [inputPassword stringByReplacingCharactersInRange:range withString:string];
    }
    
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    if (textField == self.confirmPasswordTextField) {
        confirmPassword = [confirmPassword stringByReplacingCharactersInRange:range withString:string];
    }
    

    return YES;
}

@end
