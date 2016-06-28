//
//  GFHomeContainerViewController.m
//  GetFun
//
//  Created by zhouxz on 16/1/27.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFHomeContainerViewController.h"
#import "GFAvatarView.h"
#import "GFAccountManager.h"
#import "GFLoginRegisterViewController.h"
#import "GFProfileViewController.h"
#import "GFBaseViewController.h"
#import "GFHomeViewController.h"
#import "GFTagViewController.h"
#import "GFMsgCenterViewController.h"
#import "GFMessageCenter.h"
#import "GFNetworkManager+Message.h"
#import "AppDelegate.h"
#import "GFPhotoUtil.h"
#import "GFReviewManager.h"

@interface GFHomeContainerViewController ()

@property (nonatomic, strong) HMSegmentedControl *segmentControl;
@property (nonatomic, strong) UILabel *msgCountLabel;
@property (nonatomic, strong) UIButton *msgCenterBarButton;

@property (nonatomic, strong) GFHomeViewController *homeViewController;
@property (nonatomic, strong) GFTagViewController *tagViewController;

@end

@implementation GFHomeContainerViewController
- (HMSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        
        NSArray *sectionImages = @[
                                   [UIImage imageNamed:@"nav_home_normal"],
                                   [UIImage imageNamed:@"nav_tag_normal"]
                                   ];
        NSArray *sectionSelectedImages = @[
                                           [UIImage imageNamed:@"nav_home_selected"],
                                           [UIImage imageNamed:@"nav_tag_selected"]
                                           ];
        
        _segmentControl = [[HMSegmentedControl alloc] initWithSectionImages:sectionImages sectionSelectedImages:sectionSelectedImages];
        _segmentControl.frame = CGRectMake(0, 0, 144, 29);
        _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
        _segmentControl.type = HMSegmentedControlTypeImages;
        _segmentControl.segmentEdgeInset = UIEdgeInsetsZero;
    }
    return _segmentControl;
}

- (UILabel *)msgCountLabel {
    if (!_msgCountLabel) {
        _msgCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18.0f, 18.0f)];
        _msgCountLabel.font = [UIFont systemFontOfSize:10.0f];
        _msgCountLabel.textColor = [UIColor whiteColor];
        _msgCountLabel.textAlignment = NSTextAlignmentCenter;
        _msgCountLabel.backgroundColor = [UIColor gf_colorWithHex:@"FF6421"];
        _msgCountLabel.hidden = YES;
        _msgCountLabel.layer.masksToBounds = YES;
        _msgCountLabel.layer.cornerRadius = _msgCountLabel.width/2;
    }
    return _msgCountLabel;
}

- (UIButton *)msgCenterBarButton {
    if (!_msgCenterBarButton) {
        _msgCenterBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_msgCenterBarButton setImage:[UIImage imageNamed:@"nav_message"] forState:UIControlStateNormal];
        [_msgCenterBarButton sizeToFit];
    }
    return _msgCenterBarButton;
}

- (GFHomeViewController *)homeViewController {
    if (!_homeViewController) {
        _homeViewController = [[GFHomeViewController alloc] init];
    }
    return _homeViewController;
}

- (GFTagViewController *)tagViewController {
    if (!_tagViewController) {
        _tagViewController = [[GFTagViewController alloc] init];
    }
    return _tagViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    self.navigationItem.titleView = self.segmentControl;
    [self.segmentControl addTarget:self action:@selector(segmentControlIndexChanged) forControlEvents:UIControlEventValueChanged];
    
    __weak typeof(self.segmentControl) weakSegment = self.segmentControl;
    [self.segmentControl setSegmentedControlTouchBlock:^(){
        if (weakSegment.selectedSegmentIndex == 0) {
            [weakSelf.homeViewController scrollToTop];
        } else if (weakSegment.selectedSegmentIndex == 1) {
            [weakSelf.tagViewController scrollToTop];
        }
    }];
    
    [self addChildViewController:self.homeViewController];
    [self addChildViewController:self.tagViewController];
    
    [self.view addSubview:self.homeViewController.view];
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleNone;
    self.gf_StatusBarStyle = UIStatusBarStyleDefault;
    
    [self.msgCenterBarButton bk_addEventHandler:^(id sender) {
        [weakSelf messageBarButtonItemSelected];
    } forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.msgCenterBarButton];
    self.msgCountLabel.center = CGPointMake(self.msgCenterBarButton.width, 0);
    [self.msgCenterBarButton addSubview:self.msgCountLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMsgCountLabel) name:GFNotificationDidReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMsgCountLabel) name:GFNotificationDidMessageDeleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMsgCountLabel) name:GFNotificationDidMessageStatusChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMsgCountLabel) name:GFNotificationLoginUserChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //判断是否登录获取头像
    GFUserMTL *loginUser = [GFAccountManager sharedManager].loginUser;
    GFLoginType loginType = [GFAccountManager sharedManager].loginType;
    //不能仅凭loginUser是否为nil判断是否登录，初始值载入时并不一定为nil
    if (loginUser && loginType!=GFLoginTypeAnonymous && loginType != GFLoginTypeNone) {
        GFAvatarView *avatar = [[GFAvatarView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        avatar.isShowedInFeedList = NO;
        [avatar updateWithUser:loginUser];
        [avatar bk_whenTapped:^{
            [self profileBarButtonItemSelected];
        }];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:avatar];
        
    } else {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_profile"] target:self selector:@selector(profileBarButtonItemSelected)];
    }
    
    [self updateUnreadMsgCountLabel];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [GFPhotoUtil requestAuthorization];
    });

    @synchronized(self) {
        if (self.launchOptionUserInfo) {
            DDLogVerbose(@"%s%s,launchOptionUserInfo:%@", __FILE__, __PRETTY_FUNCTION__, self.launchOptionUserInfo);
            [[AppDelegate appDelegate] handleApnsInfo:self.launchOptionUserInfo];
            self.launchOptionUserInfo = nil;
        }
    }        
}

