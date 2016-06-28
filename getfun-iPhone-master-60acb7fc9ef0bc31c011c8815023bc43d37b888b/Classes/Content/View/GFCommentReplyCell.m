//
//  GFCommentReplyCell.m
//  GetFun
//
//  Created by muhuaxin on 15/11/29.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCommentReplyCell.h"
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

@interface GFCommentReplyCell ()

@property (nonatomic, strong) UIView *avatarMaskView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *mineIcon;//楼主
//@property (nonatomic, strong) UIImageView *dateIcon;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *funButton;
@property (nonatomic, strong) TTTAttributedLabel *commentLabel;

@property (nonatomic, strong) NSMutableArray *imageViewList;

@end

@implementation GFCommentReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.avatarMaskView];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.mineIcon];
//        [self addSubview:self.dateIcon];
        [self addSubview:self.dateLabel];
        [self addSubview:self.funButton];
        [self addSubview:self.commentLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViewList removeAllObjects];
}

#pragma mark - Getters

- (UIView *)avatarMaskView {
    if (_avatarMaskView == nil) {
        _avatarMaskView = [[UIView alloc] init];
        _avatarMaskView.layer.borderColor = RGBCOLOR(109, 178, 252).CGColor;
        _avatarMaskView.layer.borderWidth = 1;
        _avatarMaskView.layer.cornerRadius = 32 / 2;
        _avatarMaskView.clipsToBounds = YES;
    }
    return _avatarMaskView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.userInteractionEnabled = YES;
        _avatarImageView.layer.cornerRadius = 30 / 2;
        _avatarImageView.clipsToBounds = YES;
        

        __weak typeof(self) weakSelf = self;
        [_avatarImageView bk_whenTapped:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(avatarTapppedInCell:)]) {
                [weakSelf.delegate avatarTapppedInCell:weakSelf];
            }
//            if (weakSelf.avatarTappedHandler) {
//                weakSelf.avatarTappedHandler(weakSelf, weakSelf.model);
//            }
        }];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor blackColor];
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
        _dateLabel.textColor = [UIColor lightGrayColor];
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

- (TTTAttributedLabel *)commentLabel {
    if (_commentLabel == nil) {
        _commentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _commentLabel.textColor = [UIColor blackColor];
        _commentLabel.font = [UIFont systemFontOfSize:15];
        _commentLabel.numberOfLines = 0;
        _commentLabel.linkAttributes = @{
                                         (__bridge NSString *)kCTUnderlineStyleAttributeName : @NO,
                                         (__bridge NSString *)kCTForegroundColorAttributeName : (__bridge id)RGBCOLOR(159, 117, 235).CGColor,
                                         };
        _commentLabel.activeLinkAttributes = @{
                                               kTTTBackgroundFillColorAttributeName : (__bridge id)[UIColor lightGrayColor].CGColor,
                                               };
    }
    return _commentLabel;
}

- (NSMutableArray *)imageViewList {
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _imageViewList;
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(funButtonClickInCell:)]) {
        [self.delegate funButtonClickInCell:self];
    }
//    if (self.funButtonHandler) {
//        self.funButtonHandler(self, self.model);
//    }
}

#pragma mark - Setters

- (void)setIsMine:(BOOL)isMine {
    _isMine = isMine;
    
    self.mineIcon.hidden = !isMine;
}

#pragma mark - Public methods
- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFCommentMTL *mtl = model;
    GFCommentMTL *parent = mtl.parent;
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[mtl.user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES]] placeholder:[UIImage imageNamed:@"default_avatar_2"]];
    
    self.nameLabel.text = mtl.user.nickName ? mtl.user.nickName : @"";
    self.dateLabel.text = [GFTimeUtil getfunStyleTimeFromTimeInterval:[mtl.commentInfo.createTime longLongValue] / 1000];
    
    [self.funButton setTitle:[NSString stringWithFormat:@"%ld FUN", (long)[mtl.commentInfo.funCount integerValue]] forState:UIControlStateNormal];
    if (mtl.loginUserHasFuned) {
        self.funButton.layer.borderColor = RGBCOLOR(159, 117, 235).CGColor;
        [self.funButton setTitleColor:RGBCOLOR(159, 117, 235) forState:UIControlStateNormal];
        self.funButton.enabled = NO;
    } else {
        self.funButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.funButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.funButton.enabled = YES;
    }
    
    if (parent) {
        NSString *text = [NSString stringWithFormat:@"回复%@:%@", parent.user.nickName ? parent.user.nickName : @"", mtl.commentInfo.commentContent];
        self.commentLabel.text = text;
        NSRange range = NSMakeRange(2, [parent.user.nickName length]);
        NSString *url = [NSString stringWithFormat:@"gf://%@", mtl.user.userId];
        TTTAttributedLabelLink *link = [self.commentLabel addLinkToURL:[NSURL URLWithString:url] withRange:range];
        link.linkTapBlock = ^(TTTAttributedLabel *label, TTTAttributedLabelLink *link) {
//            NSString *urlString = link.accessibilityValue;
//            NSURL *url = [NSURL URLWithString:urlString];
//            NSString *userId = url.host;
        };
    } else {
        self.commentLabel.text = mtl.commentInfo.commentContent;
    }
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
            NSInteger index = [mtl.commentInfo.pictureKeys indexOfObject:pictureKey];
            __weak typeof(self) weakSelf = self;
            [imageView bk_whenTapped:^{
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(imageTappedInCell:iniImageIndex:)]) {
                    [weakSelf.delegate imageTappedInCell:weakSelf iniImageIndex:index];
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
            
//            imageView.userInteractionEnabled = YES;
//            __weak typeof(self) weakSelf = self;
//            NSInteger index = [mtl.commentInfo.emotionIds indexOfObject:emotionId];
//            [imageView bk_whenTapped:^{
//                if (weakSelf.tapImageHandler) {
//                    weakSelf.tapImageHandler(weakSelf, index);
//                }
//            }];
        }
    }
    
    [self setNeedsLayout];
}

+ (CGFloat)heightWithModel:(id)model {
    GFCommentMTL *mtl = model;
    GFCommentMTL *parent = mtl.parent;
    
    CGFloat maxWidth = SCREEN_WIDTH - kPaddingWidth*2 - kIndentWidth;
    
    // header部分的高度
    CGFloat height = kHeaderHeight;
    
    TTTAttributedLabel *commentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    commentLabel.textColor = [UIColor blackColor];
    commentLabel.font = [UIFont systemFontOfSize:15];
    commentLabel.numberOfLines = 0;
    if (parent) {
        commentLabel.text = [NSString stringWithFormat:@"回复%@:%@", parent.user.nickName, mtl.commentInfo.commentContent];
    } else {
        commentLabel.text = mtl.commentInfo.commentContent;
    }
    CGSize commentLabelSize = [commentLabel sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
    height += kCommentTopSpacing + commentLabelSize.height;
    
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
    
    height += kCellBottomSpacing;
    return height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarMaskView.frame = CGRectMake(kPaddingWidth, kPaddingWidth, 32, 32);
    self.avatarImageView.frame = CGRectMake(0, 0, 30, 30);
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
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
    self.commentLabel.frame = ({
        CGRect rect = self.commentLabel.frame;
        rect.origin.x = self.nameLabel.x;
        rect.origin.y = self.avatarMaskView.bottom + 12;
        rect.size = commentLabelSize;
        rect;
    });
    
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
}

- (NSArray<UIView *> *)pictureViews {
    return self.imageViewList;
}

@end
