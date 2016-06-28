//
//  GFGroupInfoViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/5.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupInfoViewController.h"
#import "GFGroupMTL.h"
#import "GFNetworkManager+Group.h"
#import "GFAccountManager.h"
#import "GFGroupQRCodeViewController.h"
#import "GFGroupMemberViewController.h"
#import "GFLoginRegisterViewController.h"

#import "GFProfileViewController.h"
#import "GFTagDetailViewController.h"

#import "GFGroupUpdateViewController.h"
#import "GFGroupDetailViewController.h"

@interface GFGroupInfoMemberView : UIView
@property (nonatomic, strong) UIImageView *accessoryImageView;
@property (nonatomic, strong) UIView *memberAvatarView;
@property (nonatomic, strong) UILabel *memberCountLabel;

/**
 *  设置Get帮成员视图数据
 *
 *  @param memberList Get帮成员详细数据，最多包含5个用户
 *  @param count      Get帮成员全部数目
 */
- (void)setMemberList:(NSArray<GFUserMTL *> *) memberList memberCount:(NSUInteger)totalCount;
@end

@implementation GFGroupInfoMemberView
- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_light"]];
        [_accessoryImageView sizeToFit];
        _accessoryImageView.center = CGPointMake(self.width-10, self.height/2);
        _accessoryImageView.userInteractionEnabled = YES;
        _accessoryImageView.hidden = YES; //暂时修改为不显示
    }
    return _accessoryImageView;
}
- (UIView *)memberAvatarView {
    if (!_memberAvatarView) {
        _memberAvatarView = [[UIView alloc] initWithFrame:CGRectMake(0, 32, self.width, 25)];
    }
    return _memberAvatarView;
}
- (UILabel *)memberCountLabel {
    if (!_memberCountLabel) {
        _memberCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - 25 - 14, self.width, 14)];
        _memberCountLabel.textAlignment = NSTextAlignmentCenter;
        _memberCountLabel.textColor = [[UIColor textColorValue6] colorWithAlphaComponent:0.5];
        _memberCountLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _memberCountLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self gf_AddTopBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
        [self addSubview:self.accessoryImageView];
        [self addSubview:self.memberAvatarView];
        [self addSubview:self.memberCountLabel];
    }
    return self;
}

- (void)setMemberList:(NSArray<GFUserMTL *> *)memberList memberCount:(NSUInteger)totalCount{
    
    [[self.memberAvatarView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //确定显示头像的数目，以计算位置整体居中
    NSUInteger avatarCount = MIN(5, memberList.count);
    CGFloat totalWidth = 25 * avatarCount + 6 * (avatarCount - 1);
    CGFloat leftOffset = (self.memberAvatarView.width - totalWidth) / 2;
    NSUInteger index = 0;
    for (GFUserMTL *user in memberList) {
        
        if (index >= avatarCount) {
            break;
        }
        
        UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(leftOffset + index * (25 + 6), 0, 25, 25)];
        avatarView.layer.cornerRadius = 25.0f/2;
        avatarView.clipsToBounds = YES;
        [avatarView setImageWithURL:[NSURL URLWithString:[user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES]] placeholder:[UIImage imageNamed:@"default_avatar_1"]];
        [self.memberAvatarView addSubview:avatarView];
        index++;
    }
    self.memberCountLabel.text = [NSString stringWithFormat:@"等%@人加入", @(totalCount)];
    [self setNeedsLayout];
}

@end

@interface GFGroupInfoQRView : UIView
@property (nonatomic, strong) UIImageView *qrIcon;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@end

@implementation GFGroupInfoQRView
- (UIImageView *)qrIcon {
    if (!_qrIcon) {
        _qrIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_qrcode"]];
        [_qrIcon sizeToFit];
    }
    return _qrIcon;
}
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = [UIColor textColorValue6];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.font = [UIFont systemFontOfSize:14.0f];
        _textLabel.text = @"帮二维码";
        [_textLabel sizeToFit];
    }
    return _textLabel;
}
- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_light"]];
        [_accessoryImageView sizeToFit];
        _accessoryImageView.center = CGPointMake(self.width-10, self.height/2);
        _accessoryImageView.userInteractionEnabled = YES;
        _accessoryImageView.hidden = YES; //暂时修改为不显示
    }
    return _accessoryImageView;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self gf_AddTopBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
        [self addSubview:self.qrIcon];
        [self addSubview:self.textLabel];
        [self addSubview:self.accessoryImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    const CGFloat space = 5.0f;
    self.qrIcon.center = CGPointMake((self.width-20)/2-self.textLabel.width/2-space/2,
                                     self.height/2);
    self.textLabel.center = CGPointMake((self.width-20)/2+self.qrIcon.width/2+space/2,
                                        self.height/2);
}

