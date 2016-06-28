//
//  GFGroupInfoCell.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/22.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFGroupInfoCell.h"
#import "GFUserMTL.h"

@interface GFGroupInfoCell ()

@property (nonatomic, strong) UILabel *nameLabel; //名称
@property (nonatomic, strong) UILabel *locationLabel; //位置
@property (nonatomic, strong) UIImageView *separatorView; //间隔线
@property (nonatomic, strong) UILabel *interestLabel; //兴趣描述
@property (nonatomic, strong) UIImageView *accessoryImageView; //更多信息
@property (nonatomic, strong) UIView *avatarFooterView; //头像区域
@property (nonatomic, strong) NSMutableArray<UIImageView *> *avatarList;
@property (nonatomic, strong) UILabel *memberCountLabel; //group成员数目

@end

@implementation GFGroupInfoCell

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:22];
        _nameLabel.textColor = [UIColor textColorValue1];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationLabel.font = [UIFont systemFontOfSize:13];
        _locationLabel.textColor = [UIColor textColorValue3];
        _locationLabel.textAlignment = NSTextAlignmentRight;
        _locationLabel.text = @"";
    }
    return _locationLabel;
}

- (UIImageView *)separatorView {
    if (!_separatorView) {
        
        _separatorView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _separatorView.backgroundColor = [UIColor themeColorValue15];
    }
    return _separatorView;
}

- (UILabel *)interestLabel {
    if (!_interestLabel) {
        _interestLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _interestLabel.font = [UIFont systemFontOfSize:13];
        _interestLabel.textColor = [UIColor textColorValue3];
        _interestLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _interestLabel;
}


- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
    }
    return _accessoryImageView;
}

- (UIView *)avatarFooterView {
    if (!_avatarFooterView) {
        _avatarFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        __weak typeof(self) weakSelf = self;
        [_avatarFooterView bk_whenTapped:^{
            if (weakSelf.memberAvatarListHandler) {
                weakSelf.memberAvatarListHandler();
            }
        }];
    }
    return _avatarFooterView;
}

- (UILabel *)memberCountLabel {
    if (!_memberCountLabel) {
        _memberCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _memberCountLabel.font = [UIFont systemFontOfSize:13];
        _memberCountLabel.textColor = [UIColor textColorValue3];
        _memberCountLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _memberCountLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.nameLabel];
        
        [self.contentView addSubview:self.locationLabel];
        [self.contentView addSubview:self.separatorView];
        [self.contentView addSubview:self.interestLabel];
        
        [self.contentView addSubview:self.accessoryImageView];
        
        [self.contentView addSubview:self.avatarFooterView];
        [self.avatarFooterView addSubview:self.memberCountLabel];
        _avatarList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    if (!model || ![model isKindOfClass:[GFGroupMTL class]]) {
        return 0.0f;
    }
    
    return 108;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    self.group = (GFGroupMTL *)model;
    
    self.nameLabel.text = self.group.groupInfo.name;
    if ([self.group.groupInfo.address length] > 15) { //超过15个字符自动截断
        self.locationLabel.text = [self.group.groupInfo.address substringWithRange:NSMakeRange(0, 15)];
    } else {
        self.locationLabel.text = self.group.groupInfo.address;
    }
    
    GFTagInfoMTL *tagInfo = [self.group.tagList firstObject];
    NSString *interest = tagInfo ? tagInfo.tagName : @"其它";
    self.interestLabel.text = interest;
    
    
    [[self.avatarFooterView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.avatarList removeAllObjects];
    NSUInteger index = 0;
    for (GFUserMTL *user in self.group.memberList) {
        UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.avatarList addObject:avatarView];
        
        NSString *url = [user.avatar gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarFeed gifConverted:YES];        
        [avatarView setImageWithURL:[NSURL URLWithString:url]
                      placeholder:[UIImage imageNamed:@"default_avatar_1"]];
        
        [self.avatarFooterView addSubview:avatarView];
        index++;
        
        if (index == 3) {
            break;
        }
    }
    
    self.memberCountLabel.text = [NSString stringWithFormat:@"等%@人", self.group.groupInfo.memberCount];
    [self.avatarFooterView addSubview:self.memberCountLabel];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = ({
        CGSize size = [self.nameLabel sizeThatFits:CGSizeMake(self.contentView.width/2 - 16.0, MAXFLOAT)];
        CGRect rect = CGRectMake(self.contentView.width/2-size.width/2, 10, size.width, size.height);
        rect;
    });
    
    self.accessoryImageView.frame = ({
        [self.accessoryImageView sizeToFit];
        CGRect rect = CGRectMake(self.contentView.width - 16 - self.accessoryImageView.width,
                                 self.contentView.height/2 - self.accessoryImageView.height/2,
                                 self.accessoryImageView.width,
                                 self.accessoryImageView.height);
        rect;
    });
    
    CGFloat maxLabelMaxWidth = self.contentView.width/2  - self.accessoryImageView.width - 16;
    CGSize locationSize = [self.locationLabel sizeThatFits:CGSizeMake(maxLabelMaxWidth, MAXFLOAT)];
    CGSize interestSize = [self.interestLabel sizeThatFits:CGSizeMake(maxLabelMaxWidth, MAXFLOAT)];
    CGFloat separatorSpace = 12.0f;
    CGFloat totalWidth = interestSize.width + 2 * separatorSpace + 1 + locationSize.width;
    self.interestLabel.frame = ({
        CGFloat x = self.contentView.width/2 - totalWidth/2;
        CGRect rect = CGRectMake(x, self.nameLabel.bottom + 8, interestSize.width, interestSize.height);
        rect;
    });
    self.separatorView.frame = CGRectMake(self.interestLabel.right + separatorSpace, self.interestLabel.y, 1.0f, self.interestLabel.height);
    self.locationLabel.frame = ({
        CGFloat x = self.separatorView.right + separatorSpace;
        CGRect rect = CGRectMake(x, self.nameLabel.bottom + 8, locationSize.width, locationSize.height);
        rect;
    });
    
    const CGFloat avatarHeight = 25.0f;
    self.avatarFooterView.frame = CGRectMake(16, self.locationLabel.bottom + 9, self.contentView.width - 16 * 2, avatarHeight);
    NSUInteger maxCount = MIN(4, self.avatarList.count);
    if (maxCount > 0) {
        CGFloat space = 2.0f; //头像相互覆盖的宽度
        CGSize memberCountLabelSize = [self.memberCountLabel sizeThatFits:CGSizeMake(self.contentView.width - 4 * avatarHeight, MAXFLOAT)];
        self.avatarFooterView.size = CGSizeMake(space + maxCount * (avatarHeight - space) + 8 + memberCountLabelSize.width, avatarHeight);
        self.avatarFooterView.center = CGPointMake(self.contentView.width / 2, self.locationLabel.bottom + 9 + avatarHeight / 2);
        
        NSUInteger index = 0;
        for (NSInteger i = 0; i < self.avatarList.count; i++) {
            if (index == maxCount) {
                break;
            }
            
            UIImageView *avatarView = [self.avatarList objectAtIndex:index];
            avatarView.frame = CGRectMake((avatarHeight - space) * index, 0, avatarHeight, avatarHeight);
            avatarView.layer.cornerRadius = avatarHeight/2;
            avatarView.clipsToBounds = YES;
            index++;
        }
        self.memberCountLabel.size = memberCountLabelSize;
        self.memberCountLabel.center = CGPointMake(self.avatarFooterView.width - memberCountLabelSize.width/2, self.avatarFooterView.height / 2);
    }
}
@end
