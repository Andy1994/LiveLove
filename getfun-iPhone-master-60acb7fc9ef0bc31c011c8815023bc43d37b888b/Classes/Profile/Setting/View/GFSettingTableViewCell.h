//
//  GFSettingTableViewCell.h
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFBaseTableViewCell.h"

@interface GFSettingTableViewCell : GFBaseTableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switchButton;
@property (nonatomic, strong) UIImageView *accessoryImageView;

@end
