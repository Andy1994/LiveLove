//
//  TZPhotoPreviewController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZPhotoPreviewController.h"
#import "TZPhotoPreviewCell.h"
#import "UIView+Layout.h"
#import "GFAssetsPickerViewController.h"

@interface TZPhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate> {
    UICollectionView *_collectionView;
    BOOL _isHideNaviBar;
    
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_okButton;
}

@property (nonatomic, strong) UILabel *indexLabel; //提示当前图片所在索引
@end

@implementation TZPhotoPreviewController

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont systemFontOfSize:18.0f];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.text = @"99 / 99"; //最多提示张数时的文字
        [_indexLabel sizeToFit];
    }
    return _indexLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCollectionView];
    [self configCustomNaviBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)configCustomNaviBar {
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width, 64)];
    _naviBar.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    _naviBar.alpha = 0.7;
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
    [_backButton setImage:[UIImage imageNamed:@"nav_back_light"] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    _okButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.tz_width - 54, 10, 42, 42)];
    [_okButton setTitle:@"完成" forState:UIControlStateNormal];
    [_okButton addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
    
    self.indexLabel.center = CGPointMake(_naviBar.width/2, _naviBar.height/2);
    self.indexLabel.text = [NSString stringWithFormat:@"1 / %@", @(self.assets.count)];//第一次显示
    
    [_naviBar addSubview:_okButton];
    [_naviBar addSubview:_backButton];
    [_naviBar addSubview:self.indexLabel];
    [self.view addSubview:_naviBar];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.tz_width, self.view.tz_height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width , self.view.tz_height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.view.tz_width * self.assets.count, self.view.tz_height);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TZPhotoPreviewCell class] forCellWithReuseIdentifier:@"TZPhotoPreviewCell"];
}

#pragma mark - Click Event
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ok {
    
    if ([self.navigationController isKindOfClass:[GFAssetsPickerViewController class]]) {
        GFAssetsPickerViewController *picker = (GFAssetsPickerViewController *)self.navigationController;
        if (picker.gf_didFinishPickingAssetsBlock) {
            picker.gf_didFinishPickingAssetsBlock(picker, self.assets, self.thumbnails);
        }
        
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@", indexPath);
    
    TZPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZPhotoPreviewCell" forIndexPath:indexPath];
    [cell setAsset:self.assets[indexPath.row]];
    
    __block BOOL _weakIsHideNaviBar = _isHideNaviBar;
    __weak typeof(_naviBar) weakNaviBar = _naviBar;
    if (!cell.singleTapGestureBlock) {
        cell.singleTapGestureBlock = ^(){
            // show or hide naviBar / 显示或隐藏导航栏
            _weakIsHideNaviBar = !_weakIsHideNaviBar;
            weakNaviBar.hidden = _weakIsHideNaviBar;
        };
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = scrollView.contentOffset.x / scrollView.width;
    NSInteger count = (NSInteger)self.assets.count;
    self.indexLabel.text = [NSString stringWithFormat:@"%@ / %@", @(currentIndex + 1), @(count)];
}

@end