@end

@interface GFGroupInfoCategoryView : UIView
@property (nonatomic, strong) UILabel *textLabel;
- (void)setCategory:(NSString *)category;
@end

@implementation GFGroupInfoCategoryView
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _textLabel.font  =[UIFont systemFontOfSize:14.0f];
        _textLabel.textColor = [UIColor textColorValue6];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.text = @"";
    }
    return _textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self gf_AddTopBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)setCategory:(NSString *)category {
    self.textLabel.text = [NSString stringWithFormat:@"兴趣类型:%@", category];
    [self.textLabel sizeToFit];
    self.textLabel.center = CGPointMake(self.width/2, self.height/2);
}

@end

@interface GFGroupInfoViewController ()

@property (nonatomic, strong) GFGroupMTL *group;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *groupAvatarImageView;
@property (nonatomic, strong) UILabel *groupDescriptionLabel;
@property (nonatomic, strong) GFGroupInfoMemberView *memberAvatarListView;
@property (nonatomic, strong) GFGroupInfoQRView *QRCodeView;
@property (nonatomic, strong) GFGroupInfoCategoryView *categoryView;
@property (nonatomic, strong) UIButton *locationView;
@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, strong) UIButton *joinButton4S;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GFGroupInfoViewController
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.view.width - 80, 40)];
        _titleLabel.centerX = self.view.width/2;
        _titleLabel.font = [UIFont systemFontOfSize:19.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor textColorValue6];
    }
    return _titleLabel;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
    }
    return _backgroundImageView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    }
    return _maskView;
}

- (UIImageView *)groupAvatarImageView {
    if (!_groupAvatarImageView) {
        _groupAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width/2-35, 64 + 8, 68.0f, 68.0f)];
        _groupAvatarImageView.layer.masksToBounds = YES;
        _groupAvatarImageView.layer.cornerRadius = 34.0f;
    }
    return _groupAvatarImageView;
}

- (UILabel *)groupDescriptionLabel {
    if (!_groupDescriptionLabel) {
        _groupDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(42,
                                                                           self.groupAvatarImageView.bottom+10,
                                                                           self.view.width-84,
                                                                           80.0f)];
        _groupDescriptionLabel.numberOfLines = 3;
        _groupDescriptionLabel.font  =[UIFont systemFontOfSize:14.0f];
        _groupDescriptionLabel.textColor = [UIColor textColorValue6];
        _groupDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        _groupDescriptionLabel.text = @"";
        
    }
    return _groupDescriptionLabel;
}

- (GFGroupInfoCategoryView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[GFGroupInfoCategoryView alloc] initWithFrame:CGRectMake(42, self.groupDescriptionLabel.bottom + 10, self.view.width - 84, 50)];
    }
    return _categoryView;
}

