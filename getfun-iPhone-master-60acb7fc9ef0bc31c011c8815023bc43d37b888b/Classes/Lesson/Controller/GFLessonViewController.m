//
//  GFLessonViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFLessonViewController.h"
#import "GFLessonContentCell.h"
#import "GFUserCommentCell.h"
#import "GFNetworkManager+Content.h"
#import "GFNetworkManager+Comment.h"
#import "GFContentInputView.h"
#import "GFAccountManager.h"
#import "GFNetworkManager+Comment.h"
#import "GFTaskSuccessTipView.h"
#import "GFWebViewController.h"
#import "GFProfileViewController.h"
#import "GFCopyUrlActionActivity.h"
#import "NTESActivityViewController.h"


#define kNewCommentCountQueryTimeInterval 10.0f
#define kTipDuration 5.0f

@interface GFLessonLoadMoreSectionFooter : UICollectionReusableView

@property (nonatomic, copy) void (^loadMoreHandler)(GFLessonLoadMoreSectionFooter *footer);

@end
@interface GFLessonLoadMoreSectionFooter ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@end

@implementation GFLessonLoadMoreSectionFooter
- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = self.bounds;
    }
    return _button;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.text = @"查看更多";
        _textLabel.font = [UIFont systemFontOfSize:15.0f];
        _textLabel.textColor = [UIColor textColorValue8];
        [_textLabel sizeToFit];
    }
    return _textLabel;
}

- (UIImageView *)indicatorImageView {
    if (!_indicatorImageView) {
        _indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_indicatorImageView sizeToFit];
    }
    return _indicatorImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.textLabel];
        [self addSubview:self.indicatorImageView];
        self.textLabel.center = CGPointMake(self.width/2 - self.indicatorImageView.width/2, self.height/2);
        
        //和GFUserCommentCell中对应数值保持一致
        const CGFloat kIndent = 35.0f;
        const CGFloat kPadding = 15.0f;
        self.textLabel.x = kIndent * 2 + kPadding;
        self.indicatorImageView.center = CGPointMake(self.textLabel.right + self.indicatorImageView.width/2, self.height/2);
        
        [self addSubview:self.button];
        __weak typeof(self) weakSelf = self;
        [self.button bk_addEventHandler:^(id sender) {
            if (weakSelf.loadMoreHandler) {
                weakSelf.loadMoreHandler(weakSelf);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

@end

@interface GFLessonViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
HPGrowingTextViewDelegate>

@property (nonatomic, strong, readonly) GFContentMTL *content;
@property (nonatomic, strong) NSMutableArray *subContents;

@property (nonatomic, strong) GFContentInputView *inputView;

@property (nonatomic, strong) UIButton *rightNavButton; // 切换是否只看楼主
@property (nonatomic, strong) UICollectionView *lessonCollectionView;

@property (nonatomic, strong) NSMutableArray<GFCommentMTL *> *comments;
@property (nonatomic, strong) NSNumber *refCommentListQueryTime;
@property (nonatomic, strong) NSNumber *refCommentCountQueryTime;

@property (nonatomic, strong) NSTimer *commentCountQueryTimer;

@property (nonatomic, strong) GFTaskSuccessTipView *tipView;

@property (nonatomic, strong) NTESActivityViewController *shareViewController;

// 保存了没有"更多回复"的section
@property (nonatomic, strong) NSMutableArray<NSNumber *> *noMoreReplySections;

@property (nonatomic, strong) NSIndexPath *indexPathForCommentToReply;

@property (nonatomic, copy) UIImage *shareImage;

@end

@implementation GFLessonViewController
- (NSMutableArray *)subContents {
    if (!_subContents) {
        _subContents = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _subContents;
}

- (GFContentInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[GFContentInputView alloc] initWithFrame:CGRectMake(0, self.view.height - kInputViewHeight, SCREEN_WIDTH, kInputViewHeight)];
        _inputView.style = GFInputViewStyleShare;
        _inputView.textView.delegate = self;
    }
    return _inputView;
}

- (UIButton *)rightNavButton {
    if (!_rightNavButton) {
        _rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightNavButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateNormal];
        _rightNavButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_rightNavButton setTitle:@"只看楼主" forState:UIControlStateNormal];
        [_rightNavButton setTitleColor:[UIColor textColorValue7] forState:UIControlStateSelected];
        [_rightNavButton setTitle:@"查看全部" forState:UIControlStateSelected];
        [_rightNavButton sizeToFit];
    }
    return _rightNavButton;
}

