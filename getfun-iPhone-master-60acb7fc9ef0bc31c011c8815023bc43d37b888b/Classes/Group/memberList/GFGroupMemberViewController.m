//
//  GFGroupMemberViewController.m
//  GetFun
//
//  Created by liupeng on 15/12/3.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupMemberViewController.h"
#import "GFGroupMemberTableViewCell.h"
#import "GFUserMTL.h"
#import "GFNetworkManager+Group.h"
#import "GFAccountManager.h"
#import "GFProfileViewController.h"

@interface GFGroupMemberViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) GFGroupMTL *group;

@property (nonatomic, strong) NSMutableArray<GFGroupMemberMTL *> *memberList;

@property (nonatomic, strong) UITableView *memberTableView;

@property (nonatomic, strong) NSNumber *queryTime;

@end

@implementation GFGroupMemberViewController
- (instancetype)initWithGroup:(id)group {
    if (self = [super init]) {
        self.group = group;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.memberTableView];
    
    self.title = @"帮成员列表";
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackDark;
    [self queryGroupMemberList];
    
    __weak typeof(self) weakSelf = self;
    
    [self.memberTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryGroupMemberList];
    }];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray<GFGroupMemberMTL *> *)memberList {
    if (!_memberList) {
        _memberList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _memberList;
}

- (UITableView *)memberTableView {
    if (!_memberTableView) {
        _memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _memberTableView.delegate = self;
        _memberTableView.dataSource = self;
        _memberTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_memberTableView registerClass:[GFGroupMemberTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFGroupMemberTableViewCell class])];
        
        UIEdgeInsets edgeInset = _memberTableView.contentInset;
        edgeInset.bottom = 0;
        _memberTableView.contentInset = edgeInset;
        
        UIView *footerView = [UIView new];
        footerView.backgroundColor = [UIColor clearColor];
        _memberTableView.tableFooterView = footerView;
    }
    return _memberTableView;
}

/**
 *  获取成员列表
 */
- (void)queryGroupMemberList {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getMemberListWithGroupId:self.group.groupInfo.groupId
                                     queryTime:self.queryTime
                                         count:kQueryDataCount
                                       success:^(NSUInteger taskId, NSInteger code, NSArray<GFGroupMemberMTL *> *memberList, NSNumber *queryTime, NSString *apiErrorMessage) {
                                           
                                           [weakSelf.memberTableView finishInfiniteScrolling];
                                           
                                           if (code == 1) {
                                               [weakSelf.memberList addObjectsFromArray:memberList];
                                               weakSelf.queryTime = queryTime;
                                               
                                               weakSelf.memberTableView.showsInfiniteScrolling = [weakSelf.queryTime integerValue] != -1;
                                            
                                               [weakSelf.memberTableView reloadData];
                                           } else {
                                               [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                           }
                                       } failure:^(NSUInteger taskId, NSError *error) {
                                           [weakSelf.memberTableView finishInfiniteScrolling];
                                           [MBProgressHUD showHUDWithTitle:@"获取帮成员列表失败" duration:kCommonHudDuration inView:self.view];
                                       }];
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.memberTableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFGroupMemberTableViewCell class])];
    GFGroupMemberMTL *model = [self.memberList objectAtIndex:indexPath.row];
    
    [(GFGroupMemberTableViewCell*)cell bindWithModel:model];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GFGroupMemberTableViewCell heightWithModel:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GFGroupMemberMTL *memberMTL = [self.memberList objectAtIndex:indexPath.row];
    GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:memberMTL.user.userId];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
