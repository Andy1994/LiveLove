//
//  GFVoteView.m
//  GetFun
//
//  Created by muhuaxin on 15/11/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFVoteView.h"

#import "GFContentMTL.h"
#import "GFContentDetailMTL.h"
#import "GFContentSummaryMTL.h"
#import "GFVoteItemMTL.h"
#import "GFPictureMTL.h"
#import <NSString+HTML.h>

typedef NS_ENUM(NSInteger, GFVoteState) {
    GFVoteStateNone = 0,
    GFVoteStateLeft = 1,
    GFVoteStateRight = 2
};

@interface GFVoteView ()

@property (nonatomic, strong) GFContentMTL *content;
@property (nonatomic, assign) BOOL shouldLayoutWithAnimate;

@property (nonatomic, strong) UILabel     *titleLabel;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) UIView      *leftBarBGView;
@property (nonatomic, strong) UIView      *rightBarBGView;

@property (nonatomic, strong) UILabel     *leftLabel;
@property (nonatomic, strong) UILabel     *rightLabel;

@property (nonatomic, strong) UIImageView *middleImageView;

@property (nonatomic, strong) UIView      *progressView;
@property (nonatomic, strong) UIImageView *scoreView;
@property (nonatomic, strong) UILabel     *scoreLabel;

@property (nonatomic, strong) UIImageView *getImageView;

@property (nonatomic, strong) UIButton    *leftButton;
@property (nonatomic, strong) UIButton    *rightButton;

@property (nonatomic, strong) NSArray     *voteItems;
@property (nonatomic, assign) CGFloat     imageHeight;

@property (nonatomic, assign) GFVoteState voteState;

@end

#define leftColor [UIColor themeColorValue10]
#define rightColor [UIColor themeColorValue11]

static CGFloat const kImageHeight = 144.0f;
static CGFloat const kAnimateBarHeight = 42.0f;
static CGFloat const kScoreViewHeight = 30.0f;

@implementation GFVoteView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [GFVoteView titleLabel];
    }
    return _titleLabel;
}

+ (UILabel *)titleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18.0f];
    label.textColor = [UIColor textColorValue1];
    label.numberOfLines = 2;
    return label;
}

- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.clipsToBounds = YES;
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _leftImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.clipsToBounds = YES;
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _rightImageView;
}

- (UIView *)leftBarBGView {
    if (!_leftBarBGView) {
        _leftBarBGView = [[UIView alloc] init];
        _leftBarBGView.backgroundColor = leftColor;
    }
    return _leftBarBGView;
}

- (UIView *)rightBarBGView {
    if (!_rightBarBGView) {
        _rightBarBGView = [[UIView alloc] init];
        _rightBarBGView.backgroundColor = rightColor;
    }
    return _rightBarBGView;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.layer.cornerRadius = kAnimateBarHeight / 2.;
        _progressView.clipsToBounds = YES;
    }
    return _progressView;
}

- (UIImageView *)scoreView {
    if (!_scoreView) {
        _scoreView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_vote_score"]];
        [_scoreView sizeToFit];
    }
    return _scoreView;
}

- (UILabel *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _scoreLabel.font = [UIFont systemFontOfSize:15.0f];
        _scoreLabel.textAlignment = NSTextAlignmentCenter;
        _scoreLabel.textColor = [UIColor whiteColor];
    }
    return _scoreLabel;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[self class] answerLabel];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[self class] answerLabel];
    }
    return _rightLabel;
}

+ (UILabel *)answerLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    return label;
}

- (UIImageView *)middleImageView {
    if (!_middleImageView) {
        _middleImageView = [[UIImageView alloc] init];
        _middleImageView.image = [UIImage imageNamed:@"content_pk1"];
    }
    return _middleImageView;
}

