//
//  GFGroupSelectTableViewCell.m
//  GetFun
//
//  Created by zhouxz on 15/12/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFGroupSelectTableViewCell.h"
#import "GFGroupMTL.h"

@interface GFGroupSelectTableViewCell ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation GFGroupSelectTableViewCell
- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 32.0f, 32.0f)];
        _logoImageView.layer.masksToBounds = YES;
        _logoImageView.layer.cornerRadius = 16.0f;
    }
    return _logoImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _nameLabel;
}

+ (CGFloat)heightWithModel:(id)model {
    return 60.0f;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.logoImageView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFGroupMTL *group = model;

    NSString *url = [group.groupInfo.imgUrl gf_urlStandardizedWithType:GFImageStandardizedTypeAvatarGroup gifConverted:YES];
    [self.logoImageView setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageNamed:@"group_default_avatar"]];
    self.nameLabel.text = group.groupInfo.name;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.logoImageView.centerY = self.contentView.height/2;
    self.nameLabel.frame = ({
        CGSize size = [self.nameLabel sizeThatFits:CGSizeMake(self.contentView.width-16.0f-8.0f-self.logoImageView.right, self.contentView.height)];
        CGRect rect = CGRectMake(self.logoImageView.right + 8.0f, self.contentView.height/2 - size.height/2, size.width, size.height);
        rect;
    });
}
@end
