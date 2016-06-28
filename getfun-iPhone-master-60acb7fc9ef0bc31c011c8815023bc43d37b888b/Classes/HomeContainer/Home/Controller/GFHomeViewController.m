//
//  GFHomeViewController.m
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFHomeViewController.h"
#import "GFAccountManager.h"
#import "GFNetworkManager+Content.h"
#import "GFLoginRegisterViewController.h"
#import "GFContentDetailViewController.h"
#import "GFFeedArticleCell.h"
#import "GFFeedLinkCell.h"
#import "GFFeedVoteCell.h"
#import "GFFeedPictureCell.h"
#import "GFFeedAdvertiseCell.h"
#import "GFContentMTL.h"
#import "AppDelegate.h"
#import "GFPathMenu.h"

#import "GFQRViewController.h"
#import "GFPublishVoteViewController.h"
#import "GFPublishPhotoViewController.h"
#import "GFPublishLinkViewController.h"
#import "GFPublishArticleViewController.h"
#import "GFTagDetailViewController.h"

#import "GFNetworkManager+Group.h"
#import "GFNetworkManager+Common.h"
#import "GFRecommendGroupCell.h"
#import "GFLocationManager.h"
#import "GFGroupMTL.h"
#import "GFGroupDetailViewController.h"
#import "GFGroupInfoViewController.h"
#import "GFProfileViewController.h"
#import "GFMyGroupViewController.h"
#import "GFNavigationController.h"
#import "GFPublishManager.h"
#import "GFTaskSuccessTipView.h"
#import "GFHomeUserGuideView.h"
#import "GFCacheUtil.h"
#import "GFImageGroupView.h"
#import "GFLessonViewController.h"
#import "GFPublishInfoHeader.h"

#import <AVFoundation/AVFoundation.h>
#import "GFSoundEffect.h"

#define GF_HOME_DATA_PERSISTENT_FILE @"homedatapersistent.file"

NSString * const GFUserDefaultsKeyFeedAdQueryTime = @"GFUserDefaultsKeyFeedAdQueryTime";        // 首页Feed流广告的获取时间
NSString * const GFUserDefaultsKeyFeedAdData = @"GFUserDefaultsKeyFeedAdData";                  // 首页Feed流广告数据
NSString * const GFUserDefaultsKeyLastVersionForHomeGuide = @"GFUserDefaultsKeyLastVersionForHomeGuide"; //用于用户引导提示标记，只有在有用户引导时才会使用，请勿删除！！

NSString * const GFUserDefaultsKeyVersionForHomePersistentData = @"GFUserDefaultsKeyVersionForHomePersistentData";

typedef NS_ENUM(NSInteger, GFHomeLoadPosition) {
    GFHomeLoadPositionNone = 0,
    GFHomeLoadPositionDefault = 1,
    GFHomeLoadPositionTop = 2,
    GFHomeLoadPositionBottom = 3
};

@interface GFRefreshFooter : UICollectionReusableView
@property (nonatomic, copy) void(^refreshHandler)();
@end

@interface GFRefreshFooter ()
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation GFRefreshFooter

-(UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSDictionary *textAttributes1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:15.0],NSFontAttributeName,
                                        [UIColor textColorValue1],NSForegroundColorAttributeName,nil];
        NSDictionary *textAttributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:15.0],NSFontAttributeName,
                                        [UIColor textColorValue7],NSForegroundColorAttributeName,nil];
        
        NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString: @"上次看到这了，" attributes:textAttributes1];
        NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString: @"点击刷新" attributes:textAttributes2];
        [attrString1 appendAttributedString:attrString2];
        _textLabel.attributedText = attrString1;
        [_textLabel sizeToFit];
        _textLabel.center = self.refreshButton.center;
    }
    return _textLabel;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.frame = self.bounds;
    }
    return _refreshButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.refreshButton];
        [self addSubview:self.textLabel];
        __weak typeof(self) weakSelf = self;
        [self.refreshButton bk_addEventHandler:^(id sender) {
            if (weakSelf.refreshHandler) {
                weakSelf.refreshHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
@end

@interface GFHomeViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
GFPathMenuDelegate>

@property (nonatomic, strong) UICollectionView *homeCollectionView;

@property (nonatomic, strong) NSMutableArray<GFAdFeedMTL *> *advertises;

@property (nonatomic, strong) NSArray<GFGroupMTL *> *groupList;
@property (nonatomic, strong) NSMutableArray *fetchedContentList; // 服务器拉取的数据，以及本地发布数据
@property (nonatomic, strong) NSMutableArray *mergedHomeDataSource;

@property (nonatomic, strong) GFPathMenu *pathMenu;

@property (nonatomic, strong) UIImageView *noContentImageView; //没有数据时进行提示
@property (nonatomic, strong) NSMutableArray *readContents;

@end

@implementation GFHomeViewController
- (UICollectionView *)homeCollectionView {
    if (!_homeCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
            layout.sectionHeadersPinToVisibleBounds = YES;
        }
        _homeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) collectionViewLayout:layout];
        _homeCollectionView.scrollsToTop = YES;
        _homeCollectionView.backgroundColor = [UIColor clearColor];
        _homeCollectionView.delegate = self;
        _homeCollectionView.dataSource = self;
        [_homeCollectionView registerClass:[GFFeedArticleCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class])];
        [_homeCollectionView registerClass:[GFFeedLinkCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class])];
        [_homeCollectionView registerClass:[GFFeedVoteCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class])];
        [_homeCollectionView registerClass:[GFFeedPictureCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class])];
        [_homeCollectionView registerClass:[GFFeedAdvertiseCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedAdvertiseCell class])];
        [_homeCollectionView registerClass:[GFRecommendGroupCell class] forCellWithReuseIdentifier:NSStringFromClass([GFRecommendGroupCell class])];
        [_homeCollectionView registerClass:[GFPublishInfoHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFPublishInfoHeader class])];
        [_homeCollectionView registerClass:[GFRefreshFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([GFRefreshFooter class])];
    }
    return _homeCollectionView;
}

