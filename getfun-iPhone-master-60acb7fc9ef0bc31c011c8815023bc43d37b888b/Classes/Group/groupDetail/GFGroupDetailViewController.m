//
//  GFGroupInfoViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/1.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupDetailViewController.h"
#import "CExpandHeader.h"
#import "GFAccountManager.h"

#import "GFGroupInfoCell.h"
#import "GFGroupPublishCell.h"
#import "GFFeedArticleCell.h"
#import "GFFeedLinkCell.h"
#import "GFFeedVoteCell.h"
#import "GFFeedPictureCell.h"

#import "GFContentInfoMTL.h"
#import "GFNetworkManager+Group.h"
#import "GFGroupMemberViewController.h"
#import "GFGroupInfoViewController.h"
#import "GFContentDetailViewController.h"
#import "GFNavigationController.h"
#import "GFPublishArticleViewController.h"
#import "GFPublishLinkViewController.h"
#import "GFPublishVoteViewController.h"
#import "GFLoginRegisterViewController.h"
#import "GFProfileViewController.h"

#import "GFPublishManager.h"
#import "GFPublishInfoHeader.h"

#import "GFExpandView.h"
#import "GFLessonViewController.h"
#import "GFTagDetailViewController.h"
#import "GFImageGroupView.h"


#define NAV_BAR_CHANGE_THRESHOLD (-20.0f)
#define SCROLL_VIEW_INI_OFFSET_Y (-250.0f)

@interface GFGroupDetailViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) GFGroupMTL *group;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *checkinButton;

@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) CExpandHeader *header;
@property (nonatomic, strong) GFExpandView *expandView;

@property (nonatomic, strong) UIImageView *refreshImageView;

@property (nonatomic, strong) NSMutableArray<GFGroupContentMTL *> *groupContents;
@property (nonatomic, strong) NSNumber *refQueryTime;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *readContents;
@end

@implementation GFGroupDetailViewController
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _titleLabel.centerX = SCREEN_WIDTH / 2;
        _titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
        _titleLabel.font = [UIFont systemFontOfSize:19];  //设置文本字体与大小
        _titleLabel.textColor = [UIColor blackColor];  //设置文本颜色
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)checkinButton {
    if (!_checkinButton) {
        _checkinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkinButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _checkinButton.backgroundColor = [UIColor themeColorValue9];
        [_checkinButton setTitleColor:[UIColor textColorValue6] forState:UIControlStateNormal];
        [_checkinButton setTitle:@"签到" forState:UIControlStateNormal];
        [_checkinButton setTitle:@"已签到" forState:UIControlStateSelected];
        _checkinButton.frame = CGRectMake(0, 0, 60, 28);
        _checkinButton.layer.cornerRadius = 5.0f;
    }
    return _checkinButton;
}

- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _contentCollectionView.backgroundColor = [UIColor clearColor];
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;
        [_contentCollectionView registerClass:[GFGroupInfoCell class] forCellWithReuseIdentifier:NSStringFromClass([GFGroupInfoCell class])];
        [_contentCollectionView registerClass:[GFGroupPublishCell class] forCellWithReuseIdentifier:NSStringFromClass([GFGroupPublishCell class])];
        [_contentCollectionView registerClass:[GFPublishInfoHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFPublishInfoHeader class])];
        [_contentCollectionView registerClass:[GFFeedArticleCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class])];
        [_contentCollectionView registerClass:[GFFeedLinkCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class])];
        [_contentCollectionView registerClass:[GFFeedVoteCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class])];
        [_contentCollectionView registerClass:[GFFeedPictureCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class])];
    }
    return _contentCollectionView;
}

- (GFExpandView *)expandView {
    if (!_expandView) {
        _expandView = [[GFExpandView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250.0f)];
    }
    return _expandView;
}

- (UIImageView *)refreshImageView {
    if (!_refreshImageView) {
        _refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull_to_refresh_2"]];
        [_refreshImageView sizeToFit];
        _refreshImageView.center = CGPointMake(SCREEN_WIDTH/2, 125.0f);
        _refreshImageView.hidden = YES;
    }
    return _refreshImageView;
}

