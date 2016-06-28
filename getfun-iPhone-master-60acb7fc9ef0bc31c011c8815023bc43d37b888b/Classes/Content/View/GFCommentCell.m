//
//  GFCommentCell.m
//  GetFun
//
//  Created by muhuaxin on 15/11/16.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCommentCell.h"
#import "GFCommentMTL.h"
#import "GFUserMTL.h"

#define kCommentTopSpacing 15.0f
#define kPictureTopSpacing 10.0f
#define kPictureGapWidth 5.0f
#define kReplyInfoTopSpacing 12.0f
#define kReplyInfoHeight 25.0f
#define kCellBottomSpacing 16.0f

#define kPaddingWidth 15.0f
#define kIndentWidth 35.0f
#define kHeaderHeight 50.0f

@interface GFCommentCell()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *avatarMaskView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *mineIcon;//楼主
//@property (nonatomic, strong) UIImageView *dateIcon;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *funButton;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) UIView *replyBackgroundView;
@property (nonatomic, strong) UIView *replyerAvatarMaskView;
@property (nonatomic, strong) UIImageView *replyerAvatarImageView;
@property (nonatomic, strong) UILabel *replyerNameLabel;//回复者名字
@property (nonatomic, strong) UILabel *replyerNameSuffixLabel;//“回复了此跟帖”
@property (nonatomic, strong) UILabel *replyCountLabel;//查看xx条回复

@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewList;

@end

@implementation GFCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.bgView];
        self.backgroundColor = [UIColor whiteColor];
        
        [self.bgView addSubview:self.avatarMaskView];
        [self.bgView addSubview:self.avatarImageView];
        [self.bgView addSubview:self.nameLabel];
        [self.bgView addSubview:self.mineIcon];
        [self.bgView addSubview:self.dateLabel];
        [self.bgView addSubview:self.funButton];
        [self.bgView addSubview:self.commentLabel];
        
        [self.bgView addSubview:self.replyBackgroundView];
        [self.replyBackgroundView addSubview:self.replyerAvatarMaskView];
        [self.replyBackgroundView addSubview:self.replyerAvatarImageView];
        [self.replyBackgroundView addSubview:self.replyerNameLabel];
        [self.replyBackgroundView addSubview:self.replyerNameSuffixLabel];
        [self.replyBackgroundView addSubview:self.replyCountLabel];
        
        self.bottomSpace = 0;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewList removeAllObjects];
}

#pragma mark - Getters

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIView *)avatarMaskView {
    if (_avatarMaskView == nil) {
        _avatarMaskView = [[UIView alloc] init];
        _avatarMaskView.layer.borderColor = RGBCOLOR(109, 178, 252).CGColor;
        _avatarMaskView.layer.borderWidth = 2;
        _avatarMaskView.layer.cornerRadius = 34 / 2;
        _avatarMaskView.clipsToBounds = YES;
    }
    return _avatarMaskView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.userInteractionEnabled = YES;
        _avatarImageView.layer.cornerRadius = 32 / 2;
        _avatarImageView.clipsToBounds = YES;
        
        __weak typeof(self) weakSelf = self;
        [_avatarImageView bk_whenTapped:^{
            if (weakSelf.avatarTappedHandler) {
                weakSelf.avatarTappedHandler(weakSelf, weakSelf.model);
            }
        }];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor textColorValue1];
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (UIImageView *)mineIcon {
    if (_mineIcon == nil) {
        _mineIcon = [[UIImageView alloc] init];
        _mineIcon.image = [UIImage imageNamed:@"comment_louzhu"];
    }
    return _mineIcon;
}

//- (UIImageView *)dateIcon {
//    if (_dateIcon == nil) {
//        _dateIcon = [[UIImageView alloc] init];
//        _dateIcon.image = [UIImage imageNamed:@"comment_icon_time"];
//    }
//    return _dateIcon;
//}

- (UILabel *)dateLabel {
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor textColorValue4];
        _dateLabel.font = [UIFont systemFontOfSize:12];
    }
    return _dateLabel;
}

