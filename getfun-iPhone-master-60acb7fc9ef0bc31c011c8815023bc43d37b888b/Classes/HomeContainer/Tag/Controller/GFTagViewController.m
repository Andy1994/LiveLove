//
//  GFTagViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/14.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFTagViewController.h"
#import "GFNetworkManager+Tag.h"
#import "GFCollectedTagListCell.h"
#import "GFHotTagCell.h"
#import "GFAccountManager.h"
#import "GFTagDetailViewController.h"
#import "GFCollectedTagsViewController.h"

@interface GFTagSectionHeader : UICollectionReusableView
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@end
@implementation GFTagSectionHeader
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.width, self.height-10)];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, self.containerView.height/2 - 11, 22, 22)];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.right + 9,
                                                                self.containerView.height/2 - 10,
                                                                80,
                                                                20)];
        _titleLabel.textColor = [UIColor textColorValue1];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _titleLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
        _accessoryImageView.center = CGPointMake(self.width-12-_accessoryImageView.width/2, self.containerView.height/2);
    }
    return _accessoryImageView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.accessoryImageView.x - 80, self.containerView.height/2 - 8, 80, 16)];
        _countLabel.font = [UIFont systemFontOfSize:15.0f];
        _countLabel.textColor = [UIColor textColorValue4];
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor themeColorValue13];
        
        [self addSubview:self.containerView];
        
        [self.containerView addSubview:self.iconImageView];
        [self.containerView addSubview:self.titleLabel];
        [self.containerView addSubview:self.accessoryImageView];
        [self.containerView addSubview:self.countLabel];
        [self gf_AddBottomBorderWithColor:[UIColor themeColorValue15] andWidth:0.5f];
    }
    return self;
}

@end

@interface GFTagViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *tagCollectionView;

@property (nonatomic, strong) NSArray<GFTagMTL *> *collectedTags;
@property (nonatomic, assign) NSInteger collectionTotalCount;

@property (nonatomic, strong) NSArray<GFTagMTL *> *hotTags;

@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation GFTagViewController
- (UICollectionView *)tagCollectionView {
    if (!_tagCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.headerReferenceSize = CGSizeMake(self.view.width, 54);
        _tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) collectionViewLayout:layout];
        _tagCollectionView.backgroundColor = [UIColor clearColor];
        _tagCollectionView.delegate = self;
        _tagCollectionView.dataSource = self;
        [_tagCollectionView registerClass:[GFCollectedTagListCell class] forCellWithReuseIdentifier:NSStringFromClass([GFCollectedTagListCell class])];
        [_tagCollectionView registerClass:[GFHotTagCell class] forCellWithReuseIdentifier:NSStringFromClass([GFHotTagCell class])];
        [_tagCollectionView registerClass:[GFTagSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFTagSectionHeader class])];
    }
    return _tagCollectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tagCollectionView];
    
    __weak typeof(self) weakSelf = self;
    [self.tagCollectionView addPullToRefreshWithActionHandler:^{
        [weakSelf queryHotTagsWithHUD:NO];
    }];
//    [self.tagCollectionView addInfiniteScrollingWithActionHandler:^{
//        [weakSelf queryHotTagsWithHUD:NO];
//    }];
//    self.tagCollectionView.showsInfiniteScrolling = NO;
    [self queryHotTagsWithHUD:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GFLoginType type = [GFAccountManager sharedManager].loginType;
    if (type != GFLoginTypeAnonymous && type != GFLoginTypeNone) {
        [self queryCollectedTags];
    } else {
        self.collectedTags = nil;
        [self.tagCollectionView reloadData];
    }
}

- (void)queryCollectedTags {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCollectedTagWithRefTime:nil
                                         success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage, NSArray<GFTagMTL *> *tags, NSInteger totalCount) {
                                             if (code == 1) {
                                                 self.collectionTotalCount = totalCount;
                                                 
                                                 if (totalCount == 0 && weakSelf.collectedTags && [weakSelf.collectedTags count] > 0) { //删除后无关注
                                                     weakSelf.collectedTags = @[];
                                                     [weakSelf.tagCollectionView deleteSections:[NSIndexSet indexSetWithIndex:0]];
                                                 } else {
                                                     if (weakSelf.collectedTags && [weakSelf.collectedTags count] > 0) {
                                                         if (tags && [tags count] > 0) {
                                                             weakSelf.collectedTags = tags;
                                                             [weakSelf.tagCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                         }
                                                     } else {
                                                         if (tags && [tags count] > 0) {
                                                             weakSelf.collectedTags = tags;
                                                             [weakSelf.tagCollectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
                                                         }
                                                     }
                                                 }
                                                 
                                             }
                                         } failure:^(NSUInteger taskId, NSError *error) {
                                             
                                         }];
}