- (NSMutableArray *)groupContents {
    if (!_groupContents) {
        _groupContents = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _groupContents;
}

- (NSMutableArray<NSNumber *> *)readContents {
    if (!_readContents) {
        _readContents = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _readContents;
}

# pragma mark - Init
- (instancetype)initWithGroup:(GFGroupMTL *)group {
    if (self = [super init]) {
        _group = group;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.contentCollectionView];
    [self.view addSubview:self.refreshImageView];
    
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackLight;
    // 设置标题
    self.titleLabel.text = self.group.groupInfo.name;
    self.navigationItem.titleView = self.titleLabel;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.checkinButton];
    
    __weak typeof(self) weakSelf = self;
    [self.checkinButton bk_addEventHandler:^(id sender) {
        if (!weakSelf.checkinButton.selected) {
            [MobClick event:@"gf_gb_07_01_01_1"];
            weakSelf.checkinButton.selected = YES;
            [weakSelf checkIn:sender];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.header = [CExpandHeader expandWithScrollView:self.contentCollectionView expandView:self.expandView];
    
    // 设置时间默认值，单位ms
    self.refQueryTime = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    
    [self.contentCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryContent:NO];
    }];
    
    [self updateUIWithGroup:self.group];
    [self queryContent:YES];
    
    [self gf_setNavBarBackgroundTransparent:0.0f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPublishedContentChanged:) name:GFNotificationPublishStateUpdate object:nil];
    
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GFNotificationPublishStateUpdate object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)queryGroupInfo {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getGroupWithGroupId:self.group.groupInfo.groupId
                                  success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                      if (code == 1) {
                                          weakSelf.group = group;
                                          [weakSelf updateUIWithGroup:group];
                                      } else {
                                          [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
                                      }
                                  } failure:^(NSUInteger taskId, NSError *error) {
                                      [MBProgressHUD showHUDWithTitle:@"获取帮信息失败" duration:kCommonHudDuration inView:self.view];
                                  }];
}

- (void)updateUIWithGroup:(GFGroupMTL *)group{
    //更新背景图
#warning 图片裁剪标准未确定
    NSString *url = [self.group.groupInfo.imgUrl gf_urlAppendWithHorizontalEdge:SCREEN_WIDTH verticalEdge:SCREEN_HEIGHT mode:GFImageProcessModeMaxWidthAdaptiveHeightAspect convertGIF:YES];
    [self.expandView.imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"interest_group_info_bg"]];
    
    //更新cell上群组信息
    [UIView performWithoutAnimation:^{
        [self.contentCollectionView reloadData];
    }];
    
    //更新签到状态
    self.checkinButton.selected = self.group.checkedIn;
    self.checkinButton.userInteractionEnabled = !self.group.checkedIn;
    self.checkinButton.backgroundColor = self.checkinButton.selected ? [[UIColor themeColorValue9] colorWithAlphaComponent:0.5] : [UIColor themeColorValue9];
}

- (void)queryContent:(BOOL)reset {    
    NSNumber *queryTime = self.refQueryTime;
    if (reset) {
        queryTime = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
    }
    __weak typeof(self) weakSelf = self;
    DDLogInfo(@"%s%s", __FILE__, __PRETTY_FUNCTION__);
    [GFNetworkManager getGroupContentsWithGroupId:self.group.groupInfo.groupId
                                     refQueryTime:queryTime
                                            count:kQueryDataCount
                                          success:^(NSUInteger taskId, NSInteger code, NSArray<GFGroupContentMTL *> *groupContentList, NSString *errorMessage) {
                                              
                                              weakSelf.refreshImageView.hidden = YES;
                                              [weakSelf stopRefreshAnimate];
                                              [weakSelf.contentCollectionView finishInfiniteScrolling];
                                              if (code == 1) {
                                                  if (groupContentList && [groupContentList count] > 0) {
                                                      if (reset) {
                                                          weakSelf.refQueryTime = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
                                                          @synchronized (weakSelf.groupContents) {
                                                              [weakSelf.groupContents removeAllObjects];
                                                          }
                                                      }
                                                      
                                                      @synchronized (weakSelf.groupContents) {
                                                          [weakSelf.groupContents addObjectsFromArray:groupContentList];
                                                      }
                                                      
                                                      GFContentInfoMTL *contentInfo = [[[weakSelf.groupContents lastObject] content] contentInfo];
                                                      weakSelf.refQueryTime = contentInfo.createTime;
                                                      
                                                      weakSelf.contentCollectionView.showsInfiniteScrolling = [weakSelf.refQueryTime integerValue] != -1;
                                                      
                                                      [weakSelf.contentCollectionView reloadData];
                                                  }
                                              }
                                          } failure:^(NSUInteger taskId, NSError *error) {
                                              
                                              weakSelf.refreshImageView.hidden = YES;
                                              [weakSelf stopRefreshAnimate];
                                              
                                              [weakSelf.contentCollectionView finishInfiniteScrolling];
                                          }];
}

