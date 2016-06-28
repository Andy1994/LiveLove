//
//  GFCreateGroupSelectInterestViewController.m
//  GetFun
//
//  Created by Liu Peng on 15/12/9.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCreateGroupSelectInterestViewController.h"
#import "GFCreateGroupAllInterestViewController.h"
#import "GFSelectInterestViewCell.h"
#import "GFNetworkManager+Tag.h"
#import "GFGroupUpdateViewController.h"

@interface GFCreateGroupSelectInterestViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableOrderedSet *interests;
@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation GFCreateGroupSelectInterestViewController
- (NSMutableOrderedSet *)interests {
    if (!_interests) {
        _interests = [[NSMutableOrderedSet alloc] initWithCapacity:0];
    }
    return _interests;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        CGFloat itemWidth = (SCREEN_WIDTH - 36 * 2 - 20.0f * 2) / 3;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(36, 64, self.view.width - 36 * 2, self.view.height - 64) collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.minimumLineSpacing = 20.0f;
        layout.minimumInteritemSpacing = 20.0f;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 15, 0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"选择兴趣";
    [self hideFooterImageView:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[GFSelectInterestViewCell class] forCellWithReuseIdentifier:NSStringFromClass([GFSelectInterestViewCell class])];
    
    [self loadingInterest];
}

- (void)backBarButtonItemSelected {
    [MobClick event:@"gf_gb_02_02_01_1"];
    [super backBarButtonItemSelected];
}

#pragma mark - 私有方法
- (void)loadingInterest {
    MBProgressHUD *hud = [MBProgressHUD showLoadingHUDWithTitle:nil inView:self.view];
    
    [GFNetworkManager getRecommendInterestTagsSuccess:^(NSUInteger taskId, NSInteger code, NSArray<GFTagMTL *> *tags, NSString *errorMessage) {
        [hud hide:YES];
        if (code == 1) {
            [self.interests addObjectsFromArray:tags];
            
            //单独添加“全部”cell
            GFTagMTL *tagMTL = [[GFTagMTL alloc] init];
            GFTagInfoMTL *tagInfoMTL = [[GFTagInfoMTL alloc] init];
            tagInfoMTL.tagName = @"全部";
            tagInfoMTL.tagHexColor = @"#2FD59C";
            tagMTL.tagInfo = tagInfoMTL;
            [self.interests addObject:tagMTL];
            
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (NSUInteger i = 0; i < self.interests.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
            
        } else {
            if (errorMessage) {
                [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.view];
            }
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        [hud hide:YES];
    }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.interests.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GFSelectInterestViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFSelectInterestViewCell class]) forIndexPath:indexPath];
    GFTagMTL *tagMTL = (GFTagMTL*)[self.interests objectAtIndex:indexPath.row];
    
    NSString *imageKey = tagMTL.interestTagEx.interestImageUrl;
    if (imageKey) {
        GFPictureMTL *picture = [tagMTL.pictures objectForKey:imageKey];
        if (picture.url) {
            [cell bindWithModel:tagMTL withStyle:GFSelectInterestViewCellCreateGroup];
        }
    } else {
        [cell bindWithModel:tagMTL withStyle:GFSelectInterestViewCellCreateGroupAll];
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.interests.count - 1) {
        
        [MobClick event:@"gf_gb_02_01_02_1"];
        
        GFCreateGroupAllInterestViewController *controller = [[GFCreateGroupAllInterestViewController alloc] init];
        if (self.interestSelectHandler) {
            __weak typeof(self) weakSelf = self;
            controller.needPopTwoCtl = YES;
            controller.interestSelectHandler = ^(GFTagInfoMTL *tag) {
                weakSelf.interestSelectHandler(tag);
            };
        }
        [self.navigationController pushViewController:controller animated:YES];

    } else {
        GFTagMTL *tagMTL = [self.interests objectAtIndex:indexPath.row];

        if (self.interestSelectHandler) {
            self.interestSelectHandler(tagMTL.tagInfo);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            __weak typeof(self) weakSelf = self;
            [MobClick event:@"gf_gb_02_01_01_1"];
            GFGroupUpdateViewController *groupUpdateViewController = [[GFGroupUpdateViewController alloc] initWithTag:tagMTL.tagInfo];
            [self.navigationController pushViewController:groupUpdateViewController animated:YES];
        }
    }
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

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

@end
