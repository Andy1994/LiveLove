//
//  GFRegisterView.m
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFRegisterView.h"
#import "GFAccountManager+Weibo.h"
#import "GFAccountManager+Wechat.h"
#import "GFAccountManager+QQ.h"

static inline NSRegularExpression * UserProtocolRegularExpression() {
    static NSRegularExpression *_userProtocolRegularExpression = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userProtocolRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"Getfun用户协议" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _userProtocolRegularExpression;
}

@interface GFRegisterView () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *phoneNumberUnderLine;
@property (nonatomic, strong) UIView *passwordUnderLine;
@property (nonatomic, strong) UIView *verifyCodeUnderLine;

@end

@implementation GFRegisterView

- (UITextField *)phoneNumberTextField {
    if (!_phoneNumberTextField) {
        
        _phoneNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(46.0f,
                                                                              8.0f,
                                                                              self.width - 2 * 46.0f,
                                                                              50.0f)];
        _phoneNumberTextField.delegate = self;
        _phoneNumberTextField.textColor = [UIColor textColorValue1];
        _phoneNumberTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName:[UIColor textColorValue5]}];
        _phoneNumberTextField.font = [UIFont systemFontOfSize:17.0f];
        _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
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
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.phoneNumberTextField.x,
                                                                           self.phoneNumberTextField.bottom,
                                                                           self.phoneNumberTextField.width,
                                                                           self.phoneNumberTextField.height)];
        _passwordTextField.delegate = self;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
        _passwordTextField.textColor = [UIColor textColorValue1];
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:[UIColor textColorValue5]}];
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

- (UITextField *)verifyCodeTextField {
    if (!_verifyCodeTextField) {
        _verifyCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.passwordTextField.x,
                                                                                       self.passwordTextField.bottom,
                                                                                       self.passwordTextField.width/3 * 2,
                                                                                       self.passwordTextField.height)];
        _verifyCodeTextField.delegate = self;
        _verifyCodeTextField.textColor = [UIColor textColorValue1];
        _verifyCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName:[UIColor textColorValue5]}];
        _verifyCodeTextField.font = [UIFont systemFontOfSize:17.0f];
        _verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _verifyCodeTextField;
}

- (UIView *)verifyCodeUnderLine {
    if (!_verifyCodeUnderLine) {
        _verifyCodeUnderLine = [[UIView alloc] initWithFrame:CGRectMake(self.verifyCodeTextField.x,
                                                                      self.verifyCodeTextField.bottom,
                                                                      self.width - 46.0f * 2,
                                                                      0.5f)];
        _verifyCodeUnderLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _verifyCodeUnderLine;
}

- (GFVerifyButton *)verifyButton {
    if (!_verifyButton) {
        _verifyButton = [GFVerifyButton buttonWithType:UIButtonTypeCustom];
        _verifyButton.frame = ({
            CGFloat width = 80;
            CGFloat height = 34;
            CGFloat x = self.verifyCodeTextField.right;
            CGFloat y = self.verifyCodeTextField.centerY - height/2;
            CGRect rect = CGRectMake(x, y, width, height);
            rect;
        });
        [_verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_verifyButton setTitleColor:[UIColor textColorValue6] forState:UIControlStateNormal];
        _verifyButton.backgroundColor = [UIColor themeColorValue9];
        _verifyButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _verifyButton.layer.cornerRadius = 3.0f;
        _verifyButton.layer.masksToBounds = YES;
        
        __weak typeof(self) weakSelf = self;
        [_verifyButton bk_addEventHandler:^(id sender) {
            NSString *mobile = weakSelf.phoneNumberTextField.text;
            if ([mobile gf_isValidType:GFValidateTypePhoneNumber]) {
                [weakSelf queryVerifyCode:mobile];
            } else {
                [MBProgressHUD showHUDWithTitle:@"请输入有效手机号" duration:kCommonHudDuration];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyButton;
}

- (TTTAttributedLabel *)userProtocolLabel {
    if (!_userProtocolLabel) {
    
        _userProtocolLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(self.phoneNumberTextField.x,
                                                                                   self.verifyCodeTextField.bottom + 18.0f,
                                                                                   self.phoneNumberTextField.width,
                                                                                   14.0f)];
        _userProtocolLabel.userInteractionEnabled = YES;
        _userProtocolLabel.textColor = [UIColor textColorValue1];
        _userProtocolLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _userProtocolLabel.numberOfLines = 1;
        _userProtocolLabel.font = [UIFont systemFontOfSize:14.0f];
//        //设置高亮颜色
//        _userProtocolLabel.highlightedTextColor = [UIColor themeColorValue7];
        //检测url
        _userProtocolLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        //对齐方式
        _userProtocolLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
        //不显示下划线
        _userProtocolLabel.linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIColor textColorValue8],(NSString *)kCTForegroundColorAttributeName,[NSNumber numberWithBool:NO],(NSString *)kCTUnderlineStyleAttributeName, nil];
        _userProtocolLabel.activeLinkAttributes = @{NSForegroundColorAttributeName:[UIColor themeColorValue7]};
        NSString *text = @"已同意Getfun用户协议";
        
        [_userProtocolLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString)
         {
             //设置可点击文字的范围
             NSRange tapTange = [[mutableAttributedString string] rangeOfString:@"Getfun用户协议" options:NSCaseInsensitiveSearch];
             
             //设定可点击文字的的大小
             UIFont *systemFont = [UIFont systemFontOfSize:14];
             CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
             if (font) {
                 //设置可点击文本的大小
                 [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:tapTange];
                 //设置可点击文本的颜色
                 [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor textColorValue8] CGColor] range:tapTange];
                 CFRelease(font);
                 
             }
             return mutableAttributedString;
         }];
        
        //正则
        NSRegularExpression *regexp = UserProtocolRegularExpression();
        
        NSRange linkRange = [regexp rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
        NSURL *url = [NSURL URLWithString:@"https://www.17getfun.com/publish/privacy"];
        //设置链接的url
        [_userProtocolLabel addLinkToURL:url withRange:linkRange];
        

        
    }
    return _userProtocolLabel;
}

