//
//  GFContentDetailShareView.h
//  GetFun
//
//  Created by muhuaxin on 15/11/22.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFBaseCollectionViewCell.h"

@interface GFContentDetailShareView : GFBaseCollectionViewCell

@property (nonatomic, copy) void (^shareHandler)(GFShareType type);

@end
