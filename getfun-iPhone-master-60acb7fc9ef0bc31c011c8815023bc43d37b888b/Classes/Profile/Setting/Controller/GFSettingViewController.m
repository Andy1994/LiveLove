//
//  GFSettingViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFSettingViewController.h"
#import "GFSettingTableViewCell.h"
#import "GFUserDefaultsUtil.h"
#import "GFChangePasswordViewController.h"
#import "GFAboutViewController.h"
#import "GFFeedbackViewController.h"
#import "GFNetworkManager+User.h"
#import "GFAccountManager.h"
#import "GFCacheUtil.h"

#import "GFLessonViewController.h"
#import "GFProfileViewController.h"
#import "GFContentDetailViewController.h"
#import "GFTagDetailViewController.h"

#import "GFNotifySettingViewController.h"

typedef NS_ENUM(NSInteger, GFSettingOption) {
    GFSettingOptionChangePassword   = 0,
    GFSettingOptionAutoLocatingWhenPublish = 1,
    GFSettingOptionNotifySetting    = 2,
    GFSettingOptionCleanCache       = 3,
    GFSettingOptionAboutMe          = 4,
    GFSettingOptionFeedback         = 5,
    GFSettingOptionReview           = 6
};
NSString * const GFUserDefaultsKeyForbiddenAutoLocatingWhenPublish = @"GFUserDefaultsKeyForbiddenAutoLocatingWhenPublish";


@interface GFSettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *settingTableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIButton *exitButton;

@end

@implementation GFSettingViewController
- (UITableView *)settingTableView {
    if (!_settingTableView) {
        _settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _settingTableView.dataSource = self;
        _settingTableView.delegate = self;
        _settingTableView.backgroundColor = [UIColor clearColor];
        [_settingTableView registerClass:[GFSettingTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFSettingTableViewCell class])];
        _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _settingTableView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"gf_settings" ofType:@"plist"];
        NSArray *settingOptions = [[NSArray alloc] initWithContentsOfFile:plistPath];
        if ([GFAccountManager sharedManager].loginType == GFLoginTypeMobile) {
            _dataSource = [settingOptions objectAtIndex:0];
        } else {
            _dataSource = [settingOptions objectAtIndex:1];
        }
    }
    return _dataSource;
}

