//
//  GFAssetsPickerViewController.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/24.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFAssetsPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "GFAssetsAlbumViewController.h"
#import "GFAssetsItemsViewController.h"
#import "GFPhotoUtil.h"

@interface GFAssetsPickerViewController ()

@property (nonatomic, strong) NSMutableArray *albumPosters;
@property (nonatomic, strong) NSMutableArray *albumTitles;
@property (nonatomic, strong) NSMutableArray *albumAssets;

@end

@implementation GFAssetsPickerViewController
- (instancetype)init {
    if (self = [super init]) {
        //默认不剪裁
        _isCropAllowed = NO;
        
        _albumPosters = [[NSMutableArray alloc] initWithCapacity:0];
        _albumTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _albumAssets = [[NSMutableArray alloc] initWithCapacity:0];
        
        _maxSelectNumber = 1;
        
        void (^albumInitCompletionHandler)() = ^() {
            
            GFAssetsAlbumViewController *albumViewController = [[GFAssetsAlbumViewController alloc] initWithTitles:self.albumTitles posters:self.albumPosters assets:self.albumAssets];
            
            NSString *title = [self.albumTitles objectAtIndex:0];
            NSArray *assets = [self.albumAssets objectAtIndex:0];
            GFAssetsItemsViewController *assetsViewController = [[GFAssetsItemsViewController alloc] initWithTitle:title assets:assets];
            
            self.viewControllers = @[albumViewController, assetsViewController];
            
            [MobClick event:@"gf_tp_01_01_09_1"];
        };
        
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            [self iOS7AssetsAlbumsInitCompletion:albumInitCompletionHandler];
        } else {
            [self iOS8AndLaterAssetsAlbumsInitCompletion:albumInitCompletionHandler];
        }
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedAssets;
}

- (NSMutableArray *)selectedThumbnails {
    if (!_selectedThumbnails) {
        _selectedThumbnails = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectedThumbnails;
}

#pragma mark - iOS 7
- (void)iOS7AssetsAlbumsInitCompletion:(void(^)())completion {

    ALAssetsLibrary *library = [GFPhotoUtil defaultAssetsLibrary];
    ALAssetsLibraryGroupsEnumerationResultsBlock groupResultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            
            [self.albumTitles addObject:[group valueForProperty:ALAssetsGroupPropertyName]];
            [self.albumPosters addObject:[UIImage imageWithCGImage:group.posterImage]];
            
            NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:0];
            if (group.numberOfAssets > 0) {
                ALAssetsGroupEnumerationResultsBlock assetsResultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if (asset) {
                        NSString *type = [asset valueForProperty:ALAssetPropertyType];
                        if ([type isEqual:ALAssetTypePhoto]) {
                            [assets addObject:asset];
                        }
                    }
                };
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:assetsResultsBlock];
            }
            
            [self.albumAssets addObject:assets];
        } else {
            if (completion) {
                completion();
            }
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
    };
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:groupResultsBlock
                         failureBlock:failureBlock];
}

#pragma mark - iOS 8 and Later
- (void)iOS8AndLaterAssetsAlbumsInitCompletion:(void(^)())completion {
    // 相机胶卷
    {
        PHFetchResult *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                              subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                              options:nil];
        for(PHCollection *collection in cameraRoll) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                
                if(assetsFetchResult.count > 0) {
                    [self.albumTitles addObject:assetCollection.localizedTitle];
                    [self.albumAssets addObject:assetsFetchResult];
                    
                    PHAsset *asset = [assetsFetchResult objectAtIndex:0];
                    [GFPhotoUtil requestThumbnailForAsset:asset completion:^(UIImage *thumbnail) {
                        [self.albumPosters addObject:thumbnail];
                    }];
                }
            }
        }
    }
    
    // 其它智能相册
    {
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                              subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                              options:nil];
        for(PHCollection *collection in smartAlbums) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {

                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    continue;
                }
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                
                if(assetsFetchResult.count > 0) {
                    [self.albumTitles addObject:assetCollection.localizedTitle];
                    [self.albumAssets addObject:assetsFetchResult];
                    
                    PHAsset *asset = [assetsFetchResult objectAtIndex:0];
                    [GFPhotoUtil requestThumbnailForAsset:asset completion:^(UIImage *thumbnail) {
                        [self.albumPosters addObject:thumbnail];
                    }];
                }
            }
        }
    }
    
    // 用户自建相册
    {
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        for(PHCollection *collection in topLevelUserCollections) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", @[@(PHAssetMediaTypeImage)]];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                
                if (assetsFetchResult.count > 0) {
                    [self.albumTitles addObject:assetCollection.localizedTitle];
                    [self.albumAssets addObject:assetsFetchResult];
                    
                    PHAsset *asset = [assetsFetchResult objectAtIndex:0];
                    [GFPhotoUtil requestThumbnailForAsset:asset completion:^(UIImage *thumbnail) {
                        [self.albumPosters addObject:thumbnail];
                    }];
                }
            }
        }
    }
    if (completion) {
        completion();
    }
}

@end
