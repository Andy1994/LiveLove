//
//  GFPublishPhotoAlbumCollectionViewCell.h
//  GetFun
//
//  Created by Liu Peng on 16/3/16.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"

@class GFPublishPhotoAlbumCollectionViewCell;

@protocol GFPublishPhotoAlbumCollectionViewCellDelegate <NSObject>
- (void)deleteImageInCell:(GFPublishPhotoAlbumCollectionViewCell *)cell; //删除已选择图片
@end

@interface GFPublishPhotoAlbumCollectionViewCell : GFBaseCollectionViewCell
@property (nonatomic, weak) id<GFPublishPhotoAlbumCollectionViewCellDelegate> delegate;

- (void)bindWithModel:(id)model canDelete:(BOOL)canDelete;
@end
