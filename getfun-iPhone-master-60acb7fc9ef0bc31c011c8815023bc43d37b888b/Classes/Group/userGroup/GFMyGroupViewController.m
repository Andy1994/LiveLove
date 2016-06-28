//
//  GFMyGroupViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFMyGroupViewController.h"
#import "GFGroupMTL.h"
#import "GFMyGroupCell.h"
#import "GFRecommendGroupCell.h"
#import "GFNetworkManager+Group.h"
#import "GFAccountManager.h"
#import "GFLocationManager.h"
#import "GFCreateGroupSelectInterestViewController.h"
#import "GFGroupDetailViewController.h"
#import "GFGroupInfoViewController.h"
#import "GFSearchBar.h"

static const CGFloat kNonJoinedGroupCellHeight = 140.0f;

@interface GFSearchBarHeader : UICollectionReusableView

@end

@implementation GFSearchBarHeader
@end


@interface GFSearchGroupTableViewCell : GFBaseTableViewCell
@end

@implementation GFSearchGroupTableViewCell
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(17, 0, 44, 44);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.centerY = self.height / 2;
    self.imageView.layer.cornerRadius = self.imageView.height / 2;
    self.imageView.clipsToBounds = YES;
    
    CGRect labelFrame = self.textLabel.frame;
    labelFrame.origin.x = self.imageView.right + 7;
    self.textLabel.frame = labelFrame;
}
@end

@interface GFNonJoinedGroupCell : GFBaseCollectionViewCell
@end

@interface GFNonJoinedGroupCell ()
@property (nonatomic, strong) UIImageView *nonJoinedGroupImageView;
@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation GFNonJoinedGroupCell
- (UIImageView *)nonJoinedGroupImageView {
    if (!_nonJoinedGroupImageView) {
        _nonJoinedGroupImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_no_group"]];
        [_nonJoinedGroupImageView sizeToFit];
    }
    return _nonJoinedGroupImageView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:13.0f];
        _tipLabel.textColor = [UIColor grayColor];
        _tipLabel.text = @"你还没有加入任何get帮";
    }
    return _tipLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.nonJoinedGroupImageView];
        [self.contentView addSubview:self.tipLabel];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return kNonJoinedGroupCellHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nonJoinedGroupImageView.center = CGPointMake(self.contentView.width/2, self.contentView.height/2);
    self.tipLabel.center = CGPointMake(self.nonJoinedGroupImageView.centerX, self.nonJoinedGroupImageView.bottom + 15.0f);
}

@end

@interface GFMyGroupViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UISearchBarDelegate,
UISearchDisplayDelegate>

@property (nonatomic, strong) UIButton *createGroupButton;

@property (nonatomic, strong) UICollectionView *groupCollectionView;
@property (nonatomic, strong) GFSearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSMutableArray<GFGroupMTL *> *searchGroupList;

@property (nonatomic, strong) NSNumber *userJoinedGroupRefTime;
@property (nonatomic, strong) NSMutableArray<GFGroupMTL *> *userJoinedGroup;
@property (nonatomic, strong) NSMutableArray<GFGroupMTL *> *recommendGroupByInterest;
@property (nonatomic, strong) NSMutableArray<GFGroupMTL *> *recommendGroupByDistance;
@property (nonatomic, strong) UIButton *retryButton;
@end

@implementation GFMyGroupViewController