- (UIButton *)exitButton {
    if (!_exitButton) {
        _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitButton.frame = CGRectMake(0, 10, self.view.width, 44.0f);
        _exitButton.backgroundColor = [UIColor whiteColor];
        [_exitButton setTitle:@"退出账号" forState:UIControlStateNormal];
        [_exitButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        
        [_exitButton gf_AddTopBorderWithColor:[UIColor themeColorValue12] andWidth:0.5f];
        [_exitButton gf_AddBottomBorderWithColor:[UIColor themeColorValue12] andWidth:0.5f];
        
        __weak typeof(self) weakSelf = self;
        [_exitButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_sz_01_02_03_1"];
            [UIAlertView bk_showAlertViewWithTitle:@"是否确定退出登录？"
                                           message:@""
                                 cancelButtonTitle:@"取消"
                                 otherButtonTitles:@[@"确定"]
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               if (buttonIndex == 0) {
                                                   [MobClick event:@"gf_sz_01_02_05_1"];
                                               } else {
                                                   [MobClick event:@"gf_sz_01_02_04_1"];
                                                   
                                                   [[GFAccountManager sharedManager] updateLoginType:GFLoginTypeNone
                                                                                   authorizeResponse:nil
                                                                                        refreshToken:nil
                                                                                         accessToken:nil
                                                                                            userInfo:nil];
                                                   
                                                   [weakSelf.exitButton removeFromSuperview];
                                                   [weakSelf backBarButtonItemSelected];

                                                   [GFAccountManager exitSuccess:^{
                                                       [GFAccountManager anonymousLoginSuccess:NULL failure:NULL];
                                                   } failure:^{
                                                       [GFAccountManager anonymousLoginSuccess:NULL failure:NULL];
                                                   }];
                                               }
                                           }];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitButton;
}

- (void)backBarButtonItemSelected {
    if ([GFAccountManager sharedManager].loginType != GFLoginTypeNone && [GFAccountManager sharedManager].loginType != GFLoginTypeAnonymous) {
        [super backBarButtonItemSelected];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self hideFooterImageView:YES];
    
    [self.view addSubview:self.settingTableView];
    if ([GFAccountManager sharedManager].loginType != GFLoginTypeNone && [GFAccountManager sharedManager].loginType != GFLoginTypeAnonymous) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0f + 10.0f)];

        [view addSubview:self.exitButton];
        
        self.settingTableView.tableFooterView = view;
    }
    
    __weak typeof(self) weakSelf = self;
    UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"相关ID"];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
        [alertView bk_addButtonWithTitle:@"个人页" handler:^{
            [[alertView textFieldAtIndex:0] resignFirstResponder];

            NSInteger identifier = [[alertView textFieldAtIndex:0].text integerValue];
            GFProfileViewController *controller = [[GFProfileViewController alloc] initWithUserID:[NSNumber numberWithInteger:identifier]];
            [self.navigationController pushViewController:controller animated:YES];
        }];
        
        [alertView bk_addButtonWithTitle:@"详情页" handler:^{
            [[alertView textFieldAtIndex:0] resignFirstResponder];
            NSInteger identifier = [[alertView textFieldAtIndex:0].text integerValue];
            
            [GFNetworkManager getContentWithContentId:[NSNumber numberWithInteger:identifier]
                                              keyFrom:GFKeyFromUnkown
                                              success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                                  if (code == 1 && content) {
                                                      
                                                      UIViewController *viewControllerToDisplay = nil;
                                                      if ([content isGetfunLesson]) {
                                                          viewControllerToDisplay = [[GFLessonViewController alloc] initWithContent:content];
                                                      } else {
                                                          viewControllerToDisplay = [[GFContentDetailViewController alloc] initWithContent:content preview:NO];
                                                      }
                                                      
                                                      [weakSelf.navigationController pushViewController:viewControllerToDisplay animated:YES];
                                                  }
                                              } failure:^(NSUInteger taskId, NSError *error) {
                                                  //
                                              }];
        }];
        
        [alertView bk_addButtonWithTitle:@"标签页" handler:^{
            [[alertView textFieldAtIndex:0] resignFirstResponder];
            
            NSInteger identifier = [[alertView textFieldAtIndex:0].text integerValue];
            GFTagDetailViewController *controller = [[GFTagDetailViewController alloc] initWithTagId:[NSNumber numberWithInteger:identifier]];
            [self.navigationController pushViewController:controller animated:YES];
        }];
        
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:^{
            //
        }];
        
        [alertView show];
    }];
    tapGesture.numberOfTapsRequired = 4;
    [self.view addGestureRecognizer:tapGesture];
                                       
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionData = [self.dataSource objectAtIndex:section];
    return [sectionData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 10)];
    [view gf_AddBottomBorderWithColor:[UIColor themeColorValue12] andWidth:0.5f];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *sectionData = [self.dataSource objectAtIndex:indexPath.section];
    NSDictionary *model = [sectionData objectAtIndex:indexPath.row];
    
    GFSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFSettingTableViewCell class])];
    cell.titleLabel.text = [model objectForKey:@"title"];
    NSInteger accessoryStyle = [[model objectForKey:@"accessoryStyle"] integerValue];
    cell.accessoryImageView.hidden = (accessoryStyle != 0);
    cell.switchButton.hidden = (accessoryStyle != 1);

    GFSettingOption option = [[model objectForKey:@"option"] integerValue];
    if (option == GFSettingOptionAutoLocatingWhenPublish) {
        
        cell.switchButton.on = ![GFUserDefaultsUtil boolForKey:GFUserDefaultsKeyForbiddenAutoLocatingWhenPublish];
        
        [cell.switchButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_sz_01_01_02_1"];
            [GFUserDefaultsUtil setBool:!cell.switchButton.isOn forKey:GFUserDefaultsKeyForbiddenAutoLocatingWhenPublish];
        } forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *sectionData = [self.dataSource objectAtIndex:indexPath.section];
    NSDictionary *settingDict = [sectionData objectAtIndex:indexPath.row];
    GFSettingOption option = [[settingDict objectForKey:@"option"] integerValue];
    switch (option) {
        case GFSettingOptionChangePassword: {
            [MobClick event:@"gf_sz_01_01_01_1"];
            GFChangePasswordViewController *resetPwdViewController = [[GFChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:resetPwdViewController animated:YES];
            
            break;
        }
        case GFSettingOptionAutoLocatingWhenPublish: {
            [MobClick event:@"gf_sz_01_01_02_1"];
            break;
        }
        case GFSettingOptionNotifySetting: {
            GFNotifySettingViewController *notifyViewController = [[GFNotifySettingViewController alloc] init];
            [self.navigationController pushViewController:notifyViewController animated:YES];
            break;
        }
        case GFSettingOptionCleanCache: {
            double size = [GFCacheUtil cacheSizeInPath:kPathLibraryCacheDirectory];
            NSString *sizeString = @"";
            if (size < 1) {
                sizeString = [NSString stringWithFormat:@"%.2fKB", size*1000];
            } else {
                sizeString = [NSString stringWithFormat:@"%.2fMB", size];
            }
            
            MBProgressHUD *hud = [MBProgressHUD showHUDWithTitle:@"正在清理内存" inView:self.view];
            [GFCacheUtil cleanCacheInPath:kPathLibraryCacheDirectory];
            hud.labelText = [NSString stringWithFormat:@"已清理%@内存空间", sizeString];
            [hud hide:YES afterDelay:kCommonHudDuration];

            break;
        }
        case GFSettingOptionAboutMe: {
            [MobClick event:@"gf_sz_01_02_01_1"];
            GFAboutViewController *aboutViewController = [[GFAboutViewController alloc] init];
            [self.navigationController pushViewController:aboutViewController animated:YES];
            break;
        }
        case GFSettingOptionFeedback: {
            [MobClick event:@"gf_sz_01_02_02_1"];
            GFFeedbackViewController *feedbackViewController = [[GFFeedbackViewController alloc] init];
            [self.navigationController pushViewController:feedbackViewController animated:YES];
            break;
        }
        case GFSettingOptionReview: {
            NSString *reviewURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kGetfunAppID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
            break;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointMake(0, 0);
}

@end
