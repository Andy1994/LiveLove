//
//  GFCollectedTagsViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/17.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFCollectedTagsViewController.h"
#import "GFCollectedTagCell.h"
#import "GFNetworkManager+Tag.h"
#import "GFTagDetailViewController.h"


@interface GFCollectedTagsViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *tagCollectionView;
@property (nonatomic, strong) NSMutableArray *collectedTags;
@property (nonatomic, strong) NSNumber *refTime;

@end

@implementation GFCollectedTagsViewController
- (UICollectionView *)tagCollectionView {
    if (!_tagCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
        layout.minimumLineSpacing = 0;
        _tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) collectionViewLayout:layout];
        _tagCollectionView.backgroundColor = [UIColor clearColor];
        _tagCollectionView.delegate = self;
        _tagCollectionView.dataSource = self;
        [_tagCollectionView registerClass:[GFCollectedTagCell class] forCellWithReuseIdentifier:NSStringFromClass([GFCollectedTagCell class])];
    }
    return _tagCollectionView;
}

- (NSMutableArray *)collectedTags {
    if (!_collectedTags) {
        _collectedTags = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _collectedTags;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关注的标签";
    [self.view addSubview:self.tagCollectionView];
    [self queryCollectedTags];
    __weak typeof(self) weakSelf = self;
    
    [self.tagCollectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf queryCollectedTags];
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)queryCollectedTags {
    
    __weak typeof(self) weakSelf = self;
    [GFNetworkManager getCollectedTagWithRefTime:self.refTime
                                         success:^(NSUInteger taskId, NSInteger code, NSString *errorMessage, NSArray<GFTagMTL *> *tags, NSInteger totalCount) {
                                             
                                             [weakSelf.tagCollectionView finishInfiniteScrolling];
                                             if (code == 1) {
                                                 [weakSelf.collectedTags addObjectsFromArray:tags];
                                                 
                                                 if (weakSelf.collectedTags.count == totalCount) {
                                                     weakSelf.refTime = @(-1);
                                                 } else {
                                                     GFTagMTL *tag = [weakSelf.collectedTags lastObject];
                                                     weakSelf.refTime = tag.addTime;
                                                 }
                                                 
                                                 weakSelf.tagCollectionView.showsInfiniteScrolling = [weakSelf.refTime integerValue] != -1;
                                                 
                                                  [weakSelf.tagCollectionView reloadData];
                                             }
                                         } failure:^(NSUInteger taskId, NSError *error) {
                                             [weakSelf.tagCollectionView finishInfiniteScrolling];
                                         }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectedTags count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GFTagMTL *tag = [self.collectedTags objectAtIndex:indexPath.row];
    GFCollectedTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFCollectedTagCell class]) forIndexPath:indexPath];
    [cell bindWithModel:tag];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.width, 72.0f);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GFTagMTL *tag = [self.collectedTags objectAtIndex:indexPath.row];
    GFTagDetailViewController *tagDetailViewController = [[GFTagDetailViewController alloc] initWithTagId:tag.tagInfo.tagId];
    
    __weak typeof(self) weakSelf = self;
    tagDetailViewController.tagCollectHandler = ^(GFTagMTL *tagMTL) {
        if (tagMTL.collected) {
            [weakSelf.collectedTags addObject:tagMTL];
        } else {
            NSUInteger index = [weakSelf.collectedTags indexOfObject:tagMTL];
            [weakSelf.collectedTags removeObjectAtIndex:index];
        }
        [weakSelf.tagCollectionView reloadData];
    };
    [self.navigationController pushViewController:tagDetailViewController animated:YES];
}
@end
