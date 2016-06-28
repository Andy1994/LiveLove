//
//  GFForgetPwdViewController.m
//  GetFun
//
//  Created by liupeng on 15/11/20.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFForgetPwdViewController.h"
#import "GFNetworkManager+User.h"
#import "GFResetPasswordViewController.h"
#import "GFAccountManager.h"
#import "GFVerifyButton.h"

@interface GFForgetPwdViewController () <UITextFieldDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, copy) NSString *iniMobile;

@property (strong, nonatomic, readwrite) UITextField *phoneNumberTextField;
@property (strong, nonatomic, readwrite) UITextField *verifyCodeTextField;
@property (strong, nonatomic, readwrite) GFVerifyButton *verifyButton;
@property (strong, nonatomic, readwrite) TTTAttributedLabel *registerLabel;
@property (strong, nonatomic, readwrite) UIButton *nextStepButton;

@property (nonatomic, strong) UIView *phoneNumberUnderLine;
@property (nonatomic, strong) UIView *verifyCodeUnderLine;

@property (nonatomic, assign) BOOL isNumberInvalid;

@end

static inline NSRegularExpression * RegisterRegularExpression() {
    static NSRegularExpression *_registerRegularExpression = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _registerRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"现在注册" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _registerRegularExpression;
}

@implementation GFForgetPwdViewController
- (UITextField *)phoneNumberTextField {
    if (!_phoneNumberTextField) {
        _phoneNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(46.0f,
                                                                              12.0f + 64.0f,
                                                                              self.view.width - 46.0f * 2,
                                                                              50.0f)];
        _phoneNumberTextField.delegate = self;
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
                                                                         self.view.width - 46.0f * 2,
                                                                         0.5f)];
        _phoneNumberUnderLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _phoneNumberUnderLine;
}

- (UITextField *)verifyCodeTextField {
    if (!_verifyCodeTextField) {
        _verifyCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.phoneNumberTextField.x,
                                                                             self.phoneNumberTextField.bottom,
                                                                             self.phoneNumberTextField.width/3 * 2,
                                                                             self.phoneNumberTextField.height)];
        _verifyCodeTextField.delegate = self;
        _verifyCodeTextField.placeholder = @"输入验证码";
        _verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _verifyCodeTextField.font = [UIFont systemFontOfSize:17.0f];
    }
    return _verifyCodeTextField;
}

