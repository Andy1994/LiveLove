//
//  GFTagDetailViewController.m
//  GetFun
//
//  Created by liupeng on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFTagDetailViewController.h"

#import "CExpandHeader.h"
#import "GFAccountManager.h"
#import "GFNetworkManager+Tag.h"
#import "GFNetworkManager+Content.h"
#import "GFNetworkManager+Group.h"

#import "GFContentInfoMTL.h"
#import "GFPictureMTL.h"
#import "GFContentMTL.h"

#import "GFRecommendGroupCell.h"
#import "GFFeedArticleCell.h"
#import "GFFeedLinkCell.h"
#import "GFFeedVoteCell.h"
#import "GFFeedPictureCell.h"

#import "GFProfileViewController.h"

#import "GFContentDetailViewController.h"
#import "GFGroupDetailViewController.h"
#import "GFMyGroupViewController.h"
#import "GFGroupInfoViewController.h"
#import "GFTagRelatedGroupViewController.h"
#import "GFExpandView.h"
#import "NTESActivityViewController.h"
#import "GFCopyUrlActionActivity.h"
#import "GFLessonViewController.h"
#import "GFImageGroupView.h"
#import "GFTagUserGuideView.h"

#import "GFTagHeaderCell.h"
#import "GFTagHeaderView.h"
#import "GFPublishInfoHeader.h"
#import "GFPublishManager.h"

#import "GFPublishPhotoViewController.h"
//#import "GFPublishTagViewController.h"
#import "GFPublishArticleViewController.h"
#import "GFPublishVoteViewController.h"
#define NAV_BAR_CHANGE_THRESHOLD (-20.0f)
#define SCROLL_VIEW_INI_OFFSET_Y (-100.0f)
NSString * const GFUserDefaultsKeyLastVersionForTagGuide = @"GFUserDefaultsKeyLastVersionForTagGuide";

@interface GFTagDetailViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) NSNumber *tagId;
@property (nonatomic, strong) GFTagMTL *tag;

@property (nonatomic, strong) CExpandHeader *header;
@property (nonatomic, strong) GFExpandView *expandView;
@property (nonatomic, strong) GFTagUserGuideView *tagUserGuideView;
@property (nonatomic, strong) UIButton *collectButton;
@property (nonatomic, strong) UILabel *tagTitleLabel;
@property (nonatomic, strong) UILabel *tagDescriptionLabel;
@property (nonatomic, strong) UICollectionView *contentCollectionView;

@property (nonatomic, strong) UIImageView *refreshImageView;

@property (nonatomic, strong) NSMutableArray<GFContentMTL *> *contentDataSource;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *readContents;
@property (nonatomic, strong) NSArray<GFGroupMTL *> *groupList;
@property (nonatomic, strong) NSNumber *maxPublishTime;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NTESActivityViewController *shareViewController;

@property (nonatomic, copy) UIImage *shareImage;

@property (nonatomic, strong) GFTagHeaderView *tagHeaderView; //悬停的header视图，用于发布图片帖和PK
@property (nonatomic, assign) GFContentType tagType;
@end

@implementation GFTagDetailViewController
- (GFExpandView *)expandView {
    if (!_expandView) {
        _expandView = [[GFExpandView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250.f)];
        _expandView.imageView.image = [UIImage imageNamed:@"tag_banner.jpg"];
    }
    return _expandView;
}

- (GFTagUserGuideView *)tagUserGuideView {
    if (!_tagUserGuideView) {
        _tagUserGuideView = [[GFTagUserGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _tagUserGuideView.hidden = YES;
    }
    return _tagUserGuideView;
}

- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectButton setImage:[UIImage imageNamed:@"tag_collect_normal"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"tag_collect_selected"] forState:UIControlStateSelected];
        [_collectButton sizeToFit];
        _collectButton.center = CGPointMake(self.expandView.width/2, self.expandView.height-55-_collectButton.height/2);
    }
    return _collectButton;
}

- (UILabel *)tagTitleLabel {
    if (!_tagTitleLabel) {
        _tagTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagTitleLabel.font = [UIFont systemFontOfSize:18.0f];
        _tagTitleLabel.textColor = [UIColor whiteColor];
        _tagTitleLabel.textAlignment = NSTextAlignmentCenter;
        _tagTitleLabel.numberOfLines = 1;
    }
    return _tagTitleLabel;
}

- (UILabel *)tagDescriptionLabel {
    if (!_tagDescriptionLabel) {
        _tagDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagDescriptionLabel.font = [UIFont systemFontOfSize:14.0f];
        _tagDescriptionLabel.textColor = [UIColor whiteColor];
        _tagDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        _tagDescriptionLabel.numberOfLines = 2;
    }
    return _tagDescriptionLabel;
}

