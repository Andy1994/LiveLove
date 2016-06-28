 //
//  GFPublishPhotoViewController.m
//  GetFun
//
//  Created by Liu Peng on 16/3/16.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFPublishPhotoViewController.h"
#import "GFPublishPhotoAlbumCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <HPGrowingTextView.h>
#import "GFImageGroupView.h"
#import "GFPublishParameterMTL.h"
#import "GFPublishManager.h"
#import "GFAssetsPickerViewController.h"
#import "GFPhotoUtil.h"

NSString * const GFUserDefaultsKeyPublishPictureDraft = @"GFUserDefaultsKeyPublishPictureDraft";

static const NSUInteger kMaxPhotoCount = 20;
static const CGFloat kOffset = 15.0f; //两侧边距
static const CGFloat kItemSpace = 5.0f; //图片间距
static const NSInteger kItemCount = 4; //单行图片数目
static const CGFloat kGrowingTextViewMinHeight = 90; //编辑区域最小高度
//static const CGFloat kGrowingTextViewMaxHeight = 65535; //编辑区域最大高度，65536为不限制高度

@interface GFPublishPhotoViewController ()
<HPGrowingTextViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
GFPublishPhotoAlbumCollectionViewCellDelegate
>

@property (nonatomic, strong) HPGrowingTextView *growingTextView;
@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) NSMutableArray *previewImages;

@property (nonatomic, strong) NSMutableArray *pictures;
@property (nonatomic, assign) BOOL isHeightChanging;

//话题
@property (nonatomic, strong) UIButton *changeTopicButton;
@property (nonatomic, assign) NSInteger topicIndex;
//是否来自话头发布
@property (nonatomic, assign) BOOL fromTagInput;
@end

@implementation GFPublishPhotoViewController

- (instancetype)initWithTag:(GFTagMTL *)tag fromTagInput:(BOOL)fromTagInput {
    GFPublishKeyFrom publishKeyFrom = [tag.prologues count] > 0? GFPublishKeyFromTagTopic:GFPublishKeyFromTagNoTopic;
    if (self = [super initWithTag:tag keyFrom:publishKeyFrom]) {
        _fromTagInput = fromTagInput;
    }
    return self;
}

- (HPGrowingTextView *)growingTextView {
    if (!_growingTextView) {
        _growingTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 64 + kOffset - 5, SCREEN_WIDTH, kGrowingTextViewMinHeight)];

        _growingTextView.contentInset = UIEdgeInsetsMake(kOffset, kOffset - 5, kOffset, kOffset - 5);
        _growingTextView.internalTextView.showsVerticalScrollIndicator = NO;
        _growingTextView.font = [UIFont systemFontOfSize:18.0f];
        _growingTextView.returnKeyType = UIReturnKeyDone;
//        _growingTextView.maxHeight = (int)kGrowingTextViewMaxHeight;
//        _growingTextView.maxHeight = (int)(SCREEN_HEIGHT/4);
        _growingTextView.maxNumberOfLines = 5;
        _growingTextView.minHeight = (int)kGrowingTextViewMinHeight;
        _growingTextView.internalTextView.scrollEnabled = NO;
        _growingTextView.delegate = self;
    }
    _growingTextView.height = MAX(_growingTextView.height, kGrowingTextViewMinHeight);
    return _growingTextView;
}

- (UICollectionView *)photoCollectionView {
    if (!_photoCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - kPublishOptionViewHeight) collectionViewLayout:layout];
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.contentInset = UIEdgeInsetsMake(kGrowingTextViewMinHeight + kOffset - 5, 0, 0, 0);
        _photoCollectionView.showsVerticalScrollIndicator = NO;
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        [_photoCollectionView registerClass:[GFPublishPhotoAlbumCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([GFPublishPhotoAlbumCollectionViewCell class])];
    }
    return _photoCollectionView;
}

