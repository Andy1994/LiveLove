//
//  GFPathMenu.h
//  GetFun
//
//  Created by zhouxz on 15/12/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "DCPathButton.h"

@class GFPathMenu;
@protocol GFPathMenuDelegate <NSObject>
- (void)pathMenu:(GFPathMenu *)pathMenu clickItemButtonAtIndex:(NSUInteger)itemButtonIndex;
- (void)clickPathMenu:(GFPathMenu *)pathMenu;
@end

@interface GFPathItemButton : DCPathItemButton
@property (nonatomic, assign) BOOL showBadge;
@end

@interface GFPathMenu : DCPathButton
@property (nonatomic, assign) id<GFPathMenuDelegate> menuDelegate;
+ (instancetype)defaultPathMenu;
- (void)setCenterButtonEnabled:(BOOL)enabled;
@end