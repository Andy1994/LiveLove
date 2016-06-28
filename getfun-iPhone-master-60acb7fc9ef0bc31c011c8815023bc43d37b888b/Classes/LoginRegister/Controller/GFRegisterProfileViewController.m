//
//  GFRegisterProfileViewController.m
//  GetFun
//
//  Created by liupeng on 15/11/16.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFRegisterProfileViewController.h"
#import "GFNetworkManager+User.h"
#import "GFProvinceAndCityPicker.h"
#import "GFDatePicker.h"
#import "GFAccountManager.h"
#import "GFAccountManager+Weibo.h"
#import "GFAccountManager+Wechat.h"
#import "GFAccountManager+QQ.h"
#import "GFNetworkManager+Publish.h"
#import <QiniuSDK.h>
#import "GFAssetsPickerViewController.h"
#import "GFTakingPhotoViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import "GFPhotoUtil.h"

@interface GFRegisterProfileItemView : UIView
@property (nonatomic, strong) UITextField *contentTextField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@end

@implementation GFRegisterProfileItemView
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width/3, self.height)];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
        _accessoryImageView.x = self.width - _accessoryImageView.width;
        _accessoryImageView.centerY = self.height/2;
    }
    return _accessoryImageView;
}

- (UITextField *)contentTextField {
    if (!_contentTextField) {
        _contentTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.titleLabel.right+5,
                                                                          0,
                                                                          self.accessoryImageView.x-10-self.titleLabel.right,
                                                                          self.height)];
        _contentTextField.textColor = [UIColor textColorValue8];
        _contentTextField.textAlignment = NSTextAlignmentRight;
        _contentTextField.font = [UIFont systemFontOfSize:17.0f];
        _contentTextField.userInteractionEnabled = NO;
        _contentTextField.placeholder = @"请选择";
    }
    return _contentTextField;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.accessoryImageView];
        [self addSubview:self.contentTextField];
    }
    return self;
}
@end

@interface GFRegisterProfileViewController () <UITextFieldDelegate>

/**
 nickName	String	昵称
 sex        String	性别	UNKNOWN("未知性别"), MALE("男"), FEMALE("女")
 birthday	long	生日	毫秒表示的时间戳
 provinceId	int    	所在地省份，用整形数字表示，如：1-表示北京
 cityId     int    	所在地地市，用整形数字表示，结合province字段，如：1-表示北京的东城区
 avatar     String	头像图片的URL
 */
@property (nonatomic, strong) NSMutableDictionary *userInfoParameters;

@property (nonatomic, strong) id authorizeResponse;

@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImage *userAvatarImage; // 用户选择的头像.单独存储用于七牛上传
@property (nonatomic, strong) UIImageView *avatarEditIcon;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UITextField *nickNameTextField;
@property (nonatomic, strong) UIView *nickNameUnderLine;

@property (nonatomic, strong) GFRegisterProfileItemView *birthdayView;
@property (nonatomic, strong) GFRegisterProfileItemView *locationView;

@property (nonatomic, strong) UIButton *maleButton;
@property (nonatomic, strong) UIButton *femaleButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation GFRegisterProfileViewController
- (NSMutableDictionary *)userInfoParameters {
    if (!_userInfoParameters) {
        _userInfoParameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _userInfoParameters;
}

- (UIImageView *)bannerImageView {
    if (!_bannerImageView) {
        UIImage *bgImage = [UIImage imageNamed:@"register_profile_banner"];
        _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 200.0f)];
        _bannerImageView.image = bgImage;
        _bannerImageView.userInteractionEnabled = YES;
        
        __weak typeof(self) weakSelf = self;
        [_bannerImageView bk_whenTapped:^{
            [weakSelf.view endEditing:YES];
            [weakSelf changeAvatar];
        }];
    }
    return _bannerImageView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_avatar_1"]];
        [_avatarImageView sizeToFit];
        _avatarImageView.center = self.bannerImageView.center;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = _avatarImageView.width/2;
    }
    return _avatarImageView;
}

- (UIImageView *)avatarEditIcon {
    if (!_avatarEditIcon) {
        _avatarEditIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_edit_avatar"]];
        _avatarEditIcon.frame = CGRectMake(self.avatarImageView.right-20, self.avatarImageView.bottom-20, 20, 20);
    }
    return _avatarEditIcon;
}