- (UIButton *)createGroupButton {
    if (!_createGroupButton) {
        _createGroupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _createGroupButton.frame = CGRectMake(0, 0, 60, 40);
        [_createGroupButton setTitle:@"创建帮" forState:UIControlStateNormal];
        [_createGroupButton sizeToFit];
        _createGroupButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_createGroupButton setBackgroundColor:[UIColor clearColor]];
        [_createGroupButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_createGroupButton bk_addEventHandler:^(id sender) {
            [weakSelf didSelectRightBarButton];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _createGroupButton;
}

- (UICollectionView *)groupCollectionView {
    if (!_groupCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _groupCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _groupCollectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        _groupCollectionView.backgroundColor = [UIColor clearColor];
        _groupCollectionView.delegate = self;
        _groupCollectionView.dataSource = self;
        [_groupCollectionView registerClass:[GFSearchBarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFSearchBarHeader class])];
        [_groupCollectionView registerClass:[GFNonJoinedGroupCell class] forCellWithReuseIdentifier:NSStringFromClass([GFNonJoinedGroupCell class])];
        [_groupCollectionView registerClass:[GFMyGroupCell class] forCellWithReuseIdentifier:NSStringFromClass([GFMyGroupCell class])];
        [_groupCollectionView registerClass:[GFRecommendGroupCell class] forCellWithReuseIdentifier:NSStringFromClass([GFRecommendGroupCell class])];
    }
    return _groupCollectionView;
}

- (GFSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[GFSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0f)];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UISearchDisplayController *)searchDisplayController {
    if (!_searchDisplayController) {
        _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchDisplayController.delegate = self;
        _searchDisplayController.searchResultsDataSource = self;
        _searchDisplayController.searchResultsDelegate = self;
        [_searchDisplayController.searchResultsTableView registerClass:[GFSearchGroupTableViewCell class] forCellReuseIdentifier:NSStringFromClass([GFSearchGroupTableViewCell class])];
        _searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchDisplayController.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    }
    return _searchDisplayController;
}

