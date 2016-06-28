//
//  GFAssetsItemsViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFAssetsItemsViewController.h"
#import "GFAssetsPickerViewController.h"
#import "GFAssetItemCell.h"
#import "TZPhotoPreviewController.h"
#import "GFCroppingPhotoViewController.h"
#import "GFPhotoUtil.h"

#define kThumbnailLength    78.0f
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)

@interface GFAssetsItemsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RSKImageCropViewControllerDelegate>

@property (nonatomic, copy) NSString *gTitle;
@property (nonatomic, strong) NSArray *assets;

@property (nonatomic, strong) UICollectionView *assetsCollectionView;

@property (nonatomic, strong) UIView *actionBar;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation GFAssetsItemsViewController
- (instancetype)initWithTitle:(NSString *)title assets:(NSArray *)assets {
    if (self = [super init]) {
        self.gTitle = title;
        self.assets = assets;
    }
    return self;
}

- (UICollectionView *)assetsCollectionView {
    if (!_assetsCollectionView) {
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = kThumbnailSize;
        layout.sectionInset                 = UIEdgeInsetsMake(9.0, 0, 0, 0);
        layout.minimumInteritemSpacing      = 2.0;
        layout.minimumLineSpacing           = 2.0;
        layout.footerReferenceSize          = CGSizeMake(0, 44.0);
        
        _assetsCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _assetsCollectionView.delegate = self;
        _assetsCollectionView.dataSource = self;
        _assetsCollectionView.allowsMultipleSelection = YES;
        _assetsCollectionView.backgroundColor = [UIColor whiteColor];
        [_assetsCollectionView registerClass:[GFAssetItemCell class] forCellWithReuseIdentifier:NSStringFromClass([GFAssetItemCell class])];
    }
    return _assetsCollectionView;
}

- (UIView *)actionBar {
    if (!_actionBar) {
        _actionBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 40, self.view.width, 40)];
        _actionBar.backgroundColor = [UIColor blackColor];
    }
    return _actionBar;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(self.actionBar.width - 16 - self.actionBar.height, 0, self.actionBar.height, self.actionBar.height);
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    }
    return _previewButton;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.previewButton.x - 24, self.actionBar.height/2 - 12, 24, 24)];
        _countLabel.backgroundColor = [UIColor purpleColor];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.layer.masksToBounds = YES;
        _countLabel.layer.cornerRadius = 12.0f;
        _countLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _countLabel.layer.borderWidth = 2.0f;
    }
    return _countLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.gTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemSelected)];
    
    [self.view addSubview:self.assetsCollectionView];
    [self.view addSubview:self.actionBar];
    [self.actionBar addSubview:self.previewButton];
    [self.actionBar addSubview:self.countLabel];
    
    __weak typeof(self) weakSelf = self;
    [self.previewButton bk_addEventHandler:^(id sender) {
        GFAssetsPickerViewController *picker = (GFAssetsPickerViewController *)self.navigationController;
        [weakSelf previewAssets:picker.selectedAssets thumbnails:picker.selectedThumbnails];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self updateActionBar];
}

- (void)rightBarButtonItemSelected {
    
    GFAssetsPickerViewController *picker = (GFAssetsPickerViewController *)self.navigationController;
    if (picker.gf_didFinishPickingAssetsBlock) {
        picker.gf_didFinishPickingAssetsBlock(picker, picker.selectedAssets, picker.selectedThumbnails);
    }
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.assets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GFAssetItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFAssetItemCell class]) forIndexPath:indexPath];
    
    id asset = [self.assets objectAtIndex:indexPath.item];
    [cell bindWithModel:asset];

    GFAssetsPickerViewController *picker = (GFAssetsPickerViewController *)self.navigationController;
    if ([picker.selectedAssets containsObject:asset]) {
        NSInteger order = [picker.selectedAssets indexOfObject:asset];
        cell.badgeOrder = order + 1;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    GFAssetItemCell *cell = (GFAssetItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    id asset = [self.assets objectAtIndex:indexPath.row];
    
    GFAssetsPickerViewController *pickerViewController = (GFAssetsPickerViewController *)self.navigationController;
    if (pickerViewController.maxSelectNumber == 1) {
        //  确定页面
        BOOL isCropAllowed = [(GFAssetsPickerViewController *)self.navigationController isCropAllowed];
        if (isCropAllowed) {
            [GFPhotoUtil originalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                GFCroppingPhotoViewController *croppingPhotoViewController = [[GFCroppingPhotoViewController alloc] initWithImage:photo cropMode:RSKImageCropModeSquare];
                croppingPhotoViewController.delegate = self;
                [self.navigationController pushViewController:croppingPhotoViewController animated:YES];
            }];
        } else {
            [self previewAssets:@[asset] thumbnails:@[cell.thumnailImageView.image]];
        }
    } else {
        if ([pickerViewController.selectedAssets containsObject:asset]) {
            NSInteger index = [pickerViewController.selectedAssets indexOfObject:asset];
            [pickerViewController.selectedAssets removeObject:asset];
            [pickerViewController.selectedThumbnails removeObjectAtIndex:index];
        } else {
            if ([pickerViewController.selectedAssets count] < pickerViewController.maxSelectNumber) {
                [pickerViewController.selectedAssets addObject:asset];
                [pickerViewController.selectedThumbnails addObject:cell.thumnailImageView.image];
            }
        }
        [self updateActionBar];
        [self updateVisiableCellBadge];
    }
}

- (void)updateActionBar {
    GFAssetsPickerViewController *pickerViewController = (GFAssetsPickerViewController *)self.navigationController;
    
    self.previewButton.enabled = [pickerViewController.selectedAssets count] > 0;
    self.countLabel.hidden = [pickerViewController.selectedAssets count] == 0;
    self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[pickerViewController.selectedAssets count]];
}

- (void)updateVisiableCellBadge {
    GFAssetsPickerViewController *pickerViewController = (GFAssetsPickerViewController *)self.navigationController;
    NSArray *cells = [self.assetsCollectionView visibleCells];
    for (GFAssetItemCell *cell in cells) {
        
        NSInteger index = [pickerViewController.selectedAssets indexOfObject:cell.model];
        cell.badgeOrder = index + 1;
    }
}

- (void)previewAssets:(NSArray *)assets thumbnails:(NSArray *)thumbnails {
    
    TZPhotoPreviewController *photoPreview = [[TZPhotoPreviewController alloc] init];
    photoPreview.assets = assets;
    photoPreview.thumbnails = thumbnails;
    [self.navigationController pushViewController:photoPreview animated:YES];
}

#pragma mark - RSKImageCropViewControllerDelegate
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    GFAssetsPickerViewController *picker = (GFAssetsPickerViewController *)self.navigationController;
    if (picker.gf_didFinishPickingImageBlock) {
        picker.gf_didFinishPickingImageBlock(picker, croppedImage, [croppedImage gf_imageByScalingAndCroppingForSize:CGSizeMake(100, 100)]);
    }
    if (picker.presentingViewController) {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