- (UIImageView *)getImageView {
    if (!_getImageView) {
        _getImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"content_get"]];
        _getImageView.size = CGSizeMake(kAnimateBarHeight, kAnimateBarHeight);
        _getImageView.hidden = YES;
    }
    return _getImageView;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.tag = 0;
        _leftButton.exclusiveTouch = YES;
        [_leftButton addTarget:self action:@selector(voteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.tag = 1;
        _rightButton.exclusiveTouch = YES;
        [_rightButton addTarget:self action:@selector(voteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

#pragma mark - Private methods
- (void)commonInit {
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightImageView];
    [self addSubview:self.leftBarBGView];
    [self addSubview:self.rightBarBGView];
    [self addSubview:self.progressView];
    
    [self addSubview:self.scoreView];
    [self.scoreView addSubview:self.scoreLabel];
    
    [self addSubview:self.leftLabel];
    [self addSubview:self.rightLabel];
    
    [self addSubview:self.middleImageView];
    
    [self addSubview:self.getImageView];
    
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
}

- (void)showGetAtLeft:(NSNumber *)left {
    
    self.getImageView.hidden = NO;
    
    if ([left boolValue]) {
        
        CGRect getFinalFrame = CGRectMake(16,
                                          self.leftBarBGView.y + 4 - kAnimateBarHeight/2,
                                          kAnimateBarHeight,
                                          kAnimateBarHeight);
        
        if (self.shouldLayoutWithAnimate) {
            self.getImageView.frame = CGRectMake(16 + kAnimateBarHeight/2 - kAnimateBarHeight,
                                                 self.leftBarBGView.y + 4 - kAnimateBarHeight,
                                                 kAnimateBarHeight * 2,
                                                 kAnimateBarHeight * 2);
            
            [UIView animateWithDuration:0.5f animations:^{
                self.getImageView.frame = getFinalFrame;
            }];
        } else {
            self.getImageView.frame = getFinalFrame;
        }
    } else {
        
        CGRect getFinalFrame = CGRectMake(self.width - 16 - kAnimateBarHeight,
                                          self.rightBarBGView.y + 4 - kAnimateBarHeight/2,
                                          kAnimateBarHeight,
                                          kAnimateBarHeight);
        
        if (self.shouldLayoutWithAnimate) {
            self.getImageView.frame = CGRectMake(self.width - 16 - kAnimateBarHeight/2 - kAnimateBarHeight,
                                                 self.rightBarBGView.y + 4 - kAnimateBarHeight,
                                                 kAnimateBarHeight * 2,
                                                 kAnimateBarHeight * 2);
            [UIView animateWithDuration:0.5f animations:^{
                self.getImageView.frame = getFinalFrame;
            }];
        } else {
            self.getImageView.frame = getFinalFrame;
        }
    }
}

- (void)showVoteProgress {
    
    GFVoteItemMTL *leftItem = nil;
    GFVoteItemMTL *rightItem = nil;
    if (self.voteItems.count >=2) {
        leftItem = self.voteItems[0];
        rightItem = self.voteItems[1];
    }
    NSInteger leftCount = [leftItem.supportCount integerValue];
    NSInteger rightCount = [rightItem.supportCount integerValue];

    self.progressView.hidden = NO;
    self.scoreView.hidden = NO;
    
    if (leftCount > rightCount) {
        
        self.progressView.backgroundColor = leftColor;
        CGFloat progressViewWidth = ((CGFloat)leftCount / (CGFloat)(leftCount + rightCount)) * SCREEN_WIDTH;
        CGFloat scoreViewFinalCenterX = progressViewWidth;
        if (scoreViewFinalCenterX > self.width - self.scoreView.width/2) {
            scoreViewFinalCenterX = self.width - self.scoreView.width/2;
        }
        
        self.scoreView.center = CGPointMake(self.width/2, self.middleImageView.y - 10 - self.scoreView.height/2);
        self.scoreLabel.frame = CGRectMake(0, 0, self.scoreView.width, self.scoreView.height-5);
        self.progressView.frame = self.leftBarBGView.frame;
        
        if (self.shouldLayoutWithAnimate) {
            [UIView animateWithDuration:0.5f animations:^{
                self.progressView.frame = CGRectMake(0, self.leftBarBGView.y, progressViewWidth, self.leftBarBGView.height);
                self.scoreView.centerX = scoreViewFinalCenterX;
            }];
        } else {
            self.progressView.frame = CGRectMake(0, self.leftBarBGView.y, progressViewWidth, self.leftBarBGView.height);
            self.scoreView.centerX = scoreViewFinalCenterX;
        }
        
    } else if (leftCount < rightCount) {
        
        self.progressView.backgroundColor = rightColor;
        CGFloat progressViewWidth = ((CGFloat)rightCount / (CGFloat)(leftCount + rightCount)) * SCREEN_WIDTH;
        CGFloat scoreViewFinalCenterX = self.width - progressViewWidth;
        if (scoreViewFinalCenterX < self.scoreView.width/2) {
            scoreViewFinalCenterX = self.scoreView.width/2;
        }
        
        self.scoreView.center = CGPointMake(self.width/2, self.middleImageView.y - 10 - self.scoreView.height/2);
        self.scoreLabel.frame = CGRectMake(0, 0, self.scoreView.width, self.scoreView.height-5);
        self.progressView.frame = self.rightBarBGView.frame;
        if (self.shouldLayoutWithAnimate) {

            [UIView animateWithDuration:0.3f animations:^{
                self.progressView.frame = CGRectMake(self.width - progressViewWidth, self.rightBarBGView.y, progressViewWidth, self.rightBarBGView.height);
                self.scoreView.centerX = scoreViewFinalCenterX;
            }];
        } else {
            self.progressView.frame = CGRectMake(self.width - progressViewWidth, self.rightBarBGView.y, progressViewWidth, self.rightBarBGView.height);
            self.scoreView.centerX = scoreViewFinalCenterX;
        }
    } else {
        self.progressView.hidden = YES;
        self.scoreView.center = CGPointMake(self.width/2, self.middleImageView.y - 10 - self.scoreView.height/2);
        self.scoreLabel.frame = CGRectMake(0, 0, self.scoreView.width, self.scoreView.height-5);
        self.progressView.frame = self.rightBarBGView.frame;
    }
}

- (void)voteButtonAction:(UIButton *)button {
    NSInteger index = button.tag;
    
    switch (self.voteState) {
        case GFVoteStateNone: {
            if(self.voteItemHandler) {
                self.voteItemHandler(self.voteItems[index]);
            }
            break;
        }
        case GFVoteStateLeft: {
            GFVoteItemMTL *item = self.voteItems[0];
            NSString *title = [NSString stringWithFormat:@"你已投票给 %@", item.title];
            [MBProgressHUD showHUDWithTitle:title duration:kCommonHudDuration];
            break;
        }
        case GFVoteStateRight: {
            GFVoteItemMTL *item = self.voteItems[1];
            NSString *title = [NSString stringWithFormat:@"你已投票给 %@", item.title];
            [MBProgressHUD showHUDWithTitle:title duration:kCommonHudDuration];
            break;
        }
    }
}


#pragma mark - Public methods
- (void)updateContent:(GFContentMTL *)content animate:(BOOL)animate {

    _content = content;
    _shouldLayoutWithAnimate = animate;
    
    
    NSArray *voteItems = nil;
    NSString *title = nil;
    if (content.contentDetail) {
        voteItems = [(GFContentDetailVoteMTL *)content.contentDetail voteItems];
        title = content.contentDetail.title;
    } else if (content.contentSummary) {
        voteItems = [(GFContentSummaryVoteMTL *)content.contentSummary voteItems];
        title = content.contentSummary.title;
    }
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.titleLabel.text = title;
    self.voteItems = voteItems;
    
    GFVoteItemMTL *leftItem = nil;
    GFVoteItemMTL *rightItem = nil;
    if (voteItems.count >=2) {
        leftItem = voteItems[0];
        rightItem = voteItems[1];
    }
    
    self.voteState = GFVoteStateNone;
    GFContentActionStatus *voteActionStatus = content.actionStatuses[GFContentMTLActionStatusesKeySpecial];
    if ([voteActionStatus.count integerValue] > 0) {
        NSNumber *relatedId = voteActionStatus.relatedId;
        if (relatedId && [leftItem.voteItemId isEqualToNumber:relatedId]) {
            self.voteState = GFVoteStateLeft;
        } else {
            self.voteState = GFVoteStateRight;
        }
    }
    
    self.imageHeight = 0;
    self.leftImageView.image = nil;
    
    if (leftItem.imageUrl.length > 0) {
        NSString *leftImageStorekey = leftItem.imageUrl;
        GFPictureMTL *picture = content.pictures[leftImageStorekey];
        
        NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeVote gifConverted:YES];
        [self.leftImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
        self.imageHeight = kImageHeight;
    }
    self.leftLabel.text = leftItem.title;
    
    self.rightImageView.image = nil;
    if (rightItem.imageUrl.length > 0) {
        
        NSString *rightImageStorekey = rightItem.imageUrl;
        GFPictureMTL *picture = content.pictures[rightImageStorekey];
        
        NSString *url = [picture.url gf_urlStandardizedWithType:GFImageStandardizedTypeVote gifConverted:YES];
        [self.rightImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"placeholder_image"]];
        self.imageHeight = kImageHeight;
    }
    self.rightLabel.text = rightItem.title;
    
    NSInteger leftCount = [leftItem.supportCount integerValue];
    NSInteger rightCount = [rightItem.supportCount integerValue];
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld:%ld", (long)leftCount, (long)rightCount];
    
    self.getImageView.hidden = YES;
    self.progressView.hidden = YES;
    self.scoreView.hidden = YES;
    
    [self setNeedsLayout];
}

#define GF_HEIGHT_IMAGE_TOP_SPACE 15.0f

+ (CGFloat)viewHeightWithContent:(GFContentMTL *)content {
    
    UILabel *label = [GFVoteView titleLabel];
    if (content.contentDetail) {
        label.text = content.contentDetail.title;
    } else if (content.contentSummary) {
        label.text = content.contentSummary.title;
    }
    CGSize titleSize = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH - 16 * 2, MAXFLOAT)];
    CGFloat height = titleSize.height + GF_HEIGHT_IMAGE_TOP_SPACE;
    
    NSArray *voteItems = nil;
    if (content.contentDetail) {
        voteItems = [(GFContentDetailVoteMTL *)content.contentDetail voteItems];
    } else if (content.contentSummary) {
        voteItems = [(GFContentSummaryVoteMTL *)content.contentSummary voteItems];
    }
    
    GFVoteItemMTL *voteLeftItem = nil;
    GFVoteItemMTL *voteRightItem = nil;
    if (voteItems.count >=2) {
        voteLeftItem = voteItems[0];
        voteRightItem = voteItems[1];
    }
    

    if (voteLeftItem.imageUrl.length > 0 || voteRightItem.imageUrl.length > 0) {
        height += kImageHeight + kAnimateBarHeight;
    } else {
        height += kScoreViewHeight + kAnimateBarHeight;
    }
    
    return height;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = ({
        CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 16 * 2, MAXFLOAT)];
        CGRect rect = CGRectMake(16, 0, size.width, size.height);
        rect;
    });
    
    const CGFloat space = 1.0f; //两张图片间隔
    self.leftImageView.frame = CGRectMake(0, self.titleLabel.bottom + GF_HEIGHT_IMAGE_TOP_SPACE, SCREEN_WIDTH/2-space/2, self.imageHeight);
    self.rightImageView.frame = CGRectMake(self.leftImageView.right+space, self.leftImageView.y, SCREEN_WIDTH/2-space/2, self.imageHeight);
    
    //根据是否有图决定位置
    NSArray *voteItems = nil;
    if (self.content.contentDetail) {
        voteItems = [(GFContentDetailVoteMTL *)self.content.contentDetail voteItems];
    } else if (self.content.contentSummary) {
        voteItems = [(GFContentSummaryVoteMTL *)self.content.contentSummary voteItems];
    }
    GFVoteItemMTL *voteLeftItem = nil;
    GFVoteItemMTL *voteRightItem = nil;
    if (voteItems.count >=2) {
        voteLeftItem = voteItems[0];
        voteRightItem = voteItems[1];
    }
    if (voteLeftItem.imageUrl.length > 0 || voteRightItem.imageUrl.length > 0) {
        self.leftBarBGView.frame = CGRectMake(0, self.leftImageView.bottom, SCREEN_WIDTH/2, kAnimateBarHeight);
        self.rightBarBGView.frame = CGRectMake(self.leftBarBGView.right, self.leftBarBGView.y, SCREEN_WIDTH/2, kAnimateBarHeight);
    } else {
        self.leftBarBGView.frame = CGRectMake(0, self.leftImageView.bottom + kScoreViewHeight, SCREEN_WIDTH/2, kAnimateBarHeight);
        self.rightBarBGView.frame = CGRectMake(self.leftBarBGView.right, self.leftBarBGView.y, SCREEN_WIDTH/2, kAnimateBarHeight);
    }

    
    self.leftLabel.frame = CGRectMake(16,
                                      self.leftBarBGView.y,
                                      self.width/2 - 16 * 2 - kAnimateBarHeight/2,
                                      kAnimateBarHeight);
    self.rightLabel.frame = CGRectMake(self.width/2 + kAnimateBarHeight/2 + 16,
                                       self.rightBarBGView.y,
                                       self.leftLabel.width,
                                       kAnimateBarHeight);
    
    self.middleImageView.frame = CGRectMake(self.width/2 - kAnimateBarHeight/2,
                                            self.leftBarBGView.y,
                                            kAnimateBarHeight,
                                            kAnimateBarHeight);
    
    self.leftButton.frame = CGRectMake(self.leftImageView.x, self.leftImageView.y, self.leftImageView.width, self.leftImageView.height + self.leftBarBGView.height);
    self.rightButton.frame = CGRectMake(self.rightImageView.x, self.rightImageView.y, self.rightImageView.width, self.rightImageView.height + self.rightBarBGView.height);
    
    if (self.voteState != GFVoteStateNone) {
        [self showGetAtLeft:@(self.voteState == GFVoteStateLeft)];
        [self showVoteProgress];
    }
}

@end