- (UICollectionView *)lessonCollectionView {
    if (!_lessonCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _lessonCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - kInputViewHeight) collectionViewLayout:layout];
        _lessonCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _lessonCollectionView.backgroundColor = [UIColor clearColor];
        _lessonCollectionView.dataSource = self;
        _lessonCollectionView.delegate = self;
        [_lessonCollectionView registerClass:[GFLessonContentCell class] forCellWithReuseIdentifier:NSStringFromClass([GFLessonContentCell class])];
        [_lessonCollectionView registerClass:[GFUserCommentCell class] forCellWithReuseIdentifier:NSStringFromClass([GFUserCommentCell class])];
        
        [_lessonCollectionView registerClass:[GFLessonLoadMoreSectionFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([GFLessonLoadMoreSectionFooter class])];
    }
    return _lessonCollectionView;
}

- (NSMutableArray<GFCommentMTL *> *)comments {
    if (!_comments) {
        _comments = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _comments;
}

- (void)restartCommentCountQueryTimer {
    
    if (self.commentCountQueryTimer) {
        [self.commentCountQueryTimer invalidate];
        self.commentCountQueryTimer = nil;
    }
    
    if (!self.refCommentListQueryTime) return;
    
    DDLogInfo(@"%s%s", __FILE__, __PRETTY_FUNCTION__);
    __weak typeof(self) weakSelf = self;
    self.commentCountQueryTimer = [NSTimer scheduledTimerWithTimeInterval:kNewCommentCountQueryTimeInterval
                                                                   target:weakSelf
                                                                 selector:@selector(queryNewCommentsCount)
                                                                 userInfo:nil
                                                                  repeats:YES];
    
    //    [[NSRunLoop currentRunLoop] addTimer:self.commentCountQueryTimer forMode:NSRunLoopCommonModes];
}

- (GFTaskSuccessTipView *)tipView {
    if (!_tipView) {
        _tipView = [[GFTaskSuccessTipView alloc] init];
        _tipView.alpha = 0;
    }
    return _tipView;
}

- (NTESActivityViewController *)shareViewController {
    if (!_shareViewController) {
        _shareViewController = [[NTESActivityViewController alloc] init];
    }
    return _shareViewController;
}

- (NSMutableArray<NSNumber *> *)noMoreReplySections {
    if (!_noMoreReplySections) {
        _noMoreReplySections = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _noMoreReplySections;
}

- (instancetype)initWithContent:(GFContentMTL *)content {
    if (self = [super init]) {
        [self bindContent:content];
    }
    return self;
}

- (void)bindContent:(GFContentMTL *)content {
    _content = content;

    [self.subContents removeAllObjects];
    
    for (GFSubContentMTL *subContent in content.subContents) {
        if (subContent.content && [subContent.content length] > 0) {
            [self.subContents addObject:subContent];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"盖范第一课堂";
    self.backBarButtonItemStyle = GFBackBarButtonItemStyleBackDark;
    
    [self.view addSubview:self.lessonCollectionView];
    [self.view addSubview:self.inputView];
    [self.view addSubview:self.tipView];
    
    
    __weak typeof(self) weakSelf = self;
    
    //    [self.view bk_whenTapped:^{
    //        weakSelf.indexPathForCommentToReply = nil;
    //        [weakSelf.view endEditing:YES];
    //    }];
    [self.lessonCollectionView addPullToRefreshWithActionHandler:^{
        weakSelf.tipView.alpha = 0.0f;
        [weakSelf queryContent];
        [weakSelf queryComments:YES];
    }];
    [self.lessonCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryComments:NO];
    }];
    
    [self.rightNavButton bk_addEventHandler:^(id sender) {
        if(weakSelf.rightNavButton.selected) {
            [MobClick event:@"gf_xq_03_01_01_1"];
        } else {
            [MobClick event:@"gf_xq_03_02_01_1"];
        }
        
        weakSelf.rightNavButton.selected = !weakSelf.rightNavButton.selected;
        [weakSelf.lessonCollectionView triggerPullToRefresh];
        weakSelf.lessonCollectionView.contentOffset = CGPointMake(0, 0);
        
        //        [weakSelf.lessonCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
        //                                              atScrollPosition:UICollectionViewScrollPositionCenteredVertically
        //                                                      animated:NO];
        
    } forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNavButton];
    
    [self.inputView setShareButtonHandler:^{
        [MobClick event:@"gf_xq_03_04_05_1"];
        
        weakSelf.indexPathForCommentToReply = nil;
        [weakSelf.view endEditing:YES];
        [[weakSelf shareActivityViewControllerWithParams:nil] showIn:weakSelf];
    }];
    
    [self.tipView bk_whenTapped:^{
        [MobClick event:@"gf_xq_03_04_12_1"];
        
        weakSelf.rightNavButton.selected = NO;
        [weakSelf.lessonCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                              atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                      animated:NO];
        [weakSelf.lessonCollectionView triggerPullToRefresh];
    }];
    
    [self queryContent];
    [self queryComments:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self restartCommentCountQueryTimer];
    [self addkeyboardNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.commentCountQueryTimer) {
        [self.commentCountQueryTimer invalidate];
        self.commentCountQueryTimer = nil;
    }
    
    [self removeKeyboardNotification];
}

- (void)dealloc {
    [_inputView removeFromSuperview];
    _inputView = nil;
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_xq_03_04_14_1"];
    [super backBarButtonItemSelected];
}

- (void)queryContent {
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getContentWithContentId:self.content.contentInfo.contentId
                                      keyFrom:GFKeyFromUnkown
                                      success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                          [weakSelf.lessonCollectionView finishPullToRefresh];
                                          [weakSelf.lessonCollectionView finishInfiniteScrolling];
                                          
                                          if (code == 1 && content) {
                                              [weakSelf bindContent:content];
                                              [weakSelf.lessonCollectionView reloadData];
                                              
                                              [weakSelf prepareImageForShare:content];
                                          }
                                      } failure:^(NSUInteger taskId, NSError *error) {
                                          [weakSelf.lessonCollectionView finishPullToRefresh];
                                          [weakSelf.lessonCollectionView finishInfiniteScrolling];
                                      }];
}