- (UICollectionView *)contentCollectionView {
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _contentCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _contentCollectionView.backgroundColor = [UIColor clearColor];
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;
        [_contentCollectionView registerClass:[GFRecommendGroupCell class] forCellWithReuseIdentifier:NSStringFromClass([GFRecommendGroupCell class])];
        [_contentCollectionView registerClass:[GFFeedArticleCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class])];
        [_contentCollectionView registerClass:[GFFeedLinkCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class])];
        [_contentCollectionView registerClass:[GFFeedVoteCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class])];
        [_contentCollectionView registerClass:[GFFeedPictureCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class])];
        //将标签头cell和网络请求失败的header加入
        [_contentCollectionView registerClass:[GFTagCell class] forCellWithReuseIdentifier:NSStringFromClass([GFTagCell class])];
        [_contentCollectionView registerClass:[GFPublishInfoHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFPublishInfoHeader class])];
    }
    return _contentCollectionView;
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

- (NSMutableArray<GFContentMTL *> *)contentDataSource {
    if (!_contentDataSource) {
        _contentDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _contentDataSource;
}

- (NSMutableArray<NSNumber *> *)readContents {
    if (!_readContents) {
        _readContents = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _readContents;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _titleLabel.centerX = SCREEN_WIDTH / 2;
        _titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
        _titleLabel.font = [UIFont systemFontOfSize:20];  //设置文本字体与大小
        _titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];  //设置文本颜色
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"";  //设置标题
    }
    return _titleLabel;
}

- (NTESActivityViewController *)shareViewController {
    if (!_shareViewController) {
        _shareViewController = [[NTESActivityViewController alloc] init];
    }
    return _shareViewController;
}

//标签头视图, 与之对应的是一个cell内容
- (GFTagHeaderView *)tagHeaderView {
    if (!_tagHeaderView) {
        _tagHeaderView = [[GFTagHeaderView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 50.0)];
        _tagHeaderView.hidden = YES;
        _tagHeaderView.layer.shadowOffset = CGSizeMake(0, 1);
        _tagHeaderView.layer.shadowColor = [UIColor blackColor].CGColor;
        [_tagHeaderView.layer setShadowRadius:1];
        [_tagHeaderView.layer setShadowOpacity:0.2];
    }
    return _tagHeaderView;
}

- (instancetype)initWithTagId:(NSNumber *)tagId {
    if (self = [super init]) {
        _tagId = tagId;
    }
    return self;
}

#pragma mark - 根据点击内容类型加载不同的目的控制器
- (void)loadControllerByType: (GFContentType)type target: (GFTagDetailViewController *)target {
    
    GFPublishBaseViewController *publishViewController = nil;
    switch (type) {
        case GFContentTypeTag:
            //只要是点击话头进入 不管有没有话头内容，详情页不自动弹相册
            publishViewController = [[GFPublishPhotoViewController alloc] initWithTag:target.tag fromTagInput:YES];
            break;
        case GFContentTypePicture:
            publishViewController = [[GFPublishPhotoViewController alloc] initWithTag:target.tag fromTagInput:NO];
            break;
        case GFContentTypeVote:
            publishViewController = [[GFPublishVoteViewController alloc] initWithTag:target.tag keyFrom:GFPublishKeyFromTagNoTopic];
            break;
        default: break;
    }
    [target presentViewController:[[GFNavigationController alloc] initWithRootViewController:publishViewController] animated:NO completion:NULL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //子视图
    [self.view addSubview:self.contentCollectionView];
    [self.view addSubview:self.refreshImageView];
    [self.expandView addSubview:self.collectButton];
    [self.expandView addSubview:self.tagDescriptionLabel];
    [self.expandView addSubview:self.tagTitleLabel];

    [self.view addSubview:self.tagHeaderView];  //标签视图
        //tagView设置代理
    __weak typeof(self) weakSelf = self;
    self.tagHeaderView.publishHandler = ^(GFContentType type) {
        
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user) {
                [weakSelf loadControllerByType:type target:weakSelf];
                weakSelf.tagType = type;
            }
        }];
    };
    
    //导航栏设置
    [self setBackBarButtonItemStyle:GFBackBarButtonItemStyleBackLight];
    self.navigationItem.titleView = self.titleLabel;
    UIBarButtonItem *shareItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_share_light"] target:self selector:@selector(shareBarItemAction:)];
    shareItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = shareItem;
    [self gf_setNavBarBackgroundTransparent:0.0f];
    
    //底部上拉刷新加载逻辑
    [self.contentCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryContent:NO];
    }];

    //顶部Header设置
    __weak typeof(self.contentCollectionView) weakCollectionView = self.contentCollectionView;
    self.header = [CExpandHeader expandWithScrollView:weakCollectionView expandView:self.expandView];
    
    //收藏按钮触发事件
    [self.collectButton bk_addEventHandler:^(id sender) {
        
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (justLogin) {
                [weakSelf queryTagMTL:NO];
            } else if (user) {
                // 关注、取消关注
                weakSelf.collectButton.selected = !weakSelf.tag.collected;
                
                if (weakSelf.tag.collected) { //取消关注
                    [MobClick event:@"gf_bq_02_04_02_1"];
                } else {
                    [MobClick event:@"gf_bq_02_04_01_1"];
                }
                
                if (weakSelf.tag.tagInfo.tagId) {
                    [GFNetworkManager collectTag:weakSelf.tag.tagInfo.tagId
                                         collect:!weakSelf.tag.collected
                                         success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                             if (code == 1) {
                                                 NSString *msg = [NSString stringWithFormat:@"%@成功", weakSelf.tag.collected ? @"取消关注" : @"关注"];
                                                 [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:weakSelf.view];
                                                 weakSelf.tag.collected = !weakSelf.tag.collected;
                                                 
                                                 //操作回调
                                                 if (weakSelf.tagCollectHandler) {
                                                     weakSelf.tagCollectHandler(weakSelf.tag);
                                                 }
                                                 
                                                 
                                             } else {
                                                 weakSelf.collectButton.selected = weakSelf.tag.collected;
                                                 if (apiErrorMessage) {
                                                     [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:weakSelf.view];
                                                 }
                                             }
                                         } failure:^(NSUInteger taskId, NSError *error) {
                                             weakSelf.collectButton.selected = weakSelf.tag.collected;
                                             [MBProgressHUD showHUDWithTitle:@"网络请求失败" duration:kCommonHudDuration inView:weakSelf.view];
                                         }];
                }
            }
        }];
        
    } forControlEvents:UIControlEventTouchUpInside];

    
    //进入后加载标签数据
    [self queryTagMTL:YES];
    
    //判断是否第一次安装，以便决定是否显示提示蒙层
    NSString *lastVersion = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyLastVersionForTagGuide];
    if (!lastVersion || APP_VERSION_GREATER_THAN(lastVersion)) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.tagUserGuideView];
    }
    
    
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    
    //注册发布标签相关内容后的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPublishedContentChanged:) name:GFNotificationPublishStateUpdate object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tagUserGuideView removeFromSuperview];
}