- (UIButton *)funButton {
    if (_funButton == nil) {
        _funButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _funButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        _funButton.titleLabel.textColor = [UIColor textColorValue1];
        _funButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _funButton.layer.borderWidth = 0.5;
        _funButton.layer.cornerRadius = 3;
        _funButton.clipsToBounds = YES;
        [_funButton addTarget:self action:@selector(funButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _funButton;
}

- (UILabel *)commentLabel {
    if (_commentLabel == nil) {
        _commentLabel = [[UILabel alloc] init];
        _commentLabel.textColor = [UIColor textColorValue1];
        _commentLabel.font = [UIFont systemFontOfSize:17];
        _commentLabel.numberOfLines = 0;
    }
    return _commentLabel;
}

- (UIView *)replyBackgroundView {
    if (_replyBackgroundView == nil) {
        _replyBackgroundView = [[UIView alloc] init];
        _replyBackgroundView.backgroundColor = RGBCOLOR(246, 247, 249);
    }
    return _replyBackgroundView;
}

- (UIView *)replyerAvatarMaskView {
    if (_replyerAvatarMaskView == nil) {
        _replyerAvatarMaskView = [[UIView alloc] init];
        _replyerAvatarMaskView.layer.borderColor = RGBCOLOR(109, 178, 252).CGColor;
        _replyerAvatarMaskView.layer.borderWidth = 1;
        _replyerAvatarMaskView.layer.cornerRadius = 24 / 2;
        _replyerAvatarMaskView.clipsToBounds = YES;
    }
    return _replyerAvatarMaskView;
}

- (UIImageView *)replyerAvatarImageView {
    if (_replyerAvatarImageView == nil) {
        _replyerAvatarImageView = [[UIImageView alloc] init];
        _replyerAvatarImageView.layer.cornerRadius = 20 / 2;
        _replyerAvatarImageView.clipsToBounds = YES;
    }
    return _replyerAvatarImageView;
}

- (UILabel *)replyerNameLabel {
    if (_replyerNameLabel == nil) {
        _replyerNameLabel = [[UILabel alloc] init];
        _replyerNameLabel.textColor = [UIColor blackColor];
        _replyerNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _replyerNameLabel;
}

- (UILabel *)replyerNameSuffixLabel {
    if (_replyerNameSuffixLabel == nil) {
        _replyerNameSuffixLabel = [[UILabel alloc] init];
        _replyerNameSuffixLabel.textColor = [UIColor blackColor];
        _replyerNameSuffixLabel.font = [UIFont systemFontOfSize:14];
        _replyerNameSuffixLabel.text = @"回复了此帖";
    }
    return _replyerNameSuffixLabel;
}

- (UILabel *)replyCountLabel {
    if (_replyCountLabel == nil) {
        _replyCountLabel = [[UILabel alloc] init];
        _replyCountLabel.textColor = RGBCOLOR(173, 171, 204);
        _replyCountLabel.font = [UIFont systemFontOfSize:14];
    }
    return _replyCountLabel;
}

- (NSMutableArray<UIImageView *> *)imageViewList {
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _imageViewList;
}

#pragma mark - Setters

- (void)setIsMine:(BOOL)isMine {
    _isMine = isMine;
    
    self.mineIcon.hidden = !isMine;
}

- (void)doFunAnimate {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_fun_disabled"]];
    [imageView sizeToFit];
    imageView.center = self.funButton.center;
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"+1";
    [imageView addSubview:label];
    
    [UIView animateWithDuration:.3 animations:^{
        imageView.y -= 10;
    } completion:^(BOOL finished) {
        [imageView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.2];
    }];
}

#pragma mark - Private methods

- (void)funButtonAction:(UIButton *)button {
    
    if (self.funButtonHandler) {
        self.funButtonHandler(self, self.model);
    }
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_fun_disabled"]];
//    [imageView sizeToFit];
//    imageView.center = self.funButton.center;
//    [self addSubview:imageView];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:imageView.bounds];
//    label.font = [UIFont systemFontOfSize:12];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"+1";
//    [imageView addSubview:label];
//    
//    [UIView animateWithDuration:.3 animations:^{
//        imageView.y -= 10;
//    } completion:^(BOOL finished) {
//        [imageView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.2];
//    }];
}

#pragma mark - Public methods

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFCommentMTL *mtl = model;
    
    NSString *url = [mtl.user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"default_avatar_2"]];
    self.avatarMaskView.layer.borderColor = [UIColor gf_colorWithHex:mtl.user.color].CGColor;
    
    self.nameLabel.text = mtl.user.nickName ? mtl.user.nickName : @"";
    self.dateLabel.text = [GFTimeUtil getfunStyleTimeFromTimeInterval:[mtl.commentInfo.createTime longLongValue] / 1000];
    
    [self.funButton setTitle:[NSString stringWithFormat:@"%ld FUN", (long)[mtl.commentInfo.funCount integerValue]] forState:UIControlStateNormal];
    if (mtl.loginUserHasFuned) {
        self.funButton.layer.borderColor = [UIColor themeColorValue10].CGColor;
        [self.funButton setTitleColor:[UIColor themeColorValue10] forState:UIControlStateNormal];
        self.funButton.enabled = NO;
    } else {
        self.funButton.layer.borderColor = [UIColor textColorValue4].CGColor;
        [self.funButton setTitleColor:[UIColor textColorValue4] forState:UIControlStateNormal];
        self.funButton.enabled = YES;
    }
    
    self.commentLabel.text = mtl.commentInfo.commentContent;
    
    if ([mtl.commentInfo.pictureKeys count] > 0) {
        for (NSString *pictureKey in mtl.commentInfo.pictureKeys) {
            GFPictureMTL *picture = [mtl.pictures objectForKey:pictureKey];
            NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeFeedThreePictures gifConverted:YES];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.imageViewList addObject:imageView];
            [self.contentView addSubview:imageView];
            imageView.userInteractionEnabled = YES;
            __weak typeof(self) weakSelf = self;
            NSInteger index = [mtl.commentInfo.pictureKeys indexOfObject:pictureKey];
            [imageView bk_whenTapped:^{
                if (weakSelf.tapImageHandler) {
                    weakSelf.tapImageHandler(weakSelf, index);
                }
            }];
        }
    } else if ([mtl.commentInfo.emotionIds count] > 0) {
        for (NSString *emotionId in mtl.commentInfo.emotionIds) {
            GFEmotionMTL *emotion = [mtl.emotions objectForKey:[NSString stringWithFormat:@"%@", emotionId]];
            NSString *url = [emotion.imgUrl gf_urlStandardizedWithType:GFImageStandardizedTypeFeedThreePictures gifConverted:YES];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [imageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self.imageViewList addObject:imageView];
            [self.contentView addSubview:imageView];
        }
    }
    
    
    if (mtl.children.count > 0) {
        self.replyBackgroundView.hidden = NO;
        GFCommentMTL *subComment = mtl.children[0];
        [self.replyerAvatarImageView setImageWithURL:[NSURL URLWithString:[subComment.user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES]] placeholder:[UIImage imageNamed:@"default_avatar_2"]];
        self.replyerNameLabel.text = subComment.user.nickName;
        
        NSString *replyCountString = mtl.commentInfo.replyCountTotal.integerValue < 1000 ? [mtl.commentInfo.replyCountTotal stringValue] : @"1000+";
        self.replyCountLabel.text = [NSString stringWithFormat:@"查看%@条回复", replyCountString];
    } else {
        self.replyBackgroundView.hidden = YES;
    }
    
    [self setNeedsLayout];
}