- (GFGroupInfoQRView *)QRCodeView {
    if (!_QRCodeView) {
        _QRCodeView = [[GFGroupInfoQRView alloc] initWithFrame:CGRectMake(42, self.categoryView.bottom, self.view.width - 42 * 2, 50)];
        __weak typeof(self) weakSelf = self;
        [_QRCodeView bk_whenTapped:^{
            //判断是否审核通过确定是否可以进入二维码
            if (weakSelf.group.groupInfo.auditStatus != GFGroupAuditStatusPass) {
                [UIAlertView bk_showAlertViewWithTitle:@"Get帮暂未审核通过，无法查看二维码" message:@"" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
                return;
            }
            
            GFGroupQRCodeViewController *controller = [[GFGroupQRCodeViewController alloc] initWithGroup:weakSelf.group avatarImage:weakSelf.groupAvatarImageView.image];
            [weakSelf.navigationController pushViewController:controller animated:YES];
        }];
    }
    return _QRCodeView;
}

- (GFGroupInfoMemberView *)memberAvatarListView {
    if (!_memberAvatarListView) {
        _memberAvatarListView = [[GFGroupInfoMemberView alloc] initWithFrame:CGRectMake(42, self.QRCodeView.bottom, self.view.width - 42 * 2, 106)];
        __weak typeof(self) weakSelf = self;
        [_memberAvatarListView bk_whenTapped:^{
            GFGroupMemberViewController *controller = [[GFGroupMemberViewController alloc] initWithGroup:weakSelf.group];
            [weakSelf.navigationController pushViewController:controller animated:YES];
        }];
    }
    return _memberAvatarListView;
}

- (UIButton *)locationView {
    if (!_locationView) {
        _locationView = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationView.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_locationView setImage:[UIImage imageNamed:@"icon_location2"] forState:UIControlStateNormal];
//        [_locationView setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
//        [_locationView setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -14)];
        [_locationView setTitleColor:[UIColor textColorValue6] forState:UIControlStateNormal];
        _locationView.frame = CGRectMake(42, self.memberAvatarListView.bottom, self.view.width - 84, 32);
        _locationView.layer.borderColor = [UIColor textColorValue6].CGColor;
        _locationView.layer.borderWidth = 0.5f;
        _locationView.layer.cornerRadius = 16.0f; // height/2
        _locationView.enabled = NO;
    }
    return _locationView;
}
- (UIButton *)joinButton4S
{
    if (!_joinButton4S) {
        _joinButton4S= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 27)];
//        _joinButton4S.centerX = self.view.width / 2;
        _joinButton4S.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_joinButton4S setTitleColor:[UIColor textColorValue6] forState:UIControlStateNormal];
        _joinButton4S.backgroundColor = [UIColor themeColorValue9];
        _joinButton4S.layer.cornerRadius = 3;
        _joinButton4S.clipsToBounds = YES;
        //50 * 20
        [_joinButton4S setTitle:@"加入" forState:UIControlStateNormal];
        
        //加入get帮
        __weak typeof(self) weakSelf = self;
        [_joinButton4S bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_gb_05_01_01_1"];
            
            [GFAccountManager checkLoginStatus:YES
                               loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                                   
                                   // 刚刚登录成功的
                                   if (justLogin) {
                                       [GFNetworkManager getGroupWithGroupId:self.group.groupInfo.groupId
                                                                     success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                                                         if (code == 1) {
                                                                             if (group.joined) {
                                                                                 [weakSelf updateUI];
                                                                             } else {
                                                                                 // 入帮申请
                                                                                 [weakSelf joinGroup:group];
                                                                             }
                                                                         }
                                                                     } failure:^(NSUInteger taskId, NSError *error) {
                                                                         [MBProgressHUD showHUDWithTitle:@"获取帮信息失败" duration:kCommonHudDuration inView:self.view];
                                                                     }];
                                   } else if (user) { // 原本就是已经登录的
                                       // 入帮申请
                                       [weakSelf joinGroup:self.group];
                                   } else {
                                       [MBProgressHUD showHUDWithTitle:@"登录后才能加入Get帮" duration:kCommonHudDuration inView:self.view];
                                   }
                               }];
            
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinButton4S;

}
- (UIButton *)joinButton {
    if (!_joinButton) {
        _joinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.locationView.bottom + 20, 160, 42)];
        _joinButton.centerX = self.view.width / 2;
        _joinButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_joinButton setTitleColor:[UIColor textColorValue6] forState:UIControlStateNormal];
        _joinButton.backgroundColor = [UIColor themeColorValue9];
        _joinButton.layer.cornerRadius = 3;
        _joinButton.clipsToBounds = YES;
        //50 * 20
        [_joinButton setTitle:@"立即加入" forState:UIControlStateNormal];
        
        //加入get帮
        __weak typeof(self) weakSelf = self;
        [_joinButton bk_addEventHandler:^(id sender) {
            [MobClick event:@"gf_gb_05_01_01_1"];
            
            [GFAccountManager checkLoginStatus:YES
                               loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                                   
                                   // 刚刚登录成功的
                                   if (justLogin) {
                                       [GFNetworkManager getGroupWithGroupId:self.group.groupInfo.groupId
                                                                     success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                                                         if (code == 1) {
                                                                             if (group.joined) {
                                                                                 [weakSelf updateUI];
                                                                             } else {
                                                                                 // 入帮申请
                                                                                 [weakSelf joinGroup:group];
                                                                             }
                                                                         }
                                                                     } failure:^(NSUInteger taskId, NSError *error) {
                                                                         [MBProgressHUD showHUDWithTitle:@"获取帮信息失败" duration:kCommonHudDuration inView:self.view];
                                                                     }];
                                   } else if (user) { // 原本就是已经登录的
                                       // 入帮申请
                                       [weakSelf joinGroup:self.group];
                                   } else {
                                       [MBProgressHUD showHUDWithTitle:@"登录后才能加入Get帮" duration:kCommonHudDuration inView:self.view];
                                   }
                               }];
            
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinButton;
}


