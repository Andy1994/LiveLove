//
//  GFLoginRegisterViewController.m
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFLoginRegisterViewController.h"
#import "GFLoginRegisterUpperView.h"
#import "GFLoginRegisterBottomView.h"
#import "GFNetworkManager+User.h"
#import "GFRegisterProfileViewController.h"
#import "GFForgetPwdViewController.h"
#import "GFAccountManager.h"
#import "GFAccountManager+QQ.h"
#import "GFAccountManager+Wechat.h"
#import "GFAccountManager+Weibo.h"
#import "GFWebViewController.h"

@interface GFLoginRegisterViewController ()
<GFLoginRegisterBottomViewDelegate>

@property (nonatomic, strong) UIImageView *titleImageView;
@property (strong, nonatomic) GFLoginRegisterUpperView *upperView;
@property (strong, nonatomic) GFLoginRegisterBottomView *bottomView;

@end

@implementation GFLoginRegisterViewController
- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        _titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo_getfun_light"]];
    }
    return _titleImageView;
}

- (GFLoginRegisterUpperView *)upperView {
    if (!_upperView) {
        _upperView = [[GFLoginRegisterUpperView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, GF_LOGIN_HEIGHT_UPPERVIEW)];
    }
    return _upperView;
}

-(GFLoginRegisterBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[GFLoginRegisterBottomView alloc] initWithFrame:CGRectMake(0, GF_LOGIN_HEIGHT_UPPERVIEW - GF_HEIGHT_SEGMENTED_CONTROL, SCREEN_WIDTH, SCREEN_HEIGHT - GF_LOGIN_HEIGHT_UPPERVIEW + GF_HEIGHT_SEGMENTED_CONTROL)];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

#pragma - mark Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackLight;
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    self.navigationItem.titleView = self.titleImageView;
    self.titleImageView.alpha = 0.0f;
    
    //构建上下两个视图，两个视图在segmentControl部分有重叠
    [self.view addSubview:self.upperView];
    [self.view addSubview:self.bottomView];
    //TODO: 如果是4s设备，bottomView整个往上移到upperView的slogan下面
    if (SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 480) {
        CGRect sloganFrame = [self.view convertRect:self.upperView.sloganImgView.frame toView:self.view];
        CGRect originFrame = self.bottomView.frame;
        originFrame.origin.y = CGRectGetMaxY(sloganFrame) * 0.4 + 3;
        CGFloat deltaH = originFrame.origin.y - self.bottomView.frame.origin.y;
        originFrame.size.height -= deltaH;
        self.bottomView.frame = originFrame;
        [self.bottomView setNeedsLayout];
    }

    //为上方视图添加手势是键盘隐藏
    __weak typeof(self) weakSelf = self;
    [self.upperView bk_whenTapped:^{
        [weakSelf.bottomView endEditing:YES];
    }];
//    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionLeft;
//    [self.upperView addGestureRecognizer:swipeGestureRecognizer];
    
    [self gf_setNavBarBackgroundTransparent:0.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];    
}

- (void)dealloc {
    [_upperView removeFromSuperview];
    _upperView = nil;
    
    [_bottomView removeFromSuperview];
    _bottomView = nil;
    
    [GFAccountManager sharedManager].checkLoginCompletionHandler = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //移除键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBarButtonItemSelected {
    [self.view endEditing:YES];
    
    [super backBarButtonItemSelected];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer {
    [self.bottomView endEditing:YES];
}

#pragma mark - 键盘通知事件
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions options = animationCurve << 16;
    
    __weak typeof(self) weakSelf = self;
    CGFloat newBottom = SCREEN_HEIGHT - kbSize.height / 3 * 2;
    if (SCREEN_WIDTH == 320 && SCREEN_HEIGHT == 480) {
        newBottom = newBottom + 13;
    }
    [UIView animateWithDuration:animationDuration delay:0.0f options:options animations:^{
        weakSelf.bottomView.bottom = newBottom;
        weakSelf.upperView.sloganImgView.alpha = 0.0f;
        weakSelf.titleImageView.alpha = 1.0f;
    } completion:NULL];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions options = animationCurve << 16;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:animationDuration delay:0.0f options:options animations:^{
        weakSelf.bottomView.bottom = weakSelf.view.height;
        weakSelf.upperView.sloganImgView.alpha = 1.0f;
        weakSelf.titleImageView.alpha = 0.0f;
    } completion:NULL];
}

