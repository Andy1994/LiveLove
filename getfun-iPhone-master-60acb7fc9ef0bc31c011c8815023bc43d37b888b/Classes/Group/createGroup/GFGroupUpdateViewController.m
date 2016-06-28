//
//  GFGroupUpdateViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupUpdateViewController.h"
#import "GFProfileUpdateTableViewCell.h"
#import "GFNetworkManager+Group.h"
#import "GFAccountManager.h"
#import "GFLocationManager.h"
#import "GFCreateGroupAllInterestViewController.h"
#import "GFCreateGroupSelectInterestViewController.h"
#import "GFMyGroupViewController.h"
#import "GFMapPoiSelectViewController.h"
#import <QiniuSDK.h>
#import <ActionSheetPicker.h>
#import "GFNetworkManager+Publish.h"

#import "GFAssetsPickerViewController.h"
#import "GFTakingPhotoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import "GFPhotoUtil.h"

#define GF_GROUPNAME_MAX_CHARACTERS_COUNT (15)
#define GF_GROUPINTRO_MAX_CHARACTERS_COUNT (70)

@interface GFGroupUpdateViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UITextViewDelegate,
UITextFieldDelegate,
UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary *parameters;

@property (nonatomic, strong, readonly) GFGroupMTL *iniGroup;

@property (nonatomic, strong) GFTagInfoMTL *userSelectedTag;


@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *avatarEditIcon;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UITextField *groupNameTextField;
@property (nonatomic, strong) UITextView *groupIntroTextView;
@property (nonatomic, strong) UITableView *updateTableView;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UILabel *characterCountLabel; //提示get帮名称输入字符个数
@property (nonatomic, strong) UILabel *groupIntroCharacterCountLabel; // 提示get帮简介字符个数

@property (nonatomic, strong) UIImage *groupAvatarImage; // 用户选择的头像.单独存储用于七牛上传


@property (nonatomic, assign) BOOL groupIntroAlreadyBeginEditing; //判断用户是否已经开始编辑帮介绍

@end

const CGFloat bannerHeight = 100.0f;

@implementation GFGroupUpdateViewController
- (NSMutableDictionary *)parameters {
    if (!_parameters) {
        _parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _parameters;
}


- (UIButton *)okButton {
    if (!_okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.frame = CGRectMake(0, 0, 60, 40);
        [_okButton setTitle:@"完成" forState:UIControlStateNormal];
        [_okButton sizeToFit];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_okButton setBackgroundColor:[UIColor clearColor]];
        [_okButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_okButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_gb_04_02_02_1"];
            [weakSelf confirmCreateOrUpdateGroup];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (UIImageView *)bannerImageView {
    if (!_bannerImageView) {
        UIImage *bgImage = [UIImage imageNamed:@"register_profile_banner"];
        _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, bannerHeight)];
        _bannerImageView.image = bgImage;
        _bannerImageView.userInteractionEnabled = YES;
        
        __weak typeof(self) weakSelf = self;
        [_bannerImageView bk_whenTapped:^{
            [MobClick event:@"gf_gb_04_01_01_1"];
            [weakSelf.view endEditing:YES];
            [weakSelf changeAvatar];
        }];
    }
    return _bannerImageView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, self.bannerImageView.height/2-34, 68, 68)];
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = _avatarImageView.width/2;
        [_avatarImageView setImageWithURL:[NSURL URLWithString:self.iniGroup.groupInfo.imgUrl] placeholder:[UIImage imageNamed:@"default_avatar_1"]];
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
        _tipLabel.textColor = [UIColor textColorValue6];
        _tipLabel.font = [UIFont systemFontOfSize:17];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"上传一张帮头像";
        [_tipLabel sizeToFit];
        _tipLabel.centerY = self.avatarImageView.centerY;
        _tipLabel.x = self.avatarImageView.right + 12;
    }
    return _tipLabel;
}


- (UITextField *)groupNameTextField {
    if (!_groupNameTextField) {
        _groupNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10+64+bannerHeight, SCREEN_WIDTH, 50)];
        _groupNameTextField.backgroundColor = [UIColor whiteColor];
        _groupNameTextField.placeholder = @"请输入帮名称";
        _groupNameTextField.font = [UIFont systemFontOfSize:17.0F];
