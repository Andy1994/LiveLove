//
//  GFLoginRegisterBottomView.m
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFLoginRegisterBottomView.h"
#import "WXApi.h"

#define GF_HEIGHT_3RD_LOGIN_PART 300.0f

@interface GFLoginRegisterBottomView () <TTTAttributedLabelDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *bgWhiteView; // 白底
//@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) GFLoginView *loginView;
@property (strong, nonatomic) GFRegisterView *registerView;

@property (strong, nonatomic) UIButton *qqButton;
@property (strong, nonatomic) UIButton *wechatButton;
@property (strong, nonatomic) UIButton *weiboButton;

@end

@implementation GFLoginRegisterBottomView
- (HMSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"登录", @"注册"]];
        _segmentedControl.backgroundColor = [UIColor clearColor];
        _segmentedControl.titleTextAttributes = @{
                                                  NSFontAttributeName:[UIFont systemFontOfSize:17],
                                                  NSForegroundColorAttributeName : [UIColor whiteColor]
                                                  };
        _segmentedControl.frame = CGRectMake(0, 0, self.width, GF_HEIGHT_SEGMENTED_CONTROL);
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectionIndicatorColor = [UIColor themeColorValue7];
    }
    return _segmentedControl;
}

- (UIView *)bgWhiteView {
    if (!_bgWhiteView) {
        _bgWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.bottom, self.width, self.height-self.segmentedControl.height)];
        _bgWhiteView.backgroundColor = RGBCOLOR(249, 249, 249);
    }
    return _bgWhiteView;
}

- (GFLoginView *)loginView {
    if (!_loginView) {
        _loginView = [[GFLoginView alloc] initWithFrame:CGRectMake(0, 0, self.width, 200.0f)];
    }
    return _loginView;
}

-(GFRegisterView *)registerView {
    if (!_registerView) {
        _registerView = [[GFRegisterView alloc] initWithFrame:CGRectMake(0, 0, self.width, 250.0f)];
    }
    return _registerView;
}

- (UIButton *)qqButton {
    if (!_qqButton) {
        _qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _qqButton.frame = CGRectMake(46, self.loginView.bottom + 27, 40, 40);
        UIImage *img = [UIImage imageNamed:@"icon_qq"];
        [_qqButton setImage:img forState:UIControlStateNormal];
        [_qqButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _qqButton;
}

- (UIButton *)wechatButton {
    if (!_wechatButton) {
        _wechatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _wechatButton.frame = CGRectMake(self.width/2-20, self.loginView.bottom + 27, 40, 40);
        _wechatButton.hidden = YES;
        UIImage *img = [UIImage imageNamed:@"icon_wechat"];
        [_wechatButton setImage:img forState:UIControlStateNormal];
        [_wechatButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _wechatButton;
}

- (UIButton *)weiboButton {
    if (!_weiboButton) {
        _weiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _weiboButton.frame = CGRectMake(self.width-46-40, self.loginView.bottom + 27, 40, 40);
        UIImage *img = [UIImage imageNamed:@"icon_sina"];
        [_weiboButton setImage:img forState:UIControlStateNormal];
        [_weiboButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
    }
    return _weiboButton;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.segmentedControl];
        [self.segmentedControl addTarget:self action:@selector(didSelectedSegmentChanged) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:self.bgWhiteView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgWhiteViewTapGesture:)];
        gesture.delegate = self;
        [self.bgWhiteView addGestureRecognizer:gesture];
        
        [self.bgWhiteView addSubview:self.loginView];
        __weak typeof(self) weakSelf = self;
        [self.loginView.forgetPwdButton bk_addEventHandler:^(id sender) {
            
            [MobClick event:@"gf_dl_01_02_01_1"];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectForgetPassword:)]) {
                
                NSString *mobile = weakSelf.loginView.phoneNumberTextField.text;
                [weakSelf.delegate didSelectForgetPassword:[mobile gf_isValidType:GFValidateTypePhoneNumber] ? mobile : @""];
            }
            
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self.loginView.loginButton bk_addEventHandler:^(id sender) {
            
            [MobClick event:@"gf_dl_01_01_01_1"];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(loginWithMobile:password:)]) {
                
                //输入错误提示
                NSString *phoneNumber = weakSelf.loginView.phoneNumberTextField.text;
                NSString *password = weakSelf.loginView.passwordTextField.text;
                if (![phoneNumber gf_isValidType:GFValidateTypePhoneNumber] || ![password gf_isValidType:GFValidateTypeCharacter]) {
                    [MBProgressHUD showHUDWithTitle:@"用户名或密码错误" duration:kCommonHudDuration];
                } else {
                    [weakSelf.delegate loginWithMobile:weakSelf.loginView.phoneNumberTextField.text password:weakSelf.loginView.passwordTextField.text];
                }
            }
            
        } forControlEvents:UIControlEventTouchUpInside];
        [weakSelf.loginView bk_whenTapped:^{
            [weakSelf.loginView endEditing:YES];
        }];
        
        [self.bgWhiteView addSubview:self.registerView];
        self.registerView.userProtocolLabel.delegate = self;
        self.registerView.didCheckVerifyCodeSuccessHandler = ^(NSString *mobile, NSString *password, NSString *token) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didCheckRegisterVerifyCodeForMobile:password:token:)]) {
                [weakSelf.delegate didCheckRegisterVerifyCodeForMobile:mobile password:password token:token];
            }
        };
        self.registerView.hidden = YES;
        
        [self.bgWhiteView addSubview:self.qqButton];
        [self.qqButton bk_addEventHandler:^(id sender) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectLoginWithType:)]) {
                [weakSelf.delegate didSelectLoginWithType:GFLoginTypeQQ];
            }
        } forControlEvents:UIControlEventTouchUpInside];

        [WXApi registerApp:kWXAppId];
        self.wechatButton.hidden = ![WXApi isWXAppInstalled];
        [self.bgWhiteView addSubview:self.wechatButton];
        [self.wechatButton bk_addEventHandler:^(id sender) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectLoginWithType:)]) {
                [weakSelf.delegate didSelectLoginWithType:GFLoginTypeWechat];
            }
        } forControlEvents:UIControlEventTouchUpInside];

        [self.bgWhiteView addSubview:self.weiboButton];
        [self.weiboButton bk_addEventHandler:^(id sender) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didSelectLoginWithType:)]) {
                [weakSelf.delegate didSelectLoginWithType:GFLoginTypeWeiBo];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgWhiteView.frame = CGRectMake(0, self.segmentedControl.bottom, self.width, self.height-self.segmentedControl.height);
}
- (void)dealloc {
    [_loginView removeFromSuperview];
    _loginView = nil;
    
    [_registerView removeFromSuperview];
    _registerView = nil;
}

