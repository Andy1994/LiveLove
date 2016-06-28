//
//  GFProfileViewController.m
//  GetFun
//
//  Created by zhouxz on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFProfileViewController.h"
#import "GFProfileInfoView.h"
#import "GFFeedArticleCell.h"
#import "GFFeedVoteCell.h"
#import "GFFeedLinkCell.h"
#import "GFFeedPictureCell.h"
#import "GFFunAndCommentRecordCell.h"
#import "GFProfileUserGuideView.h"

#import "GFProfileUpdateViewController.h"
#import "GFSettingViewController.h"
#import "GFContentMTL.h"
#import "GFContentInfoMTL.h"
#import "GFNetworkManager+User.h"
#import "GFNetworkManager+Content.h"
#import "GFNetworkManager+Comment.h"

#import "GFMyGroupViewController.h"
#import "GFOtherGroupViewController.h"
#import "GFMyFollowerListViewController.h"
#import "GFMyFolloweeListViewController.h"
#import "GFOtherFollowerListViewController.h"
#import "GFOtherFolloweeListViewController.h"

#import "GFAccountManager.h"
#import "GFNetworkManager+Group.h"
#import "GFContentDetailViewController.h"
#import "GFGroupInfoViewController.h"
#import "GFContentTipView.h"
#import "GFLessonViewController.h"
#import "GFImageGroupView.h"
#import "GFNetworkManager+Follow.h"

NSString * const GFUserDefaultsKeyLastVersionForProfileUserGuide = @"GFUserDefaultsKeyLastVersionForProfileUserGuide"; //用户引导提示标记，只有在有用户引导时才会使用，请勿删除！！

//用于标记各个Feed流上拉刷新显示状态的键值
static NSString * const GFProfilePublishFeedKey =@"GFProfilePublishFeedKey";
static NSString * const GFProfilePaticipateFeedKey =@"GFProfilePaticipateFeedKey";
static NSString * const GFProfileFunFeedKey =@"GFProfileFunFeedKey";
static NSString * const GFProfileCommentFeedKey =@"GFProfileCommentFeedKey";

typedef NS_ENUM(NSUInteger, GFProfileRightBarButtonState) {
    GFProfileRightBarButtonStateHidden,
    GFProfileRightBarButtonStateDark,
    GFProfileRightBarButtonStateLight,
};

@interface GFProfileViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) GFProfileMTL *profileMTL;
@property (nonatomic, strong) NSArray *groupList;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *profileCollectionView;
@property (nonatomic, strong) UIImageView *noMessageImageView; //提示没有内容
@property (nonatomic, strong) GFProfileUserGuideView *profileUserGuideView; //提示没有内容

@property (nonatomic, assign) NSInteger currentSegmentedIndex;

@property (nonatomic, strong) NSMutableArray<GFContentMTL *> *publishDataSource; // 发布过的
@property (nonatomic, strong) NSMutableArray<GFContentMTL *> *participateDataSource; // 参与过的
@property (nonatomic, strong) NSNumber *funRefQueryTime; // 服务器返回的ref
@property (nonatomic, strong) NSMutableArray<GFFunRecordMTL *> *funDataSource; // fun过的
@property (nonatomic, strong) NSNumber *commentedRefQueryTime; // 服务器返回的ref
@property (nonatomic, strong) NSMutableArray<GFCommentMTL *> *commentedDataSource; // 评论过的
@property (nonatomic, strong) NSMutableDictionary *headerDictionary; //由于API版本问题，使用字典保存Header视图，键类型为NSIndexPath
@property (nonatomic, copy) NSMutableDictionary<NSString*, NSNumber *> *showInfiniteScrollingViewFlags; //标记四个部分各自showInfiniteScrollingView是否显示状态
@property (nonatomic, assign) GFProfileRightBarButtonState rightBarButtonState;
@end

@implementation GFProfileViewController

- (GFProfileUserGuideView *)profileUserGuideView {
    if (!_profileUserGuideView) {
        _profileUserGuideView = [[GFProfileUserGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _profileUserGuideView.hidden = YES;
    }
    return _profileUserGuideView;
}
-(NSMutableDictionary *)headerDictionary
{
    if (!_headerDictionary) {
        _headerDictionary = [[NSMutableDictionary alloc] init];
    }
    return _headerDictionary;
}

-(NSMutableDictionary<NSString*, NSNumber *> *)showInfiniteScrollingViewFlags{
    if (!_showInfiniteScrollingViewFlags) {
        NSDictionary *kv = @{GFProfilePublishFeedKey:@YES, GFProfilePaticipateFeedKey:@YES, GFProfileFunFeedKey:@YES, GFProfileCommentFeedKey:@YES};
        _showInfiniteScrollingViewFlags = [[NSMutableDictionary alloc] initWithDictionary:kv];
    }
    return _showInfiniteScrollingViewFlags;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _titleLabel.centerX = SCREEN_WIDTH / 2;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"个人主页";
    }
    return _titleLabel;
}

- (UIImageView *)noMessageImageView {
    if (!_noMessageImageView) {
        _noMessageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_no_msg"]];
        [_noMessageImageView sizeToFit];        
        //获取个人资料后计算上方高度，根据屏幕高度动态计算下方无内容时提示图中心位置，适配不同尺寸
        //不同尺寸要在底部空白处居中
        CGFloat height = [GFProfileInfoView heightWithModel:self.profileMTL];
        self.noMessageImageView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT - height)/2 + height);
        _noMessageImageView.hidden = YES;
    }
    return _noMessageImageView;
}

