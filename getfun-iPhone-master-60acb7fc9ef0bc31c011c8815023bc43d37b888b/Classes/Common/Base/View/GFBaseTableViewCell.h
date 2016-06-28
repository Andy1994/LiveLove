//
//  GFBaseTableViewCell.h
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFBaseTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) id model;

+ (CGFloat)heightWithModel:(id)model;

- (void)bindWithModel:(id)model;

@end