- (void)checkIn:(UIButton *)checkinButton {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager checkinGroupWithGroupId:self.group.groupInfo.groupId success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
        if (code == 1) {
            if (weakSelf.updateSignInHandler) {
                weakSelf.updateSignInHandler();
            }
            weakSelf.checkinButton.backgroundColor = [[UIColor themeColorValue9] colorWithAlphaComponent:0.5];
            weakSelf.checkinButton.selected = YES;
            weakSelf.checkinButton.userInteractionEnabled = NO;
        } else {
            checkinButton.selected = NO;
            [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        checkinButton.selected = NO;
        [MBProgressHUD showHUDWithTitle:@"签到失败" duration:kCommonHudDuration inView:self.view];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    NSInteger numberOfSection = 2;
    
    NSArray *waitingTasks = [GFPublishManager waitingTaskWithGroupId:self.group.groupInfo.groupId];
    NSArray *failedTasks = [GFPublishManager failedTaskListWithGroupId:self.group.groupInfo.groupId];
    if ((self.groupContents && [self.groupContents count] > 0) || [waitingTasks count] > 0 || [failedTasks count] > 0) {
        numberOfSection ++;
    }
    return numberOfSection;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger numberOfItems = 0;
    if (section == 0 || section == 1) {
        numberOfItems = 1;
    } else {
        numberOfItems = [self.groupContents count];
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFGroupInfoCell class]) forIndexPath:indexPath];
        [(GFGroupInfoCell *)cell bindWithModel:self.group];
        [(GFGroupInfoCell *)cell setMemberAvatarListHandler:^{
            GFGroupMemberViewController *controller = [[GFGroupMemberViewController alloc] initWithGroup:weakSelf.group];
            [weakSelf.navigationController pushViewController:controller animated:YES];
        }];
    } else if (indexPath.section == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFGroupPublishCell class]) forIndexPath:indexPath];
        [(GFGroupPublishCell *)cell setPublishHandler:^(GFContentType publishType) {
            
            GFPublishBaseViewController *publishViewController = nil;
            switch (publishType) {
                case GFContentTypeArticle: {
                    publishViewController = [[GFPublishArticleViewController alloc] initWithSelectedGroup:weakSelf.group];
                    [MobClick event:@"gf_gb_07_01_02_1"];
                    break;
                }
                case GFContentTypeLink: {
                    publishViewController = [[GFPublishLinkViewController alloc] initWithSelectedGroup:weakSelf.group];
                    [MobClick event:@"gf_gb_07_01_03_1"];
                    break;
                }
                case GFContentTypeVote: {
                    publishViewController = [[GFPublishVoteViewController alloc] initWithSelectedGroup:weakSelf.group];
                    [MobClick event:@"gf_gb_07_01_04_1"];
                    break;
                }
                case GFContentTypePicture: {
                    break;
                }
                default:
                    break;
            }
            [weakSelf presentViewController:[[GFNavigationController alloc] initWithRootViewController:publishViewController]
                                   animated:YES
                                 completion:NULL];
        }];
    } else {
        GFGroupContentMTL *groupContentMTL = [self.groupContents objectAtIndex:indexPath.row];
        GFContentMTL *contentMTL = groupContentMTL.content;
        if (contentMTL.contentInfo.type == GFContentTypeArticle) { // 图文
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class]) forIndexPath:indexPath];
            [[(GFFeedContentCell *)cell userInfoHeader] setStyle:GFUserInfoHeaderStyleTag];
            [(GFFeedArticleCell *)cell bindWithModel:contentMTL];
            [(GFFeedArticleCell *)cell setTapImageHandler:^(GFFeedArticleCell *cell, NSUInteger iniImageIndex) {
                [weakSelf collectionView:collectionView didSelectItemAtIndexPath:indexPath];
            }];
            
            if (!collectionView.isDragging && !collectionView.isDecelerating) {
                [(GFFeedArticleCell *)cell startLoadingImages];
            }
            @weakify(self)
            [(GFFeedArticleCell *)cell setTapImageHandler:^(GFFeedContentCell *cell, NSUInteger iniImageIndex) {
                @strongify(self)
                GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
                NSString *iniPictureKey = [articleSummary.pictureSummary objectAtIndex:iniImageIndex];
                GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:contentMTL.pictures
                                                                                  orderKeys:articleSummary.pictureSummary
                                                                                 initialKey:iniPictureKey
                                                                                   delegate:cell];
                [imageGroupView presentToContainer:self.navigationController.view animated:YES completion:nil];
                
            }];
            
        } else if (contentMTL.contentInfo.type == GFContentTypeVote) { // 投票
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class]) forIndexPath:indexPath];
            [[(GFFeedContentCell *)cell userInfoHeader] setStyle:GFUserInfoHeaderStyleTag];
            [(GFFeedVoteCell *)cell bindWithModel:contentMTL];
        } else if (contentMTL.contentInfo.type == GFContentTypeLink) { // 链接
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class]) forIndexPath:indexPath];
            [[(GFFeedContentCell *)cell userInfoHeader] setStyle:GFUserInfoHeaderStyleTag];
            [(GFFeedLinkCell *)cell bindWithModel:contentMTL];
        } else if (contentMTL.contentInfo.type == GFContentTypePicture) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class]) forIndexPath:indexPath];
            [[(GFFeedContentCell *)cell userInfoHeader] setStyle:GFUserInfoHeaderStyleTag];
            [(GFFeedPictureCell *)cell bindWithModel:contentMTL];
            if (!collectionView.isDragging && !collectionView.isDecelerating) {
                [(GFFeedPictureCell *)cell startLoadingImages];
            }
            @weakify(self)
            [(GFFeedPictureCell*)cell setTapImageHandler:^(GFFeedPictureCell *cell, NSUInteger iniImageIndex) {
                @strongify(self)
                GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
                NSString *iniPictureKey = [articleSummary.pictureSummary objectAtIndex:iniImageIndex];
                GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:contentMTL.pictures
                                                                                  orderKeys:articleSummary.pictureSummary
                                                                                 initialKey:iniPictureKey
                                                                                   delegate:cell];
                [imageGroupView presentToContainer:self.navigationController.view animated:YES completion:nil];
            }];
            
        }
        
        BOOL hasRead = [self.readContents containsObject:contentMTL.contentInfo.contentId];
        if (hasRead) {
            [(GFFeedContentCell *)cell markRead];
        }
        
        [[(GFFeedContentCell *)cell userInfoHeader] setTagHandler:^{
            GFTagInfoMTL *tagMTL = [contentMTL.tags objectAtIndex:0];
            if (tagMTL.tagId) {
                GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tagMTL.tagId];
                [self.navigationController pushViewController:tagDetailViewController animated:YES];
            }
        }];
        [[(GFFeedContentCell *)cell userInfoHeader] setAvatarHandler:^{
            GFUserMTL *user = contentMTL.user;
            GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }];
        [(GFFeedContentCell *)cell setFloatFunHandler:^(GFContentMTL *content) {
            switch (content.contentInfo.type) {
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_gb_07_03_01_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_gb_07_03_03_1"];
                    break;
                }
                case GFContentTypeLink: {
                    [MobClick event:@"gf_gb_07_03_02_1"];
                    break;
                }
                case GFContentTypePicture: {
                    break;
                }
                case GFContentTypeUnknown:{
                    break;
                }
            }
            [weakSelf.contentCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
    }
       return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    GFPublishInfoHeader *publishInfoHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFPublishInfoHeader class]) forIndexPath:indexPath];
    publishInfoHeader.retryHandler = ^() {
        [GFPublishManager retryFailedTaskWithGroupId:self.group.groupInfo.groupId];
        [self.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
    };
    publishInfoHeader.deleteHandler = ^() {
        [GFPublishManager removeFailedTaskWithGroupId:self.group.groupInfo.groupId];
        [weakSelf.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
    };
    
    NSString *text = nil;
    NSArray *waitingTasks = [GFPublishManager waitingTaskWithGroupId:self.group.groupInfo.groupId];
    NSArray *failedTasks = [GFPublishManager failedTaskListWithGroupId:self.group.groupInfo.groupId];
    if ([failedTasks count] > 0) {
        text = [NSString stringWithFormat:@"您有%@条帖子未发送", @([failedTasks count])];
        [publishInfoHeader showRetryAndDeleteButton:YES];
    }
    if([waitingTasks count] > 0) {
        text = [NSString stringWithFormat:@"您有%@条帖子正在发送", @([waitingTasks count])];
        [publishInfoHeader showRetryAndDeleteButton:NO];
    }
    
    [publishInfoHeader setInfoText:text];
    return publishInfoHeader;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (section == 1 || section == 2) {
        insets = UIEdgeInsetsMake(10, 0, 0, 0);
    }
    return insets;
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    CGSize size = CGSizeZero;
//    return size;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize size = CGSizeZero;
    
    NSArray *failedTasks = [GFPublishManager failedTaskListWithGroupId:self.group.groupInfo.groupId];
    NSArray *waitingTasks = [GFPublishManager waitingTaskWithGroupId:self.group.groupInfo.groupId];
    if (section == 2 && ([failedTasks count] > 0 || [waitingTasks count] > 0)) {
        size = CGSizeMake(collectionView.width, 58);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    if (indexPath.section == 0) {
        height = [GFGroupInfoCell heightWithModel:self.group];
    } else if (indexPath.section == 1) {
        height = [GFGroupPublishCell heightWithModel:nil];
    } else {
        id model = [self.groupContents objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[GFGroupContentMTL class]]) {
            GFContentMTL *contentMTL = [(GFGroupContentMTL*)model content];
            switch (contentMTL.contentInfo.type) {
                case GFContentTypeArticle: {
                    height = [GFFeedArticleCell heightWithModel:contentMTL];
                    break;
                }
                case GFContentTypeLink: {
                    height = [GFFeedLinkCell heightWithModel:contentMTL];
                    break;
                }
                case GFContentTypeVote: {
                    height = [GFFeedVoteCell heightWithModel:contentMTL];
                    break;
                }
                case GFContentTypePicture: {
                    height = [GFFeedPictureCell heightWithModel:contentMTL];
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }
    
    return CGSizeMake(collectionView.width, height);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GFGroupInfoViewController *controller = [[GFGroupInfoViewController alloc] initWithGroup:self.group];
        controller.quitGroupHandler = self.quitGroupHandler;
        [self.navigationController pushViewController: controller animated:YES];
    } else if (indexPath.section == 2) {
        
        GFGroupContentMTL *groupContentMTL = [self.groupContents objectAtIndex:indexPath.row];
        GFContentMTL *content = groupContentMTL.content;
        
        switch (content.contentInfo.type) {
            case GFContentTypeArticle: {
                [MobClick event:@"gf_gb_07_02_01_1"];
                break;
            }
            case GFContentTypeVote: {
                [MobClick event:@"gf_gb_07_02_03_1"];
                break;
            }
            case GFContentTypeLink: {
                [MobClick event:@"gf_gb_07_02_02_1"];
                break;
            }
            case GFContentTypePicture: {
                break;
            }
            case GFContentTypeUnknown:{
                break;
            }
        }
        
        NSNumber *contentId = content.contentInfo.contentId;
        if (contentId) {
            
            [self.readContents addObject:contentId];
            GFFeedContentCell *cell = (GFFeedContentCell *)[self.contentCollectionView cellForItemAtIndexPath:indexPath];
            [cell markRead];
            
            if ([content isGetfunLesson]) {
                GFLessonViewController *lessonViewController = [[GFLessonViewController alloc] initWithContent:content];
                [self.navigationController pushViewController:lessonViewController animated:YES];
            } else {
                
                GFContentDetailViewController *controller = [[GFContentDetailViewController alloc] initWithContent:content preview:NO keyFrom:GFKeyFromGroup];
                
                __weak typeof(self) weakSelf = self;
                controller.deleteContentHandler = ^(GFContentMTL *contentMTL) {
                    
                    @synchronized (weakSelf.groupContents) {
                        GFGroupContentMTL *groupContentMTL = [weakSelf.groupContents bk_match:^BOOL(id obj) {
                            return content.contentInfo.contentId && [((GFGroupContentMTL*)obj).content.contentInfo.contentId isEqualToNumber:content.contentInfo.contentId];
                        }];
                        NSInteger index = [weakSelf.groupContents indexOfObject:groupContentMTL];
                        [weakSelf.groupContents removeObjectAtIndex:index];
                        
                        if ([weakSelf.groupContents count] == 0) {
                            [weakSelf.contentCollectionView deleteSections:[NSIndexSet indexSetWithIndex:2]];
                        }else{
                            [weakSelf.contentCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:2]]];
                        }
                    }
                };
                
                controller.voteHandler = ^(GFContentMTL *content, BOOL left) {
                    
                    @synchronized (weakSelf.groupContents) {
                        GFGroupContentMTL *groupContentMTL = [weakSelf.groupContents bk_match:^BOOL(id obj) {
                            return content.contentInfo.contentId && [((GFGroupContentMTL*)obj).content.contentInfo.contentId isEqualToNumber:content.contentInfo.contentId];
                        }];
                        NSInteger index = [weakSelf.groupContents indexOfObject:groupContentMTL];
                        
                        groupContentMTL.content.contentInfo.funCount = content.contentInfo.funCount;
                        groupContentMTL.content.contentInfo.commentCount = content.contentInfo.commentCount;
                        groupContentMTL.content.actionStatuses = content.actionStatuses;
                        
                        GFContentMTL *contentMTL = groupContentMTL.content;
                        
                        contentMTL.actionStatuses = content.actionStatuses;
                        GFContentSummaryVoteMTL *voteSummary = (GFContentSummaryVoteMTL *)contentMTL.contentSummary;
                        GFContentDetailVoteMTL *voteDetail = (GFContentDetailVoteMTL *)content.contentDetail;
                        voteSummary.voteItems = voteDetail.voteItems;
                        
                        [weakSelf.contentCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:2]]];
                    }
                };
                
                controller.commentAndFunHandler = ^(GFContentMTL *content) {
                    
                    @synchronized (weakSelf.groupContents) {
                        GFGroupContentMTL *groupContentMTL = [weakSelf.groupContents bk_match:^BOOL(id obj) {
                            return content.contentInfo.contentId && [((GFGroupContentMTL*)obj).content.contentInfo.contentId isEqualToNumber:content.contentInfo.contentId];
                        }];
                        
                        NSInteger index = [weakSelf.groupContents indexOfObject:groupContentMTL];
                        
                        groupContentMTL.content.contentInfo.funCount = content.contentInfo.funCount;
                        groupContentMTL.content.contentInfo.commentCount = content.contentInfo.commentCount;
                        groupContentMTL.content.actionStatuses = content.actionStatuses;
                        
                        [weakSelf.contentCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:2]]];
                    }
                };
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat navBarAlpha = 0.0f;
    CGFloat navTitleAlpha = 0.0f;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= SCROLL_VIEW_INI_OFFSET_Y && offsetY <= NAV_BAR_CHANGE_THRESHOLD) {
        navBarAlpha = (offsetY - SCROLL_VIEW_INI_OFFSET_Y) / (-SCROLL_VIEW_INI_OFFSET_Y);
        [self setBackBarButtonItemStyle:GFBackBarButtonItemStyleBackLight];
        self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    } else if (offsetY > NAV_BAR_CHANGE_THRESHOLD) {
        navBarAlpha = 1.0f;
        navTitleAlpha = 1.0f;
        [self setBackBarButtonItemStyle:GFBackBarButtonItemStyleBackDark];
        self.gf_StatusBarStyle = UIStatusBarStyleDefault;
    }
    
    self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:navTitleAlpha];
    [self gf_setNavBarBackgroundTransparent:navBarAlpha];
    
    if ((-250) - scrollView.contentOffset.y > 50 && scrollView.isDragging && self.refreshImageView.hidden == YES) {
        [self doRefreshAnimate];
        self.refreshImageView.hidden = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        for (UICollectionViewCell *cell in [self.contentCollectionView visibleCells]) {
            if ([cell isKindOfClass:[GFFeedArticleCell class]] || [cell isKindOfClass:[GFFeedPictureCell class]]) {
                [cell performSelector:@selector(startLoadingImages)];
            }
        }
    }
    
    if ((-250) - scrollView.contentOffset.y < 25) {
        self.refreshImageView.hidden = YES;
        [self stopRefreshAnimate];
    } else {
        [self queryContent:YES];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    for (UICollectionViewCell *cell in [self.contentCollectionView visibleCells]) {
        if ([cell isKindOfClass:[GFFeedArticleCell class]] || [cell isKindOfClass:[GFFeedPictureCell class]]) {
            [cell performSelector:@selector(startLoadingImages)];
        }
    }
}