- (void)queryComments:(BOOL)refresh {
    
    NSNumber *userId = nil;
    if (self.rightNavButton.selected) {
        userId = self.content.user.userId;
    }
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCommentsWithContentId:self.content.contentInfo.contentId
                                        userId:userId
                                     queryTime:refresh ? nil : self.refCommentListQueryTime
                                       success:^(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSNumber *countQueryTime, NSString *errorMessage) {
                                           
                                           [weakSelf.lessonCollectionView finishPullToRefresh];
                                           [weakSelf.lessonCollectionView finishInfiniteScrolling];
                                           
                                           if (code == 1) {
                                               if (comments) {
                                                   weakSelf.refCommentListQueryTime = nextQueryTime;
                                               
                                               if (refresh) {
                                                   [weakSelf.comments removeAllObjects];
                                                   weakSelf.refCommentCountQueryTime = countQueryTime;
                                                   [weakSelf restartCommentCountQueryTimer];
                                               }
                                               
                                               [weakSelf.comments addObjectsFromArray:comments];
                                               
                                               weakSelf.lessonCollectionView.showsInfiniteScrolling = [nextQueryTime integerValue] != -1;
                                               
                                                [weakSelf.lessonCollectionView reloadData];
                                               }
                                           }
                                       } failure:^(NSUInteger taskId, NSError *error) {
                                           [weakSelf.lessonCollectionView finishPullToRefresh];
                                           [weakSelf.lessonCollectionView finishInfiniteScrolling];
                                       }];
}

