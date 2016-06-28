//
//  GFProfileUpdateViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//
#define GF_NICKNAME_MAX_CHARACTERS_COUNT 15

#import "GFProfileUpdateViewController.h"
#import "GFProfileUpdateTableViewCell.h"
#import "GFNetworkManager+User.h"
#import "GFAccountManager.h"
#import "GFChangeNickNameViewController.h"
#import <ActionSheetPicker.h>
#import "GFCollegeSelectViewController.h"
#import "GFProvinceAndCityPicker.h"
#import "GFDatePicker.h"
#import <QiniuSDK.h>
#import "GFNetworkManager+Publish.h"

#import "GFAssetsPickerViewController.h"
#import "GFTakingPhotoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+GetFun.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "GFPhotoUtil.h"

@interface GFProfileUpdateViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic, strong) GFUserMTL *updateUserMTL;
@property (nonatomic, strong) UITableView *profileTableView;

@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *avatarEditIcon;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIImage *userAvatarImage; // 用户选择的头像.单独存储用于七牛上传

@property (nonatomic, strong) NSArray<NSDictionary *> *allColleges; //所有学校，用于显示
@end

@implementation GFProfileUpdateViewController
- (UIImageView *)bannerImageView {
    if (!_bannerImageView) {
        UIImage *bgImage = [UIImage imageNamed:@"register_profile_banner"];
        _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 100.0f)];
        _bannerImageView.image = bgImage;
        _bannerImageView.userInteractionEnabled = YES;
        
        __weak typeof(self) weakSelf = self;
        [_bannerImageView bk_whenTapped:^{
            [MobClick event:@"gf_gr_02_01_01_1"];
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

        [_avatarImageView setImageWithURL:[NSURL URLWithString:[self.updateUserMTL.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarProfile gifConverted:YES]] placeholder:[UIImage imageNamed:@"default_avatar_1"]];
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
        _tipLabel.text = @"修改头像";
        [_tipLabel sizeToFit];
        _tipLabel.centerY = self.avatarImageView.centerY;
        _tipLabel.x = self.avatarImageView.right + 12;
    }
    return _tipLabel;
}