#pragma mark - Methods
- (void)bgWhiteViewTapGesture:(UIGestureRecognizer *)gesture {
    [self.bgWhiteView endEditing:YES];
}

- (void)didSelectedSegmentChanged {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [MobClick event:@"gf_zc_01_02_01_1"];
        [self showLoginView];
    } else {
        [MobClick event:@"gf_dl_01_04_01_1"];
        [self showRegisterView];
    }
}

- (void)showLoginView {
    self.segmentedControl.selectedSegmentIndex = 0;
    self.loginView.hidden = NO;
    self.registerView.hidden = YES;    
    [self endEditing:YES];
    
    self.qqButton.hidden = self.weiboButton.hidden = NO;
    self.wechatButton.hidden = ![WXApi isWXAppInstalled];
    self.qqButton.y = self.wechatButton.y = self.weiboButton.y = self.loginView.bottom + 27.0f;
}

- (void)showRegisterView {
    self.segmentedControl.selectedSegmentIndex = 1;
    self.loginView.hidden = YES;
    self.registerView.hidden = NO;
    [self endEditing:YES];
    
    self.qqButton.hidden = self.weiboButton.hidden = NO;
    self.wechatButton.hidden = ![WXApi isWXAppInstalled];
    //self.qqButton.hidden = self.wechatButton.hidden = self.weiboButton.hidden = YES;
    
    self.qqButton.y = self.wechatButton.y = self.weiboButton.y = self.registerView.bottom + 27.0f;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[TTTAttributedLabel class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    label.highlightedTextColor = [UIColor themeColorValue7];
    NSMutableDictionary *mutableactiveLinkAttributes = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mutableactiveLinkAttributes setObject:(__bridge id)[[UIColor themeColorValue7] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    label.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableactiveLinkAttributes];

    if (label == self.registerView.userProtocolLabel &&
        self.delegate &&
        [self.delegate respondsToSelector:@selector(didSelectUserAgreement:)]) {
        [self.delegate didSelectUserAgreement:url];
    }
}

@end