//        _groupNameTextField.delegate = self;
        [_groupNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self makeIndentSpace:15 forTextField:_groupNameTextField];
        [self makeRightIndentSpace:40 forTextField:_groupNameTextField];
        [_groupNameTextField gf_AddTopBorderWithColor:[UIColor themeColorValue12] andWidth:0.5];
        [_groupNameTextField gf_AddBottomBorderWithColor:[UIColor themeColorValue12] andWidth:0.5];
    }
    return _groupNameTextField;
}

- (UITextView *)groupIntroTextView {
    if (!_groupIntroTextView) {
        _groupIntroTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.groupNameTextField.bottom + 10, SCREEN_WIDTH, 100)];
        _groupIntroTextView.backgroundColor = [UIColor whiteColor];
        _groupIntroTextView.font = [UIFont systemFontOfSize:17.0F];
        _groupIntroTextView.text = @"请输入帮简介";
        _groupIntroTextView.editable = YES;
        _groupIntroTextView.textContainerInset = UIEdgeInsetsMake(10, 12, 0, 0);
        _groupIntroTextView.textColor = [UIColor textColorValue5];
        _groupIntroTextView.delegate = self;
        [_groupIntroTextView gf_AddTopBorderWithColor:[UIColor themeColorValue12] andWidth:0.5];
        [_groupIntroTextView gf_AddBottomBorderWithColor:[UIColor themeColorValue12] andWidth:0.5];
    }
    return _groupIntroTextView;
}

- (UILabel *)characterCountLabel {
    if (!_characterCountLabel) {
        const CGFloat width = 40;
        _characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 20, 0, width, 40)];
        _characterCountLabel.centerY = self.groupNameTextField.centerY;
        _characterCountLabel.font = [UIFont systemFontOfSize:17.0f];
        _characterCountLabel.textColor = [UIColor textColorValue5];
        _characterCountLabel.textAlignment = NSTextAlignmentRight;
        _characterCountLabel.text = [NSString stringWithFormat:@"%@", @(GF_GROUPNAME_MAX_CHARACTERS_COUNT - [self.groupNameTextField.text length])];
    }
    return _characterCountLabel;
}

- (UILabel *)groupIntroCharacterCountLabel {
    if (!_groupIntroCharacterCountLabel) {
        const CGFloat width = 40;
        _groupIntroCharacterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 20, self.groupIntroTextView.bottom-40, width, 40)];
        _groupIntroCharacterCountLabel.font = [UIFont systemFontOfSize:17.0f];
        _groupIntroCharacterCountLabel.textColor = [UIColor textColorValue5];
        _groupIntroCharacterCountLabel.textAlignment = NSTextAlignmentRight;
        [_groupIntroCharacterCountLabel setBackgroundColor:[UIColor clearColor]];
        _groupIntroCharacterCountLabel.text = [NSString stringWithFormat:@"%@", @(GF_GROUPINTRO_MAX_CHARACTERS_COUNT)];
    }
    return _groupIntroCharacterCountLabel;
}

- (UITableView *)updateTableView {
    if (!_updateTableView) {
        _updateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.groupIntroTextView.bottom + 10, SCREEN_WIDTH, 100) style:UITableViewStylePlain];
        _updateTableView.scrollEnabled = NO;
        _updateTableView.delegate = self;
        _updateTableView.dataSource = self;
        [_updateTableView registerClass:[GFProfileUpdateTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFProfileUpdateTableViewCell class])];
        [_updateTableView gf_AddTopBorderWithColor:[UIColor themeColorValue12] andWidth:0.5];
        _updateTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _updateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _updateTableView.backgroundColor = [UIColor clearColor];
    }
    return _updateTableView;
}

#pragma mark - Init

- (instancetype)initWithGroup:(GFGroupMTL *)group {
    if (self = [super init]) {
        _iniGroup = group;
        [self.parameters setObject:group.groupInfo.groupId forKey:@"id"];
        [self.parameters setObject:group.groupInfo.name forKey:@"name"];
        [self.parameters setObject:group.groupInfo.imgUrl forKey:@"imgUrl"];
        [self.parameters setObject:group.groupInfo.groupDescription forKey:@"description"];
    }
    return self;
}