- (void)backBarButtonItemSelected {
    
    [MobClick event:@"gf_bq_02_04_03_1"];
    [super backBarButtonItemSelected];
}

- (void)queryTagMTL:(BOOL)reloadContent {
    
    MBProgressHUD *hud = [MBProgressHUD showLoadingHUDWithTitle:@"" inView:self.view];
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getTagDetail:self.tagId
                           success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage, NSArray<GFContentMTL *> *contents, NSArray<GFGroupMTL *> *groups, GFTagMTL *tag) {
                               if (code == 1) {
                                   [hud hide:YES];
                                   
                                   weakSelf.tag = tag;
                                   
                                   //蒙层用户引导提示
                                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       CGPoint viewOrigin = CGPointZero;
                                       CGRect viewFrame = CGRectZero;
                                       GFTagCell *cell = (GFTagCell*)[self.contentCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                                       viewFrame = [self.tagUserGuideView convertRect:cell.frame fromView:cell.superview];
                                       viewOrigin = viewFrame.origin;
                                       if (!(viewOrigin.x == 0 && viewOrigin.y == 0)) {
                                           [self.tagUserGuideView setPublishPhotoViewFrame:viewFrame];
                                           self.tagUserGuideView.hidden = NO;
                                           [GFUserDefaultsUtil setObject:APP_VERSION forKey:GFUserDefaultsKeyLastVersionForTagGuide];
                                       }
                                   });
                                   
                                   [weakSelf updateTagDetailUI];
                                   [weakSelf prepareImageForShare:tag];
                                   
                                   if (reloadContent) {
                                       weakSelf.groupList = groups;
                                       @synchronized(weakSelf.contentDataSource) {
                                           [weakSelf.contentDataSource addObjectsFromArray:contents];
                                       }
                                       
                                       if ([weakSelf.contentDataSource count] > 4) {
                                           weakSelf.contentCollectionView.showsInfiniteScrolling = YES;
                                       } else {
                                           weakSelf.contentCollectionView.showsInfiniteScrolling = NO;
                                       }


                                       weakSelf.maxPublishTime = [[[weakSelf.contentDataSource lastObject] contentInfo] createTime];
                                       if ([weakSelf.maxPublishTime integerValue] == -1) {
                                           [weakSelf.contentCollectionView finishInfiniteScrolling];
                                           weakSelf.contentCollectionView.showsInfiniteScrolling = NO;
                                       }
                                       
                                      [weakSelf.contentCollectionView reloadData];

                                   }
                               } else {
                                   hud.labelText = errorMessage;
                                   [hud hide:YES afterDelay:kCommonHudDuration];
                               }
                           } failure:^(NSUInteger taskId, NSError *error) {
                               hud.labelText = @"获取标签数据失败";
                               [hud hide:YES afterDelay:kCommonHudDuration];
                           }];
}