- (UICollectionView *)profileCollectionView {
    if (!_profileCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _profileCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _profileCollectionView.backgroundColor = [UIColor clearColor];
        _profileCollectionView.showsVerticalScrollIndicator = NO;
        _profileCollectionView.delegate = self;
        _profileCollectionView.dataSource = self;
        [_profileCollectionView registerClass:[GFProfileInfoView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFProfileInfoView class])];
        [_profileCollectionView registerClass:[GFFeedArticleCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class])];
        [_profileCollectionView registerClass:[GFFeedLinkCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class])];
        [_profileCollectionView registerClass:[GFFeedVoteCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class])];
        [_profileCollectionView registerClass:[GFFeedPictureCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class])];
        [_profileCollectionView registerClass:[GFFunAndCommentRecordCell class] forCellWithReuseIdentifier:NSStringFromClass([GFFunAndCommentRecordCell class])];
    }
    return _profileCollectionView;
}

- (instancetype)initWithUserID:(NSNumber *)userID {
    if (self = [super init]) {
        _iniUserID = userID;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideFooterImageView:YES];
    self.navigationItem.titleView = self.titleLabel;
    self.rightBarButtonState = GFProfileRightBarButtonStateLight;
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackLight;
    [self.view addSubview:self.profileCollectionView];
    [self.view addSubview:self.noMessageImageView];
    __weak typeof(self) weakSelf = self;
    [self.profileCollectionView addInfiniteScrollingWithActionHandler:^{
        switch (weakSelf.currentSegmentedIndex) {
            case 0:
                [weakSelf queryUserPublishedContentWithHUD:NO];
                break;
            case 1:
                [weakSelf queryParticipateContentWithHUD:NO];
                break;
            case 2:
                [weakSelf queryFunContentWithHUD:NO];
                break;
            case 3:
                [weakSelf queryCommentedContentWithHUD:NO];
                break;
            default:
                break;
        }
    }];
    
    self.publishDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    self.participateDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    self.funDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    self.commentedDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self gf_setNavBarBackgroundTransparent:0.0f];
    self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
    [self queryUserPublishedContentWithHUD:YES];
    
    //用户引导， 判断是否第一次安装，以便决定是否显示提示蒙层
    NSString *lastVersion = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyLastVersionForProfileUserGuide];
    if (!lastVersion || APP_VERSION_GREATER_THAN(lastVersion)) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.profileUserGuideView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self queryUserProfile];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.profileUserGuideView removeFromSuperview];
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_gr_01_08_01_1"];
    [super backBarButtonItemSelected];
}

#pragma mark - Action
- (void)settingBarButtonItemSelected {
    [MobClick event:@"gf_gr_01_07_01_1"];
    GFSettingViewController *settingViewController = [[GFSettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

#pragma mark - Methods
- (void)setRightBarButtonState:(GFProfileRightBarButtonState)rightBarButtonState {
    _rightBarButtonState = rightBarButtonState;
    switch (_rightBarButtonState) {
        case GFProfileRightBarButtonStateHidden: {
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
        case GFProfileRightBarButtonStateDark: {
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_setting_dark"] target:self selector:@selector(settingBarButtonItemSelected)];
            break;
        }
        case GFProfileRightBarButtonStateLight: {
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem gf_barButtonItemWithImage:[UIImage imageNamed:@"nav_setting_light"] target:self selector:@selector(settingBarButtonItemSelected)];
            break;
        }
    }
}

- (void)queryUserProfile {
    @weakify(self)
    [GFNetworkManager queryProfileForUser:self.iniUserID
                                  success:^(NSUInteger taskId, NSInteger code, GFProfileMTL *profileMTL) {
                                      @strongify(self)

                                      if (code == 1) {
                                          self.profileMTL = profileMTL;
                                          [self.profileCollectionView reloadData];

                                          //判断是否显示设置按钮
                                          GFUserMTL *loginUser = [GFAccountManager sharedManager].loginUser;
                                          BOOL isSelf = loginUser && self.profileMTL.user.userId && [loginUser.userId isEqualToNumber:self.profileMTL.user.userId];
                                          if (!isSelf) {
                                              self.rightBarButtonState = GFProfileRightBarButtonStateHidden;
                                          }
                                          
                                          //更新个人资料后计算上方高度，根据屏幕高度动态计算下方无内容时提示图中心位置，适配不同尺寸不同尺寸要在底部空白处居中
                                          CGFloat height = [GFProfileInfoView heightWithModel:self.profileMTL];
                                          self.noMessageImageView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT - height)/2 + height);
                                          
                                          //新功能用户引导
                                          if (!isSelf) {  //只有浏览其他用户个人主页时才显示关注按钮，不用考虑是否登录
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                  CGPoint viewOrigin = CGPointZero;
                                                  CGRect viewFrame = CGRectZero;
                                                  GFProfileInfoView * profileInfoView = (GFProfileInfoView *)[self.headerDictionary objectForKey:[NSIndexPath indexPathForItem:0 inSection:0]];

                                                  UIButton *followButton = profileInfoView.followButton;
                                                  
                                                  viewFrame = [self.profileUserGuideView convertRect:followButton.frame fromView:followButton.superview];
                                                  viewOrigin = viewFrame.origin;
                                                  
                                                  if (!(viewOrigin.x == 0 && viewOrigin.y == 0)) {
                                                      [self.profileUserGuideView setFollowButtonFrame:viewFrame];
                                                      self.profileUserGuideView.hidden = NO;
                                                      [GFUserDefaultsUtil setObject:APP_VERSION forKey:GFUserDefaultsKeyLastVersionForProfileUserGuide];
                                                  }
                                              });
                                          }
                                      }
                                  } failure:^(NSUInteger taskId, NSError *error) {
                                      //
                                  }];
}

