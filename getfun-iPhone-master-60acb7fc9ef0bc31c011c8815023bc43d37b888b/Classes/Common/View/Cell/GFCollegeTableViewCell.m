//
//  GFCollegeTableViewCell.m
//  GetFun
//
//  Created by zhouxz on 15/12/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFCollegeTableViewCell.h"
#import "GFCollegeMTL.h"

@interface GFCollegeTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *accessoryImageView;

@end

@implementation GFCollegeTableViewCell
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow_dark"]];
        [_accessoryImageView sizeToFit];
    }
    return _accessoryImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.accessoryImageView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return 50.0f;
}

- (void)bindWithModel:(id)model {
    [super bindWithModel:model];
    
    GFCollegeMTL *college = (GFCollegeMTL *)model;
    self.titleLabel.text = college.name;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(17, 0, self.contentView.width-60, self.contentView.height);
    self.accessoryImageView.frame = CGRectMake(self.contentView.width-17-self.accessoryImageView.width,
                                               self.contentView.height/2 - self.accessoryImageView.height/2,
                                               self.accessoryImageView.width,
                                               self.accessoryImageView.height);
}
@end