- (void)queryChildCommentInSection:(NSInteger)section {
    GFCommentMTL *comment = [self.comments objectAtIndex:section - 1];
    GFCommentMTL *lastChildComment = [comment.children lastObject];
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCommentsReplyToCommentId:comment.commentInfo.commentId
                                        queryTime:lastChildComment.commentInfo.createTime
                                          success:^(NSUInteger taskId, NSInteger code, NSArray<GFCommentMTL *> *comments, NSNumber *nextQueryTime, NSString *errorMessage, BOOL hasMore) {
                                              if (code == 1) {
                                                  if(comments) {
                                                      // 获取了更多数据
                                                      NSMutableArray *children = [comment.children mutableCopy];
                                                      for (GFCommentMTL *item in comments) {
                                                          if (![children containsObject:item]) {
                                                              [children addObjectsFromArray:comments];
                                                          }
                                                      }
                                                      
                                                      comment.children = children;
                                                      
                                                      if (!hasMore) {
                                                          [weakSelf.noMoreReplySections addObject:@(section)];
                                                      }
                                                      //                                                  if ([nextQueryTime integerValue] == -1) {
                                                      //                                                      [weakSelf.noMoreReplySections addObject:@(section)];
                                                      //                                                  }
                                                      
                                                      [weakSelf.lessonCollectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
                                                  }
                                              } else {
                                                  NSString *msg = [errorMessage length] > 0 ? errorMessage : @"获取评论回复失败";
                                                  [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:self.view];
                                              }
                                          } failure:^(NSUInteger taskId, NSError *error) {
                                              [MBProgressHUD showHUDWithTitle:@"网络请求失败" duration:kCommonHudDuration inView:self.view];
                                          }];
}

- (void)queryNewCommentsCount {
    
    if (!self.refCommentCountQueryTime)
        return;
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getNewCommentsCountWithContentId:self.content.contentInfo.contentId
                                             queryTime:self.refCommentCountQueryTime
                                               success:^(NSUInteger taskId, NSInteger code, NSInteger updateCount) {
                                                   
                                                   DDLogInfo(@"%s%s new commment count=%ld", __FILE__, __PRETTY_FUNCTION__, (long)updateCount);
                                                   if (code == 1) {
                                                       if (updateCount > 0) {
                                                           NSString *text = [NSString stringWithFormat:@"%ld条新的内容 点击查看", (long)updateCount];
                                                           [weakSelf.tipView setTitle:text];
                                                           weakSelf.tipView.center = CGPointMake(weakSelf.view.width/2, 64 + 10 + weakSelf.tipView.height/2);
                                                           
                                                           [UIView animateWithDuration:0.5f animations:^{
                                                               weakSelf.tipView.alpha = 1.0f;
                                                           } completion:^(BOOL finished) {
                                                               //                                                           [UIView animateWithDuration:0.5f delay:kTipDuration options:UIViewAnimationOptionCurveLinear animations:^{
                                                               //                                                               weakSelf.tipView.alpha = 0.0f;
                                                               //                                                           } completion:^(BOOL finished) {
                                                               //
                                                               //                                                           }];
                                                           }];
                                                       } else {
                                                           weakSelf.tipView.alpha = 0.0f;
                                                       }
                                                       
                                                   }
                                               } failure:^(NSUInteger taskId, NSError *error) {
                                                   //
                                               }];
}

#pragma mark - KeyboardNotification
- (void)addkeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)onKeyboardFrameChange:(NSNotification *)notification {
    NSValue *endFrameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = [endFrameValue CGRectValue];
    CGFloat endY = endFrame.origin.y;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3 animations:^{
        weakSelf.inputView.bottom = endY;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger numberOfSections = 1 + [self.comments count];
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger numberOfItems = 0;
    if (section == 0) {
        if (!self.rightNavButton.selected) {
            numberOfItems = 1 + [self.subContents count];
        }
    } else {
        GFCommentMTL *comment = [self.comments objectAtIndex:section - 1];
        numberOfItems = 1 + [comment.children count];
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFLessonContentCell class]) forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            [(GFLessonContentCell *)cell bindWithModel:self.content
                                              userInfo:self.content.user];
            __weak typeof(self) weakSelf = self;
            [(GFLessonContentCell *)cell setShowAllButtonHandler:^{
                [MobClick event:@"gf_xq_03_04_13_1"];
                //跳转到h5页面
                NSString *pathComponent = [NSString stringWithFormat:@"publish/detail?id=%@", weakSelf.content.contentInfo.contentId];
                NSString *url = [GF_API_BASE_URL stringByAppendingPathComponent:pathComponent];
                GFWebViewController *webViewController = [[GFWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
                [weakSelf.navigationController presentViewController:[[GFNavigationController alloc] initWithRootViewController:webViewController]
                                                            animated:YES
                                                          completion:^{
                                                              //
                                                          }];
            }];
        } else {
            [(GFLessonContentCell *)cell bindWithModel:[self.subContents objectAtIndex:indexPath.row-1]
                                              userInfo:self.content.user];
        }
        
        
        __weak typeof(self) weakSelf = self;
        [[(GFLessonContentCell *)cell userInfoHeader] setAvatarHandler:^{
            [MobClick event:@"gf_xq_03_03_01_1"];
            
            GFUserMTL *user = weakSelf.content.user;
            GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }];
        
    } else {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFUserCommentCell class]) forIndexPath:indexPath];
        
        GFCommentMTL *model = nil;
        GFCommentMTL *comment = [self.comments objectAtIndex:indexPath.section - 1];
        [(GFUserCommentCell *)cell setShouldShowReplyInfo:NO];
        [[(GFUserCommentCell *)cell userInfoHeader] setStyle:GFUserInfoHeaderStyleDate];
        if (indexPath.row == 0) {
            model = comment;
            [(GFUserCommentCell *)cell setShouldIndent:NO];
            [(GFUserCommentCell *)cell bindWithModel:model
                                       contentUserId:self.content.contentInfo.userId];
        } else {
            model = [comment.children objectAtIndex:indexPath.row - 1];
            [(GFUserCommentCell *)cell setShouldIndent:YES];
            [(GFUserCommentCell *)cell bindWithModel:model
                                       contentUserId:self.content.contentInfo.userId];
        }
