//
//  GFProfileInfoView.m
//  GetFun
//
//  Created by zhouxz on 15/12/7.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFProfileInfoView.h"
#import "GFAvatarView.h"
#import <DTAttributedLabel.h>
#import "GFAccountManager.h"

static const CGFloat kSegmentControlHeight = 50.0f;
static const CGFloat kSocialViewHeight = 50.0f;
static const CGFloat kAvatarHeight = 65.0f;
static const CGFloat kSocialItemNameHeight = 20.0f;
static const CGFloat kSocialItemCountHeight = 15.0f;

//1.3版本暂时不增加他人的粉丝和关注入口，只保留get帮入口
@interface GFProfileSocialOtherView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *hiddenButton; //默认透明隐藏，显示在数目和accessory图标上方
@property (nonatomic, strong) UILabel *groupCountLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;
@property (nonatomic, strong) UILabel *noGroupTipLabel;

@property (nonatomic, copy) void(^groupTapHandler)();

@end

@implementation GFProfileSocialOtherView

- (UILabel *)textLabel {
    if(!_textLabel){
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.height)];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.text = @"Get帮";
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    return _textLabel;
}

- (UILabel *)groupCountLabel {
    if(!_groupCountLabel){
        _groupCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.accessoryImageView.left - 100 - 5, 0, 100, self.height)];
        _groupCountLabel.textAlignment = NSTextAlignmentRight;
        _groupCountLabel.textColor = [UIColor whiteColor];
        _groupCountLabel.font = [UIFont systemFontOfSize:14.0f];
        _groupCountLabel.text = @"0";
        _groupCountLabel.hidden = YES;
    }
    return _groupCountLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_light"]];
        [_accessoryImageView sizeToFit];
        _accessoryImageView.center = CGPointMake(self.width - _accessoryImageView.width/2, self.height/2);
        _accessoryImageView.hidden = YES;
    }
    return _accessoryImageView;
}

- (UIButton *)hiddenButton {
    if (!_hiddenButton) {
        _hiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hiddenButton.frame = CGRectMake(self.width - 50, 0, 50, self.height);
    }
    return _hiddenButton;
}

- (UILabel *)noGroupTipLabel {
    if(!_noGroupTipLabel){
        _noGroupTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 150, 0, 150, self.height)];
        _noGroupTipLabel.textAlignment = NSTextAlignmentRight;
        _noGroupTipLabel.textColor = [UIColor textColorValue5];
        _noGroupTipLabel.font = [UIFont systemFontOfSize:14.0f];
        _noGroupTipLabel.text = @"未加入任何Get帮";
        _noGroupTipLabel.hidden = YES;
    }
    return _noGroupTipLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.accessoryImageView];
        [self addSubview:self.textLabel];
        [self addSubview:self.groupCountLabel];
        [self addSubview:self.hiddenButton];
        [self addSubview:self.noGroupTipLabel];
        
        @weakify(self)
        [self.hiddenButton bk_addEventHandler:^(id sender) {
            @strongify(self)
            if (self.groupTapHandler) {
                self.groupTapHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

@end

//关注、粉丝、get帮等社交相关子视图
@interface GFProfileSocialItemView : UIView

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) void(^tapHandler)();
@end

@implementation GFProfileSocialItemView
- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.font = [UIFont systemFontOfSize:15.0f];
        _countLabel.textColor = [UIColor textColorValue6];
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:12.0f];
        _nameLabel.textColor = [UIColor textColorValue6];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.countLabel];
        [self addSubview:self.nameLabel];
        
        __weak typeof(self) weakSelf = self;
        self.userInteractionEnabled = YES;
        [self bk_whenTapped:^{
            if (weakSelf.tapHandler) {
                weakSelf.tapHandler();
            }
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    const CGFloat space = 5.0f; //间距
    CGFloat countLabelY = (kSocialViewHeight - kSocialItemNameHeight - space - kSocialItemCountHeight)/2;
    self.countLabel.frame = CGRectMake(0, countLabelY, self.width, kSocialItemCountHeight);
    self.nameLabel.frame = CGRectMake(0, self.countLabel.bottom + space, self.width, kSocialItemNameHeight);
}

@end

@interface GFProfileInfoView ()

@property (nonatomic, strong) GFProfileMTL *profile;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIView *socialView;
@property (nonatomic, strong) GFProfileSocialItemView *followeeItem; //当前用户关注的
@property (nonatomic, strong) GFProfileSocialItemView *followerItem; //关注当前用户的
@property (nonatomic, strong) GFProfileSocialItemView *groupItem; //当前用户Get帮信息
@property (nonatomic, strong) GFProfileSocialOtherView *otherGroupView; //1.3版本他人个人页唯一显示的get帮视图

@property (nonatomic, strong) GFAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *genderAgeLabel;
@property (nonatomic, strong) UILabel *professionLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UILabel *collegeLabel;
@property (nonatomic, strong) UIButton *detailInfoButton; //本人个人页点击进入资料编辑
@property (nonatomic, strong, readwrite) UIButton *followButton; //他人个人页显示关注状态

@property (nonatomic, strong, readwrite) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *bottomLineView; //分隔线

+ (BOOL)isSelf:(NSNumber *)userId;

@end

@implementation GFProfileInfoView
- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height+64)];
        _backgroundImageView.image = [UIImage imageNamed:@"profile_banner.jpg"];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
    }
    return _backgroundImageView;
}