- (void)queryContent:(BOOL)reset {
    
    NSNumber *queryTime = self.maxPublishTime;
    if (reset) {
        queryTime = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager queryContentListWithTag:[self.tag.tagInfo.tagId unsignedIntegerValue]
                                        count:kQueryDataCount
                               maxPublishTime:queryTime
                                      success:^(NSUInteger taskId, NSInteger code, NSArray *contentList) {
                                          
                                          [weakSelf.contentCollectionView finishInfiniteScrolling];
                                          weakSelf.refreshImageView.hidden = YES;
                                          [weakSelf stopRefreshAnimate];
                                          
                                          if (code == 1) {
                                              if (contentList && [contentList count] > 0) {
                                                  if (reset) {
                                                      weakSelf.maxPublishTime = nil;
                                                      @synchronized (weakSelf.contentDataSource) {
                                                           [weakSelf.contentDataSource removeAllObjects];
                                                      }
                                                     
                                                  }
                                                  @synchronized (weakSelf.contentDataSource) {
                                                         [weakSelf.contentDataSource addObjectsFromArray:contentList];
                                                  }
                                                  
                                                  weakSelf.maxPublishTime = [[[weakSelf.contentDataSource lastObject] contentInfo] createTime];
                                                  
                                                  weakSelf.contentCollectionView.showsInfiniteScrolling = [weakSelf.maxPublishTime integerValue] != -1;
                                                  
                                                  [weakSelf.contentCollectionView reloadData];
                                              }
                                          }
                                          
                                      } failure:^(NSUInteger taskId, NSError *error) {
                                          [weakSelf.contentCollectionView finishInfiniteScrolling];
                                          weakSelf.refreshImageView.hidden = YES;
                                          [weakSelf stopRefreshAnimate];
                                      }];
}