- (UIView *)verifyCodeUnderLine {
    if (!_verifyCodeUnderLine) {
        _verifyCodeUnderLine = [[UIView alloc] initWithFrame:CGRectMake(self.verifyCodeTextField.x,
                                                                        self.verifyCodeTextField.bottom,
                                                                        self.view.width - 46.0f * 2,
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

            [MobClick event:@"gf_wj_01_01_01_1"];
            
            NSString *mobile = weakSelf.phoneNumberTextField.text;
            if ([mobile gf_isValidType:GFValidateTypePhoneNumber]) {
                [_verifyButton startCountDown];
                [weakSelf queryVerifyCode:mobile];
            } else {
                [MBProgressHUD showHUDWithTitle:@"请输入有效手机号" duration:kCommonHudDuration inView:self.view];
            }
            
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyButton;
}

- (TTTAttributedLabel *)registerLabel {
    if (!_registerLabel) {
        _registerLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(self.phoneNumberTextField.x,
                                                                              self.verifyCodeTextField.bottom + 6,
                                                                              self.phoneNumberTextField.width,
                                                                              16)];
        _registerLabel.delegate = self;
        _registerLabel.textColor = RGBCOLOR(34,34,34);
        _registerLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _registerLabel.numberOfLines = 1;
        _registerLabel.font = [UIFont systemFontOfSize:15];
        //设置高亮颜色
        _registerLabel.highlightedTextColor = RGBCOLOR(47,213,156);
        //检测url
        _registerLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        //对齐方式
        _registerLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
        //NO 不显示下划线
        _registerLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        NSString *text = @"该账号不存在，是否现在注册？";
        
        [_registerLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString)
         {
             //设置可点击文字的范围
             NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"现在注册" options:NSCaseInsensitiveSearch];
             
             //设定可点击文字的的大小
             UIFont *boldSystemFont = [UIFont systemFontOfSize:15];
             CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
             if (font) {
                 //设置可点击文本的大小
                 [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
                 //设置可点击文本的颜色
                 [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[RGBCOLOR(47,213,156) CGColor] range:boldRange];
                 CFRelease(font);
                 
             }
             return mutableAttributedString;
         }];
        
        //正则
        NSRegularExpression *regexp = RegisterRegularExpression();
        
        NSRange linkRange = [regexp rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.17getfun.com/"]];
        
        //设置链接的url
        [_registerLabel addLinkToURL:url withRange:linkRange];
        
    }
    return _registerLabel;
}

- (UIButton *)nextStepButton {
    if (!_nextStepButton) {
        
        _nextStepButton = [UIButton gf_purpleButtonWithTitle:@"下一步"];
        _nextStepButton.frame = CGRectMake(self.phoneNumberTextField.x,
                                           self.registerLabel.bottom + 6,
                                           self.phoneNumberTextField.width,
                                           40);
        _nextStepButton.enabled = NO;
        __weak typeof(self) weakSelf = self;
        [_nextStepButton bk_addEventHandler:^(id sender) {

            [MobClick event:@"gf_wj_01_02_01_1"];
            [weakSelf checkVerifyCode];

        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextStepButton;
}

- (instancetype)initWithMobile:(NSString *)mobile {
    if (self = [super init]) {
        _iniMobile = mobile;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //自定义导航栏属性
    self.title = @"忘记密码";
    [self hideFooterImageView:YES];
    
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackDark;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.phoneNumberTextField];
    [self.view addSubview:self.phoneNumberUnderLine];
    if (self.iniMobile) {
        self.phoneNumberTextField.text = self.iniMobile;
    }
    [self.view addSubview:self.verifyCodeTextField];
    [self.view addSubview:self.verifyCodeUnderLine];
    [self.view addSubview:self.verifyButton];
    [self.view addSubview:self.registerLabel];
    [self.view addSubview:self.nextStepButton];
}

- (void)dealloc {
    [_verifyButton removeFromSuperview];
    _verifyButton = nil;
    
    [_registerLabel removeFromSuperview];
    _registerLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.registerLabel.hidden = YES;
    self.isNumberInvalid = NO;
    [self.verifyButton reset];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_wj_01_02_01_1"];
    [super backBarButtonItemSelected];
}

- (void)queryVerifyCode:(NSString *)mobile {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager queryVerificationCodeForMobile:mobile
                                         existedUserSupposed:YES
                                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                 if (code == 1) {
                                                     [MBProgressHUD showHUDWithTitle:@"验证码已发送" duration:kCommonHudDuration inView:self.view];
                                                 } else {
                                                     // 找不到手机号，未注册
                                                     weakSelf.registerLabel.hidden = NO;
                                                     weakSelf.isNumberInvalid = YES;
                                                     [weakSelf.verifyButton reset];
                                                 }
                                             } failure:^(NSUInteger taskId, NSError *error) {
                                                 [MBProgressHUD showHUDWithTitle:@"验证码获取失败" duration:kCommonHudDuration inView:self.view];
                                             }];
}

- (void)checkVerifyCode {
    [GFNetworkManager checkVerificationCode:self.verifyCodeTextField.text
                                     mobile:self.phoneNumberTextField.text
                                    success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token) {
                                        if (code==1) {
                                            GFResetPasswordViewController *resetPwdViewController = [[GFResetPasswordViewController alloc] initWithMobile:self.phoneNumberTextField.text token:token];
                                            [self.navigationController pushViewController:resetPwdViewController animated:YES];
                                        } else {
                                            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                        }
                                        
                                    } failure:^(NSUInteger taskId, NSError *error) {
                                        //
                                    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChange = YES;
    
    NSString *phoneNumber = self.phoneNumberTextField.text;
    if (textField == self.phoneNumberTextField) {
        phoneNumber = [phoneNumber stringByReplacingCharactersInRange:range withString:string];
        //出现账号非法提示后，重新输入；隐藏非法提示框
        if (!self.registerLabel.hidden && self.isNumberInvalid) {
            self.registerLabel.hidden = YES;
            self.isNumberInvalid = NO;
            [self.verifyButton reset];
        }
    }

    NSString *verifyCode = self.verifyCodeTextField.text;
    if (textField == self.verifyCodeTextField) {
        verifyCode = [verifyCode stringByReplacingCharactersInRange:range withString:string];
        if ([verifyCode length] > 6) {
            verifyCode = [verifyCode substringToIndex:6];
            self.verifyCodeTextField.text = verifyCode;
            shouldChange = NO;
        }
    }
    
    self.nextStepButton.enabled = [phoneNumber gf_isValidType:GFValidateTypePhoneNumber] && [verifyCode gf_isValidType:GFValidateTypeNumber];
    self.nextStepButton.backgroundColor = self.nextStepButton.enabled ? [UIColor themeColorValue7]:[[UIColor themeColorValue7 ]colorWithAlphaComponent:0.5];
    
    return shouldChange;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (self.registerHandler) {
        self.registerHandler();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIColor *activeColor = [UIColor themeColorValue7];
    UIColor *inActiveColor = [UIColor themeColorValue15];
    
    self.phoneNumberUnderLine.backgroundColor = (textField == self.phoneNumberTextField) ? activeColor : inActiveColor;
    self.verifyCodeUnderLine.backgroundColor = (textField == self.verifyCodeTextField) ? activeColor : inActiveColor;
}

@end