- (UIView *)socialView {
    if (!_socialView) {
        _socialView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-kSocialViewHeight-kSegmentControlHeight, self.width, kSocialViewHeight)];
        _socialView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    }
    return _socialView;
}

- (GFProfileSocialItemView *)followeeItem {
    if (!_followeeItem) {
        _followeeItem = [[GFProfileSocialItemView alloc] initWithFrame:CGRectMake(0, 0, self.socialView.width/3, kSocialViewHeight)];
        _followeeItem.countLabel.text = @"0";
        _followeeItem.nameLabel.text = @"关注";
        _followeeItem.hidden = YES;
    }
    return _followeeItem;
}

- (GFProfileSocialItemView *)followerItem {
    if (!_followerItem) {
        _followerItem = [[GFProfileSocialItemView alloc] initWithFrame:CGRectMake(self.socialView.width/3, 0, self.socialView.width/3, kSocialViewHeight)];
        _followerItem.countLabel.text = @"0";
        _followerItem.nameLabel.text = @"粉丝";
        _followerItem.hidden = YES;
    }
    return _followerItem;
}

- (GFProfileSocialItemView *)groupItem {
    if (!_groupItem) {
        _groupItem = [[GFProfileSocialItemView alloc] initWithFrame:CGRectMake(self.socialView.width/3*2, 0, self.socialView.width/3, kSocialViewHeight)];
        _groupItem.countLabel.text = @"0";
        _groupItem.nameLabel.text = @"Get帮";
        _groupItem.hidden = YES;
    }
    return _groupItem;
}

- (GFProfileSocialOtherView *)otherGroupView {
    if (!_otherGroupView) {
        _otherGroupView = [[GFProfileSocialOtherView alloc] initWithFrame:CGRectMake(12, 0, self.socialView.width - 12 * 2, self.socialView.height)];
        _otherGroupView.hidden = YES;
    }
    return _otherGroupView;
}

- (HMSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"发布", @"参与", @"FUN", @"评论"]];
        _segmentedControl.frame = CGRectMake(0, self.height - kSegmentControlHeight - 10, self.width, kSegmentControlHeight);
        //和文字长度一样宽，此时的selectionIndicatorEdgeInsets相对于单个section而言，具体frame代码在frameForSelectionIndicator中
        //如果需要完全固定indicator宽度，需要重写drawRect和frameForSelectionIndicator代码
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 10);
        _segmentedControl.selectionIndicatorColor = [UIColor themeColorValue7];
        
        CGFloat borderWidth = 0.5f;
        CALayer *topBorder = [CALayer layer];
        CALayer *bottomBorder = [CALayer layer];
        topBorder.backgroundColor = [UIColor themeColorValue12].CGColor;
        topBorder.frame = CGRectMake(0, 0, SCREEN_WIDTH, borderWidth);
        bottomBorder.backgroundColor = [UIColor themeColorValue12].CGColor;
        bottomBorder.frame = CGRectMake(0, kSegmentControlHeight - borderWidth, SCREEN_WIDTH, borderWidth);
        [_segmentedControl.layer addSublayer:topBorder];
        [_segmentedControl.layer addSublayer:bottomBorder];
    }
    return _segmentedControl;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 10, self.width, 10)];
        _bottomLineView.backgroundColor = [UIColor themeColorValue13];
    }
    return _bottomLineView;
}