#pragma mark - GFLoginRegisterBottomViewDelegate
#pragma mark 登录
- (void)didSelectForgetPassword:(NSString *)mobile {
    
    __weak typeof(self) weakSelf = self;
    GFForgetPwdViewController *forgetPwdViewController = [[GFForgetPwdViewController alloc] initWithMobile:mobile];
    forgetPwdViewController.registerHandler = ^{
        [weakSelf.bottomView showRegisterView];
    };
    [self.navigationController pushViewController:forgetPwdViewController animated:YES];
}

- (void)loginWithMobile:(NSString *)mobile password:(NSString *)password {
    __weak typeof(self) weakSelf = self;
    [GFAccountManager loginUser:mobile
                       password:password
                        success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                            if (code == 1) {
                                [MBProgressHUD showHUDWithTitle:@"登录成功" duration:kCommonHudDuration inView:self.view];
                                [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                            } else {
                                [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                            }
                        } failure:^(NSUInteger taskId, NSError *error) {
                            [MBProgressHUD showHUDWithTitle:@"登录失败" duration:kCommonHudDuration inView:self.view];
                        }];
}

- (void)didSelectLoginWithType:(GFLoginType)loginType {
    
    __weak typeof(self) weakSelf = self;
    void(^loginSuccessHandler)(NSUInteger, NSInteger, NSString *, BOOL, GFUserMTL *) = ^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, GFUserMTL *userInfo) {
        if (code == 1) {
            if (firstLogin) {
                GFRegisterProfileViewController *registerProfileViewController = [[GFRegisterProfileViewController alloc] init];
                [weakSelf.navigationController pushViewController:registerProfileViewController animated:YES];
            } else {
                [MBProgressHUD showHUDWithTitle:@"登录成功" duration:kCommonHudDuration inView:weakSelf.view];
                [weakSelf dismissViewControllerAnimated:YES completion:NULL];
            }
        } else {
            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:weakSelf.view];
        }
    };
    void(^loginFailureHandler)() = ^() {
        [MBProgressHUD showHUDWithTitle:@"登录失败" duration:kCommonHudDuration inView:weakSelf.view];
    };

    if (loginType == GFLoginTypeWechat) {
        [MobClick event:@"gf_dl_01_03_01_1"];
        [GFAccountManager wechatSSOLoginSuccess:loginSuccessHandler
                                        failure:loginFailureHandler];

    } else if (loginType == GFLoginTypeQQ) {
        [MobClick event:@"gf_dl_01_03_03_1"];
        [GFAccountManager qqSSOLoginSuccess:loginSuccessHandler
                                    failure:loginFailureHandler];
    } else if (loginType == GFLoginTypeWeiBo) {
        [MobClick event:@"gf_dl_01_03_02_1"];
        [GFAccountManager weiboSSOLoginSuccess:loginSuccessHandler
                                       failure:loginFailureHandler];
    }
}

#pragma mark  注册
- (void)didSelectUserAgreement:(NSURL *)url {
    GFWebViewController *controller = [[GFWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didCheckRegisterVerifyCodeForMobile:(NSString *)mobile password:(NSString *)password token:(NSString *)token {
    if ([password length] < 6 || [password length] > 20) {
        [MBProgressHUD showHUDWithTitle:@"请输入6-20位字符" duration:kCommonHudDuration inView:self.view];
        return;
    }
    __weak typeof(self) weakSelf = self;
    //只要填写了手机号和密码并且验证码通过，视为注册成功
    [GFAccountManager registerUserWithParameters:@{@"mobile":mobile,
                                                   @"password":password,
                                                   @"token":token}
                                         success:^(NSInteger code, NSString *apiErrorMessage) {
                                             if (code == 1) {
                                                 
                                                 GFRegisterProfileViewController *registerProfileViewController = [[GFRegisterProfileViewController alloc] init];
                                                 [weakSelf.navigationController pushViewController:registerProfileViewController animated:YES];
                                                 
                                             } else {
                                                 [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                             }
                                             
                                         } failure:^(NSUInteger taskId, NSError *error) {
                                             [MBProgressHUD showHUDWithTitle:@"网络请求失败" duration:kCommonHudDuration inView:self.view];
                                         }];
}



@end