- (UIButton *)changeTopicButton {
    if (!_changeTopicButton) {
        _changeTopicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonImage = [UIImage imageNamed:@"publish_change_topic"];
        CGSize imageSize = buttonImage.size;
        [_changeTopicButton setImage:[UIImage imageNamed:@"publish_change_topic"] forState:UIControlStateNormal];
        _changeTopicButton.adjustsImageWhenHighlighted = NO;
        _changeTopicButton.bounds = CGRectMake(0, 0, imageSize.width + 17 * 2, imageSize.height + 13 * 2);
        _changeTopicButton.contentMode = UIViewContentModeLeft;
    }
    return _changeTopicButton;
}

- (NSMutableArray *)previewImages {
    if (!_previewImages) {
        _previewImages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _previewImages;
}

- (NSMutableArray *)pictures {
    if (!_pictures) {
        _pictures = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _pictures;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"发布图片";
    
    __weak typeof(self) weakSelf = self;
    [self.view addSubview:self.photoCollectionView];
    [self.view addSubview:self.growingTextView];
    
    NSData *pictureData = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyPublishPictureDraft];
    if (pictureData) {
        GFPublishPictureMTL *publish = [NSKeyedUnarchiver unarchiveObjectWithData:pictureData];
        if (publish) {
            
            for (NSString *path in publish.pictures) {
                NSString *fixPath = [self fixSandboxFilePath:path];
                [self.pictures addObject:fixPath];
                
                UIImage *image = [UIImage imageWithContentsOfFile:fixPath];
                [self.previewImages addObject:[image gf_imageByScalingAndCroppingForSize:CGSizeMake(100, 100)]];
            }
        }
    }
    
    if ([self.tag.prologues count] > 0) {

        NSString *topic = [self.tag.prologues firstObject].prologue;

        self.growingTextView.text = [self getCroppedStringFromString:topic];
        
        if ([self.tag.prologues count] > 1) {
//            self.changeTopicButton.center = CGPointMake(SCREEN_WIDTH - 12 - self.changeTopicButton.width * 0.5, 64 + 12 + self.changeTopicButton.height * 0.5);
            self.changeTopicButton.center = CGPointMake(SCREEN_WIDTH - self.changeTopicButton.width * 0.5, 64 + self.changeTopicButton.height * 0.5);
            [self.view addSubview:self.changeTopicButton];
            
            [self.changeTopicButton bk_addEventHandler:^(id sender) {
                [MobClick event:@"gf_bq_02_05_01_1"];
                [weakSelf changeTopic:nil];
            } forControlEvents:UIControlEventTouchUpInside];
        }
    } else if (self.tag) {
        self.growingTextView.placeholder = @"说点和这个标签相关的吧";
    } else {
        self.growingTextView.placeholder = @"随便说点什么吧";
    }
    
    if (!self.fromTagInput) {
        if ([GFPhotoUtil checkAuthorization]) {
            GFAssetsPickerViewController *assetsPicker = [[GFAssetsPickerViewController alloc] init];
            assetsPicker.maxSelectNumber = kMaxPhotoCount;
            assetsPicker.gf_didFinishPickingAssetsBlock = ^(GFAssetsPickerViewController *picker, NSArray *assets, NSArray *thumbnails) {
                [self handleSelectAssets:assets thumbnails:thumbnails];
            };
            [self presentViewController:assetsPicker animated:YES completion:^{
            }];
        }

    }
}

#pragma mark - privacy methods
- (void)changeTopic:(id)sender {
    
    NSArray<GFTagPrologueMTL *> *topics = self.tag.prologues;
    self.topicIndex ++;
    if (self.topicIndex == [topics count]) {
        self.topicIndex = 0;
    }
    
    self.growingTextView.text = [self getCroppedStringFromString:topics[self.topicIndex].prologue];
}

- (NSString *)getCroppedStringFromString:(NSString *)inputString {

    UIFont *inputFont = [UIFont systemFontOfSize:18.0];
    CGFloat inputWidth = [inputString sizeWithFont:inputFont].width;
    
    if (inputWidth > SCREEN_WIDTH - 30 - 55) {
     
        if ([inputString length] > 14) {
            inputString = [inputString substringWithRange:NSMakeRange(0, 14)];
        }
        NSInteger count = 14;
        while ([inputString sizeWithFont:inputFont].width > SCREEN_WIDTH - 30 - 55) {
            count--;
            inputString = [inputString substringWithRange:NSMakeRange(0, count)];
        }
        inputString = [inputString substringWithRange:NSMakeRange(0, count - 2)];
        NSMutableString *resultString = [NSMutableString stringWithString:inputString];
        return [[resultString stringByAppendingString:@".."] copy];
     }
    return inputString;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.previewImages count] == kMaxPhotoCount ? kMaxPhotoCount : [self.previewImages count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    GFPublishPhotoAlbumCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GFPublishPhotoAlbumCollectionViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    if (indexPath.row == [self.previewImages count]) {
        [cell bindWithModel:[UIImage imageNamed:@"publish_add_photo"] canDelete:NO];
    } else {
        [cell bindWithModel:[self.previewImages objectAtIndex:indexPath.row] canDelete:YES];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, kOffset, 0, kOffset);;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    CGFloat wh = floorf((SCREEN_WIDTH - kOffset * 2 - kItemSpace * (kItemCount - 1))/kItemCount);
    size = CGSizeMake(wh, wh);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kItemSpace;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kItemSpace;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [self.view endEditing:YES];
    if (indexPath.row == [self.previewImages count]) {
        switch (self.keyFrom) {
            case GFPublishKeyFromHome: {
                [MobClick event:@"gf_fb_06_01_05_1"];
                break;
            }
            case GFPublishKeyFromTagTopic: {
                [MobClick event:@"gf_bq_02_05_06_1"];
                break;
            }
            case GFPublishKeyFromTagNoTopic: {
                [MobClick event:@"gf_bq_02_06_05_1"];
                break;
            }
            case GFPublishKeyFromGroup: {
                break;
            }
        }
        
        [self showImagePickerViewController];
    }
}

#pragma mark - GFPublishPhotoAlbumCollectionViewCellDelegate
- (void)deleteImageInCell:(GFPublishPhotoAlbumCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.photoCollectionView indexPathForCell:cell];
    [self.pictures removeObjectAtIndex:indexPath.row];
    [self.previewImages removeObjectAtIndex:indexPath.row];
    [self.photoCollectionView reloadData];
}