- (GFAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[GFAvatarView alloc] initWithFrame:CGRectMake(12, self.socialView.y-30-kAvatarHeight, kAvatarHeight, kAvatarHeight)];
        _avatarView.isShowedInFeedList = NO;
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.avatarView.right + 6,
                                                               self.avatarView.centerY - 2 - 17,
                                                               80.0f,
                                                               17.0f)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:17.0f];
        _nameLabel.textColor = [UIColor textColorValue6];
    }
    return _nameLabel;
}

- (UILabel *)genderAgeLabel {
    if (!_genderAgeLabel) {
        _genderAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.x, self.nameLabel.bottom + 4, 45, 16)];
        _genderAgeLabel.backgroundColor = [UIColor themeColorValue9];
        _genderAgeLabel.layer.masksToBounds = YES;
        _genderAgeLabel.layer.cornerRadius = 2.0f;
        _genderAgeLabel.hidden = YES;
        _genderAgeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _genderAgeLabel;
}

- (UILabel *)professionLabel {
    if (!_professionLabel) {
        _professionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.genderAgeLabel.right + 2,
                                                                             self.genderAgeLabel.centerY-16.0f/2,
                                                                             45.0f,
                                                                             16.0f)];
        _professionLabel.backgroundColor = RGBCOLOR(53, 161, 245);
        _professionLabel.layer.masksToBounds = YES;
        _professionLabel.layer.cornerRadius = 2.0f;
        _professionLabel.hidden = YES;
        _professionLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _professionLabel;
}


- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.x, self.genderAgeLabel.bottom+10, SCREEN_WIDTH/3, 15)];
        _addressLabel.backgroundColor = [UIColor clearColor];
        _addressLabel.font = [UIFont systemFontOfSize:12.0f];
        _addressLabel.textColor = [UIColor textColorValue6];
    }
    return _addressLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(self.addressLabel.right+5, self.addressLabel.y, 2, 10)];
        _separatorView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _separatorView.hidden = YES;
    }
    return _separatorView;
}

- (UILabel *)collegeLabel {
    if (!_collegeLabel) {
        _collegeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.separatorView.right+5, self.addressLabel.y, SCREEN_WIDTH/3, 15)];
        _collegeLabel.backgroundColor = [UIColor clearColor];
        _collegeLabel.font = [UIFont systemFontOfSize:12.0f];
        _collegeLabel.textColor = [UIColor textColorValue6];
    }
    return _collegeLabel;
}

