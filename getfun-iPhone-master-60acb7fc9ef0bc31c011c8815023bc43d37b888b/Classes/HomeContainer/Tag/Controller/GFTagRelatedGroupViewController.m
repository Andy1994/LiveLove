//
//  GFTagRelatedGroupViewController.m
//  GetFun
//
//  Created by Liu Peng on 16/1/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFTagRelatedGroupViewController.h"
#import "GFRecommendGroupView.h"

#import "GFGroupDetailViewController.h"
#import "GFGroupInfoViewController.h"
#import "GFNetworkManager+Group.h"

// cell外壳，内部是通用的GFRecommendGroupView
@interface GFTagRelatedGroupTableViewCell : GFBaseTableViewCell
@property (nonatomic, strong) GFRecommendGroupView *groupView;
@end

@implementation GFTagRelatedGroupTableViewCell
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

- (void)dealloc {
    [_groupView removeFromSuperview];
    _groupView = nil;
}

@end

@interface GFTagRelatedGroupViewController ()
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *groupTableView;
@property (nonatomic, strong) NSArray<GFGroupMTL *> *groupList;

@end

@implementation GFTagRelatedGroupViewController

- (UITableView *)groupTableView {
    if (!_groupTableView) {
        _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _groupTableView.delegate = self;
        _groupTableView.dataSource = self;
        [_groupTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_groupTableView registerClass:[GFTagRelatedGroupTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFTagRelatedGroupTableViewCell class])];
    }
    return _groupTableView;
}

- (instancetype)initWithGroupList:(NSArray<GFGroupMTL *> *)groupList {
    if (self = [super init]) {
        self.groupList = groupList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"相关Get帮";
    [self.view addSubview:self.groupTableView];
}

#pragma mark - TableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GFTagRelatedGroupTableViewCell heightWithModel:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.groupTableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFTagRelatedGroupTableViewCell class])];
    [(GFTagRelatedGroupTableViewCell*)cell bindWithModel:self.groupList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GFGroupMTL *group = [self.groupList objectAtIndex:indexPath.row];
    [GFNetworkManager getGroupWithGroupId:group.groupInfo.groupId
                                  success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                      if (code == 1) {
                                          //根据是否加入跳转到不同视图
                                          if (group.joined) {
                                              GFGroupDetailViewController *controller = [[GFGroupDetailViewController alloc] initWithGroup:group];
                                              [self.navigationController pushViewController:controller animated:YES];
                                          } else {
                                              GFGroupInfoViewController *controller = [[GFGroupInfoViewController alloc] initWithGroup:group];
                                              [self.navigationController pushViewController:controller animated:YES];
                                          }
                                          
                                      }
                                  } failure:^(NSUInteger taskId, NSError *error) {
                                      
                                  }];
}

@end