- (instancetype)initWithGroup:(GFGroupMTL *)group {
    if (self = [super init]) {
        self.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackLight;
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    self.navigationItem.titleView = self.titleLabel;
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.maskView];
    //由于存在位置依赖关系，必须依次添加子视图
    [self.view addSubview:self.groupAvatarImageView];
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.groupDescriptionLabel];
    [self.view addSubview:self.QRCodeView];
    [self.view addSubview:self.memberAvatarListView];
    [self.view addSubview:self.locationView];
    if ([UIScreen mainScreen].bounds.size.height > 480.f) {
        [self.view addSubview:self.joinButton];
    }
    [self gf_setNavBarBackgroundTransparent:0.0f];
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self queryGroupInfo];
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_gb_05_02_01_1"];
    [super backBarButtonItemSelected];
}

#pragma mark - Methods
- (void)updateUI {
    self.titleLabel.text = self.group.groupInfo.name;

    __weak typeof(self) weakSelf = self;
    [self.groupAvatarImageView setImageWithURL:[NSURL URLWithString:[self.group.groupInfo.imgUrl
                                                                     gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarGroup gifConverted:YES]]
                                   placeholder:nil
                                       options:kNilOptions
                                    completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                        UIImage *gfImage = [image cropToSize:CGSizeMake(image.size.width/5, image.size.height/5) usingMode:NYXCropModeCenter];
                                        weakSelf.backgroundImageView.image = [gfImage gaussianBlurWithBias:150.0f];
                                    }];
    self.groupDescriptionLabel.text = self.group.groupInfo.groupDescription;
    [self.memberAvatarListView setMemberList:self.group.memberList memberCount:[self.group.groupInfo.memberCount unsignedIntegerValue]];
    NSString *interest = self.group.tagList.count > 0 ? self.group.tagList[0].tagName : @"";
    [self.categoryView setCategory:interest];
    
    [self.locationView setTitle:self.group.groupInfo.address forState:UIControlStateNormal];
    CGSize locationSize = [self.locationView sizeThatFits:CGSizeMake(self.view.width - 84, 32)];
    self.locationView.size = CGSizeMake(MIN(locationSize.width + 16 * 4, self.view.width - 84), MAX(32, locationSize.height));
    self.locationView.centerX = self.view.width/2;
    if ([UIScreen mainScreen].bounds.size.height > 480.f) {
        self.joinButton.hidden = self.group.joined;
    }else{
        self.joinButton4S.hidden = self.group.joined;
    }
    if (self.group.created) {
        // 帮主，增加编辑帮信息功能
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 80, 40);
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button bk_addEventHandler:^(id sender) {

            [MobClick event:@"gf_gb_05_02_02_1"];
            
            GFGroupUpdateViewController *groupUpdateViewController = [[GFGroupUpdateViewController alloc] initWithGroup:self.group];
            //回调，更新头像等信息
            groupUpdateViewController.completionHandler = ^(NSMutableDictionary *parameters){
                [self queryGroupInfo];
                [self updateUI];
            };
            [self.navigationController pushViewController:groupUpdateViewController animated:YES];

        } forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    } else { //根据是否加入Get帮确定是否显示退帮按钮
        if (self.group.joined)  {
            // 非帮主，并且加入了该get帮，可以退帮
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"group_quit"] forState:UIControlStateNormal];
            [button sizeToFit];
            
            __weak typeof(self) weakSelf = self;
            [button bk_addEventHandler:^(id sender) {
                [MobClick event:@"gf_gb_05_02_03_1"];

                // 退帮操作
                [UIAlertView bk_showAlertViewWithTitle:@""
                                               message:@"确认退出该兴趣帮？"
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@[@"确认"]
                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                   if (buttonIndex == 1) {
                                                       [weakSelf doQuitGroup];
                                                   }
                                               }];
                
            } forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            
        } else {
            if ([UIScreen mainScreen].bounds.size.height > 480.f) {
                self.navigationItem.rightBarButtonItem = nil;
            }else{
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.joinButton4S];
            }
        }
        
        }
}