- (GFUserMTL *)updateUserMTL {
    if (!_updateUserMTL) {
        _updateUserMTL = [GFAccountManager sharedManager].loginUser;
    }
    return _updateUserMTL;
}
- (UITableView *)profileTableView {
    if (!_profileTableView) {
        _profileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.bannerImageView.bottom, self.view.width, self.view.height) style:UITableViewStylePlain];
        _profileTableView.backgroundColor = [UIColor clearColor];
        _profileTableView.delegate = self;
        _profileTableView.dataSource = self;
        _profileTableView.scrollEnabled = NO;
        [_profileTableView registerClass:[GFProfileUpdateTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFProfileUpdateTableViewCell class])];
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
        view.backgroundColor = [UIColor clearColor];
        _profileTableView.tableFooterView = view;
        _profileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _profileTableView;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载所有学校
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"allColleges" ofType:@"plist"];
    self.allColleges = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    self.title = @"个人信息";
    [self.view addSubview:self.bannerImageView];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.bannerImageView addSubview:self.avatarImageView];
    [self.bannerImageView addSubview:self.avatarEditIcon];
    [self.bannerImageView addSubview:self.tipLabel];
    [self.view addSubview:self.profileTableView];

}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 4 : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GFProfileUpdateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFProfileUpdateTableViewCell class])];
    id model = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                BOOL canChangeNickName = YES;
                model = @{
                          @"title" : @"昵称",
                          @"content" : self.updateUserMTL.nickName? ((self.updateUserMTL.nickName.length > GF_NICKNAME_MAX_CHARACTERS_COUNT)? [self.updateUserMTL.nickName substringToIndex:GF_NICKNAME_MAX_CHARACTERS_COUNT] : self.updateUserMTL.nickName) : @"",
                          @"placeHolder" : @"设置昵称",
                          @"accessory" : [NSNumber numberWithBool:canChangeNickName]
                          };
                break;
            }
                
            case 1: {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd";
                NSString *dateString = @"";
                if ([self.updateUserMTL.birthday longLongValue]) {
                   dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.updateUserMTL.birthday doubleValue]/1000]];
                }
                
                
                model = @{
                          @"title" : @"出生日期",
                          @"content" : dateString,
                          @"placeHolder" : @"输入出生日期",
                          @"accessory" : [NSNumber numberWithBool:YES]
                          };
                break;
            }
                
            case 2:
            {
                //性别未设置时允许修改
                BOOL canChangeGender = (self.updateUserMTL.gender==GFUserGenderUnknown);
                NSString *genderContent = nil;
                switch (self.updateUserMTL.gender) {
                    case GFUserGenderUnknown: {
                        genderContent = @"未设置";
                        break;
                    }
                    case GFUserGenderMale: {
                        genderContent = @"男";
                        break;
                    }
                    case GFUserGenderFemale: {
                        genderContent = @"女";
                        break;
                    }
                }
                model = @{
                          @"title" : @"性别",
                          @"content" : genderContent,
                          @"placeHolder" : @"选择性别",
                          @"accessory" : [NSNumber numberWithBool:canChangeGender]
                          };
                break;
            }
                
            case 3:
                //注意：显示省市时需要根据user的provinceId和cityId来进行查找
                model = @{
                          @"title" : @"所在地",
                          @"content" : self.updateUserMTL.provinceId && self.updateUserMTL.cityId ? [GFProvinceAndCityPicker gf_getProvinceAndCityByProvinceId:self.updateUserMTL.provinceId cityId:self.updateUserMTL.cityId]:@"",
                          @"placeHolder" : @"选择所在地",
                          @"accessory" : [NSNumber numberWithBool:YES]
                          };
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                //注意：显示学校时需要根据user的collegeId来进行查找
                NSString *collegeString = @"请选择";
                if (self.updateUserMTL.collegeId) {
                    collegeString = [[self.allColleges bk_match:^BOOL(id obj) {
                        return self.updateUserMTL.collegeId && [[obj objectForKey:@"id"] isEqualToNumber:self.updateUserMTL.collegeId];
                    }] objectForKey:@"name"];
                }
                model = @{
                          @"title" : @"学校",
                          @"content" : collegeString? collegeString : @"请选择",
                          @"placeHolder" : @"请选择",
                          @"accessory" : [NSNumber numberWithBool:YES]
                          };
                break;
            }
            case 1: {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd";
                NSString *dateString = @"";
                if (self.updateUserMTL.enrollTime) {
                    if ([self.updateUserMTL.enrollTime longLongValue] != 0) {
                        dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.updateUserMTL.enrollTime doubleValue]/1000]];
                    } else {
                        dateString = @"请选择";
                    }
                } else {
                    dateString = @"请选择";
                }
                
                model = @{
                          @"title" : @"入学时间",
                          @"content" : dateString,
                          @"placeHolder" : @"请选择",
                          @"accessory" : [NSNumber numberWithBool:YES]
                          };
                break;
            }
                
            default:
                break;
        }
    }
    [cell bindWithModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                
//                BOOL canChangeNickName = !self.updateUserMTL.nickName || [self.updateUserMTL.nickName length] == 0;
                BOOL canChangeNickName = YES;
                if (canChangeNickName) {
                    [MobClick event:@"gf_gr_02_01_02_1"];
                    GFChangeNickNameViewController *changeNickNameViewController = [[GFChangeNickNameViewController alloc] init];
                    changeNickNameViewController.nickNameChangeHandler = ^(NSString *nickName, Completion completion) {
                        // 提交修改昵称
                        [GFNetworkManager updateNickname:nickName
                                                 success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                     if (code == 1) {

                                                         [MBProgressHUD showHUDWithTitle:@"修改成功" duration:kCommonHudDuration inView:self.view];
                                                         weakSelf.updateUserMTL.nickName = nickName;
                                                         [weakSelf.profileTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                     } else {
                                                         [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                                     }
                                                     completion();
                                                 } failure:^(NSUInteger taskId, NSError *error) {
                                                                                                         [MBProgressHUD showHUDWithTitle:@"昵称修改失败" duration:kCommonHudDuration inView:self.view];
                                                 }];
                    };
                    [self.navigationController pushViewController:changeNickNameViewController animated:YES];
                }
                break;
            }
            case 1: { // 生日选择
                [MobClick event:@"gf_gr_02_01_03_1"];
                [self showDatePickerWithSender:[self.profileTableView cellForRowAtIndexPath:indexPath]];
            }
                break;
            case 2: { // 性别选择
                
                BOOL canChangeGender = (self.updateUserMTL.gender == GFUserGenderUnknown);
//                BOOL canChangeGender = NO;
                if (canChangeGender) {
                    [self showGenderPickerWithSender:[self.profileTableView cellForRowAtIndexPath:indexPath]];
                }

                
                break;
            }
            case 3: {
                [MobClick event:@"gf_gr_02_01_04_1"];
                __weak typeof(self) weakSelf = self;
                [GFProvinceAndCityPicker gf_showProvinceAndCityPickerInitialProvinceId:self.updateUserMTL.provinceId
                                                                         initialCityId:self.updateUserMTL.cityId
                                                                            completion:^(NSNumber *provinceId, NSString *provinceName, NSNumber *cityId, NSString *cityName) {
                                                                                
                                                                                [GFNetworkManager updateProvince:provinceId
                                                                                                            city:cityId
                                                                                                         success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                                                                             if (code == 1) {
                                                                                                                 // 上传所在地
                                                                                                                 weakSelf.updateUserMTL.provinceId = provinceId;
                                                                                                                 weakSelf.updateUserMTL.provinceName = provinceName;
                                                                                                                 weakSelf.updateUserMTL.cityId = cityId;
                                                                                                                 weakSelf.updateUserMTL.cityName = cityName;
                                                                                                                 [weakSelf.profileTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                                                                                                  withRowAnimation:UITableViewRowAnimationNone];
                                                                                                             } else {
                                                                                                                 [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:weakSelf.view];
                                                                                                             }
                                                                                                         } failure:^(NSUInteger taskId, NSError *error) {
                                                                                                             [MBProgressHUD showHUDWithTitle:@"修改失败" duration:kCommonHudDuration inView:weakSelf.view];
                                                                                                         }];
                 } cancel:^{
                     //
                 }];
            }
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0: { // 学校选择
                [MobClick event:@"gf_gr_02_02_01_1"];
                GFCollegeSelectViewController *collegeSelectViewController = [[GFCollegeSelectViewController alloc] init];
                collegeSelectViewController.provinceId = self.updateUserMTL.provinceId;
                collegeSelectViewController.collegeSelectHandler = ^(GFCollegeMTL *college) {
                    
                    [GFNetworkManager updateCollege:college.collegeId
                                         department:nil
                                         enrollTime:nil
                                            success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                if (code == 1) {
                                                    weakSelf.updateUserMTL.collegeId = college.collegeId;
                                                    weakSelf.updateUserMTL.collegeName = college.name;
                                                    [weakSelf.profileTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                                     withRowAnimation:UITableViewRowAnimationNone];
                                                } else {
                                                    [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:weakSelf.view];
                                                }
                                            } failure:^(NSUInteger taskId, NSError *error) {
                                                [MBProgressHUD showHUDWithTitle:@"修改失败" duration:kCommonHudDuration inView:weakSelf.view];
                                            }];
                };
                [self.navigationController pushViewController:collegeSelectViewController animated:YES];
                
                break;
            }
            case 1: { // 入学时间选择
                [MobClick event:@"gf_gr_02_02_02_1"];
                [self showDatePickerWithSender:[self.profileTableView cellForRowAtIndexPath:indexPath]];
                break;
            }
                
            default:
                break;
        }
    }
}