- (void)queryUserPublishedContentWithHUD:(BOOL)showHUD {
    MBProgressHUD *hud = nil;
    if (showHUD) {
        hud = [MBProgressHUD showLoadingHUDWithTitle:nil inView:self.view];
        hud.yOffset = 100.0f;
    }
    
    NSNumber *refPublishTime = nil;
    GFContentMTL *contentMTL = [self.publishDataSource lastObject];
    if (contentMTL) {
        refPublishTime = contentMTL.contentInfo.createTime;
    }
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager queryPublishedContentWithUserId:self.iniUserID
                                       refPublishTime:refPublishTime
                                                count:kQueryDataCount
                                              success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFContentMTL *> *contentList) {
                                                  [weakSelf.profileCollectionView finishInfiniteScrolling];
                                                  
                                                  if (showHUD) {
                                                      [hud hide:YES];
                                                  }
                                                  
                                                  if (code == 1) {
                                                      [weakSelf.showInfiniteScrollingViewFlags setObject:@([contentList count] > 0) forKey:GFProfilePublishFeedKey];
                                                      weakSelf.profileCollectionView.showsInfiniteScrolling = [[weakSelf.showInfiniteScrollingViewFlags objectForKey:GFProfilePublishFeedKey] boolValue];
                                                      
                                                      if (contentList) {
                                                          [weakSelf.publishDataSource addObjectsFromArray:contentList];
                                                          [weakSelf.profileCollectionView reloadData];
                                                      }
                                                  } else {
                                                      [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration];
                                                  }
                                                  weakSelf.noMessageImageView.hidden = weakSelf.publishDataSource.count > 0 || weakSelf.currentSegmentedIndex != 0;
                                                  
                                              } failure:^(NSUInteger taskId, NSError *error) {
                                                  if (showHUD) {
                                                      [hud hide:YES];
                                                  }
                                                  [weakSelf.profileCollectionView finishInfiniteScrolling];
                                                  weakSelf.noMessageImageView.hidden = weakSelf.publishDataSource.count > 0 || weakSelf.currentSegmentedIndex != 0;
                                                  [weakSelf.profileCollectionView finishInfiniteScrolling];

                                              }];
}

- (void)queryParticipateContentWithHUD:(BOOL)showHUD {
    MBProgressHUD *hud = nil;
    if (showHUD) {
        hud = [MBProgressHUD showLoadingHUDWithTitle:nil inView:self.view];
        hud.yOffset = 100.0f;
    }
    
    NSNumber *refPublishTime = nil;
    GFContentMTL *contentMTL = [self.participateDataSource lastObject];
    if (contentMTL) {
        refPublishTime = contentMTL.contentInfo.createTime;
    }
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager queryParticipateContentWithUserId:self.iniUserID
                                         refPublishTime:refPublishTime
                                                  count:kQueryDataCount
                                                success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFContentMTL *> *contentList) {
                                                    [weakSelf.profileCollectionView finishInfiniteScrolling];
                                                    
                                                    if (showHUD) {
                                                        [hud hide:YES];
                                                    }
                                                    if (code == 1) {
                                                        [weakSelf.showInfiniteScrollingViewFlags setObject:@([contentList count] > 0) forKey:GFProfilePaticipateFeedKey];
                                                        weakSelf.profileCollectionView.showsInfiniteScrolling = [weakSelf.showInfiniteScrollingViewFlags[GFProfilePaticipateFeedKey] boolValue];
                                                        
                                                        if (contentList) {
                                                            [weakSelf.participateDataSource addObjectsFromArray:contentList];
                                                            [weakSelf.profileCollectionView reloadData];
                                                        }
                                                    } else {
                                                        [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration];
                                                    }
                                                     weakSelf.noMessageImageView.hidden = weakSelf.participateDataSource.count > 0 || weakSelf.currentSegmentedIndex != 1;
                                                    
                                                } failure:^(NSUInteger taskId, NSError *error) {
                                                    if (showHUD) {
                                                        [hud hide:YES];
                                                    }
                                                    [weakSelf.profileCollectionView finishInfiniteScrolling];
                                                    weakSelf.noMessageImageView.hidden = weakSelf.participateDataSource.count > 0 || weakSelf.currentSegmentedIndex != 1;
                                                }];
}

- (void)queryFunContentWithHUD:(BOOL)showHUD {
    MBProgressHUD * hud = nil;
    if (showHUD) {
        hud = [MBProgressHUD showLoadingHUDWithTitle:nil inView:self.view];
        hud.yOffset = 100.0f;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getFunRecordWithUserId:self.iniUserID
                                refQueryTime:self.funRefQueryTime
                                     success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSNumber *refQueryTime, GFUserMTL *user, NSArray<GFFunRecordMTL *> *funRecords) {
                                         [weakSelf.profileCollectionView finishInfiniteScrolling];
                                         
                                         if (showHUD) {
                                             [hud hide:YES];
                                         }
                                         
                                         if (code == 1) {
                                             weakSelf.funRefQueryTime = refQueryTime;
                                             //设置是否可见
                                             [weakSelf.showInfiniteScrollingViewFlags setObject:@([weakSelf.funRefQueryTime integerValue] != -1) forKey:GFProfileFunFeedKey];
                                             weakSelf.profileCollectionView.showsInfiniteScrolling = [[weakSelf.showInfiniteScrollingViewFlags objectForKey:GFProfileFunFeedKey] boolValue];
                                             if (funRecords) {
                                                 [weakSelf.funDataSource addObjectsFromArray:funRecords];
                                                 [weakSelf.profileCollectionView reloadData];
                                             }
                                         } else {
                                             NSString *msg = [apiErrorMessage length] > 0 ? apiErrorMessage : @"获取fun纪录失败";
                                             [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration];
                                         }
                                         
                                         weakSelf.noMessageImageView.hidden = weakSelf.funDataSource.count > 0 || weakSelf.currentSegmentedIndex != 2;
                                         
                                     } failure:^(NSUInteger taskId, NSError *error) {
                                         if (showHUD) {
                                             [hud hide:YES];
                                         }
                                         [weakSelf.profileCollectionView finishInfiniteScrolling];
                                         weakSelf.noMessageImageView.hidden = weakSelf.funDataSource.count > 0 || weakSelf.currentSegmentedIndex != 2;
                                     }];
}

