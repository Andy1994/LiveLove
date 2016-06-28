//
//  GFGroupSelectViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupSelectViewController.h"
#import "GFGroupSelectTableViewCell.h"
#import "GFNetworkManager+Group.h"
#import "GFAccountManager.h"

@interface GFGroupSelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *groupTableView;
@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, strong) NSNumber *refQueryTime; // 服务器返回的ref
@property (nonatomic, strong) UIImageView *placeHolderImageView;
@end

@implementation GFGroupSelectViewController
- (UITableView *)groupTableView {
    if (!_groupTableView) {
        _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _groupTableView.delegate = self;
        _groupTableView.dataSource = self;
        _groupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_groupTableView registerClass:[GFGroupSelectTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFGroupSelectTableViewCell class])];
    }
    return _groupTableView;
}

- (NSMutableArray *)groupList {
    if (!_groupList) {
        _groupList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _groupList;
}

- (UIImageView *)placeHolderImageView {
    if (!_placeHolderImageView) {
        _placeHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_no_group"]];
        [_placeHolderImageView sizeToFit];
        _placeHolderImageView.center = CGPointMake(self.view.width/2, self.view.height/2);
    }
    return _placeHolderImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择发布的帮";
    
    [self.view addSubview:self.groupTableView];
    [self.view addSubview:self.placeHolderImageView];
    [self getMyGroupList];
    __weak typeof(self) weakSelf = self;
    [self.groupTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getMyGroupList];
    }];
}

- (void)getMyGroupList {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getGroupWithUserId:[GFAccountManager sharedManager].loginUser.userId
                            refQueryTime:self.refQueryTime
                                   count:kQueryDataCount
                                 success:^(NSUInteger taskId, NSInteger code, NSNumber *refQueryTime, NSString *apiErrorMessage, NSArray<GFGroupMTL *> *groupList) {
                                     [weakSelf.groupTableView finishInfiniteScrolling];
                                     if (code == 1) {
                                         
                                         [weakSelf.groupList addObjectsFromArray:groupList];
                                          weakSelf.refQueryTime = refQueryTime;
                                         weakSelf.groupTableView.showsInfiniteScrolling = [weakSelf.refQueryTime integerValue] != -1;
                                         [weakSelf.groupTableView reloadData];

                                         weakSelf.placeHolderImageView.hidden = [weakSelf.groupList count] > 0;
                                     }
                                 } failure:^(NSUInteger taskId, NSError *error) {
                                     [weakSelf.groupTableView finishInfiniteScrolling];
                                     weakSelf.placeHolderImageView.hidden = [weakSelf.groupList count] == 0;
                                 }];
}

#pragma mark - UITableViewDatasource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groupList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GFGroupSelectTableViewCell heightWithModel:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFGroupMTL *group = [self.groupList objectAtIndex:indexPath.row];
    
    GFGroupSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFGroupSelectTableViewCell class])];
    [cell bindWithModel:group];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GFGroupMTL *group = [self.groupList objectAtIndex:indexPath.row];
    [MobClick event:@"gf_fb_04_01_01_1"];
    
    
    if (self.groupSelectHandler) {
        self.groupSelectHandler(group);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