- (void)updateTagDetailUI {
    
    self.titleLabel.text = self.tag.tagInfo.tagName;
    self.collectButton.selected = self.tag.collected;
    
    self.tagDescriptionLabel.text = self.tag.tagInfo.tagDescription;
    {
        CGSize size = [self.tagDescriptionLabel sizeThatFits:CGSizeMake(self.view.width - 30, MAXFLOAT)];
        self.tagDescriptionLabel.size = size;
        self.tagDescriptionLabel.center = CGPointMake(self.view.width/2, self.collectButton.y - 20 - self.tagDescriptionLabel.height/2);
    }
    
    self.tagTitleLabel.text = self.tag.tagInfo.tagName;
    {
        CGSize size = [self.tagTitleLabel sizeThatFits:CGSizeMake(self.view.width - 30, MAXFLOAT)];
        self.tagTitleLabel.size = size;
        self.tagTitleLabel.center = CGPointMake(self.view.width/2, self.tagDescriptionLabel.y - 12 - self.tagTitleLabel.height/2);
    }
    if (self.tag.tagInfo.frontImageUrl) {
        NSString *url = ((GFPictureMTL*)[self.tag.pictures objectForKey:self.tag.tagInfo.frontImageUrl]).url;
        NSUInteger width = (NSUInteger)SCREEN_WIDTH;
        NSUInteger height = (NSUInteger)SCREEN_WIDTH;
#warning 图片剪裁标准未确定
        url = [url gf_urlAppendWithHorizontalEdge:width verticalEdge:height mode:GFImageProcessModeMaxWidthAdaptiveHeightAspect convertGIF:true];
        [_expandView.imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"tag_banner"]];
    }
    //将模型赋给tagHeaderView
    [self.tagHeaderView bindWithModel:self.tag];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems = 0;
    
    if (section == 0) {
        numberOfItems = 1;
    } else if (section == 1) {
        numberOfItems = (self.groupList && [self.groupList count] > 0) ? 1 : 0;
    } else {
        numberOfItems = [self.contentDataSource count];
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFTagCell  class]) forIndexPath:indexPath];
        [(GFTagCell *)cell setPublishHandler: ^(GFContentType type) {
            switch (type) {
                case GFContentTypeVote: {
                    [MobClick event:@"gf_bq_02_04_14_1"];
                    break;
                }
                case GFContentTypePicture: {
                    //由于需要区分是点击话头进入还是点击发图片进入，因此写入视图的事件内，不改变回调了
                    break;
                }
                default:
                    break;
            }
            //发布需要检查登录权限
            [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                if (user) {
                    [weakSelf loadControllerByType:type target:weakSelf];
                    weakSelf.tagType = type;
                }
            }];

        }];
        [(GFTagCell *)cell bindWithModel:self.tag];
        
    } else if (indexPath.section == 1) {
        
        void(^groupSelectHandler)(GFRecommendGroupCell *, GFRecommendGroupView *) = ^(GFRecommendGroupCell *cell, GFRecommendGroupView *itemView) {
            
            __weak typeof(self) weakSelf = self;
            GFGroupMTL *group = itemView.group;
            [GFNetworkManager getGroupWithGroupId:group.groupInfo.groupId
                                          success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                              if (code == 1) {
                                                  //根据是否加入跳转到不同视图(group模型的对应属性)
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
            //相关group视图
            GFTagRelatedGroupViewController *controller = [[GFTagRelatedGroupViewController alloc] initWithGroupList:self.groupList];
            [self.navigationController pushViewController:controller animated:YES];
        };
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFRecommendGroupCell class]) forIndexPath:indexPath];
        [(GFRecommendGroupCell *)cell setMaxItemCount:1];
        [(GFRecommendGroupCell *)cell bindWithModel:self.groupList style:GFRecommendGroupCellStyle_Tag showRightTitle:YES];
        [(GFRecommendGroupCell *)cell setGroupSelectHandler:groupSelectHandler];
        [(GFRecommendGroupCell *)cell setRighButtonHandler:rightButtonHandler];
        
    } else {
        
        id model = [self.contentDataSource objectAtIndex:indexPath.row];
        GFContentMTL *contentMTL = model;
        
        @weakify(self)
        switch (contentMTL.contentInfo.type) {
            case GFContentTypeUnknown:{
                break;
            }
            case GFContentTypeArticle: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class]) forIndexPath:indexPath];
                [(GFFeedArticleCell *)cell bindWithModel:model];
                [(GFFeedArticleCell *)cell setTapImageHandler:^(GFFeedContentCell *cell, NSUInteger iniImageIndex) {
                    @strongify(self)
                    [MobClick event:@"gf_bq_02_01_04_1"];
                    
                    GFContentSummaryArticleMTL *articleSummary = (GFContentSummaryArticleMTL *)contentMTL.contentSummary;
                    NSString *iniPictureKey = [articleSummary.pictureSummary objectAtIndex:iniImageIndex];
                    GFImageGroupView *imageGroupView = [[GFImageGroupView alloc] initWithImages:contentMTL.pictures
                                                                                                     orderKeys:articleSummary.pictureSummary
                                                                                                    initialKey:iniPictureKey
                                              delegate:cell];
                    [imageGroupView presentToContainer:self.navigationController.view animated:YES completion:nil];
                    
                }];
                if (!collectionView.isDragging && !collectionView.isDecelerating) {
                    [(GFFeedArticleCell *)cell startLoadingImages];
                }
                break;
            }
            case GFContentTypeVote: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class]) forIndexPath:indexPath];
                [(GFFeedVoteCell *)cell bindWithModel:model];
                break;
            }
            case GFContentTypeLink: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class]) forIndexPath:indexPath];
                [(GFFeedLinkCell *)cell bindWithModel:model];
                break;
            }
            case GFContentTypePicture: {
                
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class]) forIndexPath:indexPath];
                [(GFFeedPictureCell *)cell bindWithModel:model];
                if (!collectionView.isDragging && !collectionView.isDecelerating) {
                    [(GFFeedPictureCell *)cell startLoadingImages];
                }
                
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
                
                break;
            }
        }
        
        BOOL hasRead = [self.readContents containsObject:contentMTL.contentInfo.contentId];
        if (hasRead) {
            [(GFFeedContentCell *)cell markRead];
        }
        
        [[(GFFeedContentCell *)cell userInfoHeader] setAvatarHandler:^{
            GFContentMTL *content = model;
            
            switch (content.contentInfo.type) {
                case GFContentTypeUnknown:{
                    break;
                }
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_bq_02_01_01_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_bq_02_03_01_1"];
                    break;
                }
                case GFContentTypeLink: {
                    [MobClick event:@"gf_bq_02_02_01_1"];
                    break;
                }
                case GFContentTypePicture: {
                    break;
                }
            }
            
            GFUserMTL *user = content.user;
            GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }];
        [(GFFeedContentCell *)cell setFloatFunHandler:^(GFContentMTL *contentMTL) {
            GFContentMTL *content = model;
            switch (content.contentInfo.type) {
                case GFContentTypeUnknown:{
                    break;
                }
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_bq_02_01_03_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_bq_02_03_03_1"];
                    break;
                }
                case GFContentTypeLink: {
                    [MobClick event:@"gf_bq_02_02_03_1"];
                    break;
                }
                case GFContentTypePicture: {
                    break;
                }
            }
            
            [weakSelf.contentCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
        
    }

    return cell;
}

//返回section头 -> 发送错误的提示视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    
    GFPublishInfoHeader *publishInfoHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFPublishInfoHeader class]) forIndexPath:indexPath];
    
    publishInfoHeader.retryHandler = ^{
        [GFPublishManager retryFailedTaskWithTagId:weakSelf.tagId];
        [weakSelf.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
    };
    
    publishInfoHeader.deleteHandler = ^{
        [GFPublishManager removeFailedTaskWithTagId:weakSelf.tagId];
        [weakSelf.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
    };
    
    NSString *text = nil;
    NSArray *waitingTasks = [GFPublishManager waitingTaskWithTagId:self.tagId];
    NSArray *failedTasks = [GFPublishManager failedTaskListWithTagId:self.tagId];
    if ([failedTasks count] > 0) {
        text = [NSString stringWithFormat:@"网络不畅，您有%@条帖子未发送", @([failedTasks count])];
        [publishInfoHeader showRetryAndDeleteButton:YES];
    } else {
        text = [NSString stringWithFormat:@"您有%@条帖子正在发送", @([waitingTasks count])];
        [publishInfoHeader showRetryAndDeleteButton:NO];
    }
    [publishInfoHeader setInfoText:text];
    
    return publishInfoHeader;
}

#pragma mark - UICollectionViewDelegateFlowLayout

//sectionInset
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (section == 1) {
        if (self.groupList && self.groupList.count > 0) {
            edgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        }
    } else if (section == 2 ) {
        edgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
    }
    return edgeInsets;
}
//size for cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (indexPath.section == 0) {
        height = 50.0f;
    } else if (indexPath.section == 1) {
        height = [GFRecommendGroupCell heightWithModel:self.groupList maxItemCount:1];
    } else {
        id model = [self.contentDataSource objectAtIndex:indexPath.row];
        GFContentMTL *contentMTL = model;
        switch (contentMTL.contentInfo.type) {
            case GFContentTypeUnknown:{
                break;
            }
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
        }
        
    }
    return CGSizeMake(collectionView.width, height);
}