- (void)queryCommentedContentWithHUD:(BOOL)showHUD {
    MBProgressHUD *hud = nil;
    if (showHUD) {
        hud = [MBProgressHUD showLoadingHUDWithTitle:nil inView:self.view];
        hud.yOffset = 100.0f;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCommentsByUserId:self.iniUserID
                                queryTime:self.commentedRefQueryTime
                                  success:^(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSString *errorMessage) {
                                      [weakSelf.profileCollectionView finishInfiniteScrolling];
                                      if (showHUD) {
                                          [hud hide:YES];
                                      }
                                      if (code == 1) {
                                          weakSelf.commentedRefQueryTime = nextQueryTime;
                                          [weakSelf.showInfiniteScrollingViewFlags setObject:@([weakSelf.commentedRefQueryTime integerValue]!=-1) forKey:GFProfileCommentFeedKey];
                                          weakSelf.profileCollectionView.showsInfiniteScrolling = [[weakSelf.showInfiniteScrollingViewFlags objectForKey:GFProfileCommentFeedKey] boolValue];
                                          
                                          if (comments) {
                                              [weakSelf.commentedDataSource addObjectsFromArray:comments];
                                              [weakSelf.profileCollectionView reloadData];
                                          }
                                      } else {
                                          NSString *msg = [errorMessage length] > 0 ? errorMessage :@"获取评论失败";
                                          [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration];
                                      }
                                      weakSelf.noMessageImageView.hidden = weakSelf.commentedDataSource.count > 0 || weakSelf.currentSegmentedIndex != 3;
                                      
                                  } failure:^(NSUInteger taskId, NSError *error) {
                                      if (showHUD) {
                                          [hud hide:YES];
                                      }
                                      [weakSelf.profileCollectionView finishInfiniteScrolling];
                                      weakSelf.noMessageImageView.hidden = weakSelf.commentedDataSource.count > 0 || weakSelf.currentSegmentedIndex != 3;
                                  }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (self.currentSegmentedIndex) {
        case 0:
            numberOfRows = [self.publishDataSource count];
            break;
        case 1:
            numberOfRows = [self.participateDataSource count];
            break;
        case 2:
            numberOfRows = [self.funDataSource count];
            break;
        case 3:
            numberOfRows = [self.commentedDataSource count];
            break;
            
        default:
            break;
    }
    
    return numberOfRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = [self modelForCellAtIndexPath:indexPath];
    UICollectionViewCell *cell = nil;
    if ([model isKindOfClass:[GFContentMTL class]]) { // selectedSegmentIndex == 0,1
        GFContentMTL *contentMTL = model;

        GFUserInfoHeaderStyle headerStyle = GFUserInfoHeaderStyleDefault;
        if (self.currentSegmentedIndex == 0) {
            headerStyle = GFUserInfoHeaderStyleDate;
            GFUserMTL *loginUser = [GFAccountManager sharedManager].loginUser;
            if (loginUser.userId && [self.iniUserID isEqualToNumber:loginUser.userId]) {
                headerStyle = GFUserInfoHeaderStyleDateAndDelete;
            }
        } else if (self.currentSegmentedIndex == 1) {
            headerStyle = GFUserInfoHeaderStyleDefault;
        }
        
        @weakify(self)
        switch (contentMTL.contentInfo.type) {
            case GFContentTypeArticle: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedArticleCell class]) forIndexPath:indexPath];
                [[(GFFeedContentCell *)cell userInfoHeader] setStyle:headerStyle];
                [(GFFeedArticleCell *)cell bindWithModel:model];
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
                if (!collectionView.isDragging && !collectionView.isDecelerating) {
                    [(GFFeedArticleCell *)cell startLoadingImages];
                }
                break;
            }
            case GFContentTypeLink: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedLinkCell class]) forIndexPath:indexPath];
                [[(GFFeedContentCell *)cell userInfoHeader] setStyle:headerStyle];
                [(GFFeedLinkCell *)cell bindWithModel:model];
                break;
            }
            case GFContentTypeVote: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedVoteCell class]) forIndexPath:indexPath];
                [[(GFFeedContentCell *)cell userInfoHeader] setStyle:headerStyle];
                [(GFFeedVoteCell *)cell bindWithModel:model];
                break;
            }
            case GFContentTypePicture: {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFeedPictureCell class]) forIndexPath:indexPath];
                [[(GFFeedContentCell *)cell userInfoHeader] setStyle:headerStyle];
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
            default: {
                break;
            }
        }
        
        [[(GFFeedContentCell *)cell userInfoHeader] setDate:[contentMTL.contentInfo.createTime longLongValue] / 1000];
        
        __weak typeof(self) weakSelf = self;
        [(GFFeedContentCell *)cell setFloatFunHandler:^(GFContentMTL *content) {
            if (weakSelf.currentSegmentedIndex == 0) {
                switch (contentMTL.contentInfo.type) {
                        
                    case GFContentTypeArticle: {
                        [MobClick event:@"gf_gr_01_01_11_1"];
                        break;
                    }
                    case GFContentTypeVote: {
                        [MobClick event:@"gf_gr_01_01_13_1"];
                        break;
                    }
                    case GFContentTypeLink: {
                        [MobClick event:@"gf_gr_01_01_12_1"];
                        break;
                    }
                    case GFContentTypePicture: {
                        break;
                    }
                    case GFContentTypeUnknown: {
                        break;
                    }
                }
            } else if(weakSelf.currentSegmentedIndex == 1) {
                [MobClick event:@"gf_gr_01_02_04_1"];
            }
            
            [weakSelf.profileCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
        
        if (self.currentSegmentedIndex == 0) {
            __weak typeof(self) weakSelf = self;
            [[(GFFeedContentCell *)cell userInfoHeader] setDeleteHandler:^{
                
                switch (contentMTL.contentInfo.type) {
                    case GFContentTypeArticle: {
                        [MobClick event:@"gf_gr_01_01_04_1"];
                        break;
                    }
                    case GFContentTypeVote: {
                        [MobClick event:@"gf_gr_01_01_10_1"];
                        break;
                    }
                    case GFContentTypeLink: {
                        [MobClick event:@"gf_gr_01_01_07_1"];
                        break;
                    }
                    case GFContentTypePicture: {
                        break;
                    }
                    case GFContentTypeUnknown: {
                        break;
                    }
                }
                
                [UIAlertView bk_showAlertViewWithTitle:@"确认删除?" message:@"" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        
                        NSInteger row = [weakSelf.publishDataSource indexOfObject:contentMTL];
                        NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:row inSection:0];
                        
                        [weakSelf.publishDataSource removeObject:contentMTL];
                        [weakSelf.profileCollectionView deleteItemsAtIndexPaths:@[indexPathToDelete]];
                        
                        NSInteger publishCount = [weakSelf.profileMTL.publishCount integerValue];
                        NSInteger updatePublishCount = publishCount >= 1 ? publishCount-1 : 0;
                        weakSelf.profileMTL.publishCount = @(updatePublishCount);
                        
//                        GFProfileInfoView *profileInfoView = (GFProfileInfoView *)[weakSelf.profileCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                          GFProfileInfoView *profileInfoView = (GFProfileInfoView *)[weakSelf.headerDictionary objectForKey:[NSIndexPath indexPathForRow:0 inSection:0]];
                        [profileInfoView.segmentedControl setNeedsDisplay];
                        
                        [GFNetworkManager deleteContentWithContentId:contentMTL.contentInfo.contentId
                                                             success:NULL
                                                             failure:NULL];
                    }
                }];
            }];
        }
        
    } else if ([model isKindOfClass:[GFFunRecordMTL class]] || [model isKindOfClass:[GFCommentMTL class]]) { // selectedSegmentIndex == 2,3

        GFUserInfoHeaderStyle headerStyle = GFUserInfoHeaderStyleDate;
        [[(GFFunAndCommentRecordCell *)cell userInfoHeader] setStyle:headerStyle];
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFFunAndCommentRecordCell class]) forIndexPath:indexPath];
        [(GFFunAndCommentRecordCell *)cell bindWithModel:model user:self.profileMTL.user];

        GFContentMTL *contentMTL = nil;
        if ([model isKindOfClass:[GFFunRecordMTL class]]){
            contentMTL = [(GFFunRecordMTL*)model content];
        } else if([model isKindOfClass:[GFCommentMTL class]]){
            contentMTL = [(GFCommentMTL*)model content];
        }
        [[(GFFunAndCommentRecordCell *)cell userInfoHeader] setDate:[contentMTL.contentInfo.createTime longLongValue] / 1000];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    GFProfileInfoView *profileInfoView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFProfileInfoView class]) forIndexPath:indexPath];
    [self.headerDictionary setObject:profileInfoView forKey:indexPath];
    //由于setupBlocksForProfileInfoView中设置block依赖于profileMTL，因此更新数据需要在建立回调之前
    [profileInfoView updateWithProfile:self.profileMTL];
    [self setupBlocksForProfileInfoView:profileInfoView];
    return profileInfoView;
}
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    [self.headerDictionary removeObjectForKey:indexPath];
}
//当前查看个人是否为登录用户本人
- (BOOL)isSelf {
    BOOL isSelf = NO;
    GFUserMTL *loginUser = [GFAccountManager sharedManager].loginUser;
    if (self.iniUserID && [loginUser.userId isEqualToNumber:self.iniUserID]) {
        isSelf = YES;
    }
    
    return isSelf;
}