- (UIButton *)detailInfoButton {
    if (!_detailInfoButton) {
        _detailInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailInfoButton.frame = CGRectMake(self.width-12-36,
                                                 self.avatarView.centerY-36.0f/2,
                                                 36.0f,
                                                 36.0f);
        UIImage *img = [UIImage imageNamed:@"profile_info"];
        [_detailInfoButton setImage:img forState:UIControlStateNormal];
        [_detailInfoButton setImage:[img opacity:0.5f] forState:UIControlStateHighlighted];
        [_detailInfoButton bk_addEventHandler:^(id sender) {
            if (_detailInfoButtonHandler) {
                _detailInfoButtonHandler();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _detailInfoButton;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.frame = CGRectMake(self.width-12-38,
                                                 self.avatarView.centerY-27.0f/2,
                                                 38.0f,
                                                 27.0f);
        _followButton.layer.cornerRadius = 5.0f;
        _followButton.clipsToBounds = YES;
        [_followButton setImage:[UIImage imageNamed:@"profile_not_follow"] forState:UIControlStateNormal];
        _followButton.hidden = YES;
    }
    return _followButton;
}

/**
 *  根据状态设置背景图和是否选中
 */
- (void)updateFollowButton {
    
    self.followButton.enabled = YES;
    
    switch ([self.profile followState]) {
        case GFFollowStateNo: {
            [self.followButton setImage:[UIImage imageNamed:@"profile_not_follow"] forState:UIControlStateNormal];
            break;
        }
        case GFFollowStateFollowing: {
            [self.followButton setImage:[UIImage imageNamed:@"profile_follow"] forState:UIControlStateNormal];
            break;
        }
        case GFFollowStateFollowingEachOther: {
            [self.followButton setImage:[UIImage imageNamed:@"profile_follow_eachother"] forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)setCurrentSegmentedIndex:(NSInteger)currentSegmentedIndex {
    self.segmentedControl.selectedSegmentIndex = currentSegmentedIndex;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundImageView];

        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.genderAgeLabel];
        [self addSubview:self.professionLabel];
        [self addSubview:self.addressLabel];
        [self addSubview:self.separatorView];
        [self addSubview:self.collegeLabel];
        [self addSubview:self.detailInfoButton];
        [self addSubview:self.followButton];
        [self addSubview:self.socialView];
        
        [self.socialView addSubview:self.followeeItem];
        [self.socialView addSubview:self.followerItem];
        [self.socialView addSubview:self.groupItem];
        [self.socialView addSubview:self.otherGroupView];        
        
        [self addSubview:self.segmentedControl];
        
        [self addSubview:self.bottomLineView];
        
        @weakify(self)
        [self.segmentedControl bk_addEventHandler:^(id sender) {
            @strongify(self)
            if (self.segmentedControlHandler) {
                self.segmentedControlHandler(self.segmentedControl.selectedSegmentIndex);
            }
        } forControlEvents:UIControlEventValueChanged];
        
        [self.followButton bk_addEventHandler:^(id sender) {
            @strongify(self)
            if (self.followButtonHandler) {
                self.followButton.enabled = NO;
                self.followButtonHandler(self, [self.profile followState]);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        self.clipsToBounds = YES;
    }
    return self;
}
+ (CGFloat)heightWithModel:(GFProfileMTL *)profileMTL{
    CGFloat height = 250.0f; // 个人信息区域
    height += kSocialViewHeight; //社交区域
    height += kSegmentControlHeight;    // segmentedControl区域
    height += 10;    //间隔线宽度
    
    return height;
}

- (void)setFolloweeTapHandler:(void (^)())followeeTapHandler {
    _followeeTapHandler = followeeTapHandler;
    self.followeeItem.tapHandler = followeeTapHandler;
}

- (void)setFollowerTapHandler:(void (^)())followerTapHandler {
    _followerTapHandler = followerTapHandler;
    self.followerItem.tapHandler = followerTapHandler;
}

- (void)setGroupTapHandler:(void (^)())groupTapHandler {
    _groupTapHandler = groupTapHandler;
    if ([[self class] isSelf:self.profile.user.userId]) {
        self.groupItem.tapHandler = groupTapHandler;
    } else {
        self.otherGroupView.groupTapHandler = groupTapHandler;
    }
}

- (void)setSegmentControlTitleFormatter:(HMTitleFormatterBlock)segmentControlTitleFormatter {
    _segmentControlTitleFormatter = segmentControlTitleFormatter;
    self.segmentedControl.titleFormatter = segmentControlTitleFormatter;
}

+ (NSMutableAttributedString *)attributedStringForGenderAndAge:(GFUserMTL *)userMTL {
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = userMTL.gender == GFUserGenderMale ? [UIImage imageNamed:@"icon_male"] : [UIImage imageNamed:@"icon_female"];
    textAttachment.bounds = CGRectMake(0, -3, 14, 14);
    NSMutableAttributedString *genderAttributedString = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
    NSDate *birthday = [NSDate dateWithTimeIntervalSince1970:[userMTL.birthday longLongValue] / 1000];
    NSTimeInterval dateDiff = [birthday timeIntervalSinceNow];
    NSInteger age=trunc(dateDiff/(60*60*24))/365;
    NSString *ageString  = [NSString stringWithFormat:@"%@岁", @(-age)];
    NSMutableAttributedString *ageAttributedString = [[[NSAttributedString alloc] initWithString: ageString] mutableCopy];
    [ageAttributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11.0f],
                                         NSForegroundColorAttributeName : [UIColor whiteColor]
                                         } range:NSMakeRange(0, [ageAttributedString length])];
    [genderAttributedString appendAttributedString:ageAttributedString];
    return genderAttributedString;
}

+ (NSMutableAttributedString *)attributedStringForProfessionWithIcon:(UIImage *)icon name:(NSString *)name {
    if (!icon || !name) {
        return nil;
    }
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = icon;
    textAttachment.bounds = CGRectMake(0, -3, 14, 14);
    NSMutableAttributedString *iconAttributedString = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
    NSMutableAttributedString *nameAttributedString = [[[NSAttributedString alloc] initWithString: name] mutableCopy];
    [nameAttributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11.0f],
                                         NSForegroundColorAttributeName : [UIColor whiteColor]
                                         } range:NSMakeRange(0, [nameAttributedString length])];
    [iconAttributedString appendAttributedString:nameAttributedString];
    return iconAttributedString;
}

- (void)updateWithProfile:(GFProfileMTL *)profileMTL {
    if (!profileMTL) {
        return;
    }
    
    self.profile = profileMTL;
    GFUserMTL *userMTL = profileMTL.user;
    
    [self.avatarView updateWithUser:userMTL];
    NSString *nickName = userMTL.nickName;
    NSUInteger minlength = MIN([nickName length], 10);
    self.nameLabel.text = [nickName substringWithRange:NSMakeRange(0, minlength)];
    self.genderAgeLabel.attributedText = [[self class] attributedStringForGenderAndAge:userMTL];
    [self.genderAgeLabel sizeToFit];
    self.genderAgeLabel.hidden = NO;
    
    if (userMTL.professions.count > 0) {
        //注意：此URL不能使用剪裁的标准
        NSURL *url = [NSURL URLWithString:userMTL.professions[0].info.iconUrl];
        NSString *name = userMTL.professions[0].info.name;
        if (url) {
            @weakify(self)
            [[YYWebImageManager sharedManager] requestImageWithURL:url options:YYWebImageOptionShowNetworkActivity progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            } transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                return image;
            } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                @strongify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.professionLabel.attributedText = [[self class] attributedStringForProfessionWithIcon:image name:name];
                    [self.professionLabel sizeToFit];
                    self.professionLabel.hidden = NO;
                    [self setNeedsLayout];
                });
            }];
        }
    }

    NSString *address = [NSString stringWithFormat:@"%@%@",
                         [userMTL.provinceName length] > 0 ? userMTL.provinceName : @"",
                         [userMTL.cityName length] > 0 ? userMTL.cityName : @""];
    NSString *college = [userMTL.collegeName length] > 0 ? userMTL.collegeName : @"";
    
    self.addressLabel.text = address;
    self.collegeLabel.text = college;
    self.separatorView.hidden = [address length] == 0 || [college length] == 0;

    self.detailInfoButton.hidden = ![GFProfileInfoView isSelf:userMTL.userId];
    self.followButton.hidden = [GFProfileInfoView isSelf:userMTL.userId];
    //设置关注按钮状态
    if (![GFProfileInfoView isSelf:userMTL.userId]) {
        [self updateFollowButton];
    }
    
    if ([[self class] isSelf:userMTL.userId]) {
        self.groupItem.countLabel.text = [NSString stringWithFormat:@"%@", profileMTL.interestGroupCount];
        self.followerItem.countLabel.text = [NSString stringWithFormat:@"%@", profileMTL.followerCount];
        self.followeeItem.countLabel.text = [NSString stringWithFormat:@"%@", profileMTL.followeeCount];
        self.groupItem.hidden = NO;
        self.followerItem.hidden = NO;
        self.followeeItem.hidden = NO;
    } else {
        self.otherGroupView.hidden = NO;
        if ([profileMTL.interestGroupCount integerValue] == 0) {
            self.otherGroupView.groupCountLabel.hidden = YES;
            self.otherGroupView.accessoryImageView.hidden = YES;
            self.otherGroupView.noGroupTipLabel.hidden = NO;
        } else {
            self.otherGroupView.groupCountLabel.text = [NSString stringWithFormat:@"%@", profileMTL.interestGroupCount];
            self.otherGroupView.groupCountLabel.hidden = NO;
            self.otherGroupView.accessoryImageView.hidden = NO;
            self.otherGroupView.noGroupTipLabel.hidden = YES;
        }
    }
    [self setNeedsLayout];
}

