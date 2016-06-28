//
//  GFMyFollowerListViewController.m
//  GetFun
//
//  Created by Liu Peng on 16/3/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFMyFollowerListViewController.h"
#import "GFFollowTableViewCell.h"
#import "GFNetworkManager+Follow.h"
#import "GFProfileViewController.h"
#import "GFAccountManager.h"

@interface GFMyFollowerListViewController ()
<UITableViewDelegate, UITableViewDataSource, GFFollowTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<GFFollowerMTL *> *followerList;
@property (nonatomic, strong) NSNumber *refTime;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation GFMyFollowerListViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[GFFollowTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFFollowTableViewCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)followerList {
    if (!_followerList) {
        _followerList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _followerList;
}


- (void)queryFollowerList {
    
//    if (self.tableView.infiniteScrollingView.state == SVInfiniteScrollingStateLoading ) {
//        return;
//    }
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;
    @weakify(self)
    [GFNetworkManager queryFollowerListWithUserId:nil refTime:self.refTime success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFFollowerMTL *> *followerList, NSNumber *refTime) {
        @strongify(self)
        [self.tableView finishInfiniteScrolling];
        if (code == 1) {
            if (followerList && followerList.count > 0) {
                //[self.followerList removeAllObjects];
                [self.followerList addObjectsFromArray:followerList];
            }
            self.refTime = refTime;
            if ([refTime integerValue] == -1) {
                self.tableView.showsInfiniteScrolling = NO;
            }
            [self.tableView reloadData];
            
        } else {
            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
        }
        self.isLoading = NO;
    } failure:^(NSUInteger taskId, NSError *error) {
        [self.tableView finishInfiniteScrolling];
        [MBProgressHUD showHUDWithTitle:@"网络出错" duration:kCommonHudDuration inView:self.view];
        self.isLoading = NO;
    }];
}

# pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.gf_StatusBarStyle = UIStatusBarStyleDefault;
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackDark;
    self.title = @"我的粉丝";
    
    @weakify(self)
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        @strongify(self)
        [self queryFollowerList];
    }];
    
    [self queryFollowerList];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.followerList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GFFollowTableViewCell heightWithModel:self.followerList[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFFollowTableViewCell class]) forIndexPath:indexPath];
    cell.style = GFFollowTableViewCellStyleMyFollower;
    GFFollowerMTL *followerMTL = self.followerList[indexPath.row];
    [cell bindWithModel:followerMTL];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [MobClick event:@"gf_gr_01_16_05_1"];
    
    NSNumber *userId = self.followerList[indexPath.row].user.userId;
    GFProfileViewController *controller = [[GFProfileViewController alloc] initWithUserID:userId];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - GFFollowTableViewCellDelegate

//切换关注状态
- (void)followActionWithButton:(UIButton *)button InCell:(GFFollowTableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    GFFollowerMTL *followerMTL = self.followerList[indexPath.row];
    
    switch ([followerMTL followState]) {
        case GFFollowStateNo: {
            [MobClick event:@"gf_gr_01_16_01_1"];
            break;
        }
        case GFFollowStateFollowing: {
            [MobClick event:@"gf_gr_01_16_02_1"];;
            break;
        }
        case GFFollowStateFollowingEachOther: {
            [MobClick event:@"gf_gr_01_16_02_1"];
            break;
        }
    }

    
    @weakify(self)
    //根据cell当前状态切换状态
    void (^followSuccess)(NSUInteger, NSInteger, NSString *) = ^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage){
        @strongify(self)
        if (code == 1) {
            followerMTL.loginUserFollowUser = YES;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"对%@关注成功",followerMTL.user.nickName] duration: kCommonHudDuration inView:self.view];
        } else {
            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
        }
        button.enabled = YES;
    };
    void (^cancelFollowSuccess)(NSUInteger, NSInteger, NSString *) = ^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage){
        @strongify(self)
        if (code == 1) {
            followerMTL.loginUserFollowUser = NO;
            [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
//            [self.followerList removeObjectAtIndex:indexPath.row];
//            [self.tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationFade];
            [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"已取消对%@的关注",followerMTL.user.nickName] duration: kCommonHudDuration inView:self.view];
        } else {
            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
        }
        button.enabled = YES;
    };
    
    void (^failure)(NSUInteger, NSError *) = ^(NSUInteger taskId, NSError * error){
        [MBProgressHUD showHUDWithTitle:@"网络出错" duration:kCommonHudDuration inView:self.view];
        button.enabled = YES;
    };
    
    [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
        if (user) {
            //防止重复点击
            button.enabled = NO;
            switch ([followerMTL followState]) {
                case GFFollowStateNo: {
                    [GFNetworkManager followWithUserId:followerMTL.user.userId success:followSuccess failure:failure];
                    break;
                }
                case GFFollowStateFollowing: {
                    [UIAlertView bk_showAlertViewWithTitle:[NSString stringWithFormat:@"是否取消对%@的关注？", followerMTL.user.nickName] message:nil cancelButtonTitle:@"否" otherButtonTitles:@[@"是"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex==0) {
                            [MobClick event:@"gf_gr_01_16_04_1"];
                        } else{
                            [MobClick event:@"gf_gr_01_16_03_1"];
                            [GFNetworkManager cancelFollowWithUserId:followerMTL.user.userId success:cancelFollowSuccess failure:failure];
                        }
                        
                    }];
                    break;
                }
                case GFFollowStateFollowingEachOther: {
                    [UIAlertView bk_showAlertViewWithTitle:[NSString stringWithFormat:@"是否取消对%@的关注？", followerMTL.user.nickName] message:nil cancelButtonTitle:@"否" otherButtonTitles:@[@"是"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex==0) {
                            [MobClick event:@"gf_gr_01_16_04_1"];
                        } else{
                            [MobClick event:@"gf_gr_01_16_03_1"];
                            [GFNetworkManager cancelFollowWithUserId:followerMTL.user.userId success:cancelFollowSuccess failure:failure];
                        }
                        
                    }];
                    break;
                }
            }
        }
    }];
#warning 待完善
}

@end