- (void)setupBlocksForProfileInfoView:(GFProfileInfoView *)profileInfoView {
    
    //触发一次事件，使第一次加载时数据进行显示
    profileInfoView.currentSegmentedIndex = self.currentSegmentedIndex;
    
    @weakify(self)
    [profileInfoView setGroupTapHandler:^{
        @strongify(self)
            if ([self isSelf]) {
                GFMyGroupViewController *myGroupViewController = [[GFMyGroupViewController alloc] init];
                [self.navigationController pushViewController:myGroupViewController animated:YES];
            } else {
                if ([self.profileMTL.interestGroupCount integerValue] > 0){
                GFOtherGroupViewController *otherGroupViewController = [[GFOtherGroupViewController alloc] initWithUserId:self.iniUserID];
                    [self.navigationController pushViewController:otherGroupViewController animated:YES];
                }
            }
    }];
    
    [profileInfoView setFollowerTapHandler:^{
        [MobClick event:@"gf_gr_01_12_01_1"];
        @strongify(self)
        if ([self.profileMTL.followerCount integerValue] > 0) {
            if ([self isSelf]) {
                GFMyFollowerListViewController *controller = [[GFMyFollowerListViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            } else {
                GFOtherFollowerListViewController *controller = [[GFOtherFollowerListViewController alloc] initWithUserId:self.profileMTL.user.userId];
                [self.navigationController pushViewController:controller animated:YES];            }
        }

    }];
    
    [profileInfoView setFolloweeTapHandler:^{
        [MobClick event:@"gf_gr_01_11_01_1"];
        @strongify(self)
        if ([self.profileMTL.followeeCount integerValue] > 0) {
            if ([self isSelf]) {
                GFMyFolloweeListViewController *controller = [[GFMyFolloweeListViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            } else {
                GFOtherFolloweeListViewController *controller = [[GFOtherFolloweeListViewController alloc] initWithUserId:self.profileMTL.user.userId];
                [self.navigationController pushViewController:controller animated:YES];            }
        }
    }];
    
    [profileInfoView setFollowButtonHandler:^(GFProfileInfoView *profileInfoView, GFFollowState followState) {
        switch ([self.profileMTL followState]) {
            case GFFollowStateNo: {
                [MobClick event:@"gf_gr_01_10_01_1"];
                break;
            }
            case GFFollowStateFollowing: {
                [MobClick event:@"gf_gr_01_10_02_1"];
                break;
            }
            case GFFollowStateFollowingEachOther: {
                [MobClick event:@"gf_gr_01_10_02_1"];
                break;
            }
        }
        
        
        @strongify(self)
        void (^followSuccess)(NSUInteger, NSInteger, NSString *) = ^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage){
            if (code == 1) {
                self.profileMTL.loginUserFollowUser = YES;
                self.profileMTL.followerCount = @([self.profileMTL.followerCount integerValue] + 1);

                if (!self.profileMTL.user.nickName || [self.profileMTL.user.nickName length] == 0) {
                    [MBProgressHUD showHUDWithTitle:@"关注成功" duration: kCommonHudDuration inView:self.view];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"对%@关注成功",self.profileMTL.user.nickName] duration: kCommonHudDuration inView:self.view];
                }
            } else {
                [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
            }
            [profileInfoView updateWithProfile:self.profileMTL];
        };
        void (^cancelFollowSuccess)(NSUInteger, NSInteger, NSString *) = ^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
            if (code == 1) {
                self.profileMTL.loginUserFollowUser = NO;
                self.profileMTL.followerCount = @([self.profileMTL.followerCount integerValue] - 1);
                
                if (!self.profileMTL.user.nickName || [self.profileMTL.user.nickName length] == 0) {
                    [MBProgressHUD showHUDWithTitle:@"已取消关注" duration: kCommonHudDuration inView:self.view];
                } else {
                    [MBProgressHUD showHUDWithTitle:[NSString stringWithFormat:@"已取消对%@的关注",self.profileMTL.user.nickName] duration: kCommonHudDuration inView:self.view];
                }

            } else {
                [MBProgressHUD showHUDWithTitle:apiErrorMessage duration:kCommonHudDuration inView:self.view];
            }
            [profileInfoView updateWithProfile:self.profileMTL];
        };
        
        void (^failure)(NSUInteger, NSError *) = ^(NSUInteger taskId, NSError * error){
            [MBProgressHUD showHUDWithTitle:@"网络出错" duration:kCommonHudDuration inView:self.view];
            [profileInfoView updateWithProfile:self.profileMTL];
        };
        
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user && !justLogin) {
                //防止重复点击
                NSNumber *userId = self.profileMTL.user.userId;
                switch ([self.profileMTL followState]) {
                    case GFFollowStateNo: {
                        [GFNetworkManager followWithUserId:userId success:followSuccess failure:failure];
                        break;
                    }
                    case GFFollowStateFollowing: {
                        [GFNetworkManager cancelFollowWithUserId:userId success:cancelFollowSuccess failure:failure];
                        break;
                    }
                    case GFFollowStateFollowingEachOther: {
                        [GFNetworkManager cancelFollowWithUserId:userId success:cancelFollowSuccess failure:failure];
                        break;
                    }
                }
            }
        }];
    }];
    
    [profileInfoView setDetailInfoButtonHandler:^{
        @strongify(self)
        [MobClick event:@"gf_gr_01_06_01_1"];
        GFProfileUpdateViewController *profileUpdateViewController = [[GFProfileUpdateViewController alloc] init];
        [self.navigationController pushViewController:profileUpdateViewController animated:YES];
    }];
    
    [profileInfoView setSegmentedControlHandler:^(NSInteger index) {
        @strongify(self)
        //切换时需要回复到初始默认状态
        self.noMessageImageView.hidden = YES;
        self.currentSegmentedIndex = index;
        
        //共享的是否显示上拉刷新状态需要在切换时进行设置
        BOOL showsInfiniteScrollingView = YES;
        switch (index) {
            case 0:
            {
                showsInfiniteScrollingView = [self.showInfiniteScrollingViewFlags[GFProfilePublishFeedKey] boolValue];
                break;
            }
            case 1:
            {
                showsInfiniteScrollingView = [self.showInfiniteScrollingViewFlags[GFProfilePaticipateFeedKey] boolValue];
                break;
            }
            case 2:
            {
                showsInfiniteScrollingView = [self.showInfiniteScrollingViewFlags[GFProfileFunFeedKey] boolValue];
                break;
            }
            case 3:
            {
                showsInfiniteScrollingView = [self.showInfiniteScrollingViewFlags[GFProfileCommentFeedKey] boolValue];
                break;
            }
            default:
                break;
        }
        self.profileCollectionView.showsInfiniteScrolling = showsInfiniteScrollingView;
        
        [self.profileCollectionView reloadData];
        
        if (index == 0) {
            [MobClick event:@"gf_gr_01_01_01_1"];
            if ([self.publishDataSource count] == 0) {
                [self queryUserPublishedContentWithHUD:YES];
        }
        } else if (index == 1) {
            [MobClick event:@"gf_gr_01_02_01_1"];
            if ([self.participateDataSource count] == 0) {
                [self queryParticipateContentWithHUD:YES];
            }
        } else if (index == 2) {
            [MobClick event:@"gf_gr_01_03_01_1"];
            if ([self.funDataSource count] == 0 && [self.funRefQueryTime integerValue] != -1) {
                [self queryFunContentWithHUD:YES];
            } else if([self.funDataSource count] == 0 && [self.funRefQueryTime integerValue] == -1) {
               self.noMessageImageView.hidden = NO;
            }
        } else if (index == 3) {
            [MobClick event:@"gf_gr_01_04_01_1"];
            if ([self.commentedDataSource count] == 0 && [self.commentedRefQueryTime integerValue] != -1) {
                [self queryCommentedContentWithHUD:YES];
            }else if([self.commentedDataSource count] == 0 && [self.commentedRefQueryTime integerValue] != -1) {
                self.noMessageImageView.hidden = NO;
            }
        }
        
        
    }];
    
    [profileInfoView setSegmentControlTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        @strongify(self)
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:14.0],NSFontAttributeName,
                                        [UIColor textColorValue1],NSForegroundColorAttributeName,nil];
        NSDictionary *numAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:12.0],NSFontAttributeName,
                                       [UIColor textColorValue4],NSForegroundColorAttributeName,nil];
        
        NSMutableAttributedString *titleAttrString = nil;
        NSAttributedString *numAttrString = nil;
        
        NSInteger contentCount = [self.profileMTL.publishCount integerValue];
        NSInteger participateCount = [self.profileMTL.participationCount integerValue];
        NSInteger funCount = [self.profileMTL.funCount integerValue];
        NSInteger commentCount = [self.profileMTL.commentCount integerValue];
        
        switch (index) {
            case 0:
            {
                titleAttrString = [[NSMutableAttributedString alloc] initWithString: contentCount==0? @"发布":@"发布 " attributes:textAttributes];
                numAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", contentCount==0? @"":@(contentCount)] attributes:numAttributes];
                break;
            }
            case 1:{
                titleAttrString = [[NSMutableAttributedString alloc] initWithString:participateCount==0 ?@"参与":@"参与 " attributes:textAttributes];
                numAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", participateCount==0? @"":@(participateCount)] attributes:numAttributes];
                
                break;
            }
            case 2:
            {
                titleAttrString = [[NSMutableAttributedString alloc] initWithString:funCount==0?@"FUN":@"FUN " attributes:textAttributes];
                numAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", funCount==0? @"":@(funCount)] attributes:numAttributes];
                break;
            }
            case 3:
            {
                titleAttrString = [[NSMutableAttributedString alloc] initWithString:commentCount==0?@"评论":@"评论 " attributes:textAttributes];
                numAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", commentCount==0? @"":@(commentCount)] attributes:numAttributes];
                break;
            }
            default:
                break;
        }
        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@""];
        [titleAttrString appendAttributedString:space];
        [titleAttrString appendAttributedString:numAttrString];
        return titleAttrString;
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    if (section == 0) {
        CGFloat height = [GFProfileInfoView heightWithModel:self.profileMTL];
        size = CGSizeMake(collectionView.width, height);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0.0f;
    
    id model = [self modelForCellAtIndexPath:indexPath];
    if ([model isKindOfClass:[GFContentMTL class]]) {
        GFContentMTL *contentMTL = model;
        switch (contentMTL.contentInfo.type) {
            case GFContentTypeArticle: {
                height = [GFFeedArticleCell heightWithModel:model];
                break;
            }
            case GFContentTypeLink: {
                height = [GFFeedLinkCell heightWithModel:model];
                break;
            }
            case GFContentTypeVote: {
                height = [GFFeedVoteCell heightWithModel:model];
                break;
            }
            case GFContentTypePicture: {
                height = [GFFeedPictureCell heightWithModel:model];
                break;
            }
            default: {
                break;
            }
        }
    } else if ([model isKindOfClass:[GFFunRecordMTL class]] || [model isKindOfClass:[GFCommentMTL class]]) {
        height = [GFFunAndCommentRecordCell heightWithModel:model];
    }
    return CGSizeMake(collectionView.width, height);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self modelForCellAtIndexPath:indexPath];
    GFContentMTL *contentMTL = nil;
    
    if ([model isKindOfClass:[GFContentMTL class]]) { // selectedSegmentIndex == 0,1
        
        contentMTL = model;
        
        if (self.currentSegmentedIndex == 0) {
            switch (contentMTL.contentInfo.type) {
                case GFContentTypeArticle: {
                    [MobClick event:@"gf_gr_01_01_03_1"];
                    break;
                }
                case GFContentTypeVote: {
                    [MobClick event:@"gf_gr_01_01_09_1"];
                    break;
                }
                case GFContentTypeLink: {
                    [MobClick event:@"gf_gr_01_01_06_1"];
                    break;
                }
                case GFContentTypePicture: {
                    break;
                }
                case GFContentTypeUnknown: {
                    break;
                }
            }
        } else {
            [MobClick event:@"gf_gr_01_02_03_1"];
        }
        
    } else if ([model isKindOfClass:[GFFunRecordMTL class]]) { // selectedSegmentIndex == 2
        contentMTL = ((GFFunRecordMTL *)model).content;
        
        switch (contentMTL.contentInfo.type) {
            case GFContentTypeArticle: {
                [MobClick event:@"gf_gr_01_03_03_1"];
                break;
            }
            case GFContentTypeVote: {
                [MobClick event:@"gf_gr_01_03_07_1"];
                break;
            }
            case GFContentTypeLink: {
                [MobClick event:@"gf_gr_01_03_05_1"];
                break;
            }
            case GFContentTypePicture: {
                break;
            }
            case GFContentTypeUnknown: {
                break;
            }
        }
        
    } else if ([model isKindOfClass:[GFCommentMTL class]]) {// selectedSegmentIndex == 3
        contentMTL = ((GFCommentMTL *)model).content;
        
        switch (contentMTL.contentInfo.type) {
            case GFContentTypeArticle: {
                [MobClick event:@"gf_gr_01_04_03_1"];
                break;
            }
            case GFContentTypeVote: {
                [MobClick event:@"gf_gr_01_04_07_1"];
                break;
            }
            case GFContentTypeLink: {
                [MobClick event:@"gf_gr_01_04_05_1"];
                break;
            }
            case GFContentTypePicture: {
                break;
            }
            case GFContentTypeUnknown: {
                break;
            }
        }
    }
    
    if (contentMTL && contentMTL.contentInfo.contentId) {
        
        if ([contentMTL isGetfunLesson]) {
        
            GFLessonViewController *lessonViewController = [[GFLessonViewController alloc] initWithContent:contentMTL];
            [self.navigationController pushViewController:lessonViewController animated:YES];
        
        } else {
            
            GFContentDetailViewController *controller = [[GFContentDetailViewController alloc] initWithContent:contentMTL contentType:contentMTL.contentInfo.type preview:NO keyFrom:GFKeyFromProfile];

            __weak typeof(self) weakSelf = self;
            controller.commentAndFunHandler = ^(GFContentMTL *content) {
                
                NSInteger row = -1;
                GFContentMTL *contentToUpdate = nil;
                if (weakSelf.currentSegmentedIndex == 0) {
                    row = [weakSelf.publishDataSource indexOfObject:content];
                    contentToUpdate = [weakSelf.publishDataSource objectAtIndex:row];

                } else if (weakSelf.currentSegmentedIndex == 1) {
                    
                    row = [weakSelf.participateDataSource indexOfObject:content];
                    contentToUpdate = [weakSelf.participateDataSource objectAtIndex:row];
                }
                
                if (row != -1) {
                    
                    contentToUpdate.contentInfo.funCount = content.contentInfo.funCount;
                    contentToUpdate.contentInfo.commentCount = content.contentInfo.commentCount;
                    contentToUpdate.actionStatuses = content.actionStatuses;
                    
                    NSIndexPath *indexPathForReload = [NSIndexPath indexPathForRow:row inSection:0];
                    [weakSelf.profileCollectionView reloadItemsAtIndexPaths:@[indexPathForReload]];
                }
            };

            controller.deleteContentHandler = ^(GFContentMTL *content) {
                NSInteger row = -1;
                if (weakSelf.currentSegmentedIndex == 0) {
                    row = [weakSelf.publishDataSource indexOfObject:content];
                    if (row != NSNotFound) {
                        [weakSelf.publishDataSource removeObjectAtIndex:row];
                        NSIndexPath *indexPathForReload = [NSIndexPath indexPathForRow:row inSection:0];
                        [weakSelf.profileCollectionView deleteItemsAtIndexPaths:@[indexPathForReload]];
                    }
                }

            };
            controller.voteHandler = ^(GFContentMTL *content, BOOL left) {
                NSInteger row = -1;
                if (weakSelf.currentSegmentedIndex == 0) {
                    if ([weakSelf.publishDataSource containsObject:content]) {
                        row = [weakSelf.publishDataSource indexOfObject:content];
                        if (row != -1 && row != NSNotFound) {
                            [weakSelf.publishDataSource replaceObjectAtIndex:row withObject:content];
                            NSIndexPath *indexpathUpdate = [NSIndexPath indexPathForItem:row inSection:0];
                            [weakSelf.profileCollectionView reloadItemsAtIndexPaths:@[indexpathUpdate]];
                        }
                    }
                }
                if (weakSelf.currentSegmentedIndex == 1) {
                    if ([weakSelf.participateDataSource containsObject:content]) {
                        row = [weakSelf.participateDataSource indexOfObject:content];
                        if (row != -1 && row != NSNotFound) {
                            [weakSelf.participateDataSource replaceObjectAtIndex:row withObject:content];
                            NSIndexPath *indexpathUpdate = [NSIndexPath indexPathForItem:row inSection:0];
                            [weakSelf.profileCollectionView reloadItemsAtIndexPaths:@[indexpathUpdate]];
                        }
                    }
                }
            };
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (id)modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = nil;
    switch (self.currentSegmentedIndex) {
        case 0:
            model = [self.publishDataSource objectAtIndex:indexPath.row];
            break;
        case 1:
            model = [self.participateDataSource objectAtIndex:indexPath.row];
            break;
        case 2:
            model = [self.funDataSource objectAtIndex:indexPath.row];
            break;
        case 3:
            model = [self.commentedDataSource objectAtIndex:indexPath.row];
            break;
            
        default:
            break;
    }
    return model;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static CGFloat startTransPoint = 80.0f;
    static CGFloat endTransPoint = 160.0f;
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY < endTransPoint) { // 设置alpla
        CGFloat alpha = (offsetY - startTransPoint) / (endTransPoint - startTransPoint);
        if (alpha < 0) {
            alpha = 0;
        }
        
        self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:(1-alpha)];
        [self gf_setNavBarBackgroundTransparent:alpha];
        
        self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackLight;
        self.gf_StatusBarStyle = UIStatusBarStyleLightContent;
        if (self.rightBarButtonState!=GFProfileRightBarButtonStateHidden) {
            self.rightBarButtonState = GFProfileRightBarButtonStateLight;
        }
        
    } else {
        [self gf_setNavBarBackgroundTransparent:1];
        self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackDark;
        self.gf_StatusBarStyle = UIStatusBarStyleDefault;
        if (self.rightBarButtonState!=GFProfileRightBarButtonStateHidden) {
            self.rightBarButtonState = GFProfileRightBarButtonStateDark;
        }
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        for (UICollectionViewCell *cell in [self.profileCollectionView visibleCells]) {
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
    
    for (UICollectionViewCell *cell in [self.profileCollectionView visibleCells]) {
        if ([cell isKindOfClass:[GFFeedArticleCell class]] || [cell isKindOfClass:[GFFeedPictureCell class]]) {
            [cell performSelector:@selector(startLoadingImages)];
        }
    }
}

@end