#warning 这里还是有代码冗余 -_-!!!!!! 20160303 byzxz
        __weak typeof(self) weakSelf = self;
        [[(GFUserCommentCell *)cell userInfoHeader] setAvatarHandler:^{
            [MobClick event:@"gf_xq_03_03_01_1"];
            
            GFCommentMTL *comment = model;
            GFUserMTL *user = comment.user;
            GFProfileViewController *profileViewController = [[GFProfileViewController alloc] initWithUserID:user.userId];
            [weakSelf.navigationController pushViewController:profileViewController animated:YES];
        }];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    GFLessonLoadMoreSectionFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([GFLessonLoadMoreSectionFooter class]) forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [footer setLoadMoreHandler:^(GFLessonLoadMoreSectionFooter *footer) {
        [weakSelf queryChildCommentInSection:indexPath.section];
    }];
    
    return footer;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    
    if (section > 0) {
        GFCommentMTL *rootComment = [self.comments objectAtIndex:section-1];
        
        // 有更多子评论(第一次拉取一级评论时，带了一部分子评论，且后面还有未拉取的
        // && 拉取后，后台返回的字段表明后续还有二级评论
        if (rootComment.hasMoreChildren
            && ![self.noMoreReplySections containsObject:@(section)]) {
            size = CGSizeMake(collectionView.width, 40);
        }
    }
    return size;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            height = [GFLessonContentCell heightWithModel:self.content];
        } else {
            height = [GFLessonContentCell heightWithModel:[self.subContents objectAtIndex:indexPath.row-1]];
        }
    } else {
        GFCommentMTL *comment = [self.comments objectAtIndex:indexPath.section - 1];
        if (indexPath.row == 0) {
            height = [GFUserCommentCell heightWithModel:comment
                                                 indent:NO
                                    shouldShowReplyInfo:NO];
        } else {
            height = [GFUserCommentCell heightWithModel:[comment.children objectAtIndex:indexPath.row - 1]
                                                 indent:YES
                                    shouldShowReplyInfo:NO];
        }
    }
    
    return CGSizeMake(collectionView.width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minLineSpacing = 0.0f;
    if (section == 0) {
        minLineSpacing = 10.0f;
    }
    return minLineSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (section == 0) {
        edgeInsets = UIEdgeInsetsMake(10, 0, 10, 0);
    }
    return edgeInsets;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DDLogInfo(@"%s%s", __FILE__, __PRETTY_FUNCTION__);
    
    if (indexPath.section > 0) {
        [MobClick event:@"gf_xq_03_05_01_1"];
        
        self.indexPathForCommentToReply = indexPath;
        GFCommentMTL *rootComment = [self.comments objectAtIndex:indexPath.section - 1];
        GFCommentMTL *commentToReply = nil;
        if (indexPath.row == 0) {
            commentToReply = rootComment;
        } else {
            commentToReply = [rootComment.children objectAtIndex:indexPath.row - 1];
        }
        
        self.inputView.textView.placeholder = [NSString stringWithFormat:@"回复 %@", commentToReply.user.nickName];
        [self.inputView.textView becomeFirstResponder];
    }
}