- (void)doQuitGroup {
    
    // 用户退出Get帮的前提是已经加入Get帮，则当前页面必定是从groupdetailviewcontroller中push过来的，则navigationviewcontroller的
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager quitGroupWithGroupId:self.group.groupInfo.groupId
                                   success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                       if (code == 1) {
                                           
                                           if (weakSelf.quitGroupHandler) {
                                               weakSelf.quitGroupHandler(weakSelf.group);
                                           }
                                           
                                           NSArray *viewControllers = [weakSelf.navigationController viewControllers];
                                           if ([viewControllers count] > 2) {
                                               UIViewController *destViewController = [viewControllers objectAtIndex:([viewControllers count] - 3)];
                                               [weakSelf.navigationController popToViewController:destViewController animated:YES];
                                           } else {
                                               [weakSelf.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
                                           }
                                           
                                           
                                       }
                                   } failure:^(NSUInteger taskId, NSError *error) {
                                       //
                                   }];
}

- (void)joinGroup:(GFGroupMTL *)group {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager joinGroupWithGroupId:group.groupInfo.groupId success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
        if (code == 1) {
            
            weakSelf.group.joined = YES;
            [weakSelf updateUI];
            
            if (weakSelf.joinGroupHandler) {
                weakSelf.joinGroupHandler(group);
            }
            
            //加入成功后跳转到帮详情页
            GFGroupDetailViewController *controller = [[GFGroupDetailViewController alloc] initWithGroup:group];
            controller.updateSignInHandler = ^(){
                if(weakSelf.updateSignInHandler){
                    weakSelf.updateSignInHandler(group);
                }
            };
            [self.navigationController pushViewController:controller animated:YES];
            
        } else {
            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [MBProgressHUD showHUDWithTitle:@"加入Get帮失败" duration:kCommonHudDuration inView:self.view];
    }];
}

- (void)queryGroupInfo {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getGroupWithGroupId:self.group.groupInfo.groupId
                                  success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                      if (code == 1) {
                                          weakSelf.group = group;
                                          [weakSelf updateUI];
                                      }
                                  } failure:^(NSUInteger taskId, NSError *error) {

                                  }];
}

@end
