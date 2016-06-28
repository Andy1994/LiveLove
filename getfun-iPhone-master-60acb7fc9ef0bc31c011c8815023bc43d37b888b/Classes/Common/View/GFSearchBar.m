//
//  GFSearchBar.m
//  GetFun
//
//  Created by zhouxz on 15/12/22.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFSearchBar.h"

@implementation GFSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.barTintColor = [UIColor themeColorValue15];
        self.backgroundColor = [UIColor themeColorValue12];
        self.searchBarStyle = UISearchBarStyleProminent;
        [self setImage:[UIImage imageNamed:@"icon_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }
    return self;
}

@end