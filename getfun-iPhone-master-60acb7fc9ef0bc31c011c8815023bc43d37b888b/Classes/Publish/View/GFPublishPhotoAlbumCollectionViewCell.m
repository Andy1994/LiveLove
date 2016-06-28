//
//  GFPublishPhotoAlbumCollectionViewCell.m
//  GetFun
//
//  Created by Liu Peng on 16/3/16.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFPublishPhotoAlbumCollectionViewCell.h"

static const CGFloat kDeleteButtonWH = 24.0f;

@interface GFPublishPhotoAlbumCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation GFPublishPhotoAlbumCollectionViewCell
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"publish_delete_photo"] forState:UIControlStateNormal];
        _deleteButton.size = CGSizeMake(kDeleteButtonWH, kDeleteButtonWH);
    }
    return _deleteButton;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.deleteButton.hidden = NO;
    self.imageView.image = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.deleteButton];
        self.deleteButton.center = CGPointMake(self.imageView.right - self.deleteButton.width/2 + 4, self.imageView.y + self.deleteButton.height/2 - 4);

        @weakify(self)
        [self.deleteButton bk_addEventHandler:^(id sender) {
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(deleteImageInCell:)]) {
                [self.delegate deleteImageInCell:self];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)bindWithModel:(id)model canDelete:(BOOL)canDelete {
    [super bindWithModel:model];
    
    self.deleteButton.hidden = !canDelete;
    if ([model isKindOfClass:[UIImage class]]) {
        self.imageView.image = (UIImage *)model;
    }

    [self setNeedsLayout];
}

@end
