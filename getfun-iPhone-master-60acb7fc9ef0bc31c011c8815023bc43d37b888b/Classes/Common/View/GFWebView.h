//
//  GFWebView.h
//  GetFun
//
//  Created by zhouxz on 16/1/20.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GFWebView : UIWebView

- (void)setCookieIfNeeded:(NSString *)url;
+(instancetype)shareWithFrame:(CGRect)frame;
@end
