//
//  GFAssetsAlbumViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFAssetsAlbumViewController.h"
#import "GFAssetsPickerViewController.h"
#import "GFAssetsItemsViewController.h"
#import "GFAssetsAlbumCell.h"

@interface GFAssetsAlbumViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *posters;
@property (nonatomic, strong) NSArray *assets;


@property (nonatomic, strong) UICollectionView *albumCollectionView;

@end

@implementation GFAssetsAlbumViewController
- (instancetype)initWithTitles:(NSArray *)titles posters:(NSArray *)posters assets:(NSArray *)assets {
    
    if (self = [super init]) {
        self.titles = titles;
        self.posters = posters;
        self.assets = assets;
    }
    return self;
}

- (UICollectionView *)albumCollectionView {
    if (!_albumCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.view.width, 80.0f);
        
        _albumCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.backgroundColor = [UIColor whiteColor];
        [_albumCollectionView registerClass:[GFAssetsAlbumCell class] forCellWithReuseIdentifier:NSStringFromClass([GFAssetsAlbumCell class])];
    }
    return _albumCollectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.albumCollectionView];
    self.title = @"相册列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarButtonSelected)];
}

- (void)rightBarButtonSelected {
    
    GFAssetsPickerViewController *picker = (GFAssetsPickerViewController *)self.navigationController;
    if (picker.gf_didCancelPickingAssetsBlock) {
        picker.gf_didCancelPickingAssetsBlock(picker);
    }
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.titles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GFAssetsAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFAssetsAlbumCell class]) forIndexPath:indexPath];
    cell.imageView.image = [self.posters objectAtIndex:indexPath.item];
    cell.textLabel.text = [self.titles objectAtIndex:indexPath.item];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[self.assets objectAtIndex:indexPath.item] count]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles objectAtIndex:indexPath.item];
    NSArray *assets = [self.assets objectAtIndex:indexPath.item];
    GFAssetsItemsViewController *assetsViewController = [[GFAssetsItemsViewController alloc] initWithTitle:title assets:assets];
    [self.navigationController pushViewController:assetsViewController animated:YES];
}

@end
