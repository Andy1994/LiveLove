//
//  GFNotifySettingViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/4.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFNotifySettingViewController.h"
#import "GFNetworkManager+User.h"
#import "GFMetaInfoMTL.h"
#import "GFSettingTableViewCell.h"

NSString * const GFUserDefaultsKeyMetaInfo = @"GFUserDefaultsKeyMetaInfo";

typedef NS_ENUM(NSInteger, GFNotifySettingOption) {
    GFNotifySettingOptionAllowContentMessage = 0,
    GFNotifySettingOptionAllowCommentMessage = 1,
    GFNotifySettingOptionAllowFunMessage = 2,
    GFNotifySettingOptionAllowParticipateMessage = 3,
    GFNotifySettingOptionAllowNotifyMessage = 4
};

@interface GFNotifySettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) GFMetaInfoMTL *metaInfo;
@property (nonatomic, strong) NSArray *notifySettings;
@property (nonatomic, strong) UITableView *notifyTableView;

@end

@implementation GFNotifySettingViewController
- (NSArray *)notifySettings {
    if (!_notifySettings) {
        _notifySettings = @[
                            @[
                                @{
                                    @"title" : @"精彩内容推送",
                                    @"accessoryStyle" : @(1),
                                    @"option" : @(GFNotifySettingOptionAllowContentMessage)
                                    }
                                ],
                            @[
                                @{
                                    @"title" : @"回复评论提醒",
                                    @"accessoryStyle" : @(1),
                                    @"option" : @(GFNotifySettingOptionAllowCommentMessage)
                                    },
                                @{
                                    @"title" : @"FUN提醒",
                                    @"accessoryStyle" : @(1),
                                    @"option" : @(GFNotifySettingOptionAllowFunMessage)
                                    },
                                @{
                                    @"title" : @"参与提醒",
                                    @"accessoryStyle" : @(1),
                                    @"option" : @(GFNotifySettingOptionAllowParticipateMessage)
                                    },
                                @{
                                    @"title" : @"系统通知",
                                    @"accessoryStyle" : @(1),
                                    @"option" : @(GFNotifySettingOptionAllowNotifyMessage)
                                    }
                                ]
                            ];
    }
    return _notifySettings;
}
- (UITableView *)notifyTableView {
    if (!_notifyTableView) {
        _notifyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
        _notifyTableView.dataSource = self;
        _notifyTableView.delegate = self;
        _notifyTableView.backgroundColor = [UIColor clearColor];
        _notifyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_notifyTableView registerClass:[GFSettingTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFSettingTableViewCell class])];
    }
    return _notifyTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息通知";
    [self.view addSubview:self.notifyTableView];
    
    [self loadMetaInfo];
}

- (void)loadMetaInfo {
    
    NSData *metaInfoData = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyMetaInfo];
    if (metaInfoData) {
        self.metaInfo = [NSKeyedUnarchiver unarchiveObjectWithData:metaInfoData];
    }
    if (!self.metaInfo) {
        self.metaInfo = [[GFMetaInfoMTL alloc] init];
        [self persistent];
    }
    [self.notifyTableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager queryMetaInfoSuccess:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFMetaInfoMTL *metaInfo) {
        if (code == 0) {
            weakSelf.metaInfo = metaInfo;
            [weakSelf persistent];
            [weakSelf.notifyTableView reloadData];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        
    }];
}

- (void)persistent {
    NSData *metaInfoData = [NSKeyedArchiver archivedDataWithRootObject:self.metaInfo];
    [GFUserDefaultsUtil setObject:metaInfoData forKey:GFUserDefaultsKeyMetaInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.notifySettings count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *sectionData = [self.notifySettings objectAtIndex:section];
    return [sectionData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *sectionData = [self.notifySettings objectAtIndex:indexPath.section];
    NSDictionary *model = [sectionData objectAtIndex:indexPath.row];
    
    GFSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFSettingTableViewCell class])];
    cell.titleLabel.text = [model objectForKey:@"title"];
    
    NSInteger accessoryStyle = [[model objectForKey:@"accessoryStyle"] integerValue];
    cell.accessoryImageView.hidden = (accessoryStyle != 0);
    cell.switchButton.hidden = (accessoryStyle != 1);
    
    GFNotifySettingOption option = [[model objectForKey:@"option"] integerValue];
    switch (option) {
        case GFNotifySettingOptionAllowContentMessage: {
            cell.switchButton.on = self.metaInfo.allowContentMessage;
            break;
        }
        case GFNotifySettingOptionAllowCommentMessage: {
            cell.switchButton.on = self.metaInfo.allowCommentMessage;
            break;
        }
        case GFNotifySettingOptionAllowFunMessage: {
            cell.switchButton.on = self.metaInfo.allowFunMessage;
            break;
        }
        case GFNotifySettingOptionAllowParticipateMessage: {
            cell.switchButton.on = self.metaInfo.allowParticipateMessage;
            break;
        }
        case GFNotifySettingOptionAllowNotifyMessage: {
            cell.switchButton.on = self.metaInfo.allowNotifyMessage;
            break;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [cell.switchButton bk_addEventHandler:^(id sender) {
        [weakSelf didSelectSwitchButtonAtIndexPath:indexPath];
    } forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (void)didSelectSwitchButtonAtIndexPath:(NSIndexPath *)indexPath {
    
    GFSettingTableViewCell *cell = [self.notifyTableView cellForRowAtIndexPath:indexPath];
    
    NSArray *sectionData = [self.notifySettings objectAtIndex:indexPath.section];
    NSDictionary *model = [sectionData objectAtIndex:indexPath.row];
    GFNotifySettingOption option = [[model objectForKey:@"option"] integerValue];
    
    BOOL accept = cell.switchButton.on;
    GFMetaInfoMTL *tmpMetaInfo = [self.metaInfo copy];
    GFAcceptMessageType type = 0;
    switch (option) {
        case GFNotifySettingOptionAllowContentMessage: {
            [MobClick event:@"gf_sz_01_02_02_1"];
            type = GFAcceptMessageTypeContent;
            self.metaInfo.allowContentMessage = accept;
            break;
        }
        case GFNotifySettingOptionAllowCommentMessage: {
            [MobClick event:@"gf_sz_01_02_03_1"];
            type = GFAcceptMessageTypeComment;
            self.metaInfo.allowCommentMessage = accept;
            break;
        }
        case GFNotifySettingOptionAllowFunMessage: {
            [MobClick event:@"gf_sz_01_02_04_1"];
            type = GFAcceptMessageTypeFun;
            self.metaInfo.allowFunMessage = accept;
            break;
        }
        case GFNotifySettingOptionAllowParticipateMessage: {
            [MobClick event:@"gf_sz_01_02_05_1"];
            type = GFAcceptMessageTypeParticipate;
            self.metaInfo.allowParticipateMessage = accept;
            break;
        }
        case GFNotifySettingOptionAllowNotifyMessage: {
            type = GFAcceptMessageTypeNotify;
            self.metaInfo.allowNotifyMessage = accept;
            break;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager updateAcceptPushMessageSetting:accept
                                                type:type
                                             success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {

                                                 if (code == 1) {
                                                     [weakSelf persistent];
                                                 } else {
                                                     weakSelf.metaInfo = tmpMetaInfo;
                                                     [weakSelf.notifyTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                 }

                                             } failure:^(NSUInteger taskId, NSError *error) {
                                                 weakSelf.metaInfo = tmpMetaInfo;
                                                 [weakSelf.notifyTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                             }];
    
}

@end