- (void)profileBarButtonItemSelected {
    [MobClick event:@"gf_sy_03_01_01_1"];
    
    GFLoginType loginType = [GFAccountManager sharedManager].loginType;
    if (loginType == GFLoginTypeNone || loginType == GFLoginTypeAnonymous) {
        GFLoginRegisterViewController *loginViewController = [[GFLoginRegisterViewController alloc] init];
        [self presentViewController:[[GFNavigationController alloc] initWithRootViewController:loginViewController]
                           animated:YES
                         completion:NULL];
    } else {
        GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:[GFAccountManager sharedManager].loginUser.userId];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void)messageBarButtonItemSelected {
    [MobClick event:@"gf_sy_03_02_01_1"];

    GFMsgCenterViewController *msgCenterViewController = [[GFMsgCenterViewController alloc] init];
    [self.navigationController pushViewController:msgCenterViewController animated:YES];
}

- (void)segmentControlIndexChanged {
 
    @synchronized (self) {
        UIViewController *fromViewController = nil;
        UIViewController *toViewController = nil;
        
        if (self.segmentControl.selectedSegmentIndex == 0) {
            [MobClick event:@"gf_sy_03_04_01_1"];
            
            fromViewController = self.tagViewController;
            toViewController = self.homeViewController;
        } else {
            [MobClick event:@"gf_sy_03_03_01_1"];
            fromViewController = self.homeViewController;
            toViewController = self.tagViewController;
        }
        
        [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.05f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            //
        } completion:^(BOOL finished) {
            //
        }];
    }
}

- (void)updateUnreadMsgCountLabel {
    
    GFLoginType type = [GFAccountManager sharedManager].loginType;
    if (type == GFLoginTypeAnonymous || type == GFLoginTypeNone) {
        GFUnreadCountMTL *unreadCount = [[GFUnreadCountMTL alloc] init]; // zero
        [self updateUnreadMsgCountLabelWithUnreadCount:unreadCount];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getUnreadMessageCountSuccess:^(NSUInteger taskId, NSInteger code, GFUnreadCountMTL *unreadCount) {
        if (code == 1) {
            [weakSelf updateUnreadMsgCountLabelWithUnreadCount:unreadCount];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        //
    }];
}

- (void)updateUnreadMsgCountLabelWithUnreadCount:(GFUnreadCountMTL *)unreadCount {
    
    NSUInteger unreadActivityCount = [GFMessageCenter unreadActivityMessageCount];
    BOOL shouldShowRedDot = unreadCount.fun + unreadCount.audit + unreadActivityCount > 0;
    NSInteger numberToShow = unreadCount.participate + unreadCount.comment;
    
    if (numberToShow > 0) {
        // 显示text
        NSString *text = [NSString stringWithFormat:@"%ld", (long)numberToShow];
        if (numberToShow > 99) {
            text = @"99+";
        }
        self.msgCountLabel.text = text;
        self.msgCountLabel.frame = CGRectMake(0, 0, 18, 18);
        self.msgCountLabel.hidden = NO;
    } else if (shouldShowRedDot) {
        // 显示红点
        self.msgCountLabel.text = @"";
        self.msgCountLabel.frame = CGRectMake(0, 0, 5, 5);
        self.msgCountLabel.hidden = NO;
    } else {
        self.msgCountLabel.text = @"";
        self.msgCountLabel.hidden = YES;
    }
    
    self.msgCountLabel.layer.cornerRadius = self.msgCountLabel.width/2;
    self.msgCountLabel.center = CGPointMake(self.msgCenterBarButton.width, 0);
}

@end