- (NSMutableArray <GFAdFeedMTL *> *)advertises {
    if (!_advertises) {
        NSArray *tmpAdList = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyFeedAdData];
        if (tmpAdList) {
            _advertises = [[MTLJSONAdapter modelsOfClass:[GFAdFeedMTL class] fromJSONArray:tmpAdList error:nil] mutableCopy];
        }
        if (!_advertises) {
            _advertises = [[NSMutableArray alloc] initWithCapacity:0];
        }
    }
    return _advertises;
}

- (NSMutableArray *)fetchedContentList {
    if (!_fetchedContentList) {
        _fetchedContentList = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSString *path = [GFCacheUtil gf_persistentPath];
        if (path) {
            NSString *file = [path stringByAppendingPathComponent:GF_HOME_DATA_PERSISTENT_FILE];
            NSArray *persistentData = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
            if (persistentData && [persistentData count] > 0) {
                [_fetchedContentList addObjectsFromArray:persistentData];
            }
        }
    }
    return _fetchedContentList;
}

- (NSMutableArray *)mergedHomeDataSource {
    if (!_mergedHomeDataSource) {
        _mergedHomeDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _mergedHomeDataSource;
}

- (GFPathMenu *)pathMenu {
    if (!_pathMenu) {
        _pathMenu = [GFPathMenu defaultPathMenu];
        _pathMenu.menuDelegate = self;
    }
    return _pathMenu;
}

- (UIImageView *)noContentImageView {
    if (!_noContentImageView) {
        _noContentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_no_content_by_network"]];
        [_noContentImageView sizeToFit];
        _noContentImageView.center = CGPointMake(self.view.width/2, self.view.height/2);
        _noContentImageView.hidden = YES;
    }
    return _noContentImageView;
}

- (NSMutableArray *)readContents {
    if (!_readContents) {
        _readContents = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _readContents;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self hideFooterImageView:YES];
    
    NSString *lastVersionForData = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyVersionForHomePersistentData];
    if (!lastVersionForData || APP_VERSION_GREATER_THAN(lastVersionForData)) {
        // 将上一版本的首页数据清空
        [self removeData];
        [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyFeedAdData];
        [GFUserDefaultsUtil setObject:APP_VERSION forKey:GFUserDefaultsKeyVersionForHomePersistentData];
    }
    
    [self doMergeHomeDataSourcePosition:GFHomeLoadPositionNone contents:self.fetchedContentList];
    
    [self.view addSubview:self.noContentImageView];
    [self.view addSubview:self.homeCollectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPublishedContentChanged:) name:GFNotificationPublishStateUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLocationUpdated:) name:GFNotificationLocationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData) name:UIApplicationWillResignActiveNotification object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.homeCollectionView addPullToRefreshWithActionHandler:^{
        [GFSoundEffect playSoundEffect:GFSoundEffectTypeSuccess];
        [weakSelf queryHomeContent:GFHomeLoadPositionTop];
        [weakSelf queryRecommendGroupList];
    }];
    [self.homeCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryHomeContent:GFHomeLoadPositionBottom];
    }];
    self.homeCollectionView.showsInfiniteScrolling = NO;
    
    [self.pathMenu setDcButtonCenter:CGPointMake(self.view.width/2, self.view.height-44)];
    [self.navigationController.view addSubview:self.pathMenu];
//    [self.view addSubview:self.pathMenu];
    [self queryFeedAdvertise];
    
    if ([self.mergedHomeDataSource count] < 5) {
         [self queryHomeContent:GFHomeLoadPositionDefault];
    }
    
    [self queryRecommendGroupList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.pathMenu.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.pathMenu.hidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GFNotificationPublishStateUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GFNotificationLocationUpdated object:nil];
}

#pragma mark - Methods
- (void)saveAdvertise {
    if ([self.advertises count] > 0) {
            NSArray *tmpAdvertise = [MTLJSONAdapter JSONArrayFromModels:self.advertises];
            
            [GFUserDefaultsUtil setObject:tmpAdvertise forKey:GFUserDefaultsKeyFeedAdData];
    }
}

- (void)saveData {
    @synchronized (self.fetchedContentList) {
        @synchronized (self.mergedHomeDataSource) {
            NSString *path = [GFCacheUtil gf_persistentPath];
            if (path) {
                NSString *file = [path stringByAppendingPathComponent:GF_HOME_DATA_PERSISTENT_FILE];
                NSMutableArray *dataToPersistent = [[NSMutableArray alloc] initWithCapacity:10];
                for (id obj in self.fetchedContentList) {
                    if ([obj isKindOfClass:[GFContentMTL class]]) {
                        [dataToPersistent addObject:obj];
                        if ([dataToPersistent count] == 10) {
                            break;
                        }
                    }
                }
                
                if ([dataToPersistent count] < 10) {
                    for (id obj in self.mergedHomeDataSource) {
                        if ([obj isKindOfClass:[GFContentMTL class]]) {
                            [dataToPersistent addObject:obj];
                            if ([dataToPersistent count] == 10) {
                                break;
                            }
                        }
                    }
                }
                
                [NSKeyedArchiver archiveRootObject:dataToPersistent toFile:file];
            }
        }
    }
}

- (void)removeData {
    NSString *path = [GFCacheUtil gf_persistentPath];
    if (path) {
        NSString *file = [path stringByAppendingPathComponent:GF_HOME_DATA_PERSISTENT_FILE];
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
}

- (void)showSuccessTipWithText:(NSString *)text {
    GFTaskSuccessTipView *tipView = [GFTaskSuccessTipView tipViewWithTitle:text];
    tipView.center = CGPointMake(self.view.width/2, 64 + 10 + tipView.height/2);
    tipView.alpha = 0.0f;
    [self.view addSubview:tipView];
    
    [UIView animateWithDuration:0.5f animations:^{
        tipView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
            tipView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [tipView removeFromSuperview];
        }];
    }];
}