#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    CGFloat delta = height - growingTextView.size.height;
    if (height >= kGrowingTextViewMinHeight) {
        self.isHeightChanging = YES;
        
        CGPoint contentOffset = self.photoCollectionView.contentOffset;
        contentOffset.y -= delta;
        self.photoCollectionView.contentOffset = contentOffset;
        
        UIEdgeInsets inset = self.photoCollectionView.contentInset;
        inset.top += delta;
        self.photoCollectionView.contentInset = inset;
    }
}

-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    self.isHeightChanging = NO;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    switch (self.keyFrom) {
        case GFPublishKeyFromHome: {
            [MobClick event:@"gf_fb_06_01_01_1"];
            break;
        }
        case GFPublishKeyFromTagTopic: {
            [MobClick event:@"gf_bq_02_05_02_1"];
            break;
        }
        case GFPublishKeyFromTagNoTopic: {
            [MobClick event:@"gf_bq_02_06_01_1"];
            break;
        }
        case GFPublishKeyFromGroup: {
            break;
        }
    }
    
    
    self.changeTopicButton.hidden = YES;
    if ([self.tag.prologues count] > 0) {
        self.growingTextView.text = self.tag.prologues[self.topicIndex].prologue;
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isHeightChanging) {
        CGPoint contentOffset = scrollView.contentOffset;
        CGPoint origin = self.growingTextView.origin;
        origin.y = 64 -(self.growingTextView.height + contentOffset.y);
        self.growingTextView.origin = origin;
    }
}