- (instancetype)initWithTag:(GFTagInfoMTL *)tag {
    if (self = [super init]) {
        _userSelectedTag = tag;
        [self.parameters setObject:tag.tagId forKey:@"tagId"];
    }
    return self;
}


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.iniGroup) {
        self.title = @"完善帮信息";
    } else {
        self.title = @"创建Get帮";
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.okButton];
    self.view.backgroundColor = [UIColor themeColorValue13];
    
    [self.view addSubview:self.bannerImageView];
    [self.bannerImageView addSubview:self.avatarImageView];
    [self.bannerImageView addSubview:self.avatarEditIcon];
    [self.bannerImageView addSubview:self.tipLabel];
    
    [self.view addSubview:self.groupNameTextField];
    [self.view addSubview:self.characterCountLabel];
    [self.view addSubview:self.groupIntroTextView];
    [self.view addSubview:self.groupIntroCharacterCountLabel];
    [self.view addSubview:self.updateTableView];
    
    if (self.iniGroup) {
        self.groupNameTextField.text = [self.parameters objectForKey:@"name"];
        self.groupIntroTextView.text = [self.parameters objectForKey:@"description"];
    } else {
        [self autoLocating];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapGesture:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
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

- (void)backBarButtonItemSelected {
    if (self.iniGroup) {
        [MobClick event:@"gf_gb_04_02_01_1"];
    } else {

    }
    [super backBarButtonItemSelected];
}

#pragma mark - Methods

- (void)autoLocating {
    __weak typeof(self) weakSelf = self;
    [GFLocationManager startUpdateLocationSuccess:^(CLLocation *location, AMapLocationReGeocode *regeocode) {
        [weakSelf.parameters setObject:regeocode.formattedAddress forKey:@"address"];
        [weakSelf.parameters setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
        [weakSelf.parameters setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [weakSelf.updateTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFProfileUpdateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFProfileUpdateTableViewCell class])];
    id model = nil;

    switch (indexPath.row) {
        case 0: {
            
            NSString *content = @"";
            if (self.iniGroup) {
                for (GFTagInfoMTL *tag in self.iniGroup.tagList) {
                    content = [content stringByAppendingString:[NSString stringWithFormat:@" %@", tag.tagName]];
                }
            } else if (self.userSelectedTag) {
                content = self.userSelectedTag.tagName;
            }
            
            model = @{
                      @"title" : @"帮兴趣",
                      @"content" : content ? content : @"",
                      @"placeHolder" : @"请选择帮兴趣",
                      @"accessory" : [NSNumber numberWithBool:YES]
                      };
            break;
        }
        case 1: {
            
            NSString *address = @"";
            if (self.iniGroup) {
                address = self.iniGroup.groupInfo.address;
            } else {
                address = [self.parameters objectForKey:@"address"];
            }
            model = @{
                      @"title" : @"本帮所在地",
                      @"content" : address && [address length] > 0 ? address : @"",
                      @"placeHolder" : @"请选择帮所在地",
                      @"accessory" : [NSNumber numberWithBool:YES]
                      };
            break;
        }
            
        default:
            break;
    }
    
    [cell bindWithModel:model];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 更新帮信息，不可以修改兴趣和地点
    if (self.iniGroup) {
        return;
    }
    
    
    [self.groupNameTextField resignFirstResponder];
    [self.groupIntroTextView resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0: { // 帮兴趣选择
            [MobClick event:@"gf_gb_04_01_02_1"];
#if 1 // modified by lhc, 2016-01-21
            GFCreateGroupSelectInterestViewController *controller = [[GFCreateGroupSelectInterestViewController alloc] init];
            controller.interestSelectHandler = ^(GFTagInfoMTL *tag) {
                weakSelf.userSelectedTag = tag;
                [weakSelf.parameters setObject:tag.tagId forKey:@"tagId"];
                [weakSelf.updateTableView reloadData];
            };
#else
            GFCreateGroupAllInterestViewController *controller = [[GFCreateGroupAllInterestViewController alloc] init];
            controller.interestSelectHandler = ^(GFTagInfoMTL *tag) {
                weakSelf.userSelectedTag = tag;
                [weakSelf.parameters setObject:tag.tagId forKey:@"tagId"];
                [weakSelf.updateTableView reloadData];
            };
#endif
            [self.navigationController pushViewController:controller animated:YES];
            

            break;
        }
        case 1: { // 地点选择
            
            [MobClick event:@"gf_gb_04_01_03_1"];
            GFMapPoiSelectViewController *mapPoiSelectViewController = [[GFMapPoiSelectViewController alloc] init];
            mapPoiSelectViewController.mapPoiSelectHandler = ^(AMapPOI *poi) {
                
                if ([poi isKindOfClass:[AMapPOI class]]) {
                    
                    NSString *address = [NSString stringWithFormat:@"%@%@%@",
                                         [poi.province isEqualToString:poi.city] ? @"" : poi.province,
                                         poi.city,
                                         poi.name];
                    [weakSelf.parameters setObject:address forKey:@"address"];
                    [weakSelf.parameters setObject:[NSNumber numberWithDouble:poi.location.longitude] forKey:@"longitude"];
                    [weakSelf.parameters setObject:[NSNumber numberWithDouble:poi.location.latitude] forKey:@"latitude"];
                    [weakSelf.updateTableView reloadData];
                } else {
                    [weakSelf.parameters removeObjectForKey:@"address"];
                    [weakSelf.parameters removeObjectForKey:@"longitude"];
                    [weakSelf.parameters removeObjectForKey:@"latitude"];
                    [weakSelf.updateTableView reloadData];
                }
            };
            [self.navigationController pushViewController:mapPoiSelectViewController animated:YES];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Methods
- (void)viewTapGesture:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

//设置缩进
- (void)makeIndentSpace:(CGFloat)space forTextField:(UITextField *)textField{
    UIView *indentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, textField.height)];
    indentView.backgroundColor = [UIColor clearColor];
    textField.leftView = indentView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)makeRightIndentSpace:(CGFloat)space forTextField:(UITextField *)textField{
    UIView *indentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space, textField.height)];
    indentView.backgroundColor = [UIColor clearColor];
    textField.rightView = indentView;
    textField.rightViewMode = UITextFieldViewModeAlways;
}

- (BOOL)validateInput {
    if (!self.parameters[@"name"] || [self.parameters[@"name"] isEqualToString:@""]) {
        [MBProgressHUD showHUDWithTitle:@"帮名称不能为空" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    if (!self.parameters[@"description"] || [self.parameters[@"description"] isEqualToString:@""]) {
        [MBProgressHUD showHUDWithTitle:@"帮简介不能为空" duration:kCommonHudDuration inView:self.view];
        return NO;
    } else if([self.parameters[@"description"] isEqualToString:@"请输入帮简介"] && !self.groupIntroAlreadyBeginEditing) {
        [MBProgressHUD showHUDWithTitle:@"帮简介不能为空" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    
    if (!self.iniGroup && self.groupAvatarImage == nil) {
        [MBProgressHUD showHUDWithTitle:@"请选择头像" duration:kCommonHudDuration inView:self.view];
        return NO;
    }
    
    if (!self.iniGroup) {
        if (!self.parameters[@"address"] || [self.parameters[@"address"] isEqualToString:@""]) {
            [MBProgressHUD showHUDWithTitle:@"请选择本帮所在地" duration:kCommonHudDuration inView:self.view];
            return NO;
        }
        if (!self.parameters[@"tagId"]) {
            [MBProgressHUD showHUDWithTitle:@"请选择帮兴趣" duration:kCommonHudDuration inView:self.view];
            return NO;
        }
    }
    
    return YES;
}


- (void)createGroup {
    __weak typeof(self) weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showLoadingHUDWithTitle:@"正在创建Get帮..." inView:self.view];
    // 创建新的帮
    [GFNetworkManager createGroupWithParameters:self.parameters
                                        success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {

                                            if (code == 1) {
                                                [hud hide:YES];
                                                [UIAlertView bk_showAlertViewWithTitle:@"创建get帮成功，请耐心等待后台审核，审核通过后会出现在“我加入的Get帮" message:@"" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                    if (weakSelf.completionHandler) {
                                                        weakSelf.completionHandler(weakSelf.parameters);
                                                    }
                                                    
                                                    NSArray<UIViewController *> *viewControllers = weakSelf.navigationController.viewControllers;
                                                    for (UIViewController *viewController in viewControllers) {
                                                        if ([viewController isKindOfClass:[GFMyGroupViewController class]]) {
                                                            [weakSelf.navigationController popToViewController:viewController animated:YES];
                                                            break;
                                                        }
                                                    }
                                                }];
                                                
                                            } else {
                                                hud.labelText = apiErrorMessage;
                                                [hud hide:YES afterDelay:kCommonHudDuration];
                                            }
                                            //
                                        } failure:^(NSUInteger taskId, NSError *error) {
                                            hud.labelText = @"创建Get帮失败";
                                            [hud hide:YES afterDelay:kCommonHudDuration];
                                        }];
}

- (void)updateGroup {
    // 更新帮信息
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager updateGroupWithParameters:self.parameters
                                        success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                            if (code == 1) {
                                                [MBProgressHUD showHUDWithTitle:@"修改帮信息成功" duration:kCommonHudDuration inView:self.view];
                                                if (weakSelf.completionHandler) {
                                                    weakSelf.completionHandler(weakSelf.parameters);
                                                }
                                                [weakSelf.navigationController popViewControllerAnimated:YES];
                                            } else {
                                                [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                            }
                                        } failure:^(NSUInteger taskId, NSError *error) {
                                            [MBProgressHUD showHUDWithTitle:@"修改帮信息失败" duration:kCommonHudDuration inView:self.view];
                                        }];
    
}

- (void)confirmCreateOrUpdateGroup {
    
    NSString *groupName = self.groupNameTextField.text;
    if (groupName) {
        [self.parameters setObject:groupName forKey:@"name"];
    }
    NSString *groupIntro = self.groupIntroTextView.text;
    if (groupIntro) {
        [self.parameters setObject:groupIntro forKey:@"description"];
    }
    
    if (![self validateInput]) {
        return;
    }
    
    if (self.iniGroup) {  //更新帮信息
        //检查是否需要上传头像
        if(self.groupAvatarImage){
            
            MBProgressHUD *hud = [MBProgressHUD showHUDWithTitle:@"正在提交资料" inView:self.view];
            //上传七牛
            __weak typeof(self) weakSelf = self;
            [GFNetworkManager queryQiNiuTokenSuccess:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token) {
                if (code == 1) {
                    
                    NSError *error = nil;
                    QNFileRecorder *file = [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:@"QNGetGun"] error:&error];
                    QNUploadManager *uploadManager = [[QNUploadManager alloc] initWithRecorder:file];
                    [uploadManager putData:UIImageJPEGRepresentation([weakSelf.groupAvatarImage gf_autoResizeImageWithNet], 1)
                                       key:nil
                                     token:token
                                  complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                      if (resp) {
                                        [hud hide:YES];
                                          NSDictionary *picture = [resp objectForKey:@"picture"];
                                          NSString *storeKey = [picture objectForKey:@"storeKey"];
                                          if (storeKey) {
                                              [weakSelf.parameters setObject:storeKey forKey:@"imgUrl"];
                                          }
                                          [weakSelf updateGroup];
                                      } else {
                                          hud.labelText = @"提交资料失败";
                                          [hud hide:YES afterDelay:kCommonHudDuration];
                                      }

                                  } option:nil];
                } else {
                    hud.labelText = @"提交资料失败";
                    [hud hide:YES afterDelay:kCommonHudDuration];
                }
            } failure:^(NSUInteger taskId, NSError *error) {
                hud.labelText = @"提交资料失败";
                [hud hide:YES afterDelay:kCommonHudDuration];
            }];

        } else {
            [self updateGroup];
        }
        
    } else { //创建帮，此时一定有头像，在validateInput内部验证
        
        MBProgressHUD *hud = [MBProgressHUD showHUDWithTitle:@"正在提交资料" inView: self.view];
        //上传七牛
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager queryQiNiuTokenSuccess:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token) {
            if (code == 1) {
                
                NSError *error = nil;
                QNFileRecorder *file = [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:@"QNGetGun"] error:&error];
                QNUploadManager *uploadManager = [[QNUploadManager alloc] initWithRecorder:file];
                [uploadManager putData:UIImageJPEGRepresentation([weakSelf.groupAvatarImage gf_autoResizeImageWithNet], 1)
                                   key:nil
                                 token:token
                              complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                  if (resp) {
                                      [hud hide:YES];
                                      NSDictionary *picture = [resp objectForKey:@"picture"];
                                      NSString *storeKey = [picture objectForKey:@"storeKey"];
                                      if (storeKey) {
                                          [weakSelf.parameters setObject:storeKey forKey:@"imgUrl"];
                                      }
                                      [weakSelf createGroup];
                                  } else {
                                      hud.labelText = @"提交资料失败";
                                      [hud hide:YES afterDelay:kCommonHudDuration];
                                  }
                              } option:nil];
            } else {
                hud.labelText = @"提交资料失败";
                [hud hide:YES afterDelay:kCommonHudDuration];
            }
        } failure:^(NSUInteger taskId, NSError *error) {
            hud.labelText = @"提交资料失败";
            [hud hide:YES afterDelay:kCommonHudDuration];
        }];
    }
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
                GFAssetsPickerViewController *assetsPickerViewController = [[GFAssetsPickerViewController alloc] init];
                assetsPickerViewController.maxSelectNumber = 1;
                assetsPickerViewController.isCropAllowed = YES;
                assetsPickerViewController.gf_didFinishPickingImageBlock = ^(GFAssetsPickerViewController *picker, UIImage *image, UIImage *thumbnail){
                    [self handleSelectAvatar:image];
                };
                assetsPickerViewController.gf_didFinishPickingAssetsBlock = ^(GFAssetsPickerViewController *picker, NSArray *assets, NSArray *thumbnails) {
                    [self handleSelectAvatar:[thumbnails firstObject]];
                };
                assetsPickerViewController.gf_didCancelPickingAssetsBlock = ^(GFAssetsPickerViewController *picker) {
                    
                };
                
                [self presentViewController:assetsPickerViewController animated:YES completion:NULL];
            }
        }];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:^{
        
    }];
    
    [actionSheet showInView:self.view];
}