//size for header
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize size = CGSizeZero;

    NSArray *failedTasks = [GFPublishManager failedTaskListWithTagId:self.tagId];
    NSArray *waitingTasks = [GFPublishManager waitingTaskWithTagId:self.tagId];
    if (section == 2 && ([failedTasks count] > 0 || [waitingTasks count] > 0)) {
        size = CGSizeMake(collectionView.width, 58);
    }
    return size;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        GFContentMTL *content = [self.contentDataSource objectAtIndex:indexPath.row];
        
        switch (content.contentInfo.type) {
            case GFContentTypeUnknown:{
                break;
            }
            case GFContentTypeArticle: {
                [MobClick event:@"gf_bq_02_01_02_1"];
                break;
            }
            case GFContentTypeVote: {
                [MobClick event:@"gf_bq_02_03_02_1"];
                break;
            }
            case GFContentTypeLink: {
                [MobClick event:@"gf_bq_02_02_02_1"];
                break;
            }
            case GFContentTypePicture: {
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
                
                GFContentDetailViewController *controller = [[GFContentDetailViewController alloc] initWithContent:content contentType:content.contentInfo.type preview:NO keyFrom:GFKeyFromTag];
                
                __weak typeof(self) weakSelf = self;
                controller.commentAndFunHandler = ^(GFContentMTL *content){
                    
                    NSInteger indexInContentList = [weakSelf.contentDataSource indexOfObject:content];
                    
                    GFContentMTL *contentToUpdate = [[weakSelf.contentDataSource objectAtIndex:indexInContentList] copy];
                    contentToUpdate.contentInfo.funCount = content.contentInfo.funCount;
                    contentToUpdate.contentInfo.commentCount = content.contentInfo.commentCount;
                    contentToUpdate.actionStatuses = content.actionStatuses;
                    @synchronized (weakSelf.contentDataSource) {
                        [weakSelf.contentDataSource replaceObjectAtIndex:indexInContentList withObject:contentToUpdate];
                    }
                    [weakSelf.contentCollectionView reloadData];
                };

                controller.voteHandler = ^(GFContentMTL *content, BOOL left) {
                    NSInteger row = -1;
                    if ([weakSelf.contentDataSource containsObject:content]) {
                        row = [weakSelf.contentDataSource indexOfObject:content];
                        GFContentMTL *contentMTL = [weakSelf.contentDataSource objectAtIndex:row];
                        
                        contentMTL.actionStatuses = content.actionStatuses;
                        
                        GFContentSummaryVoteMTL *voteSummary = (GFContentSummaryVoteMTL *)contentMTL.contentSummary;
                        GFContentDetailVoteMTL *voteDetail = (GFContentDetailVoteMTL *)content.contentDetail;
                        voteSummary.voteItems = voteDetail.voteItems;
                    }
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:2];
                    [weakSelf.contentCollectionView reloadItemsAtIndexPaths:@[indexPath]];
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
        
        UIBarButtonItem *shareItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_share_light"] target:self selector:@selector(shareBarItemAction:)];
        shareItem.tintColor = [UIColor blackColor];
        self.navigationItem.rightBarButtonItem = shareItem;
        self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
        
        self.tagHeaderView.hidden = YES; //隐藏tagHeaderView
        
    } else if (offsetY > NAV_BAR_CHANGE_THRESHOLD) {
        navBarAlpha = 1.0f;
        navTitleAlpha = 1.0f;
        [self setBackBarButtonItemStyle:GFBackBarButtonItemStyleBackDark];
        
        UIBarButtonItem *shareItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_share_dark"] target:self selector:@selector(shareBarItemAction:)];
        shareItem.tintColor = [UIColor blackColor];
        self.navigationItem.rightBarButtonItem = shareItem;
        self.gf_StatusBarStyle = UIStatusBarStyleDefault;
        //将tagHeaderView显示出来
        self.tagHeaderView.hidden = NO;
    }
    
    self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:navTitleAlpha];
    [self gf_setNavBarBackgroundTransparent:navBarAlpha];
    
    if ((-250) - scrollView.contentOffset.y > 50 && scrollView.isDragging && self.refreshImageView.hidden == YES) {
        [self doRefreshAnimate];
        self.refreshImageView.hidden = NO;
    }
    if (self.refreshImageView.hidden == NO && self.tagHeaderView.hidden == NO) {
        self.tagHeaderView.hidden = YES;
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
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= SCROLL_VIEW_INI_OFFSET_Y && offsetY <= NAV_BAR_CHANGE_THRESHOLD) {
        self.tagHeaderView.hidden = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for (UICollectionViewCell *cell in [self.contentCollectionView visibleCells]) {
        if ([cell isKindOfClass:[GFFeedArticleCell class]] || [cell isKindOfClass:[GFFeedPictureCell class]]) {
            [cell performSelector:@selector(startLoadingImages)];
        }
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= SCROLL_VIEW_INI_OFFSET_Y && offsetY <= NAV_BAR_CHANGE_THRESHOLD) {
        self.tagHeaderView.hidden = YES;
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= SCROLL_VIEW_INI_OFFSET_Y && offsetY <= NAV_BAR_CHANGE_THRESHOLD) {
        self.tagHeaderView.hidden = YES;
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

#pragma mark - Share Activity
- (void)shareBarItemAction:(UIBarButtonItem *)item {
    [MobClick event:@"gf_bq_02_04_04_1"];
    [[self shareActivityViewControllerWithParams:nil] showIn:self];
}

- (NTESActivityViewController *)shareActivityViewControllerWithParams:(NSDictionary *)params {
    
    NTESWeixinSessionShareActivity *weixinSession = [self getWeixinSessionActivityWithParams:params];
    NTESWeixinTimelineShareActivity *weixinTimeline = [self getWeixinTimelineActivityWithParams:params];
    NTESSinaWeiboShareActivity *sinaWeibo = [self getSinaWeiboActivityWithParams:params];
    NTESQQSessionShareActivity *qq = [self getQQSessionActivityWithParams:params];
    NTESQzoneShareActivity *qzone = [self getQzoneActivityWithParams:params];
    GFCopyUrlActionActivity *copy = [self getCopyUrlActionActivityWithParams:params];
    
    NSArray *activities = @[weixinSession, weixinTimeline, sinaWeibo, qq, qzone, copy];
    self.shareViewController.applicationActivities = activities;
    __weak typeof(self) weakSelf = self;
    self.shareViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (!activityType) { //复制链接
            if (completed) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                hud.labelText = @"已经复制到剪贴板";
                hud.mode = MBProgressHUDModeText;
                hud.removeFromSuperViewOnHide  =YES;
                hud.userInteractionEnabled = NO;
                [hud hide:YES afterDelay:kCommonHudDuration];
                
            }
            [MobClick event:@"gf_bq_02_04_10_1"];
        } else {
            GFShareType shareType = [activityType gf_shareType];
            switch (shareType) {
                case GFShareTypeQQ: {
                    [MobClick event:@"gf_bq_02_04_06_1"];
                    break;
                }
                case GFShareTypeQZone: {
                    [MobClick event:@"gf_bq_02_04_05_1"];
                    break;
                }
                case GFShareTypeWeChat: {
                    [MobClick event:@"gf_bq_02_04_07_1"];
                    break;
                }
                case GFShareTypeTimeline: {
                    [MobClick event:@"gf_bq_02_04_08_1"];
                    break;
                }
                case GFShareTypeWeibo: {
                    [MobClick event:@"gf_bq_02_04_09_1"];
                    break;
                }
            }
            
        }
    };
    return self.shareViewController;
}

