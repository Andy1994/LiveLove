//
//  GFBaseTableViewCell.m
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseTableViewCell.h"

@interface GFBaseTableViewCell ()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation GFBaseTableViewCell
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor themeColorValue12];
    }
    return _lineView;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

+ (CGFloat)heightWithModel:(id)model {
    return 80.0f;
}

- (void)bindWithModel:(id)model {
    _model = model;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView bringSubviewToFront:self.lineView];
    self.lineView.frame = CGRectMake(0, self.contentView.height-0.5f, self.contentView.width, 0.5f);
}
@end