- (void)handleSelectAvatar:(UIImage *)avatar {
    
    UIImage *selectedImage = [avatar imageByResizeToSize:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH) contentMode:UIViewContentModeCenter];
    self.avatarImageView.image = selectedImage;
    self.groupAvatarImage = selectedImage;
    
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
        self.view.bottom = SCREEN_HEIGHT - kbSize.height + 240.0f;
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

- (void)textFieldDidChange:(UITextField *)textField
{
    UITextRange *selectedRange = [textField markedTextRange];
    NSString * newText = [textField textInRange:selectedRange];
    //获取高亮部分
    if(newText.length > 0) {
        return;
    } else {
        NSString *text = textField.text;
        NSInteger length = text.length;
        if (text.length <= GF_GROUPNAME_MAX_CHARACTERS_COUNT) {
            self.characterCountLabel.text = length > GF_GROUPNAME_MAX_CHARACTERS_COUNT ? @"0" : [NSString stringWithFormat:@"%@", @(GF_GROUPNAME_MAX_CHARACTERS_COUNT - length)];
        } else {
            self.characterCountLabel.text = @"0";
            textField.text = [text substringToIndex:GF_GROUPNAME_MAX_CHARACTERS_COUNT];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    const NSUInteger maxWordCount = 10;
    NSString *text = textField.text;
    if ([text length] > maxWordCount) {
        text = [text substringWithRange:NSMakeRange(0, maxWordCount)];
        textField.text = text;
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {

    [MobClick event:@"gf_fb_02_01_01_1"];
    if (!self.groupIntroAlreadyBeginEditing) {
        self.groupIntroTextView.text = nil;
        self.groupIntroTextView.textColor = [UIColor textColorValue1];
        self.groupIntroAlreadyBeginEditing = YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange];
    //获取高亮部分
    if(newText.length > 0) {
        return;
    } else {
        NSString *text = textView.text;
        
        NSInteger length = text.length;
        if (length <= GF_GROUPINTRO_MAX_CHARACTERS_COUNT) {
            self.groupIntroCharacterCountLabel.text = length > GF_GROUPINTRO_MAX_CHARACTERS_COUNT ? @"0" : [NSString stringWithFormat:@"%@", @(GF_GROUPINTRO_MAX_CHARACTERS_COUNT - length)];
        } else {
            self.groupIntroCharacterCountLabel.text = @"0";
            text = [text substringWithRange:NSMakeRange(0, GF_GROUPINTRO_MAX_CHARACTERS_COUNT)];
            textView.text = text;
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.updateTableView]) {
        return NO;
    }
    return YES;
}

@end
