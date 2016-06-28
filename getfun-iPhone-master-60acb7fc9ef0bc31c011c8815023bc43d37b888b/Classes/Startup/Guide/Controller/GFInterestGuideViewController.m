//
//  GFInterestGuideViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFInterestGuideViewController.h"
#import "GFSelectInterestViewCell.h"
#import "GFNetworkManager+User.h"
#import "AppDelegate.h"
#import "GFNetworkManager+Tag.h"
#import "GFLocationManager.h"

#define GF_INTEREST_GUIDE_BUTTON_HEIGHT 50.0f
#define GF_INTEREST_GUIDE_LABEL_HEIGHT 25.0f

NSString * const GFUserDefaultsKeyInterestSelected = @"GFUserDefaultsKeyInterestSelected";

@interface GFInterestGuideViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *recommendInterest;
@property (nonatomic, strong) NSMutableArray *selectedInterest;

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIButton *enterHomeButton;

@end

@implementation GFInterestGuideViewController
- (NSMutableArray *)recommendInterest {
    if (!_recommendInterest) {
        _recommendInterest = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _recommendInterest;
}

- (NSMutableArray *)selectedInterest {
    if (!_selectedInterest) {
        _selectedInterest = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedInterest;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 140) / 2, 20, 140, GF_INTEREST_GUIDE_LABEL_HEIGHT)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:18];
        _textLabel.textColor = [UIColor textColorValue3];
        _textLabel.text = @"选择你的兴趣";
    }
    return _textLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        CGFloat itemWidth = (SCREEN_WIDTH - 36 * 2 - 20.0f * 2) / 3;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.minimumLineSpacing = 20.0f;
        layout.minimumInteritemSpacing = 20.0f;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 5);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(36, self.textLabel.bottom, self.view.width - 36 * 2, self.view.height - GF_INTEREST_GUIDE_BUTTON_HEIGHT - self.textLabel.bottom) collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[GFSelectInterestViewCell class] forCellWithReuseIdentifier:NSStringFromClass([GFSelectInterestViewCell class])];
    }
    return _collectionView;
}

- (UIButton *)enterHomeButton {
    if (!_enterHomeButton) {
        _enterHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _enterHomeButton.frame = CGRectMake(0, SCREEN_HEIGHT - GF_INTEREST_GUIDE_BUTTON_HEIGHT, SCREEN_WIDTH, GF_INTEREST_GUIDE_BUTTON_HEIGHT);
        [_enterHomeButton setTitle:@"生成你的个性化首页" forState: UIControlStateNormal];
        [_enterHomeButton setBackgroundColor:[UIColor grayColor]];
        [_enterHomeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_enterHomeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _enterHomeButton.enabled = NO;
    }
    return _enterHomeButton;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self hideFooterImageView:YES];
    
    [self.view addSubview:self.textLabel];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.enterHomeButton];
    
    //设置按钮点击事件
    __weak typeof(self) weakSelf = self;
    [self.enterHomeButton bk_addEventHandler:^(id sender) {
        [MobClick event:@"gf_yd_01_02_19_1"];
        
        [GFUserDefaultsUtil setBool:YES forKey:GFUserDefaultsKeyInterestSelected];
        
        NSMutableArray<NSNumber *> *tagIdList = [[NSMutableArray alloc] initWithCapacity:0];
        for (GFTagMTL *tag in weakSelf.selectedInterest) {
            [tagIdList addObject:tag.tagInfo.tagId];
        }
        [GFNetworkManager addUserInterestTags:tagIdList
                                      success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage) {
                                          [[AppDelegate appDelegate] switchToNextViewController:weakSelf];
                                      }
                                      failure:^(NSUInteger taskId, NSError *error) {
                                          [[AppDelegate appDelegate] switchToNextViewController:weakSelf];
                                      }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self loadingInterest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [GFLocationManager initManager];
}
#pragma mark - 私有方法
- (void)loadingInterest {
    
    __weak typeof(self) weakSelf = self;
    
    [GFNetworkManager getRecommendInterestTagsSuccess:^(NSUInteger taskId, NSInteger code, NSArray<GFTagMTL *> *tags, NSString *errorMessage) {
        if (code == 1) {
            if (tags && [tags count] > 0) {
                
                [weakSelf.recommendInterest addObjectsFromArray:tags];
                
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                for (NSUInteger i = 0; i < weakSelf.recommendInterest.count; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [weakSelf.collectionView insertItemsAtIndexPaths:indexPaths];
            } else {
                [MBProgressHUD showHUDWithTitle:@"获取兴趣列表失败" duration:kCommonHudDuration inView:weakSelf.view];
            }
        }
        else {
            [MBProgressHUD showHUDWithTitle:@"获取兴趣列表失败" duration:kCommonHudDuration inView:weakSelf.view];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [MBProgressHUD showHUDWithTitle:@"网络请求失败" duration:kCommonHudDuration inView:weakSelf.view];
    }];
}

//- (void)ignoreRecommendInterest {
//    [UIAlertView bk_showAlertViewWithTitle:nil
//                                   message:@"获取兴趣列表失败，是否直接进入首页?"
//                         cancelButtonTitle:@"取消"
//                         otherButtonTitles:@[@"确定"]
//                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                       if (buttonIndex == 1) {
//                                           [[AppDelegate appDelegate] switchToHomeContainerViewController];
//                                       }
//                                   }];
//}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.recommendInterest.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GFSelectInterestViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFSelectInterestViewCell class]) forIndexPath:indexPath];
    
    GFTagMTL *tagMTL = (GFTagMTL*)[self.recommendInterest objectAtIndex:indexPath.row];
    cell.selected = [self.selectedInterest containsObject:tagMTL];
    [cell bindWithModel:tagMTL withStyle:GFSelectInterestViewCellUserGuide];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *event = nil;
    if (indexPath.row < 9) {
        event = [NSString stringWithFormat:@"gf_yd_01_02_0%@_1", @(indexPath.row + 1)];
    } else if(indexPath.row < 18) {
        event = [NSString stringWithFormat:@"gf_yd_01_02_%@_1", @(indexPath.row + 1)];
    }
    if (!event) {
        [MobClick event:event];
    }
    
    GFTagMTL *tagMTL = [self.recommendInterest objectAtIndex:indexPath.row];
    if ([self.selectedInterest containsObject:tagMTL]) {
        [self.selectedInterest removeObject:tagMTL];
    } else {
        [self.selectedInterest addObject:tagMTL];
    }
    self.enterHomeButton.enabled = [self.selectedInterest count] > 0;
    self.enterHomeButton.backgroundColor =  self.enterHomeButton.enabled ? [UIColor themeColorValue9] : [UIColor grayColor];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//定义每个UICollectionView 的纵向间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

//-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//

@end