- (NTESWeixinSessionShareActivity *)getWeixinSessionActivityWithParams:(NSDictionary *)params {
    
    
    return [[NTESWeixinSessionShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeWeChat]
                                                         image:nil
                                                    thumbImage:[self thumbImageForShareType:GFShareTypeWeChat]
                                                         title:[self titleForShareType:GFShareTypeWeChat]
                                                   description:[self descriptionForShareType:GFShareTypeWeChat]];
}

- (NTESWeixinTimelineShareActivity *)getWeixinTimelineActivityWithParams:(NSDictionary *)params {
    
    return [[NTESWeixinTimelineShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeTimeline]
                                                          image:nil
                                                     thumbImage:[self thumbImageForShareType:GFShareTypeTimeline]
                                                          title:[self titleForShareType:GFShareTypeTimeline]
                                                    description:nil];
}

- (NTESQQSessionShareActivity *)getQQSessionActivityWithParams:(NSDictionary *)params {
    
    return [[NTESQQSessionShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeQQ]
                                                     image:nil
                                                thumbImage:[self thumbImageForShareType:GFShareTypeQQ]
                                                     title:[self titleForShareType:GFShareTypeQQ]
                                               description:[self descriptionForShareType:GFShareTypeQQ]];
}

- (NTESQzoneShareActivity *)getQzoneActivityWithParams:(NSDictionary *)params {
    
    return [[NTESQzoneShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeQZone]
                                                 image:nil
                                            thumbImage:[self thumbImageForShareType:GFShareTypeQZone]
                                                 title:[self titleForShareType:GFShareTypeQZone]
                                           description:[self descriptionForShareType:GFShareTypeQZone]];
}