+ (CGFloat)heightWithModel:(id)model {
    GFCommentMTL *mtl = model;

    CGFloat maxWidth = SCREEN_WIDTH - kPaddingWidth*2 - kIndentWidth;

    // header部分的高度
    CGFloat height = kHeaderHeight;

    if (mtl.commentInfo.commentContent) {
        // 评论部分的高度
        UILabel *commentLabel = [[UILabel alloc] init];
        commentLabel.textColor = [UIColor blackColor];
        commentLabel.font = [UIFont systemFontOfSize:17];
        commentLabel.numberOfLines = 0;
        commentLabel.text = mtl.commentInfo.commentContent;
        CGSize commentLabelSize = [commentLabel sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
        height += kCommentTopSpacing + commentLabelSize.height;
    }
    
    // 图片部分的高度
    if ([mtl.commentInfo.pictureKeys count] > 0) {
        NSInteger numberOfRows = ([mtl.commentInfo.pictureKeys count] + 2) / 3;
        CGFloat pictureWH = (maxWidth - kPictureGapWidth * 2) / 3;
        height += pictureWH * numberOfRows + kPictureGapWidth * (numberOfRows - 1) + kPictureTopSpacing;
    } else if ([mtl.commentInfo.emotionIds count] > 0) {
        NSInteger numberOfRows = ([mtl.commentInfo.emotionIds count] + 2) / 3;
        CGFloat pictureWH = (maxWidth - kPictureGapWidth * 2) / 3;
        height += pictureWH * numberOfRows + kPictureGapWidth * (numberOfRows - 1) + kPictureTopSpacing;
    }
    
    // 回复信息高度
    if (mtl.children.count > 0) {
        height += kReplyInfoTopSpacing + kReplyInfoHeight;
    }
    
    return height += kCellBottomSpacing;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height - self.bottomSpace);
    
    self.avatarMaskView.frame = CGRectMake(kPaddingWidth, kPaddingWidth, 34, 34);
    self.avatarImageView.frame = CGRectMake(0, 0, 32, 32);
    self.avatarImageView.center = self.avatarMaskView.center;
    
    self.funButton.frame = ({
        CGRect rect = self.funButton.frame;
        rect.size = CGSizeMake(48, 22);
        rect.origin.x = self.width - kPaddingWidth - rect.size.width;
        rect.origin.y = 17 + 6;
        rect;
    });
    
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = ({
        CGRect rect = self.nameLabel.frame;
        rect.origin = CGPointMake(self.avatarMaskView.right + 13, self.avatarMaskView.y);
        rect;
    });
    
    [self.mineIcon sizeToFit];
    self.mineIcon.x = self.nameLabel.right + 4;
    self.mineIcon.centerY = self.nameLabel.centerY;
    
    [self.dateLabel sizeToFit];
    self.dateLabel.frame = ({
        CGRect rect = self.dateLabel.frame;
        rect.origin.x = self.nameLabel.x;
        rect.origin.y = self.avatarMaskView.bottom - rect.size.height;
        rect;
    });
    
    CGFloat maxWidth = SCREEN_WIDTH - kPaddingWidth*2 - kIndentWidth;
    
    GFCommentMTL *comment = self.model;
    if (comment.commentInfo.commentContent) {
        CGSize commentLabelSize = [self.commentLabel sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
        self.commentLabel.frame = CGRectMake(kPaddingWidth + kIndentWidth, kHeaderHeight + kCommentTopSpacing, commentLabelSize.width, commentLabelSize.height);
    } else {
        self.commentLabel.frame = CGRectZero;
    }
    
    CGFloat pictureWH = (maxWidth - kPictureGapWidth * 2) / 3;
    CGFloat contentX = kPaddingWidth + kIndentWidth;
    CGFloat replyInfoViewY = kHeaderHeight + kReplyInfoTopSpacing;
    for (UIImageView *imageView in self.imageViewList) {
        NSInteger index = [self.imageViewList indexOfObject:imageView];
        NSInteger row = index / 3;
        NSInteger column = index % 3;
        
        CGFloat x =  contentX + column * (pictureWH + kPictureGapWidth);
        CGFloat y = self.commentLabel.bottom + kPictureTopSpacing + row * (pictureWH + kPictureGapWidth);
        imageView.frame = CGRectMake(x, y, pictureWH, pictureWH);
        replyInfoViewY = imageView.bottom + kReplyInfoTopSpacing;
    }
    
    self.replyBackgroundView.frame = ({
        CGRect rect = self.replyBackgroundView.frame;
        rect.origin = CGPointMake(contentX, replyInfoViewY);
        rect.size = CGSizeMake(maxWidth, kReplyInfoHeight);
        rect;
    });
    
    self.replyerAvatarMaskView.frame = ({
        CGRect rect;
        rect.size = CGSizeMake(24, 24);
        rect.origin.x = 13;
        rect.origin.y = (self.replyBackgroundView.height - rect.size.height) / 2.;
        rect;
    });
    
    self.replyerAvatarImageView.frame = CGRectMake(0, 0, 20, 20);
    self.replyerAvatarImageView.center = self.replyerAvatarMaskView.center;
    
    [self.replyCountLabel sizeToFit];
    self.replyCountLabel.x = self.replyBackgroundView.width - 5 - self.replyCountLabel.width;
    self.replyCountLabel.centerY = self.replyBackgroundView.height / 2.;
    
    [self.replyerNameLabel sizeToFit];
    [self.replyerNameSuffixLabel sizeToFit];
    self.replyerNameLabel.centerY = self.replyerNameSuffixLabel.centerY = self.replyCountLabel.centerY;
    self.replyerNameLabel.x = self.replyerAvatarMaskView.right + 13;
    if (self.replyerNameLabel.x + self.replyerNameLabel.width + self.replyerNameSuffixLabel.width + 30 > self.replyCountLabel.x) {
        self.replyerNameLabel.width = self.replyCountLabel.x - 30 - self.replyerNameSuffixLabel.width - self.replyerNameLabel.x;
    }
    self.replyerNameSuffixLabel.x = self.replyerNameLabel.right;
}

#pragma mark - GFImageGroupDelegate
- (NSArray<UIView *> *)pictureViews {
    return self.imageViewList;
}

@end