- (void)doRefreshAnimate {
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    [CATransaction setValue:[NSNumber numberWithFloat:0.5] forKey:kCATransactionAnimationDuration];
    
    CABasicAnimation* rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 ];
    rotateAnimation.repeatCount = HUGE_VAL;
    [self.refreshImageView.layer addAnimation:rotateAnimation forKey:@"rotationAnimation"];
    
    [CATransaction commit];
}

- (void)stopRefreshAnimate {
    [self.refreshImageView.layer removeAnimationForKey:@"rotationAnimation"];
}


- (void)didPublishedContentChanged:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    if ([notification.name isEqualToString:GFNotificationPublishStateUpdate]) {
        id updateModel = [userInfo objectForKey:kPublishNotificationUserInfoKeyData];
        if ([updateModel isKindOfClass:[GFContentMTL class]]) {
            GFPublishMTL *originTask = [userInfo objectForKey:kPublishNotificationUserInfoKeyOrigin];
            if (self.group.groupInfo.groupId && [originTask.groupId isEqualToNumber:self.group.groupInfo.groupId]) {
                GFGroupContentMTL *groupContent = [[GFGroupContentMTL alloc] init];
                groupContent.user = [GFAccountManager sharedManager].loginUser;
                groupContent.content = updateModel;
                groupContent.action = GFUserActionPublish;
                
                @synchronized (self.groupContents) {
                    [self.groupContents insertObject:groupContent atIndex:0];
                }
                [self.contentCollectionView reloadData];

//                if ([self.groupContents count] == 1) {
//                    [self.contentCollectionView reloadData];
//                } else {
//                    [self.contentCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]]];
//                }
            }
        } else  if([updateModel isKindOfClass:[GFPublishMTL class]]){
            GFPublishMTL *updatePublishMTL = updateModel;
            if (self.group.groupInfo.groupId && [updatePublishMTL.groupId isEqualToNumber:self.group.groupInfo.groupId]) {
                GFPublishState state = [updatePublishMTL.state integerValue];
                if (state == GFPublishStateFailed) {
                    
                    NSString *msg = [userInfo objectForKey:kPublishNotificationUserInfoKeyMsg];
                    if (!msg) {
                        msg = @"未知错误";
                    }
                    
                    __weak typeof(self) weakSelf = self;
                    [UIAlertView bk_showAlertViewWithTitle:@"发布失败" message:msg cancelButtonTitle:@"我知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [weakSelf.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
                    }];
                } else if(state == GFPublishStateSending) { //提示发送中状态
                    [self.contentCollectionView reloadData];
                }
            }
        }
    }
}
@end