#pragma mark - HPGrowingTextViewDelegate
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    [MobClick event:@"gf_xq_03_04_01_1"];
    
    GFLoginType type = [GFAccountManager sharedManager].loginType;
    __weak typeof(self) weakSelf = self;
    if (type == GFLoginTypeAnonymous || type == GFLoginTypeNone) {
        [GFAccountManager checkLoginStatus:YES loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
            if (user) {
                [MobClick event:@"gf_xq_03_04_02_1"];
                [weakSelf.inputView.textView becomeFirstResponder];
            } else {
                [MobClick event:@"gf_xq_03_04_03_1"];
            }
        }];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [MobClick event:@"gf_xq_03_04_04_1"];
    
    NSString *text = growingTextView.text;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        [MBProgressHUD showHUDWithTitle:@"评论不能为空" duration:kCommonHudDuration inView:self.view];
        return YES;
    }else if([text length] > 1000){
        [MBProgressHUD showHUDWithTitle:@"评论不能超过1000字" duration:kCommonHudDuration inView:self.view];
        return YES;
    }
    growingTextView.text = nil;
    [growingTextView resignFirstResponder];
    
    NSNumber *parentId = nil;
    if (self.indexPathForCommentToReply) {
        GFCommentMTL *rootComment = [self.comments objectAtIndex:self.indexPathForCommentToReply.section - 1];
        GFCommentMTL *commentToReply = nil;
        if (self.indexPathForCommentToReply.row == 0) {
            commentToReply = rootComment;
        } else {
            commentToReply = [rootComment.children objectAtIndex:self.indexPathForCommentToReply.row - 1];
        }
        parentId = commentToReply.commentInfo.commentId;
    }
    [self addComment:text parentId:parentId withIndexPath:self.indexPathForCommentToReply];
    self.indexPathForCommentToReply = nil;
    self.inputView.textView.placeholder = @"";
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    CGFloat deltaHeight = height - growingTextView.height;
    
    CGRect rect = self.inputView.frame;
    CGRect frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - CGRectGetHeight(rect) - deltaHeight, CGRectGetWidth(rect), CGRectGetHeight(rect) + deltaHeight);
    self.inputView.frame = frame;
}