#pragma mark - Methods

- (void)showDatePickerWithSender:(id)sender {
    NSIndexPath *indexPath = [self.profileTableView indexPathForCell:sender];
    
    NSDate *initialDate = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    if (indexPath.section == 0 && indexPath.row == 1) { //出生日期
        if ([self.updateUserMTL.birthday longLongValue] != 0) {
            initialDate = [[NSDate alloc] initWithTimeIntervalSince1970:[self.updateUserMTL.birthday longLongValue]/1000];
        } else {
            initialDate = [formatter dateFromString:@"1995-01-01"];
        }
    } else { //入学时间
        if ([self.updateUserMTL.enrollTime longLongValue] != 0) {
            initialDate = [[NSDate alloc] initWithTimeIntervalSince1970:[self.updateUserMTL.enrollTime longLongValue]/1000];
        } else {
            initialDate = [formatter dateFromString:@"2012-09-01"];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [GFDatePicker gf_showDatePickerInitialDate:initialDate
                                    completion:^(NSDate *selectedDate) {
                                        
                                        if (indexPath.section == 0 && indexPath.row == 1) {
                                            
                                            // 上传出生日期
                                            [GFNetworkManager updateBirthday:selectedDate
                                                                     success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                                         if (code == 1) {
                                                                             weakSelf.updateUserMTL.birthday = [NSNumber numberWithDouble:[selectedDate timeIntervalSince1970] * 1000];
                                                                             [weakSelf.profileTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                                                              withRowAnimation:UITableViewRowAnimationNone];
                                                                         } else {
                                                                             [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:weakSelf.view];
                                                                         }
                                                                     } failure:^(NSUInteger taskId, NSError *error) {
                                                                         [MBProgressHUD showHUDWithTitle:@"修改失败" duration:kCommonHudDuration inView:weakSelf.view];
                                                                     }];
                                        } else if (indexPath.section == 1 && indexPath.row == 1) { // 入学时间
                                            
                                            [GFNetworkManager updateCollege:nil
                                                                 department:nil
                                                                 enrollTime:selectedDate
                                                                    success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                                        if (code == 1) {
                                                                            weakSelf.updateUserMTL.enrollTime = [NSNumber numberWithDouble:[selectedDate timeIntervalSince1970] * 1000];
                                                                            [weakSelf.profileTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                                                             withRowAnimation:UITableViewRowAnimationNone];
                                                                        } else {
                                                                            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:weakSelf.view];
                                                                        }
                                                                    } failure:^(NSUInteger taskId, NSError *error) {
                                                                        [MBProgressHUD showHUDWithTitle:@"修改失败" duration:kCommonHudDuration inView:weakSelf.view];
                                                                    }];
                                        }
                                    } cancel:^{
                                        //
                                    }];
}