- (void)queryFeedAdvertise {
    
    NSTimeInterval lastQueryTime = [[GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyFeedAdQueryTime] doubleValue];
    NSDate *lastQueryDate = [NSDate dateWithTimeIntervalSince1970:lastQueryTime];
    if ([lastQueryDate isToday]) {
        return;
    }
    @synchronized (self.advertises) {
        [self.advertises removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getFeedAdvertiseListSuccess:^(NSUInteger taskId, NSInteger code, NSArray<GFAdFeedMTL *> *advertises) {
        if (code == 1) {
            NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
            [GFUserDefaultsUtil setObject:[NSNumber numberWithDouble:nowTimeInterval] forKey:GFUserDefaultsKeyFeedAdQueryTime];
            if (advertises && [advertises count] > 0) {
                @synchronized (weakSelf.advertises) {
                    [weakSelf.advertises addObjectsFromArray:advertises];
                }
                [weakSelf saveAdvertise];
                [weakSelf.homeCollectionView reloadData];
            }
        }
    } failure:^(NSUInteger taskId, NSInteger code) {
        //
    }];
}


- (void)queryHomeContent:(GFHomeLoadPosition)position {

    MBProgressHUD *hud = nil;
    if (position == GFHomeLoadPositionDefault) {
        hud = [MBProgressHUD showLoadingHUDWithTitle:@"" inView:self.view];
    }
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager queryHomeContentSuccess:^(NSUInteger taskId, NSInteger code, NSArray<GFContentMTL *> *contentList) {
        if (hud) {
            [hud hide:YES];
        }
        
        [weakSelf.homeCollectionView finishPullToRefresh];
        [weakSelf.homeCollectionView finishInfiniteScrolling];
        
        if (code == 1 && contentList) {
            
            if (position == GFHomeLoadPositionTop) {
                
                // 下拉刷新数据，移除一个广告显示下一个
                if ([weakSelf.advertises count] > 0) {
                    @synchronized (weakSelf.advertises) {
                        [weakSelf.advertises removeObjectAtIndex:0];
                    }
                    [weakSelf saveAdvertise];
                }
                
                [weakSelf showSuccessTipWithText:contentList.count > 0? [NSString stringWithFormat:@"成功为您推荐%@条新内容", @(contentList.count)] : @"暂时没有新内容~"];
            }
            
            [weakSelf doMergeHomeDataSourcePosition:position contents:contentList];
            
            weakSelf.noContentImageView.hidden = ([weakSelf.fetchedContentList count] > 0 || [weakSelf.mergedHomeDataSource count] > 0);
            
            weakSelf.homeCollectionView.showsInfiniteScrolling = YES;
            
            [weakSelf.homeCollectionView reloadData];            
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        if (hud) {
            [hud hide:YES];
        }
        [weakSelf.homeCollectionView finishPullToRefresh];
        [weakSelf.homeCollectionView finishInfiniteScrolling];
        
        weakSelf.homeCollectionView.showsInfiniteScrolling
        = weakSelf.noContentImageView.hidden
        = [self.fetchedContentList count] > 0 || [self.mergedHomeDataSource count] > 0;
    }];
}

- (void)queryRecommendGroupList {
    CLLocation *location = [GFLocationManager lastLocation];
    if (location) {
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager getRecommendGroupWithLongitude:@(location.coordinate.longitude) latitude:@(location.coordinate.latitude) success:^(NSUInteger taskId, NSInteger code, NSArray<GFGroupMTL *> *groupList, NSString *errorMessage) {
            
            [weakSelf.homeCollectionView finishPullToRefresh];
            [weakSelf.homeCollectionView finishInfiniteScrolling];
            
            if (code == 1) {
                if (groupList && [groupList count] > 0) {
                    self.groupList = groupList;
                }
            }
        } failure:^(NSUInteger taskId, NSError *error) {
            NSLog(@"error:%@",error);
        }];
    }
}

- (id)findAdvertise:(NSArray *)sourceList {
    id advertise = nil;
    for (id obj in sourceList) {
        if ([obj isKindOfClass:[GFAdFeedMTL class]]) {
            advertise = obj;
            break;
        }
    }
    return advertise;
}

- (id)findGroupList:(NSArray *)sourceList {
    id groupList = nil;
    for (id obj in sourceList) {
        if ([obj isKindOfClass:[NSArray class]]) {
            id firstItem = [obj firstObject];
            if ([firstItem isKindOfClass:[GFGroupMTL class]]) {
                groupList = obj;
                break;
            }
        }
    }
    return groupList;
}

- (void)removeObjectFromDataSource:(id)obj {
    if ([self.fetchedContentList containsObject:obj]) {
        @synchronized (self.fetchedContentList) {
            [self.fetchedContentList removeObject:obj];
        }
    } else if ([self.mergedHomeDataSource containsObject:obj]) {
        @synchronized (self.mergedHomeDataSource) {
            [self.mergedHomeDataSource removeObject:obj];
        }
    }
}