-(UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont systemFontOfSize:15];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"上传一张美美的头像吧~";
        [_tipLabel sizeToFit];
        _tipLabel.center = CGPointMake(self.view.width/2, self.avatarImageView.bottom+10+_tipLabel.height/2);
    }
    return _tipLabel;
}

- (UITextField *)nickNameTextField {
    if (!_nickNameTextField) {
        _nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(46.0f,
                                                                           self.bannerImageView.bottom + 8,
                                                                           self.view.width - 46.0f * 2,
                                                                           50.0f)];
        _nickNameTextField.font = [UIFont systemFontOfSize:17.0];
        _nickNameTextField.placeholder= @"请输入昵称";
        _nickNameTextField.delegate = self;
    }
    return _nickNameTextField;
}

- (UIView *)nickNameUnderLine {
    if (!_nickNameUnderLine) {
        _nickNameUnderLine = [[UIView alloc] initWithFrame:CGRectMake(self.nickNameTextField.x,
                                                                      self.nickNameTextField.bottom,
                                                                      self.view.width - 46.0f * 2,
                                                                      0.5f)];
        _nickNameUnderLine.backgroundColor = [UIColor themeColorValue15];
    }
    return _nickNameUnderLine;
}


- (GFRegisterProfileItemView *)birthdayView {
    if (!_birthdayView) {
        _birthdayView = [[GFRegisterProfileItemView alloc] initWithFrame:self.nickNameTextField.frame];
        _birthdayView.y = self.nickNameTextField.bottom;
        [_birthdayView gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
        _birthdayView.titleLabel.text = @"出生日期";
        __weak typeof(self) weakSelf = self;
        [_birthdayView bk_whenTapped:^{
            [MobClick event:@"gf_zc_02_01_01_1"];
            [weakSelf.view endEditing:YES];
            [weakSelf selectBirthday];
        }];
    }
    return _birthdayView;
}

- (GFRegisterProfileItemView *)locationView {
    if (!_locationView) {
        _locationView = [[GFRegisterProfileItemView alloc] initWithFrame:self.nickNameTextField.frame];
        _locationView.y = self.birthdayView.bottom;
        [_locationView gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
        _locationView.titleLabel.text = @"所在地";
        __weak typeof(self) weakSelf = self;
        [_locationView bk_whenTapped:^{
            [MobClick event:@"gf_zc_02_01_02_1"];
            [weakSelf.view endEditing:YES];
            [weakSelf selectLocation];
        }];
    }
    return _locationView;
}

- (UIButton *)maleButton {
    if (!_maleButton) {
        _maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _maleButton.frame = CGRectMake(self.locationView.x,
                                       self.locationView.bottom + 24,
                                       self.locationView.width/2-7,
                                       self.locationView.height);
        UIImage *img = [UIImage imageNamed:@"icon_male"];
        [_maleButton setImage:img forState:UIControlStateNormal];
        [_maleButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
        [_maleButton setTitle:@"BOY" forState:UIControlStateNormal];
        _maleButton.backgroundColor = [UIColor themeColorValue13];
        _maleButton.imageView.size = CGSizeMake(18, 18);
        _maleButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _maleButton.layer.cornerRadius = 4.0f;
        __weak typeof(self) weakSelf = self;
        [_maleButton bk_addEventHandler:^(id sender) {
            _maleButton.selected = YES;
            _maleButton.backgroundColor = RGBCOLOR(47, 213, 156);
            _femaleButton.selected = NO;
            _femaleButton.backgroundColor = [UIColor themeColorValue14];
            [weakSelf.userInfoParameters setObject:@"MALE" forKey:@"sex"];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _maleButton;
}

- (UIButton *)femaleButton {
    if (!_femaleButton) {
        _femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _femaleButton.frame = CGRectMake(self.maleButton.right + 14,
                                         self.maleButton.y,
                                         self.maleButton.width,
                                         self.maleButton.height);
        UIImage *img = [UIImage imageNamed:@"icon_female"];
        _femaleButton.imageView.size = CGSizeMake(18, 18);
        [_femaleButton setImage:img forState:UIControlStateNormal];
        [_femaleButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
        [_femaleButton setTitle:@"GIRL" forState:UIControlStateNormal];
        _femaleButton.backgroundColor = [UIColor themeColorValue14];
        _femaleButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _femaleButton.layer.cornerRadius = 4.0f;
        __weak typeof(self) weakSelf = self;
        [_femaleButton bk_addEventHandler:^(id sender) {
            _maleButton.selected = NO;
            _femaleButton.selected = YES;
            _femaleButton.backgroundColor = RGBCOLOR(255, 125, 195);
            _maleButton.backgroundColor = [UIColor themeColorValue13];
            
            [weakSelf.userInfoParameters setObject:@"FEMALE" forKey:@"sex"];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _femaleButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton gf_purpleButtonWithTitle:@"完成"];
        _confirmButton.frame = self.locationView.frame;
        _confirmButton.height = 40.0f;
        _confirmButton.y = self.maleButton.bottom + 24;
        __weak typeof(self) weakSelf = self;
        [_confirmButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_zc_02_02_01_1"];
            [weakSelf uploadAvatarAndUpdateProfile];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.bannerImageView];
    [self.view addSubview:self.avatarImageView];
    [self.view addSubview:self.avatarEditIcon];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.nickNameTextField];
    [self.view addSubview:self.birthdayView];
    [self.view addSubview:self.locationView];
    [self.view addSubview:self.maleButton];
    [self.view addSubview:self.femaleButton];
    [self.view addSubview:self.confirmButton];

    [self hideFooterImageView:YES];
    
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackLight;
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view bk_whenTapped:^{
        [self.view endEditing:YES];
    }];
    
    [self gf_setNavBarBackgroundTransparent:0.0f];
    
    self.authorizeResponse = [GFAccountManager sharedManager].authorizeResponse;
    
    //第三方登录信息加载
    if (self.authorizeResponse) {
        __weak typeof(self) weakSelf = self;
        void (^profileHandleBlock)(NSString *, GFUserGender, NSString *) = ^(NSString *nickName, GFUserGender gender, NSString *avatarURL) {
            weakSelf.nickNameTextField.text = nickName;
            if (avatarURL) {
#warning 图片剪裁标准未确定
                [weakSelf.avatarImageView setImageWithURL:[NSURL URLWithString:[avatarURL gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarProfile gifConverted:YES]]
                                              placeholder:[UIImage imageNamed:@"default_avatar_1"]
                                                  options:kNilOptions
                                               completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                                       weakSelf.userAvatarImage = image;
                                               }];
            }
            weakSelf.maleButton.selected = (gender == GFUserGenderMale);
            weakSelf.femaleButton.selected = (gender == GFUserGenderFemale);
            if (nickName) {
                [weakSelf.userInfoParameters setObject:nickName forKey:@"nickName"];
            }

        };
        
        if ([self.authorizeResponse isKindOfClass:[WBAuthorizeResponse class]]) {
            // 获取微博资料
            WBAuthorizeResponse *resp = self.authorizeResponse;
            [GFAccountManager queryWeiboProfileWithUID:resp.userID
                                           accessToken:resp.accessToken
                                               success:profileHandleBlock
                                               failure:NULL];
            
        } else if ([self.authorizeResponse isKindOfClass:[GFWXAuthorizeResponse class]]) {
            // 获取微信资料
            GFWXAuthorizeResponse *resp = self.authorizeResponse;
            [GFAccountManager queryWechatProfileWithOpenId:resp.openid
                                               accessToken:resp.access_token
                                                   success:profileHandleBlock
                                                   failure:NULL];
        } else if ([self.authorizeResponse isKindOfClass:[TencentOAuth class]]) {
            // 获取QQ资料
            [GFAccountManager queryQQProfileWithSuccess:profileHandleBlock
                                                failure:NULL];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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


#pragma mark - Bar Button Action
- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_zc_02_02_02_1"];
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions options = animationCurve << 16;
    
    [UIView animateWithDuration:animationDuration delay:0.0f options:options animations:^{
        self.view.bottom = SCREEN_HEIGHT - kbSize.height / 2 - 15;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    UIViewAnimationOptions options = animationCurve << 16;
    
    [UIView animateWithDuration:animationDuration delay:0.0f options:options animations:^{
        self.view.bottom = self.view.height;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - 选择头像
- (void)changeAvatar {
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"选择图片"];    
    // 拍照
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        GFTakingPhotoViewController *takingPhotoViewController = [[GFTakingPhotoViewController alloc] init];
        takingPhotoViewController.isCropAllowed = YES;
        takingPhotoViewController.gf_didFinishTakingPhotoBlock = ^(GFTakingPhotoViewController *controller, UIImage *image) {
            [self handleSelectAvatar:image];
        };
        takingPhotoViewController.gf_didCancelTakingPhotoBlock = ^(GFTakingPhotoViewController *controller) {

        };
        [actionSheet bk_addButtonWithTitle:@"拍照" handler:^{
             [self presentViewController:takingPhotoViewController animated:YES completion:NULL];
        }];
    }
    
    // 相册上传
    [actionSheet bk_addButtonWithTitle:@"从相册上传" handler:^{
        
        [GFPhotoUtil checkAuthorizationCompletion:^(BOOL authorized) {
            if (authorized) {
                GFAssetsPickerViewController *imagePickerPhoto = [[GFAssetsPickerViewController alloc] init];
                imagePickerPhoto.maxSelectNumber = 1;
                imagePickerPhoto.isCropAllowed = YES;
                imagePickerPhoto.gf_didFinishPickingImageBlock = ^(GFAssetsPickerViewController *picker, UIImage *image, UIImage *thumbnail){
                    [self handleSelectAvatar:image];
                };
                imagePickerPhoto.gf_didFinishPickingAssetsBlock = ^(GFAssetsPickerViewController *picker, NSArray *assets, NSArray *thumbnails) {
                    [self handleSelectAvatar:[thumbnails firstObject]];
                };
                
                imagePickerPhoto.gf_didCancelPickingAssetsBlock = ^(GFAssetsPickerViewController *picker) {
                    
                };
                
                [self presentViewController:imagePickerPhoto animated:YES completion:NULL];
            }
        }];
    }];
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    
    [actionSheet showInView:self.view];
}

- (void)handleSelectAvatar:(UIImage *)avatar {
    
    UIImage *selectedImage = [avatar gf_imageByScalingAndCroppingForSize:CGSizeMake(100, 100)];
    self.avatarImageView.image = selectedImage;
    self.userAvatarImage = selectedImage;
    [self animateAvatarAnimation];
}

- (void)animateAvatarAnimation {
    POPSpringAnimation *layerScaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    layerScaleAnimation.springBounciness = 20;
    layerScaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(6, 6)];
    layerScaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    layerScaleAnimation.delegate = self;
    [self.avatarImageView.layer pop_addAnimation:layerScaleAnimation forKey:@"avatarImageViewScaleAnimaiton"];
}

#pragma mark - 选择昵称
#pragma mark UITextFieldDelegate
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField == self.nickNameTextField) {
//        NSString *nickName = textField.text;
//        if (nickName) {
//            [self.userInfoParameters setObject:nickName forKey:@"nickName"];
//        }
//    }
//}

#pragma mark - 选择日期和地点
- (void)selectBirthday {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *initialDate = [formatter dateFromString:@"1995-01-01"];
    
    __weak typeof(self) weakSelf = self;
    [GFDatePicker gf_showDatePickerInitialDate:initialDate
                                    completion:^(NSDate *selectedDate) {
                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                        formatter.dateFormat = @"yyyy-MM-dd";
                                        NSString *dateString = [formatter stringFromDate:selectedDate];
                                        weakSelf.birthdayView.contentTextField.text = dateString;
                                        [weakSelf.userInfoParameters setObject:[NSNumber numberWithLongLong:[selectedDate timeIntervalSince1970] * 1000] forKey:@"birthday"];
                                    } cancel:^{
                                        
                                    }];
}

- (void)selectLocation {
    __weak typeof(self) weakSelf = self;
    [GFProvinceAndCityPicker gf_showProvinceAndCityPickerInitialProvinceId:nil
                                                             initialCityId:nil
                                                                completion:^(NSNumber *provinceId, NSString *provinceName, NSNumber *cityId, NSString *cityName) {
                                                                    NSString *location = [NSString stringWithFormat:@"%@ | %@", provinceName, cityName];
                                                                    weakSelf.locationView.contentTextField.text = location;
                                                                    
                                                                    [weakSelf.userInfoParameters setObject:provinceId forKey:@"provinceId"];
                                                                    [weakSelf.userInfoParameters setObject:cityId forKey:@"cityId"];
                                                                } cancel:^{
                                                                    //
                                                                }];
}

#pragma mark - 验证是否可以提交
/**
 token      String	手机号验证通过后返回给客户端的token
 mobile     String	手机号码
 password	String	密码
 nickName	String	昵称
 sex        String	性别	UNKNOWN("未知性别"), MALE("男"), FEMALE("女")
 birthday	long	生日	毫秒表示的时间戳
 provinceId	int    	所在地省份，用整形数字表示，如：1-表示北京
 cityId     int    	所在地地市，用整形数字表示，结合province字段，如：1-表示北京的东城区
 avatar     String	头像图片的URL
 手机号注册时，前三个参数为必需。第三方登录进行完善信息时，前三个参数为空
 */
- (BOOL)validateInput {
    
    if (![self.userInfoParameters objectForKey:@"nickName"] ||
        [[self.userInfoParameters objectForKey:@"nickName"] isEqualToString:@""]) {
        [MBProgressHUD showHUDWithTitle:@"请填写用户名" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    
    if (self.userAvatarImage == nil) {
        [MBProgressHUD showHUDWithTitle:@"请选择头像" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    
    if (![self.userInfoParameters objectForKey:@"sex"]) {
        [MBProgressHUD showHUDWithTitle:@"请选择性别" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    
    if (![self.userInfoParameters objectForKey:@"birthday"]) {
        [MBProgressHUD showHUDWithTitle:@"请选择出生日期" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    
    if (![self.userInfoParameters objectForKey:@"provinceId"] || ![self.userInfoParameters objectForKey:@"cityId"]) {
        [MBProgressHUD showHUDWithTitle:@"请选择所在地" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    return YES;
}

#pragma mark - 确认提交
- (void)uploadAvatarAndUpdateProfile {
    
    //防止昵称输入框尚未失去焦点名称，统一在提交时更新获取昵称
    NSString *nickName = self.nickNameTextField.text;
    if (nickName) {
        [self.userInfoParameters setObject:nickName forKey:@"nickName"];
    }
    
    
    if (![self validateInput]) {
        return;
    }
    
    self.hud = [MBProgressHUD showHUDWithTitle:@"正在提交资料" inView:self.view];
    if (self.userAvatarImage) {

        // 上传七牛
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager queryQiNiuTokenSuccess:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token) {
            if (code == 1) {
                NSError *error = nil;
                QNFileRecorder *file = [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:@"QNGetGun"] error:&error];
                QNUploadManager *uploadManager = [[QNUploadManager alloc] initWithRecorder:file];
                [uploadManager putData:UIImageJPEGRepresentation([weakSelf.userAvatarImage gf_autoResizeImageWithNet], 1)
                                   key:nil
                                 token:token
                              complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                  
                                  if (resp) {
                                      NSDictionary *picture = [resp objectForKey:@"picture"];
                                      NSString *storeKey = [picture objectForKey:@"storeKey"];
                                      if(storeKey) {
                                          [weakSelf.userInfoParameters setObject:storeKey forKey:@"avatar"];
                                      }
                                      [weakSelf updateProfile];
                                  } else {
                                      self.hud.labelText = @"提交资料失败";
                                      [self.hud hide:YES afterDelay:kCommonHudDuration];
                                  }
                              } option:nil];
                
            } else {
                self.hud.labelText = @"提交资料失败";
                [self.hud hide:YES afterDelay:kCommonHudDuration];
            }
        } failure:^(NSUInteger taskId, NSError *error) {
            self.hud.labelText = @"提交资料失败";
            [self.hud hide:YES afterDelay:kCommonHudDuration];
        }];
        
    } else {
        [self updateProfile];
    }
}

- (void)updateProfile {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager updateProfileWithParameters:self.userInfoParameters
                                          success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFUserMTL *user) {
                                              if (code == 1) {
                                                  self.hud.labelText = @"提交资料成功";
                                                  [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                                                  if (user) {
                                                      [GFAccountManager sharedManager].loginUser = user;
                                                  }
                                              } else {
                                                  self.hud.labelText = apiErrorMessage;
                                              }
                                            [self.hud hide:YES afterDelay:kCommonHudDuration];
                                          } failure:^(NSUInteger taskId, NSError *error) {
                                              self.hud.labelText = @"提交资料失败，请重试！";
                                              [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                                              [self.hud hide:YES afterDelay:kCommonHudDuration];
                                          }];
}

@end

