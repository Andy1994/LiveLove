//
//  GFMsgCenterViewController.m
//  GetFun
//
//  Created by zhouxz on 16/1/27.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMsgCenterViewController.h"
#import "GFMsgCenterHeader.h"
#import "GFMsgTableViewCell.h"
#import "GFMessageCenter.h"
#import "GFMessageMTL.h"
#import "GFMsgListViewController.h"
#import "AppDelegate.h"
#import "GFAccountManager.h"
#import "GFNetworkManager+Message.h"

@interface GFMsgCenterViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

@property (nonatomic, strong) GFMsgCenterHeader *msgCenterTableHeader;
@property (nonatomic, strong) UITableView *msgCenterTableView;
@property (nonatomic, strong) UIButton *ignoreButton;

@end

@implementation GFMsgCenterViewController
- (GFMsgCenterHeader *)msgCenterTableHeader {
    if (!_msgCenterTableHeader) {
        _msgCenterTableHeader = [[GFMsgCenterHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 284)];
    }
    return _msgCenterTableHeader;
}

- (UITableView *)msgCenterTableView {
    if (!_msgCenterTableView) {
        _msgCenterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _msgCenterTableView.backgroundColor = [UIColor clearColor];
        _msgCenterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _msgCenterTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_msgCenterTableView registerClass:[GFMsgTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFMsgTableViewCell class])];
    }
    return _msgCenterTableView;
}

- (UIButton *)ignoreButton {
    if (!_ignoreButton) {
        _ignoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ignoreButton setTitle:@"忽略未读" forState:UIControlStateNormal];
        [_ignoreButton setTitleColor:[UIColor themeColorValue10] forState:UIControlStateNormal];
        [_ignoreButton setTitleColor:[UIColor textColorValue4] forState:UIControlStateDisabled];
        _ignoreButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_ignoreButton sizeToFit];
    }
    return _ignoreButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的消息";
    [self.view addSubview:self.msgCenterTableView];
    self.msgCenterTableView.delegate = self;
    self.msgCenterTableView.dataSource = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.ignoreButton];    
    __weak typeof(self) weakSelf = self;
    self.msgCenterTableHeader.msgCenterHeaderHandler = ^(GFBasicMessageType type) {
        switch (type) {
            case GFBasicMessageTypeAudit: {
                [MobClick event:@"gf_xx_01_02_04_1"];
                break;
            }
            case GFBasicMessageTypeComment: {
                [MobClick event:@"gf_xx_01_01_03_1"];
                break;
            }
            case GFBasicMessageTypeFun: {
                [MobClick event:@"gf_xx_01_01_01_1"];
                break;
            }
            case GFBasicMessageTypeParticipate: {
                [MobClick event:@"gf_xx_01_01_02_1"];
                break;
            }
            case GFBasicMessageTypeFollow:{
                break;
            }
            case GFBasicMessageTypeNotify:{
                break;
            }
            case GFBasicMessageTypeActivity:{
                break;
            }
            case GFBasicMessageTypeUnknown:{
                break;
            }
        }
        
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user) {
                GFMsgListViewController *msgListViewController = [[GFMsgListViewController alloc] initWithBasicMessageType:type];
                [weakSelf.navigationController pushViewController:msgListViewController animated:YES];
            }
        }];
    };
    self.msgCenterTableView.tableHeaderView = self.msgCenterTableHeader;
    
    [self.ignoreButton addTarget:self action:@selector(markAllRead) forControlEvents:UIControlEventTouchUpInside];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:GFNotificationDidReceiveMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didMessageStatusChanged:) name:GFNotificationDidMessageStatusChanged object:nil];
    
    [self queryUnreadMsgCount];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self queryUnreadMsgCount];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GFNotificationDidReceiveMessage object:nil];
}

- (void)didReceiveMessage:(NSNotification *)notification {
    GFMessageMTL *message = [notification.userInfo objectForKey:kMessageNotificationUserInfoKeyMsg];
    GFBasicMessageType type = message.messageDetail.messageType & 0xF0;
    
    if (type == GFBasicMessageTypeActivity) {
        [self.msgCenterTableView reloadData];
    } else {
        [self queryUnreadMsgCount];
    }
}

- (void)didMessageStatusChanged:(NSNotification *)notification {
    [self queryUnreadMsgCount];
}

- (void)queryUnreadMsgCount {
    @weakify(self)
    [GFNetworkManager getUnreadMessageCountSuccess:^(NSUInteger taskId, NSInteger code, GFUnreadCountMTL *unreadCount) {
        @strongify(self)
        if (code == 1) {
            [self.msgCenterTableHeader updateUnreadBadge:unreadCount];
            self.msgCenterTableView.tableHeaderView = self.msgCenterTableHeader;
            
            NSUInteger unreadActivityCount = [GFMessageCenter unreadActivityMessageCount];
            self.ignoreButton.enabled = (unreadCount.participate + unreadCount.comment + unreadCount.fun + unreadCount.audit + unreadActivityCount > 0);
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        //
    }];
}

- (void)markAllRead {
    [MobClick event:@"gf_xx_01_03_01_1"];
    @weakify(self)
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"忽略所有未读消息？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        @strongify(self)
        if (buttonIndex == 1) {
            [GFMessageCenter markAllMessageRead];
            self.ignoreButton.enabled = NO;
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[GFMessageCenter activityMessages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFMsgTableViewCell class])];
    cell.enableDelete = YES;
    cell.delegate = self;
    GFMessageMTL *message = [[GFMessageCenter activityMessages] objectAtIndex:indexPath.row];
    [cell bindWithModel:message];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [[GFMessageCenter activityMessages] objectAtIndex:indexPath.row];
    return [GFMsgTableViewCell heightWithModel:model];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        NSString * event = [NSString stringWithFormat:@"gf_xx_01_02_0%@_1", @(indexPath.row + 1)];
        [MobClick event:event];
    }
    
    GFMessageMTL *message = [[GFMessageCenter activityMessages] objectAtIndex:indexPath.row];
    if (message.messageDetail.unread == YES) {
        message.messageDetail.unread = NO;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [GFMessageCenter markReadMessage:message];
    }
    
    NSString *linkUrl = message.messageDetail.linkUrl;
    if (linkUrl) {
        [[AppDelegate appDelegate] handleGetfunLinkUrl:linkUrl];
    }
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [self.msgCenterTableView indexPathForCell:cell];
    GFMessageMTL *message = [[GFMessageCenter activityMessages] objectAtIndex:indexPath.row];
    [GFMessageCenter deleteActivityMessage:message];
    [self.msgCenterTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