+ (BOOL)isSelf:(NSNumber *)userId {
    GFUserMTL *loginUser = [GFAccountManager sharedManager].loginUser;
    return loginUser && userId && [loginUser.userId isEqualToNumber:userId];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.segmentedControl.frame = CGRectMake(0, self.height - kSegmentControlHeight - 10, self.width, kSegmentControlHeight);
    self.bottomLineView.frame = CGRectMake(0, self.height - 10, self.width, 10);
    
    self.socialView.frame = CGRectMake(0,
                                      self.segmentedControl.y - kSocialViewHeight,
                                      self.width,
                                      kSocialViewHeight);
    
    self.avatarView.frame = CGRectMake(12, self.socialView.y - 15 - kAvatarHeight, kAvatarHeight, kAvatarHeight);
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = ({
        CGRect rect = CGRectMake(self.avatarView.right + 6,
                                 self.avatarView.y + 5,
                                 self.nameLabel.width,
                                 self.nameLabel.height);
        rect;
    });
    
    CGFloat genderAgeLabelOriginY = self.nameLabel.bottom + 4;
    CGFloat genderAgeLabelOriginX = self.nameLabel.x;
    if (self.nameLabel.height == 0) {
        genderAgeLabelOriginY = self.nameLabel.y - 16.0f;
        genderAgeLabelOriginX = self.nameLabel.right;
    }
    self.genderAgeLabel.frame = CGRectMake(genderAgeLabelOriginX,
                                           genderAgeLabelOriginY,
                                           self.genderAgeLabel.width + 4,
                                           16);
    //和genderAgeLabel同高
    self.professionLabel.frame = CGRectMake(self.genderAgeLabel.right + 3, self.genderAgeLabel.y, self.professionLabel.width + 4, self.genderAgeLabel.height);
    
    //限制文字的最大宽度为屏幕宽度的三分之一
    [self.addressLabel sizeToFit];
    [self.collegeLabel sizeToFit];
    self.addressLabel.width = MIN(self.addressLabel.width, SCREEN_WIDTH/3);
    self.collegeLabel.width = MIN(self.collegeLabel.width, SCREEN_WIDTH/3);
    
    //根据文字长度动态调整位置和决定是否显示分隔线
    if (![self.addressLabel.text isEqualToString:@""] && ![self.collegeLabel.text isEqualToString:@""]) {
        self.separatorView.origin = CGPointMake(self.addressLabel.right + 5, self.addressLabel.origin.y);
        self.collegeLabel.origin = CGPointMake(self.separatorView.right + 5, self.addressLabel.origin.y);
    } else {
        self.collegeLabel.origin = CGPointMake(self.addressLabel.right, self.addressLabel.origin.y);
    }
    
    self.addressLabel.y = self.genderAgeLabel.bottom + 2;
    self.collegeLabel.y = self.genderAgeLabel.bottom + 2;
    self.separatorView.centerY = self.addressLabel.centerY;
    self.detailInfoButton.frame = CGRectMake(self.width-12-36,
                                             self.avatarView.centerY-36.0f/2,
                                             36.0f,
                                             36.0f);
    self.followButton.origin = CGPointMake(self.width-12-self.followButton.width,
                                           self.avatarView.centerY-self.followButton.height/2);
}




@end