- (void)doMergeHomeDataSourcePosition:(GFHomeLoadPosition)position
                             contents:(NSArray<GFContentMTL *> *)contents {
    
    @synchronized (self.fetchedContentList) {
        @synchronized (self.mergedHomeDataSource) {
            
            {
                // 移除广告数据
                id ad = [self findAdvertise:self.fetchedContentList];
                if (ad) {
                    [self.fetchedContentList removeObject:ad];
                } else {
                    ad = [self findAdvertise:self.mergedHomeDataSource];
                    if (ad) {
                        [self.mergedHomeDataSource removeObject:ad];
                    }
                }
                
                // 移除推荐Get帮
                id groups = [self findGroupList:self.fetchedContentList];
                if (groups) {
                    [self.fetchedContentList removeObject:groups];
                    
                } else {
                    groups = [self findGroupList:self.mergedHomeDataSource];
                    if (groups) {
                        [self.mergedHomeDataSource removeObject:groups];
                    }
                }
            }
            
            // 整理普通帖子列表
            switch (position) {
                case GFHomeLoadPositionNone: {
                    [self.mergedHomeDataSource insertObjects:self.fetchedContentList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.fetchedContentList count])]];
                    [self.fetchedContentList removeAllObjects];
                    
                    break;
                }
                case GFHomeLoadPositionDefault:
                case GFHomeLoadPositionTop: {
                    [self.mergedHomeDataSource insertObjects:self.fetchedContentList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.fetchedContentList count])]];
                    [self.fetchedContentList removeAllObjects];
                    [self.fetchedContentList addObjectsFromArray:contents];
                    
                    break;
                }
                    // 底部加载数据
                case GFHomeLoadPositionBottom: {
                    [self.mergedHomeDataSource insertObjects:self.fetchedContentList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.fetchedContentList count])]];
                    [self.fetchedContentList removeAllObjects];
                    [self.mergedHomeDataSource addObjectsFromArray:contents];
                    break;
                }
            }
            
            {
                if (position != GFHomeLoadPositionBottom) {
                    // 添加广告数据
                    if ([self.advertises count] > 0) {
                        id ad = [self.advertises objectAtIndex:0];
                        
                        if ([self.fetchedContentList count] > 7) {
                            [self.fetchedContentList insertObject:ad atIndex:7];
                        } else if ([self.fetchedContentList count] + [self.mergedHomeDataSource count] > 7) {
                            NSInteger index = [self.mergedHomeDataSource count] - 7;
                            [self.mergedHomeDataSource insertObject:ad atIndex:index];
                        } else {
                            [self.mergedHomeDataSource addObject:ad];
                        }
                    }
                }
                
                // 添加推荐Get帮
                if (self.groupList) {
                    if ([self.fetchedContentList count] > 11) {
                        [self.fetchedContentList insertObject:self.groupList atIndex:11];
                    } else if ([self.fetchedContentList count] + [self.mergedHomeDataSource count] > 11) {
                        NSInteger index = [self.mergedHomeDataSource count] - 11;
                        [self.mergedHomeDataSource insertObject:self.groupList atIndex:index];
                    } else {
                        [self.mergedHomeDataSource addObject:self.groupList];
                    }
                }
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numberOfSections = 0;
    if ([self.fetchedContentList count] > 0) {
        numberOfSections ++;
    }
    if ([self.mergedHomeDataSource count] > 0) {
        numberOfSections ++;
    }
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    if (section == 0 && [self.fetchedContentList count] > 0) {
        numberOfItems = [self.fetchedContentList count];
    } else {
        numberOfItems = [self.mergedHomeDataSource count];
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = nil;
    if (indexPath.section == 0 && [self.fetchedContentList count] > 0) {
        model = [self.fetchedContentList objectAtIndex:indexPath.row];
    } else {
        model = [self.mergedHomeDataSource objectAtIndex:indexPath.row];
    }
    
    GFBaseCollectionViewCell *cellToUse = nil;
    
    __weak typeof(self) weakSelf = self;
    if ([model isKindOfClass:[GFContentMTL class]]) { // 普通卡片
        GFContentMTL *contentMTL = model;
        if (contentMTL.contentInfo.type == GFContentTypeArticle) { // 图文
            GFFeedArticleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class]) forIndexPath:indexPath];
            [cell.userInfoHeader setStyle:GFUserInfoHeaderStyleTag];
            [cell bindWithModel:model];
            if (!collectionView.isDragging && !collectionView.isDecelerating) {
                [cell startLoadingImages];
            }
            @weakify(self)
            cell.tapImageHandler = ^(GFFeedContentCell *cell, NSUInteger iniImageIndex) {
                @strongify(self)
                [MobClick event:@"gf_sy_01_01_06_1"];
                GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
                NSString *iniPictureKey = [articleSummary.pictureSummary objectAtIndex:iniImageIndex];
                GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:contentMTL.pictures
                                                                                  orderKeys:articleSummary.pictureSummary
                                                                                 initialKey:iniPictureKey
                                                                                   delegate:cell];
                [imageGroupView presentToContainer:self.navigationController.view animated:YES completion:nil];            };
            cellToUse = cell;
        } else if (contentMTL.contentInfo.type == GFContentTypeVote) { // 投票
            GFFeedVoteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class]) forIndexPath:indexPath];
            [cell.userInfoHeader setStyle:GFUserInfoHeaderStyleTag];
            [cell bindWithModel:model];
            cellToUse = cell;
        } else if (contentMTL.contentInfo.type == GFContentTypeLink) { // 链接
            GFFeedLinkCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class]) forIndexPath:indexPath];
            [cell.userInfoHeader setStyle:GFUserInfoHeaderStyleTag];
            [cell bindWithModel:model];
            cellToUse = cell;
        } else if (contentMTL.contentInfo.type == GFContentTypePicture) { // 图片类型
            GFFeedPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class]) forIndexPath:indexPath];
            [cell.userInfoHeader setStyle:GFUserInfoHeaderStyleTag];
            [cell bindWithModel:model];
            if (!collectionView.isDragging && !collectionView.isDecelerating) {
                [cell startLoadingImages];
            }
            @weakify(self)
            cell.tapImageHandler = ^(GFFeedContentCell *cell, NSUInteger iniImageIndex) {
                @strongify(self)
                [MobClick event:@"gf_sy_01_07_05_1"];
                
                GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
                NSString *iniPictureKey = [articleSummary.pictureSummary objectAtIndex:iniImageIndex];
                GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:contentMTL.pictures
                                                                                  orderKeys:articleSummary.pictureSummary
                                                                                 initialKey:iniPictureKey
                                                                                   delegate:cell];
                [imageGroupView presentToContainer:self.navigationController.view animated:YES completion:nil];
            };
            cellToUse = cell;
        }
        
        BOOL hasRead = [self.readContents containsObject:contentMTL.contentInfo.contentId];
        if (hasRead) {
            [(GFFeedContentCell *)cellToUse markRead];
        }
        
        [[(GFFeedContentCell *)cellToUse userInfoHeader] setAvatarHandler:^{
            GFContentMTL *content = model;
            switch (content.contentInfo.type) {
                case GFContentTypeUnknown:{
                    break;
                }
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_sy_01_01_01_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_sy_01_03_01_1"];
                    break;
                }
                case GFContentTypeLink: {
                    [MobClick event:@"gf_sy_01_02_01_1"];
                    break;
                }
                case GFContentTypePicture: {
                    [MobClick event:@"gf_sy_01_07_01_1"];
                    break;
                }
            }
            
            GFUserMTL *user = content.user;
            GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
            [weakSelf.navigationController pushViewController:profileViewController animated:YES];
        }];
        [[(GFFeedContentCell *)cellToUse userInfoHeader] setTagHandler:^{
            GFContentMTL *content = model;
            switch (content.contentInfo.type) {
                case GFContentTypeUnknown:{
                    break;
                }
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_sy_01_01_04_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_sy_01_03_04_1"];
                    break;
                }
                case GFContentTypeLink: {
                    [MobClick event:@"gf_sy_01_02_04_1"];
                    break;
                }
                case GFContentTypePicture: {
                    [MobClick event:@"gf_sy_01_07_03_1"];
                    break;
                }
            }
            
            GFTagInfoMTL *tagMTL = [contentMTL.tags objectAtIndex:0];
            if (tagMTL.tagId) {
                GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tagMTL.tagId];
                [weakSelf.navigationController pushViewController:tagDetailViewController animated:YES];
            }
        }];
        
        [(GFFeedContentCell *)cellToUse setFloatFunHandler:^(GFContentMTL *contentMTL) {
            GFContentMTL *content = model;
            switch (content.contentInfo.type) {
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_sy_01_01_05_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_sy_01_03_05_1"];
                    break;
                }
                case GFContentTypeLink: {
                    [MobClick event:@"gf_sy_01_02_05_1"];
                    break;
                }
                case GFContentTypePicture: {
                    [MobClick event:@"gf_sy_01_07_04_1"];
                    break;
                }
                case GFContentTypeUnknown:{
                    break;
                }
            }
            
            [weakSelf.homeCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];

    } else if ([model isKindOfClass:[NSArray class]]) {
        id obj = [(NSArray *)model firstObject];
        if ([obj isKindOfClass:[GFGroupMTL class]]) {    // 推荐get帮
            
            void(^groupSelectHandler)(GFRecommendGroupCell *, GFRecommendGroupView *) = ^(GFRecommendGroupCell *cell, GFRecommendGroupView *itemView) {
                NSString *eventID = nil;
                if (itemView.tag + 2 < 10) {
                    eventID = [NSString stringWithFormat:@"gf_sy_01_05_0%ld_1", (long)itemView.tag+2];
                } else {
                    eventID = [NSString stringWithFormat:@"gf_sy_01_05_%ld_1", (long)itemView.tag+2];
                }
                [MobClick event:eventID];
                
                __weak typeof(self) weakSelf = self;
                GFGroupMTL *group = itemView.group;
                [GFNetworkManager getGroupWithGroupId:group.groupInfo.groupId
                                              success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                                  if (code == 1) {
                                                      //根据是否加入跳转到不同视图
                                                      if (group.joined) {
                                                          GFGroupDetailViewController *controller = [[GFGroupDetailViewController alloc] initWithGroup:group];
                                                          [weakSelf.navigationController pushViewController:controller animated:YES];
                                                      } else {
                                                          GFGroupInfoViewController *controller = [[GFGroupInfoViewController alloc] initWithGroup:group];
                                                          [weakSelf.navigationController pushViewController:controller animated:YES];
                                                      }
                                                  }
                                              } failure:^(NSUInteger taskId, NSError *error) {
                                                  
                                              }];
            };
            void(^rightButtonHandler)(GFRecommendGroupCell *) = ^(GFRecommendGroupCell *cell) {
                [MobClick event:@"gf_sy_01_05_01_1"];
                __weak typeof(self) weakSelf = self;
                [GFAccountManager checkLoginStatus:YES
                                   loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                                       if (user) {
                                           GFMyGroupViewController *myGroupViewController = [[GFMyGroupViewController alloc] init];
                                           [weakSelf.navigationController pushViewController:myGroupViewController animated:YES];
                                       } else {
                                           [MBProgressHUD showHUDWithTitle:@"登录后才能查看我的Get帮" duration:kCommonHudDuration inView:self.view];
                                       }
                                   }];
            };
            
            GFRecommendGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFRecommendGroupCell class]) forIndexPath:indexPath];
            [cell setMaxItemCount:3];
            [cell bindWithModel:model style:GFRecommendGroupCellStyle_Home showRightTitle:YES];
            cell.groupSelectHandler = groupSelectHandler;
            cell.righButtonHandler = rightButtonHandler;
            cellToUse = cell;
        }
    } else if ([model isKindOfClass:[GFAdFeedMTL class]]) {
        
        __weak typeof(self) weakSelf = self;
        GFFeedAdvertiseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedAdvertiseCell class]) forIndexPath:indexPath];
        [cell bindWithModel:model];
        [cell setCloseHandler:^{
            [MobClick event:@"gf_sy_01_04_02_1"];
            if (weakSelf.advertises &&[weakSelf.advertises count] > 0) {
                @synchronized (weakSelf.advertises) {
                    [weakSelf.advertises removeObjectAtIndex:0];
                }
            }
            [weakSelf removeObjectFromDataSource:model];
            [weakSelf.homeCollectionView reloadData];
        }];
        cellToUse = cell;
    }
    
    return cellToUse;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        GFPublishInfoHeader *publishInfoHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFPublishInfoHeader class]) forIndexPath:indexPath];
        publishInfoHeader.retryHandler = ^() {
            [GFPublishManager retryAllFailedTask];            
            [self.homeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        };
        publishInfoHeader.deleteHandler = ^() {
            [GFPublishManager removeAllFailedTask];
            [weakSelf.homeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        };
        
        NSString *text = nil;
        NSArray *waitingTasks = [GFPublishManager allWaitingTask];
        NSArray *failedTasks = [GFPublishManager allFailedTask];
        if ([failedTasks count] > 0) {
            text = [NSString stringWithFormat:@"您有%lu条帖子未发送", (unsigned long)[failedTasks count]];
            [publishInfoHeader showRetryAndDeleteButton:YES];
        } else {
            text = [NSString stringWithFormat:@"您有%lu条帖子正在发送", (unsigned long)[waitingTasks count]];
            [publishInfoHeader showRetryAndDeleteButton:NO];
        }
        
        [publishInfoHeader setInfoText:text];
        return publishInfoHeader;
    } else {
        
        GFRefreshFooter *refreshFooter = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([GFRefreshFooter class]) forIndexPath:indexPath];
        refreshFooter.refreshHandler = ^() {
            [MobClick event:@"gf_sy_01_06_01_1"];
            
            [weakSelf.homeCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                        animated:NO];
            [weakSelf.homeCollectionView triggerPullToRefresh];
        };
        return refreshFooter;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (section == 0) {
        insets = UIEdgeInsetsMake(10, 0, 0, 0);
    }
    return insets;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    
    NSArray *failedTasks = [GFPublishManager allFailedTask];
    NSArray *waitingTasks = [GFPublishManager allWaitingTask];
    if (section == 0 && ([failedTasks count] > 0 || [waitingTasks count] > 0)) {
        size = CGSizeMake(collectionView.width, 58);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    CGSize size = CGSizeZero;
    if (section == 0 && [self.fetchedContentList count] > 0 && [self.mergedHomeDataSource count] > 0) {
        size = CGSizeMake(collectionView.width, 40);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    id model = nil;
    if (indexPath.section == 0 && [self.fetchedContentList count] > 0) {
        model = [self.fetchedContentList objectAtIndex:indexPath.row];
    } else {
        model = [self.mergedHomeDataSource objectAtIndex:indexPath.row];
    }
    
    if ([model isKindOfClass:[GFContentMTL class]]) {
        GFContentMTL *contentMTL = model;
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
    } else if ([model isKindOfClass:[NSArray class]]) {
        id obj = [(NSArray *)model firstObject];
        if ([obj isKindOfClass:[GFGroupMTL class]]) {
            height = [GFRecommendGroupCell heightWithModel:model maxItemCount:3];
        }
    } else if ([model isKindOfClass:[GFAdFeedMTL class]]) {
        height = [GFFeedAdvertiseCell heightWithModel:model];
    }
    
    return CGSizeMake(collectionView.width, height);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = nil;
    if (indexPath.section == 0 && [self.fetchedContentList count] > 0) {
        model = [self.fetchedContentList objectAtIndex:indexPath.row];
    } else {
        model = [self.mergedHomeDataSource objectAtIndex:indexPath.row];
    }
    
    if ([model isKindOfClass:[GFContentMTL class]]) {
        GFContentMTL *contentMTL = model;
        
        switch (contentMTL.contentInfo.type) {
            case GFContentTypeArticle: {
                [MobClick event:@"gf_sy_01_01_02_1"];
                break;
            }
            case GFContentTypeVote: {
                [MobClick event:@"gf_sy_01_03_02_1"];
                break;
            }
            case GFContentTypeLink: {
                [MobClick event:@"gf_sy_01_02_02_1"];
                break;
            }
            case GFContentTypePicture: {
                [MobClick event:@"gf_sy_01_07_02_1"];
                break;
            }
            case GFContentTypeUnknown:{
                break;
            }
        }
        
        NSNumber *contentId = contentMTL.contentInfo.contentId;
        if (!contentId) return;
        
        [self.readContents addObject:contentId];
        GFFeedContentCell *cell = (GFFeedContentCell *)[self.homeCollectionView cellForItemAtIndexPath:indexPath];
        [cell markRead];
        
        __weak typeof(self) weakSelf = self;
        void(^deleteContentHandler)(GFContentMTL *) = ^(GFContentMTL *content){

            @synchronized (weakSelf.fetchedContentList) {
                @synchronized (weakSelf.mergedHomeDataSource) {
                    NSInteger row = -1;
                    NSInteger section = -1;
                    if ([weakSelf.fetchedContentList containsObject:content]) {
                        row = [weakSelf.fetchedContentList indexOfObject:content];
                        section = 0;
                        [weakSelf.fetchedContentList removeObject:content];
                        
                    } else if ([weakSelf.mergedHomeDataSource containsObject:content]) {
                        row = [weakSelf.mergedHomeDataSource indexOfObject:content];
                        if ([weakSelf.fetchedContentList count] > 0) {
                            section = 1;
                        } else {
                            section = 0;
                        }
                        [weakSelf.mergedHomeDataSource removeObject:content];
                    }
                    
                    if (section >= 0) {
                        if ([self.fetchedContentList count] > 0) { //section 0删除后仍然有数据，同时存在section 0 和section 1
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                            [weakSelf.homeCollectionView deleteItemsAtIndexPaths:@[indexPath]];
                        } else { //section 0删除后没有数据，原来的section 1变成了section 0， 删除原来的section 0
                            [weakSelf.homeCollectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
                        }
                    }
                }
            }
        };
        void(^voteContentHandler)(GFContentMTL *, BOOL) = ^(GFContentMTL *content, BOOL left) {
            NSInteger row = -1;
            NSInteger section = -1;
            GFContentMTL *contentMTL = nil;
            
            if ([weakSelf.fetchedContentList containsObject:content]) {
                row = [weakSelf.fetchedContentList indexOfObject:content];
                section = 0;
                
                contentMTL = [weakSelf.fetchedContentList objectAtIndex:row];
            } else if ([weakSelf.mergedHomeDataSource containsObject:content]) {
                row = [weakSelf.mergedHomeDataSource indexOfObject:content];
                if ([weakSelf.fetchedContentList count] > 0) {
                    section = 1;
                } else {
                    section = 0;
                }
                contentMTL = [weakSelf.mergedHomeDataSource objectAtIndex:row];
            }
            
            contentMTL.actionStatuses = content.actionStatuses;
            
            GFContentSummaryVoteMTL *voteSummary = (GFContentSummaryVoteMTL *)contentMTL.contentSummary;
            GFContentDetailVoteMTL *voteDetail = (GFContentDetailVoteMTL *)content.contentDetail;
            voteSummary.voteItems = voteDetail.voteItems;
            
            if (row >= 0 && section >= 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [weakSelf.homeCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        };
        void(^commentAndFunHandler)(GFContentMTL *) = ^(GFContentMTL *content) {
            NSInteger row = -1;
            NSInteger section = -1;
            if ([weakSelf.fetchedContentList containsObject:contentMTL]) {
                row = [weakSelf.fetchedContentList indexOfObject:contentMTL];
                section = 0;
                
                GFContentMTL *contentToUpdate = [weakSelf.fetchedContentList objectAtIndex:row];
                contentToUpdate.contentInfo.funCount = content.contentInfo.funCount;
                contentToUpdate.contentInfo.commentCount = content.contentInfo.commentCount;
                contentToUpdate.actionStatuses = content.actionStatuses;
                @synchronized (weakSelf.fetchedContentList) {
                    [weakSelf.fetchedContentList replaceObjectAtIndex:row withObject:contentToUpdate];
                }
            } else if ([weakSelf.mergedHomeDataSource containsObject:contentMTL]) {
                row = [weakSelf.mergedHomeDataSource indexOfObject:contentMTL];
                if ([weakSelf.fetchedContentList count] > 0) {
                    section = 1;
                } else {
                    section = 0;
                }
                
                GFContentMTL *contentToUpdate = [weakSelf.mergedHomeDataSource objectAtIndex:row];
                contentToUpdate.contentInfo.funCount = content.contentInfo.funCount;
                contentToUpdate.contentInfo.commentCount = content.contentInfo.commentCount;
                contentToUpdate.actionStatuses = content.actionStatuses;
                @synchronized (weakSelf.mergedHomeDataSource) {
                    [weakSelf.mergedHomeDataSource replaceObjectAtIndex:row withObject:contentToUpdate];
                }
            }
            
            if (row >= 0 && section >= 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [weakSelf.homeCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        };
        
        // 这个跟上面的commentAndFunHandler目前做的事情一样，就先这样吧
        void(^contentUpdateHandler)(GFContentMTL *) = commentAndFunHandler;
//        void(^contentUpdateHandler)(GFContentMTL *) = ^(GFContentMTL *content) {
//            NSInteger row = -1;
//            NSInteger section = -1;
//            if ([weakSelf.fetchedContentList containsObject:contentMTL]) {
//                row = [weakSelf.fetchedContentList indexOfObject:contentMTL];
//                section = 0;
//                
//                GFContentMTL *contentToUpdate = [weakSelf.fetchedContentList objectAtIndex:row];
//                contentToUpdate.contentInfo.funCount = content.contentInfo.funCount;
//                contentToUpdate.contentInfo.commentCount = content.contentInfo.commentCount;
//                contentToUpdate.actionStatuses = content.actionStatuses;
//                [weakSelf.fetchedContentList replaceObjectAtIndex:row withObject:contentToUpdate];
//                
//            } else if ([weakSelf.mergedHomeDataSource containsObject:contentMTL]) {
//                row = [weakSelf.mergedHomeDataSource indexOfObject:contentMTL];
//                if ([weakSelf.fetchedContentList count] > 0) {
//                    section = 1;
//                } else {
//                    section = 0;
//                }
//                
//                GFContentMTL *contentToUpdate = [weakSelf.mergedHomeDataSource objectAtIndex:row];
//                contentToUpdate.contentInfo.funCount = content.contentInfo.funCount;
//                contentToUpdate.contentInfo.commentCount = content.contentInfo.commentCount;
//                contentToUpdate.actionStatuses = content.actionStatuses;
//                [weakSelf.mergedHomeDataSource replaceObjectAtIndex:row withObject:contentToUpdate];
//            }
//            
//            if (row >= 0 && section >= 0) {
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//                [weakSelf.homeCollectionView reloadItemsAtIndexPaths:@[indexPath]];
//            }
//        };
        
        if (contentMTL && contentMTL.contentInfo.contentId) {            
            if ([contentMTL isGetfunLesson]) {
                GFLessonViewController *lessonViewController = [[GFLessonViewController alloc] initWithContent:contentMTL];
                [self.navigationController pushViewController:lessonViewController animated:YES];
            } else {                
                
                GFContentDetailViewController *controller = [[GFContentDetailViewController alloc] initWithContent:contentMTL contentType:contentMTL.contentInfo.type preview:NO keyFrom:GFKeyFromHome];
                controller.deleteContentHandler = deleteContentHandler;
                controller.voteHandler = voteContentHandler;
                controller.commentAndFunHandler = commentAndFunHandler;
                controller.contentUpdateHandler = contentUpdateHandler;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    } else if ([model isKindOfClass:[GFAdFeedMTL class]]) {
        [MobClick event:@"gf_sy_01_04_01_1"];
        
        GFAdFeedMTL *ad = model;
        [[AppDelegate appDelegate] handleGetfunLinkUrl:ad.adRedirectUrl];
    }
}

#pragma mark - GFPathMenuDelegate
- (void)pathMenu:(GFPathMenu *)pathMenu clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
    if ([GFAccountManager sharedManager].loginType == GFLoginTypeNone ||
        [GFAccountManager sharedManager].loginType == GFLoginTypeAnonymous) {
        GFLoginRegisterViewController *loginViewController = [[GFLoginRegisterViewController alloc] init];
        [self presentViewController:[[GFNavigationController alloc] initWithRootViewController:loginViewController]
                           animated:YES
                         completion:NULL];
    } else {
        switch (itemButtonIndex) {
            case 0: { // 扫一扫
                [MobClick event:@"gf_sy_02_01_02_1"];
                //是否可用
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                    if(authStatus == AVAuthorizationStatusAuthorized){
                        GFQRViewController *qrViewController = [[GFQRViewController alloc] init];
                        [qrViewController hideFooterImageView:YES];
                        [self presentViewController:[[GFNavigationController alloc] initWithRootViewController:qrViewController]
                                           animated:YES
                                         completion:NULL];
                    } else {
                        [UIAlertView bk_showAlertViewWithTitle:@"提示"
                                                       message:@"请先在\"设置\"－\"隐私\"中的\"相机\"中允许\"盖范\"使用相机"
                                             cancelButtonTitle:@"暂不允许"
                                             otherButtonTitles:@[@"马上设置"]
                                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                           if (buttonIndex == 1) {
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Camera"]];
                                                           }
                                                       }];
                    }
                } else {
                    [UIAlertView bk_showAlertViewWithTitle:@"提示"
                                                   message:@"找不到可用的摄像设备"
                                         cancelButtonTitle:@"我知道了"
                                         otherButtonTitles:nil
                                                   handler:NULL];
                }
                break;
            }
                
            case 1: { // 投票
                [MobClick event:@"gf_sy_02_01_05_1"];
                GFPublishVoteViewController *voteViewController = [[GFPublishVoteViewController alloc] initWithKeyFrom:GFPublishKeyFromHome];
                [self presentViewController:[[GFNavigationController alloc] initWithRootViewController:voteViewController]
                                   animated:YES
                                 completion:NULL];
            }
                break;
            case 2: { // 图片
                GFPublishPhotoViewController *photoViewController = [[GFPublishPhotoViewController alloc] initWithKeyFrom:GFPublishKeyFromHome];
                [self presentViewController:[[GFNavigationController alloc] initWithRootViewController:photoViewController]
                                   animated:NO
                                 completion:NULL];
                break;
            }
                
            case 3: { // 投票
                [MobClick event:@"gf_sy_02_01_03_1"];
                GFPublishLinkViewController *linkViewController = [[GFPublishLinkViewController alloc] initWithKeyFrom:GFPublishKeyFromHome];
                [self presentViewController:[[GFNavigationController alloc] initWithRootViewController:linkViewController]
                                   animated:YES
                                 completion:NULL];
                break;
            }
            case 4: { // 文章
                [MobClick event:@"gf_sy_02_01_04_1"];
                GFPublishArticleViewController *articleViewController = [[GFPublishArticleViewController alloc] initWithKeyFrom:GFPublishKeyFromHome];
                [self presentViewController:[[GFNavigationController alloc] initWithRootViewController:articleViewController]
                                   animated:YES
                                 completion:NULL];
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)clickPathMenu:(GFPathMenu *)pathMenu {
    [GFSoundEffect playSoundEffect:GFSoundEffectTypePublish];
    [MobClick event:@"gf_sy_02_01_01_1"];
}

#pragma mark - notification
- (void)didPublishedContentChanged:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    if ([notification.name isEqualToString:GFNotificationPublishStateUpdate]) {
        id updateModel = [userInfo objectForKey:kPublishNotificationUserInfoKeyData];
        
        if ([updateModel isKindOfClass:[GFContentMTL class]]) {
            // 检查来源，非标签页和get帮
            GFPublishMTL *originTask = userInfo[kPublishNotificationUserInfoKeyOrigin];
            if (!originTask.tagId && !originTask.groupId) {
                // 发布成功了，插入到第一个cell
                [self showSuccessTipWithText:@"您有一个帖子发布成功"];
                @synchronized (self.fetchedContentList) {
                    [self.fetchedContentList insertObject:updateModel atIndex:0];
                }
                if ([self.fetchedContentList count] == 1) {
                    [self.homeCollectionView reloadData];
                } else {
                    [self.homeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                }
            }
        } else if([updateModel isKindOfClass:[GFPublishMTL class]]){
            GFPublishMTL *updatePublishMTL = updateModel;
            // 检查来源，非标签页和get帮
            if (!updatePublishMTL.tagId && !updatePublishMTL.groupId) {
                GFPublishState state = [updatePublishMTL.state integerValue];
                if (state == GFPublishStateFailed) {
                    
                    NSString *msg = [userInfo objectForKey:kPublishNotificationUserInfoKeyMsg];
                    if (!msg) {
                        msg = @"未知错误";
                    }
                    
                    __weak typeof(self) weakSelf = self;
                    [UIAlertView bk_showAlertViewWithTitle:@"发布失败" message:msg cancelButtonTitle:@"我知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if ([weakSelf.fetchedContentList count] == 1) {
                            [weakSelf.homeCollectionView reloadData];
                        } else {
                            [weakSelf.homeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                        }
                    }];
                } else if(state == GFPublishStateSending){ //有发送任务
                    if ([self.fetchedContentList count] == 1) {
                        [self.homeCollectionView reloadData];
                    } else {
                        [self.homeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    }
                }
            }
        }
    }
}

- (void)didLocationUpdated:(NSNotification *)notification {
    if (!self.groupList) {
        [self queryRecommendGroupList];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        for (UICollectionViewCell *cell in [self.homeCollectionView visibleCells]) {
            if ([cell isKindOfClass:[GFFeedArticleCell class]] || [cell isKindOfClass:[GFFeedPictureCell class]]) {
                [cell performSelector:@selector(startLoadingImages)];
            }
        }
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    for (UICollectionViewCell *cell in [self.homeCollectionView visibleCells]) {
        if ([cell isKindOfClass:[GFFeedArticleCell class]] || [cell isKindOfClass:[GFFeedPictureCell class]]) {
            [cell performSelector:@selector(startLoadingImages)];
        }
    }
}

- (void)scrollToTop {
    [self.homeCollectionView setContentOffset:CGPointZero animated:YES];
}
@end