- (UIButton *)nextStepButton {
    if (!_nextStepButton) {
        _nextStepButton = [UIButton gf_purpleButtonWithTitle:@"下一步"];
        _nextStepButton.frame = CGRectMake(self.passwordTextField.x,
                                           self.userProtocolLabel.bottom+20.0f,
                                           self.passwordTextField.width,
                                           40.0f);
        _nextStepButton.enabled = NO;
    }
    return _nextStepButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.phoneNumberTextField];
        [self addSubview:self.phoneNumberUnderLine];
        [self addSubview:self.passwordTextField];
        [self addSubview:self.passwordUnderLine];
        [self addSubview:self.verifyCodeTextField];
        [self addSubview:self.verifyCodeUnderLine];
        
        [self addSubview:self.verifyButton];
        [self addSubview:self.userProtocolLabel];
        [self addSubview:self.nextStepButton];
        
        __weak typeof(self) weakSelf = self;
        [self.nextStepButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_zc_01_01_02_1"];
            [weakSelf checkVerifyCode];
        } forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        gesture.delegate = self;
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)dealloc {
    [_verifyButton removeFromSuperview];
    _verifyButton = nil;
    
    [_userProtocolLabel removeFromSuperview];
    _userProtocolLabel = nil;
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[TTTAttributedLabel class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Methods

- (void)tapGesture:(UIGestureRecognizer *)recognizer {
    [self endEditing:YES];
}

- (void)queryVerifyCode:(NSString *)mobile {
    [MobClick event:@"gf_zc_01_01_01_1"];
    [GFNetworkManager queryVerificationCodeForMobile:mobile
                                  existedUserSupposed:NO
                                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                 if (code == 1) {
                                                     [MBProgressHUD showHUDWithTitle:@"验证码已发送" duration:kCommonHudDuration];
                                                     [self.verifyButton startCountDown];
                                                 } else {
                                                     [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration];
                                                 }
                                             } failure:^(NSUInteger taskId, NSError *error) {
                                                 [MBProgressHUD showHUDWithTitle:@"验证码获取失败" duration:kCommonHudDuration];
                                             }];
}

- (void)checkVerifyCode {
    
    NSString *mobile = self.phoneNumberTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *verifyCode = self.verifyCodeTextField.text;
    
    if (![mobile gf_isValidType:GFValidateTypePhoneNumber]) {
        [MBProgressHUD showHUDWithTitle:@"手机号输入错误" duration:kCommonHudDuration];
        return;
    }
    
    if (![password gf_isValidType:GFValidateTypePassword]) {
        [MBProgressHUD showHUDWithTitle:@"密码应为6~20位字符" duration:kCommonHudDuration];
        return;
    }
    
    if (![verifyCode gf_isValidType:GFValidateTypeNumber]) {
        [MBProgressHUD showHUDWithTitle:@"验证码输入错误" duration:kCommonHudDuration];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager checkVerificationCode:verifyCode
                                     mobile:mobile
                                    success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token) {
                                        if (code == 1) {
                                            if (weakSelf.didCheckVerifyCodeSuccessHandler) {
                                                weakSelf.didCheckVerifyCodeSuccessHandler(mobile, password, token);
                                            }
                                        } else {
                                            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration];
                                        }
                                    } failure:^(NSUInteger taskId, NSError *error) {
                                        [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration];
                                    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 手机号
    NSString *phoneNumber = self.phoneNumberTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *verifyCode = self.verifyCodeTextField.text;
    
    self.nextStepButton.enabled = [phoneNumber length] > 0 && [password length] > 0 && [verifyCode length] > 0;

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    UIColor *activeColor = [UIColor themeColorValue7];
    UIColor *inActiveColor = [UIColor themeColorValue15];
    
    self.phoneNumberUnderLine.backgroundColor = (textField == self.phoneNumberTextField) ? activeColor : inActiveColor;
    self.passwordUnderLine.backgroundColor = (textField == self.passwordTextField) ? activeColor : inActiveColor;
    self.verifyCodeUnderLine.backgroundColor = (textField == self.verifyCodeTextField) ? activeColor : inActiveColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIColor *inActiveColor = [UIColor themeColorValue15];
    if (textField == self.phoneNumberTextField) {
        self.phoneNumberUnderLine.backgroundColor = inActiveColor;
    } else if(textField == self.passwordTextField) {
        self.passwordUnderLine.backgroundColor = inActiveColor;
    } else if(textField == self.verifyCodeTextField) {
        self.verifyCodeUnderLine.backgroundColor = inActiveColor;
    }
}

@end