- (NSMutableArray<GFGroupMTL *> *)searchGroupList {
    if (!_searchGroupList) {
        _searchGroupList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _searchGroupList;
}

- (NSMutableArray<GFGroupMTL *> *)userJoinedGroup {
    if (!_userJoinedGroup) {
        _userJoinedGroup = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _userJoinedGroup;
}

- (NSMutableArray<GFGroupMTL *> *)recommendGroupByInterest {
    if (!_recommendGroupByInterest) {
        _recommendGroupByInterest = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _recommendGroupByInterest;
}

- (NSMutableArray<GFGroupMTL *> *)recommendGroupByDistance {
    if (!_recommendGroupByDistance) {
        _recommendGroupByDistance = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _recommendGroupByDistance;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的GET帮列表";
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackDark;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.createGroupButton];
    [self.view addSubview:self.groupCollectionView];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    __weak typeof(self) weakSelf = self;
    [self.groupCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryUserJoinedGroup];
    }];
    [self queryUserJoinedGroup];
}
- (void)showRetryButtonIfNeeded {
    
    if (!self.retryButton) {
        self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.retryButton setShowsTouchWhenHighlighted:YES];
        [self.retryButton setBackgroundImage:[UIImage imageNamed:@"content_reload"] forState:UIControlStateNormal];
        [self.retryButton sizeToFit];
        self.retryButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        
        __weak typeof(self) weakSelf = self;
        [self.retryButton bk_addEventHandler:^(id sender) {
            [weakSelf.retryButton removeFromSuperview];
            [self queryUserJoinedGroup];
            [self queryRecommendGroupByDistance];
            [self queryRecommendGroupByInterest];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (![self.retryButton superview] &&
        [self.userJoinedGroup count] == 0 &&
        [self.recommendGroupByDistance count] == 0 &&
        [self.recommendGroupByInterest count] == 0) {
        [self.view addSubview:self.retryButton];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLocationUpdated:) name:GFNotificationLocationUpdated object:nil];
//    [self queryUserJoinedGroup];
    [self queryRecommendGroupByDistance];
    [self queryRecommendGroupByInterest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GFNotificationLocationUpdated object:nil];
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_gb_01_06_01_1"];
    [super backBarButtonItemSelected];
}

#pragma mark - Methods
- (void)didSelectRightBarButton {
    [MobClick event:@"gf_gb_01_01_01_1"];
    GFCreateGroupSelectInterestViewController *selectInterestViewController = [[GFCreateGroupSelectInterestViewController alloc] init];
       [self.navigationController pushViewController:selectInterestViewController animated:YES];
}

- (void)didLocationUpdated:(NSNotification *)notification {
    if (!self.recommendGroupByDistance) {
        [self queryRecommendGroupByDistance];
    }
}

#pragma mark 网络请求
- (void)queryUserJoinedGroup {
    __weak typeof(self) weakSelf = self;
    
    NSNumber *userId = [GFAccountManager sharedManager].loginUser.userId;
    if (!userId) return;
    
    [GFNetworkManager getGroupWithUserId:userId
                            refQueryTime:self.userJoinedGroupRefTime
                                   count:kQueryDataCount
                                 success:^(NSUInteger taskId, NSInteger code, NSNumber *refQueryTime, NSString *apiErrorMessage, NSArray<GFGroupMTL *> *groupList) {
                                     
                                     [weakSelf.groupCollectionView finishInfiniteScrolling];
                                     
                                     if (code == 1) {
                                         weakSelf.userJoinedGroupRefTime = refQueryTime;
                                         [weakSelf.userJoinedGroup addObjectsFromArray:groupList];
                                         
                                         weakSelf.groupCollectionView.showsInfiniteScrolling = [refQueryTime integerValue] != -1;
                                         
                                         [weakSelf.groupCollectionView reloadData];
                                     }
                                 } failure:^(NSUInteger taskId, NSError *error) {
                                     [weakSelf.groupCollectionView finishInfiniteScrolling];
                                     [weakSelf showRetryButtonIfNeeded];
                                 }];
}

- (void)queryRecommendGroupByInterest {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getUserInterestGroupSuccess:^(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> *interestGroupList, BOOL hasMore, NSString *errorMessage) {
        if (code == 1) {
            [weakSelf.recommendGroupByInterest removeAllObjects];
            [weakSelf.recommendGroupByInterest addObjectsFromArray:interestGroupList];
            [weakSelf.groupCollectionView reloadData];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [weakSelf showRetryButtonIfNeeded];
    }];
}

- (void)queryRecommendGroupByDistance {
    CLLocation *location = [GFLocationManager lastLocation];
    if (location) {
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager getRecommendGroupWithLongitude:@(location.coordinate.longitude)
                                                latitude:@(location.coordinate.latitude)
                                                 success:^(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> *groupList, NSString *errorMessage) {
                                                     if (code == 1) {
                                                         if (groupList) {
                                                             [weakSelf.recommendGroupByDistance removeAllObjects];
                                                             [weakSelf.recommendGroupByDistance addObjectsFromArray:groupList];
                                                             [weakSelf.groupCollectionView reloadData];
                                                         }
                                                     }
                                                 }
                                                 failure:^(NSUInteger taskId, NSError *error) {
                                                     [weakSelf showRetryButtonIfNeeded];
                                                 }];
    }
}

-(void)queryGroupWithText:(NSString *)text {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getGroupWithKeyword:text
                                queryTime:nil
                                    count:kQueryDataCount
                                  success:^(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> * groupList, NSNumber * queryTime, NSString * apiErrorMessage) {

                                      [weakSelf.searchGroupList removeAllObjects];
                                      
                                      if (code == 1 && [groupList count] > 0) {
                                          [weakSelf.searchGroupList addObjectsFromArray:groupList];
                                      }
                                      [weakSelf.searchDisplayController.searchResultsTableView reloadData];
                                  }
                                  failure:^(NSUInteger taskId, NSError * error) {
                                      
                                  }];
}

