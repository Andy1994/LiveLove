//
//  AppDelegate.h
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFMessageMTL.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (AppDelegate *)appDelegate;

@property (strong, nonatomic) UIWindow *window;

- (void)switchToNextViewController:(UIViewController *)sender;

- (void)handleApnsInfo:(NSDictionary *)userInfo;
- (void)handleGetfunLinkUrl:(NSString *)linkUrl;
- (void)handleRedirectMessage:(GFMessageMTL *)message;
- (void)displayViewController:(UIViewController *)viewControllerToDisplay;

- (void)refreshGetfunTokenCompletion:(void (^)())completion;

@end

