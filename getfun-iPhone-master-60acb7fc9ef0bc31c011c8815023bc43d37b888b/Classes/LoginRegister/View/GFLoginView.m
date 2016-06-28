//
//  GFLoginView.m
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFLoginView.h"
#import "UIColor+Getfun.h"

@interface GFLoginView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *phoneNumberUnderLine;
@property (nonatomic, strong) UIView *passwordUnderLine;

@end

@implementation GFLoginView
- (UITextField *)phoneNumberTextField {
    if (!_phoneNumberTextField) {
        _phoneNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(46.0f,
                                                                              8.0f,
                                                                              self.width - 46.0f*2,
                                                                              50.0f)];
        _phoneNumberTextField.textColor = [UIColor textColorValue1];
        _phoneNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName:[UIColor textColorValue5]}];
        _phoneNumberTextField.font = [UIFont systemFontOfSize:17.0f];
        _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNumberTextField.delegate = self;
    }
    return _phoneNumberTextField;
}

- (UIView *)phoneNumberUnderLine {
    if (!_phoneNumberUnderLine) {
        _phoneNumberUnderLine = [[UIView alloc] initWithFrame:CGRectMake(self.phoneNumberTextField.x,
                                                                         self.phoneNumberTextField.bottom,
                                                                         self.width - 46.0f * 2,
                                                                         0.5f)];
        _phoneNumberUnderLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _phoneNumberUnderLine;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] initWithFrame:self.phoneNumberTextField.frame];
        _passwordTextField.y = self.phoneNumberTextField.bottom;
        _passwordTextField.textColor = [UIColor textColorValue1];
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:[UIColor textColorValue5]}];
        _passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
        _passwordTextField.font = [UIFont systemFontOfSize:17.0f];
        _passwordTextField.delegate = self;        
    }
    return _passwordTextField;
}

- (UIView *)passwordUnderLine {
    if (!_passwordUnderLine) {
        _passwordUnderLine = [[UIView alloc] initWithFrame:CGRectMake(self.passwordTextField.x,
                                                                      self.passwordTextField.bottom,
                                                                      self.width - 46.0f * 2,
                                                                      0.5f)];
        _passwordUnderLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _passwordUnderLine;
}

- (UIButton *)forgetPwdButton {
    if (!_forgetPwdButton) {
        _forgetPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetPwdButton.frame = CGRectMake(self.passwordTextField.x, self.passwordTextField.bottom + 18.0f, 80.0f, 18.0f);
        [_forgetPwdButton setTitle:@"忘记密码？" forState: UIControlStateNormal];
        [_forgetPwdButton setTitleColor:[UIColor textColorValue8] forState:UIControlStateNormal];
        [_forgetPwdButton setTitleColor:[UIColor themeColorValue7] forState:UIControlStateHighlighted];
        _forgetPwdButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _forgetPwdButton;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton gf_purpleButtonWithTitle:@"登录"];
        _loginButton.frame = CGRectMake(self.passwordTextField.x,
                                        self.forgetPwdButton.bottom+20.0f,
                                        self.passwordTextField.width,
                                        40.0f);
        _loginButton.enabled = NO;
    }
    
    return _loginButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.phoneNumberTextField];
        [self addSubview:self.phoneNumberUnderLine];
        [self addSubview:self.passwordTextField];
        [self addSubview:self.passwordUnderLine];
        [self addSubview:self.forgetPwdButton];
        [self addSubview:self.loginButton];
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *phoneNumber = self.phoneNumberTextField.text;
    if (textField == self.phoneNumberTextField) {
        phoneNumber = [phoneNumber stringByReplacingCharactersInRange:range withString:string];
    }

    NSString *password = self.passwordTextField.text;
    if (textField == self.passwordTextField) {
        password = [password stringByReplacingCharactersInRange:range withString:string];
    }
    
//    self.loginButton.enabled = [phoneNumber gf_isValidType:GFValidateTypePhoneNumber] && [password gf_isValidType:GFValidateTypeCharacter];
    self.loginButton.enabled = [phoneNumber length] > 0 && [password length] > 0;
    self.loginButton.backgroundColor = self.loginButton.enabled ? [UIColor themeColorValue7] : [[UIColor themeColorValue7] colorWithAlphaComponent:0.5];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIColor *activeColor = [UIColor themeColorValue7];
    UIColor *inActiveColor = [UIColor themeColorValue15];
    
    self.phoneNumberUnderLine.backgroundColor = (textField == self.phoneNumberTextField) ? activeColor : inActiveColor;
    self.passwordUnderLine.backgroundColor = (textField == self.passwordTextField) ? activeColor : inActiveColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIColor *inActiveColor = [UIColor themeColorValue15];
    if (textField == self.phoneNumberTextField) {
        self.phoneNumberUnderLine.backgroundColor = inActiveColor;
    } else if(textField == self.passwordTextField) {
        self.passwordUnderLine.backgroundColor = inActiveColor;
    }
}

@end