- (void)queryHotTagsWithHUD:(BOOL)showHUD {
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = nil;
    if (showHUD) {
        hud = [MBProgressHUD showLoadingHUDWithTitle:@"" inView:self.view];
    }

    [GFNetworkManager getHotTagSuccess:^(NSUInteger taskId, NSInteger code, NSString *errorMessage, NSArray<GFTagMTL *> *tags) {
        [weakSelf.tagCollectionView finishPullToRefresh];
        if (hud) {
            [hud hide:YES];
        }
        if (code == 1) {
            self.hotTags = tags;
            [self.tagCollectionView reloadData];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [weakSelf.tagCollectionView finishPullToRefresh];
        if (hud) {
            [hud hide:YES];
            [self showRetryButton];
        }
    }];
}
- (void)showRetryButton {
    
    if (!self.retryButton) {
        self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.retryButton setBackgroundImage:[UIImage imageNamed:@"content_reload"] forState:UIControlStateNormal];
        [self.retryButton sizeToFit];
        self.retryButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        
        __weak typeof(self) weakSelf = self;
        [self.retryButton bk_addEventHandler:^(id sender) {
            [weakSelf.retryButton removeFromSuperview];
            [self queryHotTagsWithHUD:YES];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (![self.retryButton superview]) {
        [self.view addSubview:self.retryButton];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numberOfSections = 0;
    if (self.collectedTags && [self.collectedTags count] > 0) {
        numberOfSections ++;
    }
    
    if (self.hotTags && [self.hotTags count] > 0) {
        numberOfSections ++;
    }
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    NSInteger numberOfItems = 0;
    if (section == 0 && self.collectedTags && [self.collectedTags count] > 0) {
        numberOfItems = 1;
    } else {
        numberOfItems = [self.hotTags count];
    }
    
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {    
    if (indexPath.section == 0 && self.collectedTags && [self.collectedTags count] > 0) {
        
        __weak typeof(self) weakSelf = self;
        GFCollectedTagListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFCollectedTagListCell class]) forIndexPath:indexPath];
        [cell bindWithModel:self.collectedTags];
        cell.selectTagHandler = ^(GFTagMTL *tag) {
            [MobClick event:@"gf_bq_03_01_01_1"];
            GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tag.tagInfo.tagId];
            [weakSelf.navigationController pushViewController:tagDetailViewController animated:YES];
        };
        return cell;
        
    } else {
        
        GFTagMTL *tag = [self.hotTags objectAtIndex:indexPath.row];
        GFHotTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFHotTagCell class]) forIndexPath:indexPath];
        [cell bindWithModel:tag];
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    GFTagSectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GFTagSectionHeader class]) forIndexPath:indexPath];
    if (indexPath.section == 0 && self.collectedTags && [self.collectedTags count] > 0) {
        sectionHeader.iconImageView.image = [UIImage imageNamed:@"tag_icon_collected"];
        sectionHeader.titleLabel.text = @"关注的标签";
        sectionHeader.countLabel.text = [NSString stringWithFormat:@"全部%ld个", (long)self.collectionTotalCount];
        sectionHeader.countLabel.hidden = NO;
        sectionHeader.accessoryImageView.hidden = NO;
        [sectionHeader bk_whenTapped:^{
            GFCollectedTagsViewController *collectedTagsViewController = [[GFCollectedTagsViewController alloc] init];
            [weakSelf.navigationController pushViewController:collectedTagsViewController animated:YES];
        }];
    } else if (indexPath.row == 0) {
        sectionHeader.iconImageView.image = [UIImage imageNamed:@"tag_icon_hottag"];
        sectionHeader.titleLabel.text = @"热门标签";
        sectionHeader.countLabel.hidden = YES;
        sectionHeader.accessoryImageView.hidden = YES;
    }
    
    return sectionHeader;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    if (indexPath.section == 0 && self.collectedTags && [self.collectedTags count] > 0) {
        height = [GFCollectedTagListCell heightWithModel:self.collectedTags];
    } else {
        id model = [self.hotTags objectAtIndex:indexPath.row];
        height = [GFHotTagCell heightWithModel:model];
    }
    return CGSizeMake(self.tagCollectionView.width, height);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.collectedTags && [self.collectedTags count] > 0) {
        // do nothing
    } else {
        NSString *event = nil;
        if (indexPath.row <= 8) {
            event = [NSString stringWithFormat:@"gf_bq_01_01_0%@_1", @(indexPath.row+1)];
        } else if (indexPath.row <= 50) {
            event = [NSString stringWithFormat:@"gf_bq_01_01_%@_1", @(indexPath.row+1)];
        }
        if (!event) {
            [MobClick event:event];
        }
        
        GFTagMTL *tag = [self.hotTags objectAtIndex:indexPath.row];
        GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tag.tagInfo.tagId];
        [self.navigationController pushViewController:tagDetailViewController animated:YES];
    }
}

- (void)scrollToTop {
    [self.tagCollectionView setContentOffset:CGPointZero animated:YES];
}

@end