- (void)addComment:(NSString *)text parentId:(NSNumber *)parentId withIndexPath:(NSIndexPath *)indexPath {
    if (text.length == 0) {
        return;
    }
    
    [MobClick event:@"gf_xq_01_02_06_1"];
    
    __weak typeof(self) weakSelf = self;
    @weakify(self)
    [GFAccountManager checkLoginStatus:YES
                       loginCompletion:^(BOOL justLogin, GFUserMTL *user) {
                           if (user) {
                               [GFNetworkManager addCommentWithRelateId:weakSelf.content.contentInfo.contentId
                                                                content:text
                                                               parentId:parentId
                                                                success:^(NSUInteger taskId, NSInteger code, GFCommentMTL *comment, NSString *errorMessage) {
                                                                    @strongify(self)
                                                                    if (code == 1) {
                                                                        if (comment) {
                                                                            
                                                                            if (indexPath) {
                                                                                // 回复的是评论
                                                                                
                                                                                GFCommentMTL *commentToReply = nil;
                                                                                GFCommentMTL *rootComment = [self.comments objectAtIndex:indexPath.section - 1];
                                                                                if (indexPath.row == 0) {
                                                                                    commentToReply = rootComment;
                                                                                } else {
                                                                                    commentToReply = [rootComment.children objectAtIndex:indexPath.row - 1];
                                                                                }
                                                                                
                                                                                NSMutableArray *children = [commentToReply.children mutableCopy];
                                                                                if (!children) {
                                                                                    children = [[NSMutableArray alloc] initWithCapacity:0];
                                                                                }
                                                                                [children addObject:comment];
                                                                                commentToReply.children = children;
                                                                                [weakSelf.lessonCollectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
                                                                            } else {
                                                                                // 回复的是帖子
                                                                                [weakSelf.comments insertObject:comment atIndex:0];
                                                                                [weakSelf.lessonCollectionView insertSections:[NSIndexSet indexSetWithIndex:1]];
                                                                            }
                                                                            [MBProgressHUD showHUDWithTitle:@"评论成功！" duration:kCommonHudDuration inView:weakSelf.view];
                                                                        }
                                                                    } else {
                                                                        NSString *msg = [errorMessage length] > 0 ? errorMessage : @"评论失败";
                                                                        [MBProgressHUD showHUDWithTitle:msg duration:kCommonHudDuration inView:weakSelf.view];
                                                                    }
                                                                } failure:^(NSUInteger taskId, NSError *error) {
                                                                    [MBProgressHUD showHUDWithTitle:@"网络失败" duration:kCommonHudDuration inView:weakSelf.view];
                                                                }];
                               
                           } else {
                               [MBProgressHUD showHUDWithTitle:@"登录后才能评论" duration:kCommonHudDuration inView:self.view];
                           }
                       }];
}

#pragma mark - share
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
        if (activityType) {
            [GFNetworkManager didShareContentWithContentId:weakSelf.content.contentInfo.contentId shareType:activityType];
        }
        
        if (!activityType) { //复制链接
            [MobClick event:@"gf_xq_03_04_11_1"];
        } else {
            GFShareType shareType = [activityType gf_shareType];
            switch (shareType) {
                case GFShareTypeQQ: {
                    [MobClick event:@"gf_xq_03_04_07_1"];
                    break;
                }
                case GFShareTypeQZone: {
                    [MobClick event:@"gf_xq_03_04_06_1"];
                    break;
                }
                case GFShareTypeWeChat: {
                    [MobClick event:@"gf_xq_03_04_08_1"];
                    break;
                }
                case GFShareTypeTimeline: {
                    [MobClick event:@"gf_xq_03_04_09_1"];
                    break;
                }
                case GFShareTypeWeibo: {
                    [MobClick event:@"gf_xq_03_04_10_1"];
                    break;
                }
            }
            
        }
    };
    
    return self.shareViewController;
}

#pragma mark - share activity
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
    NSString *url = [NSString stringWithFormat:@"%@/publish/detail?id=%@", GF_API_BASE_URL, self.content.contentInfo.contentId];
    GFCopyUrlActionActivity *activity = [[GFCopyUrlActionActivity alloc] initWithUrl:url];
    return activity;
}

- (NSString *)urlForShareType:(GFShareType)type {
    NSString *url = [NSString stringWithFormat:@"%@/publish/detail?id=%@", GF_API_BASE_URL, self.content.contentInfo.contentId];
    return url;
    
//    NSString *url = [GF_API_BASE_URL stringByAppendingPathComponent:[NSString stringWithFormat:@"publish/detail?id=%@", self.content.contentInfo.contentId]];
//    return url;
}

- (UIImage *)imageForShareType:(GFShareType)type {
    
    return self.shareImage ? self.shareImage : [UIImage imageNamed:@"default_share_logo"];
}

- (UIImage *)thumbImageForShareType:(GFShareType)type {
    
    return [self imageForShareType:type];
}

- (NSString *)titleForShareType:(GFShareType)type {
    
    return @"盖范第一课堂叫你来上课";
}

- (NSString *)descriptionForShareType:(GFShareType)type {
    
    GFContentDetailArticleMTL *articleDetail = (GFContentDetailArticleMTL *)self.content.contentDetail;
    NSString *desc = articleDetail.title;
    
    if (type == GFShareTypeWeibo) {
        desc = [desc stringByAppendingString:[self urlForShareType:GFShareTypeWeibo]];
    }
    
    if ([desc length] > 500) {
        desc = [desc substringToIndex:500];
    }
    return desc;
}

- (void)prepareImageForShare:(GFContentMTL *)content {
    
    NSString *url = nil;
    NSDictionary *pictures = content.pictures;
    if ([pictures count] > 0) {
        GFPictureMTL *picture = [[pictures allValues] objectAtIndex:0];
        url = picture.url;
    }
    
    if (url) {
        url = [url gf_urlStandardizedWithType:GFImageStandardizedTypeContentDetailArticle gifConverted:YES];
        __weak typeof(self) weakSelf = self;
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:url] options:YYWebImageOptionShowNetworkActivity progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
            return image;
        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            weakSelf.shareImage = image;
        }];
    }
}

@end