- (NTESSinaWeiboShareActivity *)getSinaWeiboActivityWithParams:(NSDictionary *)params {
    
    return [[NTESSinaWeiboShareActivity alloc] initWithURL:[self urlForShareType:GFShareTypeWeibo]
                                                     image:[self thumbImageForShareType:GFShareTypeWeibo]
                                                thumbImage:[self thumbImageForShareType:GFShareTypeWeibo]
                                                     title:[self titleForShareType:GFShareTypeWeibo]
                                               description:[self descriptionForShareType:GFShareTypeWeibo]];
}

- (GFCopyUrlActionActivity *)getCopyUrlActionActivityWithParams:(NSDictionary *)params {
    NSString *url = [NSString stringWithFormat:@"%@/publish/tag?id=%@", GF_API_BASE_URL, self.tag.tagInfo.tagId];
    GFCopyUrlActionActivity *activity = [[GFCopyUrlActionActivity alloc] initWithUrl:url];
    return activity;
}

- (NSString *)urlForShareType:(GFShareType)type {
    NSString *url = [NSString stringWithFormat:@"%@/publish/tag?id=%@", GF_API_BASE_URL, self.tag.tagInfo.tagId];
    
    return url;
    
//    NSString *url = [GF_API_BASE_URL stringByAppendingPathComponent:[NSString stringWithFormat:@"publish/tag?id=%@", self.tag.tagInfo.tagId]];
//    return url;
}

- (UIImage *)imageForShareType:(GFShareType)type {
    
    return self.shareImage ? self.shareImage : [UIImage imageNamed:@"default_share_logo"];
}

- (UIImage *)thumbImageForShareType:(GFShareType)type {
    
    return [self imageForShareType:type];
}

- (NSString *)titleForShareType:(GFShareType)type {
    return [NSString stringWithFormat:@"我在盖范发现一个好的标签 \"%@\"", self.tag.tagInfo.tagName];
}

- (NSString *)descriptionForShareType:(GFShareType)type {
    NSString *desc = self.tag.tagInfo.tagDescription;
    
    if (type == GFShareTypeWeibo) {
        desc = [desc stringByAppendingString:[self urlForShareType:GFShareTypeWeibo]];
    }
    
    if ([desc length] > 500) {
        desc = [desc substringToIndex:500];
    }
    return desc;
}


- (void)prepareImageForShare:(GFTagMTL *)tag {
    NSString *url;
    if(self.tag.tagInfo.frontImageUrl) {
        url = ((GFPictureMTL*)[tag.pictures objectForKey:self.tag.tagInfo.frontImageUrl]).url;
    }
    if (url) {
#warning 图片剪裁标准未确定
        url = [url gf_urlAppendWithHorizontalEdge:100 verticalEdge:100 mode:GFImageProcessModeMinWidthMinHeightCut convertGIF:YES];
        __weak typeof(self) weakSelf = self;
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:url] options:YYWebImageOptionShowNetworkActivity progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } transform: nil
         completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            weakSelf.shareImage = image;
        }];

    }
}

#pragma mark - 发布消息以后的回调
- (void)didPublishedContentChanged:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    if ([notification.name isEqualToString:GFNotificationPublishStateUpdate]) {
        id updateModel = userInfo[kPublishNotificationUserInfoKeyData];
        //检测是不是发布的内容模型
        if ([updateModel isKindOfClass:[GFContentMTL class]]) {
            GFPublishMTL *originTask = userInfo[kPublishNotificationUserInfoKeyOrigin];
            //检测是不是发布的标签模型
            if (self.tagId && [originTask.tagId isEqualToNumber:self.tagId]) {
                @synchronized (self.contentDataSource) {
                    [self.contentDataSource insertObject:(GFContentMTL *)updateModel atIndex:0];
                }
                [self.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
            }
        } else if([updateModel isKindOfClass:[GFPublishMTL class]]) {
            //发送失败
            GFPublishMTL *updatePublishMTL = updateModel;
            if (self.tagId && [updatePublishMTL.tagId isEqualToNumber:self.tagId]) {
                GFPublishState state = updatePublishMTL.state.integerValue;
                if (GFPublishStateFailed == state) {
                    
                    NSString *msg = userInfo[kPublishNotificationUserInfoKeyMsg];
                    if (!msg) {
                        msg = @"未知错误";
                    }
                    
                    __weak typeof(self) weakSelf = self;
                    [UIAlertView bk_showAlertViewWithTitle:@"发送失败" message:msg cancelButtonTitle:@"我知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [weakSelf.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
                    }];
                } else if(state == GFPublishStateSending) { //提示发送中状态
                    [self.contentCollectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
                }
            }
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GFNotificationPublishStateUpdate object:nil];
}
@end