- (void)handleSelectImage:(UIImage *)image path:(NSString *)path {
    
    [super handleSelectImage:image path:path];
    [self.previewImages addObject:image];
    [self.photoCollectionView reloadData];
    
    [self.pictures addObject:path];
}

- (void)backBarButtonItemSelected {
    
    switch (self.keyFrom) {
        case GFPublishKeyFromHome: {
            [MobClick event:@"gf_fb_06_01_03_1"];
            break;
        }
        case GFPublishKeyFromTagTopic: {
            [MobClick event:@"gf_bq_02_05_04_1"];
            break;
        }
        case GFPublishKeyFromTagNoTopic: {
            [MobClick event:@"gf_bq_02_06_03_1"];
            break;
        }
        case GFPublishKeyFromGroup: {
            break;
        }
    }
    
    [self.view endEditing:YES];
    
    NSArray *pictures = self.pictures;
    if ([pictures count] > 0) {
        [UIAlertView bk_showAlertViewWithTitle:@"是否保存草稿" message:@"" cancelButtonTitle:@"放弃" otherButtonTitles:@[@"保存"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                
                GFPublishPictureMTL *pictureMTL = [[GFPublishPictureMTL alloc] init];
                pictureMTL.pictures = pictures;
                
                NSData *pictureData = [NSKeyedArchiver archivedDataWithRootObject:pictureMTL];
                [GFUserDefaultsUtil setObject:pictureData forKey:GFUserDefaultsKeyPublishPictureDraft];
            } else {
                [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishPictureDraft];
            }
            [super backBarButtonItemSelected];
        }];
    } else {
        [GFUserDefaultsUtil setObject:nil forKey:GFUserDefaultsKeyPublishPictureDraft];
        [super backBarButtonItemSelected];
    }
}

- (void)sendBarButtonItemSelected {
    switch (self.keyFrom) {
        case GFPublishKeyFromHome: {
            [MobClick event:@"gf_fb_06_01_04_1"];
            break;
        }
        case GFPublishKeyFromTagTopic: {
            [MobClick event:@"gf_bq_02_05_05_1"];
            break;
        }
        case GFPublishKeyFromTagNoTopic: {
            [MobClick event:@"gf_bq_02_06_04_1"];
            break;
        }
        case GFPublishKeyFromGroup: {
            break;
        }
    }
    
    if ([self.pictures count] == 0 && [[self.growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [MBProgressHUD showHUDWithTitle:@"标题和图片不能同时为空~" duration:kCommonHudDuration];
        return;
    }
    
    GFPublishPictureMTL *pictureMTL = [[GFPublishPictureMTL alloc] init];
    pictureMTL.pictures = self.pictures;
    
    NSString *content = @"";
    if (self.changeTopicButton.hidden) {
        content = [self.growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else if ([self.tag.prologues count] > 0) {
        content = [self.tag.prologues objectAtIndex:self.topicIndex].prologue;
    }
    pictureMTL.content = content;
    
    if (self.currentPOI) {
        pictureMTL.longitude = [NSNumber numberWithDouble:self.currentPOI.location.longitude];
        pictureMTL.latitude = [NSNumber numberWithDouble:self.currentPOI.location.latitude];
        
        NSString *address = [NSString stringWithFormat:@"%@%@%@%@",
                             [self.currentPOI.province isEqualToString:self.currentPOI.city] ? @"" : self.currentPOI.province,
                             self.currentPOI.city,
                             self.currentPOI.district,
                             self.currentPOI.name];
        pictureMTL.address = address;
    }
    if (self.selectedGroup) {
        pictureMTL.groupId = self.selectedGroup.groupInfo.groupId;
    }
    if (self.tag) {
        pictureMTL.tagId = self.tag.tagInfo.tagId;
    }
    [GFPublishManager publish:pictureMTL];
    
    [super sendBarButtonItemSelected];
}

//重写父类属性方法
- (NSUInteger)currentSelectedPhotoCount {
    return [self.previewImages count];
}

@end