- (void)showGenderPickerWithSender:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [ActionSheetStringPicker showPickerWithTitle:@""
                                            rows:@[@"男", @"女"]
                                initialSelection:(weakSelf.updateUserMTL.gender == GFUserGenderMale ? 0 : 1)
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           NSIndexPath *indexPath = [weakSelf.profileTableView indexPathForCell:sender];
                                           
                                           if (indexPath.section == 0 && indexPath.row == 2) {
                                               [GFNetworkManager updateGender:(selectedIndex == 0 ? GFUserGenderMale : GFUserGenderFemale)
                                                                      success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                                                          if (code == 1) {
                                                                              weakSelf.updateUserMTL.gender = (selectedIndex == 0 ? GFUserGenderMale : GFUserGenderFemale);
                                                                              
                                                                              [weakSelf.profileTableView reloadRowsAtIndexPaths:@[indexPath]
                                                                                                               withRowAnimation:UITableViewRowAnimationNone];
                                                                          } else {
                                                                              [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:weakSelf.view];
                                                                          }
                                                                      } failure:^(NSUInteger taskId, NSError *error) {
                                                                          [MBProgressHUD showHUDWithTitle:@"修改失败" duration:kCommonHudDuration inView:weakSelf.view];
                                                                      }];
                                           }
                                       } cancelBlock:^(ActionSheetStringPicker *picker) {
                                           //
                                       } origin:self.view];
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
    
    UIImage *image = [avatar gf_imageByScalingAndCroppingForSize:CGSizeMake(100, 100)];
    
    self.avatarImageView.image = image;
    self.userAvatarImage = image;

//    MBProgressHUD *hud = [MBProgressHUD showHUDWithTitle:@"正在提交资料"];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"正在提交资料";
    hud.removeFromSuperViewOnHide = YES;

    //上传七牛
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
                                  weakSelf.updateUserMTL.avatar = storeKey;
                                  
                                  [GFNetworkManager updateAvatar:storeKey success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *avatarURL) {
                                      
                                      [GFAccountManager sharedManager].loginUser.avatar = avatarURL;
                                      [hud hide:YES afterDelay:0.5f];
                                  } failure:^(NSUInteger taskId, NSError *error) {
                                      hud.labelText = @"提交资料失败";
                                      [hud hide:YES afterDelay:kCommonHudDuration];
                                  }];
                                  
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

@end