#pragma mark - 我的Get帮
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numberOfSections = 1;
    if ([self.userJoinedGroupRefTime integerValue] == -1) {
        if ([self.recommendGroupByInterest count] > 0) {
            numberOfSections ++;
        }
        if ([self.recommendGroupByDistance count] > 0) {
            numberOfSections ++;
        }
    }
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 1;
    if (section == 0 && [self.userJoinedGroup count] > 0) {
        numberOfItems = [self.userJoinedGroup count];
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = 0;
    if (indexPath.section == 0) {
        if ([self.userJoinedGroup count] == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFNonJoinedGroupCell class]) forIndexPath:indexPath];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFMyGroupCell class]) forIndexPath:indexPath];
            __weak typeof(self) weakSelf = self;
            __weak typeof(cell) weakCell = cell;
            [(GFMyGroupCell *)cell setStyle:GFMyGroupCellStyleCheckIn];
            id model = [self.userJoinedGroup objectAtIndex:indexPath.row];
            [(GFMyGroupCell *)cell bindWithModel:model];
            [(GFMyGroupCell *)cell setCheckInHandler:^(GFGroupMTL *group) {
                [MobClick event:@"gf_gb_01_03_01_1"];
                [GFNetworkManager checkinGroupWithGroupId:group.groupInfo.groupId success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                    //处理数据
                    GFGroupMTL * group = [weakSelf.userJoinedGroup objectAtIndex:indexPath.row];
                    group.checkedIn = YES;
                    
                } failure:^(NSUInteger taskId, NSError *error) {
                    [(GFMyGroupCell *)weakCell updateCheckInState:NO];
                }];
            }];
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFRecommendGroupCell class]) forIndexPath:indexPath];
        GFRecommendGroupCellStyle style = (indexPath.section == 1 && [self.recommendGroupByInterest count] > 0) ? GFRecommendGroupCellStyle_ProfileByInterest : GFRecommendGroupCellStyle_ProfileByDistance;
        [(GFRecommendGroupCell *)cell bindWithModel:(style == GFRecommendGroupCellStyle_ProfileByInterest) ? self.recommendGroupByInterest : self.recommendGroupByDistance
                                              style:style
                                     showRightTitle:YES];

        __weak typeof(self) weakSelf = self;
        [(GFRecommendGroupCell *)cell setGroupSelectHandler:^(GFRecommendGroupCell *cell, GFRecommendGroupView *itemView) {
            if (style == GFRecommendGroupCellStyle_ProfileByInterest) {
                [MobClick event:@"gf_gb_01_04_01_1"];
            } else {
                [MobClick event:@"gf_gb_01_05_01_1"];
            }
            GFGroupMTL *group = itemView.group;
            GFGroupInfoViewController *groupInfoViewController = [[GFGroupInfoViewController alloc] initWithGroup:group];
            [groupInfoViewController setJoinGroupHandler:^(GFGroupMTL *groupMTL) {
                    groupMTL.joined = YES;
                    
                    if (![weakSelf.userJoinedGroup containsObject:groupMTL]) {
                        [weakSelf.userJoinedGroup addObject:groupMTL];
                    }
                    
                    if ([weakSelf.recommendGroupByInterest containsObject:groupMTL]) {
                        [weakSelf.recommendGroupByInterest removeObject:groupMTL];
                    }
                    if ([weakSelf.recommendGroupByDistance containsObject:groupMTL]) {
                        [weakSelf.recommendGroupByDistance removeObject:groupMTL];
                    }
                    
                    [weakSelf.groupCollectionView reloadData];
            }];
            [groupInfoViewController setUpdateSignInHandler:^(GFGroupMTL *groupMTL){
                groupMTL.checkedIn = YES;
                [weakSelf.groupCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            [weakSelf.navigationController pushViewController:groupInfoViewController animated:YES];
        }];

        [(GFRecommendGroupCell *)cell setRighButtonHandler:^(GFRecommendGroupCell *cell) {
            if (style == GFRecommendGroupCellStyle_ProfileByInterest) {
                // 换兴趣推荐
                [weakSelf queryRecommendGroupByInterest];
            } else {
                [MobClick event:@"gf_gb_01_05_02_1"];
                // 换距离推荐
                [weakSelf queryRecommendGroupByDistance];
            }
        }];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    GFSearchBarHeader *searchBarHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFSearchBarHeader class]) forIndexPath:indexPath];
    if (![self.searchBar superview]) {
        [searchBarHeader addSubview:self.searchBar];
    }
    self.searchBar.opaque = YES;
    UIView *view = [[self.searchBar subviews] firstObject];
    view.frame = CGRectMake(0, 0.5, SCREEN_WIDTH, 43.5);
    self.searchBar.barTintColor = [UIColor themeColorValue12];
    
    return searchBarHeader;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    if (section == 0) {
        size = CGSizeMake(collectionView.width, 32.0f);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0) {
        if ([self.userJoinedGroup count] > 0) {
            id model = [self.userJoinedGroup objectAtIndex:indexPath.row];
            height = [GFMyGroupCell heightWithModel:model];
        } else {
            height = kNonJoinedGroupCellHeight;
        }
    } else if (indexPath.section == 1 && [self.recommendGroupByInterest count] > 0) {
        height = [GFRecommendGroupCell heightWithModel:self.recommendGroupByInterest];
    } else {
        height = [GFRecommendGroupCell heightWithModel:self.recommendGroupByDistance];
    }
    
    return CGSizeMake(collectionView.width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [self.userJoinedGroup count] > 0) {
        [MobClick event:@"gf_gb_01_03_02_1"];
        
        GFGroupMTL *groupMTL = [self.userJoinedGroup objectAtIndex:indexPath.row];
        GFGroupDetailViewController *groupDetailViewController = [[GFGroupDetailViewController alloc] initWithGroup:groupMTL];
        __weak typeof(self) weakSelf = self;
        groupDetailViewController.quitGroupHandler = ^(GFGroupMTL *group) {
            [weakSelf.userJoinedGroup removeObject:group];
            if ([weakSelf.userJoinedGroup count] > 0) {
                [weakSelf.groupCollectionView deleteItemsAtIndexPaths:@[indexPath]];
            } else {
                [weakSelf.groupCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }
        };
        groupDetailViewController.updateSignInHandler = ^() {
                groupMTL.checkedIn = YES;
                [weakSelf.groupCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        };
        [self.navigationController pushViewController:groupDetailViewController animated:YES];
    }
}

#pragma mark - 搜索结果
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchGroupList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //搜索结果的帮
    GFSearchGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([GFSearchGroupTableViewCell class])];
    
    GFGroupMTL *group = self.searchGroupList[indexPath.row];
    
    NSString *url = [group.groupInfo.imgUrl gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarGroup gifConverted:YES];
    [cell.imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"default_avatar_1"]];
    cell.textLabel.text = group.groupInfo.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //搜索结果的帮
    __weak typeof(self) weakSelf = self;
    GFGroupMTL *group = self.searchGroupList[indexPath.row];
    
    if (group.joined == YES) {
        GFGroupDetailViewController *groupDetailViewController = [[GFGroupDetailViewController alloc] initWithGroup:group];
        [groupDetailViewController setQuitGroupHandler:^(GFGroupMTL *groupMTL) {
            if (![weakSelf.userJoinedGroup containsObject:groupMTL]) {
                [weakSelf.userJoinedGroup addObject:groupMTL];
                if ([weakSelf.userJoinedGroup count] == 1) {
                    [weakSelf.groupCollectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
                }
            }
        }];
        [self.navigationController pushViewController:groupDetailViewController animated:YES];
    } else {
        GFGroupInfoViewController *groupInfoViewController = [[GFGroupInfoViewController alloc] initWithGroup:group];
        [groupInfoViewController setJoinGroupHandler:^(GFGroupMTL *groupMTL) {
                groupMTL.joined = YES;
                
                if (![weakSelf.userJoinedGroup containsObject:groupMTL]) {
                    [weakSelf.userJoinedGroup addObject:groupMTL];
                }
                
                if ([weakSelf.recommendGroupByInterest containsObject:groupMTL]) {
                    [weakSelf.recommendGroupByInterest removeObject:groupMTL];
                }
                if ([weakSelf.recommendGroupByDistance containsObject:groupMTL]) {
                    [weakSelf.recommendGroupByDistance removeObject:groupMTL];
                }
                [weakSelf.groupCollectionView reloadData];
        }];
        [groupInfoViewController setUpdateSignInHandler:^(GFGroupMTL *groupMTL) {
            groupMTL.checkedIn = YES;
            [weakSelf.groupCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
        [self.navigationController pushViewController:groupInfoViewController animated:YES];
    }

    
    [self.searchDisplayController setActive:NO animated:NO];
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [MobClick event:@"gf_gb_01_02_01_1"];
    NSString *text = searchBar.text;
    [self queryGroupWithText:text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        [self.searchGroupList removeAllObjects];
    }
}

@end
