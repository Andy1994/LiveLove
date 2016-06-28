//
//  GFOtherGroupViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//


#import "GFOtherGroupViewController.h"
#import "GFGroupMTL.h"
#import "GFNetworkManager+Group.h"
#import "GFRecommendGroupView.h"
#import "GFGroupDetailViewController.h"
#import "GFGroupInfoViewController.h"

// cell外壳，内部是通用的GFRecommendGroupView
@interface GFOtherGroupTableViewCell : GFBaseTableViewCell
@property (nonatomic, strong) GFRecommendGroupView *groupView;
@end

@implementation GFOtherGroupTableViewCell
- (GFRecommendGroupView *)groupView {
    if (!_groupView) {
        _groupView = [[GFRecommendGroupView alloc] initWithFrame:CGRectZero];
    }
    return _groupView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.groupView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return 86.0f;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    self.groupView.group = model;
    self.groupView.distanceVisible = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.groupView.frame = self.contentView.bounds;
}

@end

@interface GFOtherGroupViewController ()
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, strong) UITableView *groupTableView;

@property (nonatomic, strong) NSMutableArray<GFGroupMTL *> *groupList;

@property (nonatomic, strong) NSNumber *userGroupRefTime;

@end

@implementation GFOtherGroupViewController
- (UITableView *)groupTableView {
    if (!_groupTableView) {
        _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _groupTableView.delegate = self;
        _groupTableView.dataSource = self;
        [_groupTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_groupTableView registerClass:[GFOtherGroupTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFOtherGroupTableViewCell class])];
    }
    return _groupTableView;
}

- (NSMutableArray<GFGroupMTL *> *)groupList {
    if (!_groupList) {
        _groupList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _groupList;
}

- (instancetype)initWithUserId:(NSNumber *)userId {
    if (self = [super init]) {
        self.userId = userId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ta加入的Get帮";
    [self.view addSubview:self.groupTableView];
    [self queryGroupList];
    
    __weak typeof(self) weakSelf = self;
    [self.groupTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryGroupList];
    }];
}

#pragma mark - 获取数据
- (void)queryGroupList {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getGroupWithUserId:self.userId
                            refQueryTime:self.userGroupRefTime
                                   count:kQueryDataCount
                                 success:^(NSUInteger taskId, NSInteger code, NSNumber *refQueryTime, NSString *apiErrorMessage, NSArray<GFGroupMTL *> *groupList) {
                                     [weakSelf.groupTableView finishInfiniteScrolling];
                                     if (code == 1) {
                                         weakSelf.userGroupRefTime = refQueryTime;
                                         [weakSelf.groupList addObjectsFromArray:groupList];
                                         
                                         weakSelf.groupTableView.showsInfiniteScrolling = [refQueryTime integerValue] != -1;
                                         
                                         [weakSelf.groupTableView reloadData];
                                     } else {
                                         [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                     }
                                 } failure:^(NSUInteger taskId, NSError *error) {
                                     [weakSelf.groupTableView finishInfiniteScrolling];
                                     [MBProgressHUD showHUDWithTitle:@"获取get帮列表失败" duration:kCommonHudDuration inView:self.view];
                                 }];
}

#pragma mark - TableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GFOtherGroupTableViewCell heightWithModel:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.groupTableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFOtherGroupTableViewCell class])];
    [(GFOtherGroupTableViewCell*)cell bindWithModel:self.groupList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GFGroupMTL *group = [self.groupList objectAtIndex:indexPath.row];
    if (group.joined) {
        GFGroupDetailViewController *detailViewController = [[GFGroupDetailViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        GFGroupInfoViewController *infoViewController = [[GFGroupInfoViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:infoViewController animated:YES];
    }
}

@end
