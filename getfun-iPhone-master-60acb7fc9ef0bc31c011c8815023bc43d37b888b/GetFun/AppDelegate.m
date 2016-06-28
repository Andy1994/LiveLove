//
//  AppDelegate.m
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "AppDelegate.h"
#import "GFAccountManager.h"
#import "GFAccountManager+Weibo.h"
#import "GFAccountManager+Wechat.h"
#import "GFAccountManager+QQ.h"

#import "GFNetworkManager+Common.h"
#import "GFNetworkManager+User.h"
#import "GFNetworkManager+Publish.h"
#import "GFNetworkManager+Group.h"
#import "GFNetworkManager+Message.h"

#import "GFStartupAdViewController.h"
#import "GFHomeContainerViewController.h"
#import "GFUserGuideViewController.h"
#import "GFInterestGuideViewController.h"

#import "GFNavigationController.h"
#import "GFWebViewController.h"
#import "GFContentDetailViewController.h"
#import "GFProfileViewController.h"
#import "GFGroupDetailViewController.h"
#import "GFGroupInfoViewController.h"
#import "GFTagDetailViewController.h"
#import "GFGroupUpdateViewController.h"
#import "GFCommentDetailViewController.h"
#import "GFLessonViewController.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "GFLocationManager.h"
#import "GFContainerViewController.h"
#import "GFMessageCenter.h"
#import "TalkingDataAppCpa.h"
#import "GFReviewManager.h"
// getfun协议前缀
NSString * const GFGetfunRedirectLogin = @"login";
NSString * const GFGetfunRedirectPreview = @"preview";
NSString * const GFGetfunRedirectDetail = @"detail";
NSString * const GFGetfunRedirectGroup = @"group";
NSString * const GFGetfunRedirectUser = @"user";
NSString * const GFGetfunRedirectTag = @"tag";
NSString * const GFGetfunRedirectHome = @"home";
NSString * const GFGetfunRedirectShare = @"share"; //getfun://share?title=xxx&shortTitle=xxx&desc=xxx&img=xxx&url=xxx

NSString * const kRedirectURI = @"http://www.17getfun.com";

// 微信
NSString * const kWXAppId = @"wx14a055cbfa3f79f2";
NSString * const kWXAppSecret = @"d4624c36b6795d1d99dcf0547af5443d";
// QQ
NSString * const kTencentAppId = @"1104879479";
NSString * const kTencentAppKey = @"kwe1zSKpt17vv7Po";
// 微博
NSString * const kWeiboAppKey = @"1025548023";
NSString * const kWeiboAppSecret = @"55ca779e4ca79771c72f2f7e13240277";

// 友盟
NSString * const kUMengAppKey = @"56979d24e0f55a9ce8002198";

// TalkingData
NSString * const kTalkingDataAppID = @"80e23786cffd4bca9d223373a7694ef5";

NSString * const GFUserDefaultsKeyGetfunIdentifierForVendor = @"GFUserDefaultsKeyGetfunIdentifierForVendor";
NSString * const GFUserDefaultsKeyLastLaunchVersionForUserGuide = @"GFUserDefaultsKeyLastLaunchVersionForUserGuide";
NSString * const GFUserDefaultsKeyLastLaunchBuildForUserGuide = @"GFUserDefaultsKeyLastLaunchBuildForUserGuide";

@interface AppDelegate ()

@property (nonatomic, strong) GFStartupAdViewController *startupAdViewController;
@property (nonatomic, strong) GFHomeContainerViewController *homeContainerViewController;
@property (nonatomic, strong) GFUserGuideViewController *userGuideViewController;
@property (nonatomic, strong) GFInterestGuideViewController *interestGuideViewController;
@property (nonatomic, strong) GFContainerViewController *containerViewController;

@property (nonatomic, assign) BOOL isRefreshingToken;

@property (nonatomic, copy) NSString *apnsDeviceToken;

@end

@implementation AppDelegate
- (GFStartupAdViewController *)startupAdViewController {
    if (!_startupAdViewController) {
        _startupAdViewController = [[GFStartupAdViewController alloc] init];
    }
    return _startupAdViewController;
}
- (GFHomeContainerViewController *)homeContainerViewController {
    if (!_homeContainerViewController) {
        _homeContainerViewController = [[GFHomeContainerViewController alloc] init];
    }
    return _homeContainerViewController;
}

- (GFUserGuideViewController *)userGuideViewController {
    if (!_userGuideViewController) {
        _userGuideViewController = [[GFUserGuideViewController alloc] init];
    }
    return _userGuideViewController;
}

- (GFInterestGuideViewController *)interestGuideViewController {
    if (!_interestGuideViewController) {
        _interestGuideViewController = [[GFInterestGuideViewController alloc] init];
    }
    return _interestGuideViewController;
}

+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor themeColorValue13];
    int memoryCapacity;
    int diskCapacity;
    int height = (int)[UIScreen mainScreen].bounds.size.height ;
    //根据屏幕高度来判断设备机型 高度大于480说明是5及以上的机型
    if (height > 480) {
        memoryCapacity = 100 *1024 *1024;
        diskCapacity   = 500 *1024 *1024;
    }else{
        memoryCapacity = 50 *1024 *1024;
        diskCapacity   = 300 *1024 *1024;
    }
    [YYImageCache sharedCache].memoryCache.costLimit = memoryCapacity;
    [YYImageCache sharedCache].diskCache.costLimit = diskCapacity;
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:cache];
//    NSURLCache *cache = [NSURLCache sharedURLCache];
//    [cache setMemoryCapacity:1024 *50];

    // 日志
    [self initDDLogger];
    // 崩溃跟踪
    [Fabric with:@[[Crashlytics class]]];
    // 网络状态监测
    [self initNetworkMonitor];
    // 友盟统计
    [self setupUmengAnalytics];
    // TalkingData
    [self initTalkingData];
    // http header
    [GFNetworkManager gf_updateHTTPHeader];
    // getfun消息中心
    [GFMessageCenter setup];
    
    [self refreshGetfunTokenCompletion:^{
        // apns
        [self initAPNS];
        // 上报登录时间
        [GFNetworkManager reportLoginTimeToGetfunServer];
        
        NSNumber *userId = [GFAccountManager sharedManager].loginUser.userId;
        NSString *userIdString = [NSString stringWithFormat:@"%@", userId];
        [TalkingDataAppCpa onLogin:userIdString];
        [self doClearAPNsMessageCount];
    }];
    
    [self initRootViewController];
    
    // 启动应用，需要检测是否通过点击apns启动.
    if (launchOptions) {
        NSLog(@"launchOpitions = %@", launchOptions);
        // 目前这里的launchOptions就是支持apns
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        self.homeContainerViewController.launchOptionUserInfo = userInfo;
        
        NSLog(@"%s%s, userInfo=%@", __FILE__, __PRETTY_FUNCTION__, userInfo);
    } else {
        NSLog(@"%s%s, %@", __FILE__, __PRETTY_FUNCTION__, @"launchOptions nil");
    }
    
    [self.window makeKeyAndVisible];
    
    [GFReviewManager review];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([GFAccountManager sharedManager].accessToken) {
        [self performSelector:@selector(doClearAPNsMessageCount) withObject:nil afterDelay:2.0f];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 处理剪贴板
    NSString *textInPasteboard = [UIPasteboard generalPasteboard].string;
    NSString *subString = [textInPasteboard subStringWithPattern:@"(http|https)(://)[0-9A-Za-z:/[-]_#[&][?][=][.]]*"];
    if ([[subString lowercaseString] rangeOfString:@"openinapp=1"].location != NSNotFound) {
        [self performSelector:@selector(handleGetfunLinkUrl:) withObject:subString afterDelay:1.5f];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 有apnsDeviceToken，说明不是刚刚启动应用，就重新获取apnsDeviceToken
    if (self.apnsDeviceToken) {
        [self initAPNS];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [self handleURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [self handleURL:url];
}

- (BOOL)handleURL:(NSURL *)url {
    
    if ([[url scheme] isEqualToString:@"wb1025548023"]) {
        return [GFAccountManager handleWeiboURL:url];
    } else if ([[url scheme] isEqualToString:kWXAppId]) {
        return [GFAccountManager handleWechatURL:url];
    } else if ([[url scheme] isEqualToString:@"tencent1104879479"]) {
        return [GFAccountManager handleQQURL:url];
    } else if ([[url scheme] isEqualToString:@"getfun"]) {
        [self handleGetfunLinkUrl:url.absoluteString];
    }
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSString *deviceTokenStr = [[[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (deviceTokenStr) {
        NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken = %@", deviceTokenStr);
        self.apnsDeviceToken = deviceTokenStr;
        [GFNetworkManager addAPNsDeviceToken:deviceTokenStr];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError = %@", error);
}


//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//}

//// 现在后台推送的aps中没有content-available = 1的参数，因此应用不会被系统唤起. 这里只会是用户点击push从后台进入前台
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"didReceiveRemoteNotification = %@", userInfo);
    // apns消息
    // 前台运行，不做任何处理。前台运行只处理个推透传消息
    // 从后台进入前台，需要处理apns消息
    UIApplicationState state = application.applicationState;
    NSLog(@"applicationState = %ld", (long)state);
    if (state != UIApplicationStateActive) {
        
        [self handleApnsInfo:userInfo];
    }
}

// 两个来源:
// 1. 点击apns全新启动app,从homeContainerViewController中转过来的
// 2. 点击apps后台进入前台,从上面的didReceiveRemoteNotification直接传递过来的
// 在这里只需要从后台拉取相关的完整message数据
- (void)handleApnsInfo:(NSDictionary *)userInfo {
    NSString *messageTypeKey = [userInfo objectForKey:@"messageType"];
    NSNumber *relatedId = [userInfo objectForKey:@"relatedId"];
    
    NSLog(@"%s%s, messageTypeKey=%@, relatedId=%@", __FILE__, __PRETTY_FUNCTION__, messageTypeKey, relatedId);
    GFMessageType type = messageType(messageTypeKey);
    // 通知消息，只在apns处理
    [GFNetworkManager getMessageWithRelatedId:relatedId type:type success:^(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFMessageMTL *message) {
        
        NSLog(@"%s%s, getMessageWithRelatedId: code=%ld, apiErrorMessage=%@, message=%@", __FILE__, __PRETTY_FUNCTION__, (long)code, apiErrorMessage, message);
        if (code == 1) {
            [GFMessageCenter handleMessage:message shouldRedirect:YES];
        }
    } failure:^(NSUInteger taskId, NSError *error) {
        //
    }];
}

#pragma mark - Public methods
- (void)switchToNextViewController:(UIViewController *)sender {
    NSInteger index = [self.containerViewController.viewControllers indexOfObject:sender];
    index ++;
    [self.containerViewController switchToViewController:index];
}

- (void)handleGetfunLinkUrl:(NSString *)linkUrl {
    
    NSURL *url = [NSURL URLWithString:linkUrl];
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme isEqualToString:@"http"]) {
        UIViewController *viewControllerToDisplay = [[GFWebViewController alloc] initWithURL:[NSURL URLWithString:linkUrl]];
        [self displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
        return;
    }
    if (![scheme isEqualToString:@"getfun"]) return;
    
    NSString *host = [[url host] lowercaseString];
    NSInteger redirectId = [[url lastPathComponent] integerValue];
    
    if ([host isEqualToString:GFGetfunRedirectLogin]) {
        [GFNetworkManager qrWebLogin:linkUrl
                             success:^(NSUInteger taskId, NSInteger code) {
                                 if (code == 1) {
                                     [MBProgressHUD showHUDWithTitle:@"登录成功，请到网页端发布" duration:kCommonHudDuration];
                                 } else {
                                     [MBProgressHUD showHUDWithTitle:@"登录失败，请重试" duration:kCommonHudDuration];
                                 }
                             } failure:^(NSUInteger taskId, NSError *error) {
                                 [MBProgressHUD showHUDWithTitle:@"当前网络不可用，请检查你的网络设置" duration:kCommonHudDuration];
                             }];
        
    } else if ([host isEqualToString:GFGetfunRedirectPreview]) {
        
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager getContentWithContentId:[NSNumber numberWithInteger:redirectId]
                                          keyFrom:GFKeyFromUnkown
                                          success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                              if (code == 1 && content) {
                                                  
                                                  UIViewController *viewControllerToDisplay = [[GFContentDetailViewController alloc] initWithContent:content preview:NO];
                                                  [self displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
                                              }
                                          } failure:^(NSUInteger taskId, NSError *error) {
                                              //
                                          }];
    } else if ([host isEqualToString:GFGetfunRedirectDetail]) {
        
        __weak typeof(self) weakSelf = self;
        [GFNetworkManager getContentWithContentId:[NSNumber numberWithInteger:redirectId]
                                          keyFrom:GFKeyFromUnkown
                                          success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                              if (code == 1 && content) {
                                                  
                                                  UIViewController *viewControllerToDisplay = nil;
                                                  if ([content isGetfunLesson]) {
                                                      viewControllerToDisplay = [[GFLessonViewController alloc] initWithContent:content];
                                                  } else {
                                                      viewControllerToDisplay = [[GFContentDetailViewController alloc] initWithContent:content preview:NO];
                                                  }
                                                  if (viewControllerToDisplay) {
                                                      [weakSelf displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
                                                  }
                                              }
                                          } failure:^(NSUInteger taskId, NSError *error) {
                                              //
                                          }];
    } else if ([host isEqualToString:GFGetfunRedirectGroup]) {
        
        [GFNetworkManager getGroupWithGroupId:[NSNumber numberWithInteger:redirectId]
                                      success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *apiErrorMessage) {
                                          
                                          UIViewController *viewControllerToDisplay = nil;
                                          if (group.joined) {
                                              viewControllerToDisplay = [[GFGroupDetailViewController alloc] initWithGroup:group];
                                          } else {
                                              viewControllerToDisplay = [[GFGroupInfoViewController alloc] initWithGroup:group];
                                          }
                                          if (viewControllerToDisplay) {
                                              [self displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
                                          }
                                          
                                      } failure:^(NSUInteger taskId, NSError *error) {
                                          //
                                      }];
        
    } else if ([host isEqualToString:GFGetfunRedirectUser]) {
        
        UIViewController *viewControllerToDisplay = [[GFProfileViewController alloc] initWithUserID:[NSNumber numberWithInteger:redirectId]];
        [self displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
        
    } else if ([host isEqualToString:GFGetfunRedirectTag]) {
        
        GFTagDetailViewController *viewControllerToDisplay = [[GFTagDetailViewController alloc] initWithTagId:[NSNumber numberWithInteger:redirectId]];
        [self displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
        
    } else if ([host isEqualToString:GFGetfunRedirectHome]) {
        // 回到首页
        if (self.homeContainerViewController.presentedViewController) {
            [self.homeContainerViewController dismissViewControllerAnimated:YES completion:NULL];
        }
        if ([[self.homeContainerViewController.navigationController viewControllers] count] > 1) {
            [self.homeContainerViewController.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

// 这里处理消息的跳转, 事件有两个来源:
// 1. 消息列表页面的点击事件
// 2. apns推送的事件(后台进入前台需要跳转)
// 在这里统一处理跳转逻辑
#warning 这里面往详情页或者第一课堂跳转的逻辑有大段重复代码，头疼先不改了，清醒了再整理 20160303 byzxz
- (void)handleRedirectMessage:(GFMessageMTL *)message {
    
    switch (message.messageDetail.messageType) {
        case GFMessageTypeUnknown:{
            break;
        }
            // 对于审核消息，都不跳转(apns有可能会需要跳转到消息中心吧?暂时不处理)
        case GFMessageTypeAuditContent:
        case GFMessageTypeAuditComment:
        case GFMessageTypeAuditUser: {
            //
            break;
        }
            // 对于审核get帮，需要跳转到帮详情或者帮信息或者帮完善页面
        case GFMessageTypeAuditGroup: {
            
            NSNumber *groupId = message.messageDetail.relatedId;
            NSLog(@"%s%s,groupId : %@", __FILE__, __PRETTY_FUNCTION__, groupId);
            if (groupId) {
                [GFNetworkManager getGroupWithGroupId:groupId success:^(NSUInteger taskId, NSInteger code, GFGroupMTL *group, NSString *errorMessage) {
                    if (code == 1 && group) {
                        
                        UIViewController *viewControllerToDisplay = nil;
                        // 审核通过
                        if (message.relatedData.relatedGroupInfo.auditStatus == GFGroupAuditStatusPass) {
                            if (group.joined) {
                                viewControllerToDisplay = [[GFGroupDetailViewController alloc] initWithGroup:group];
                            } else {
                                viewControllerToDisplay = [[GFGroupInfoViewController alloc] initWithGroup:group];
                            }
                        } else { // 审核不通过
                            viewControllerToDisplay = [[GFGroupUpdateViewController alloc] initWithGroup:group];
                        }
                        if (viewControllerToDisplay) {
                            [self displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
                        }
                    }else if([errorMessage length] > 0){
                        [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.window];
                    }
                } failure:^(NSUInteger taskId, NSError *error) {
                    //
                }];
            }
            
            break;
        }
            
            // 参与的pk或者fun的帖子,需要跳转到帖子页面
        case GFMessageTypeParticipate:
        case GFMessageTypeFunContent: {
            NSNumber *contentId = message.messageDetail.relatedId;
            if (contentId) {
                
                __weak typeof(self) weakSelf = self;
                [GFNetworkManager getContentWithContentId:contentId
                                                  keyFrom:GFKeyFromUnkown
                                                  success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                                      if (code == 1 && content) {
                                                          
                                                          UIViewController *viewControllerToDisplay = nil;
                                                          if ([content isGetfunLesson]) {
                                                              viewControllerToDisplay = [[GFLessonViewController alloc] initWithContent:content];
                                                          } else {
                                                              viewControllerToDisplay = [[GFContentDetailViewController alloc] initWithContent:content preview:NO];
                                                          }
                                                          if (viewControllerToDisplay) {
                                                              [weakSelf displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
                                                          }
                                                      } else if([errorMessage length] > 0){
                                                          [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.window];
                                                      }
                                                  } failure:^(NSUInteger taskId, NSError *error) {
                                                      [MBProgressHUD showHUDWithTitle:@"网络错误" duration:kCommonHudDuration inView:self.window];
                                                  }];
            }
            
            break;
        }
            // 对于评论的帖子，需要跳转到帖子页面
        case GFMessageTypeComment: {
            NSNumber *contentId = message.relatedData.relatedCommentInfo.relatedId;
            if (contentId) {
                
                __weak typeof(self) weakSelf = self;
                [GFNetworkManager getContentWithContentId:contentId
                                                  keyFrom:GFKeyFromUnkown
                                                  success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                                      if (code == 1 && content) {
                                                          
                                                          UIViewController *viewControllerToDisplay = nil;
                                                          if ([content isGetfunLesson]) {
                                                              viewControllerToDisplay = [[GFLessonViewController alloc] initWithContent:content];
                                                          } else {
                                                              viewControllerToDisplay = [[GFContentDetailViewController alloc] initWithContent:content preview:NO];
                                                          }
                                                          if (viewControllerToDisplay) {
                                                              [weakSelf displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
                                                          }
                                                      }
                                                      else if([errorMessage length] > 0){
                                                          [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.window];
                                                      }
                                                  } failure:^(NSUInteger taskId, NSError *error) {
                                                      //
                                                  }];
            }
            break;
        }
            
            // 对于回复评论或者FUN评论，需要跳转到评论详情页
        case GFMessageTypeCommentReply:
        case GFMessageTypeFunComment: {
            
            
            NSNumber *contentId = message.relatedData.relatedCommentInfo.relatedId;
            if (contentId) {
                
                __weak typeof(self) weakSelf = self;
                [GFNetworkManager getContentWithContentId:contentId
                                                  keyFrom:GFKeyFromUnkown
                                                  success:^(NSUInteger taskId, NSInteger code, GFContentMTL *content, NSDictionary *data, NSString *errorMessage) {
                                                      if (code == 1 && content) {
                                                          
                                                          NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:2];
                                                          
                                                          UIViewController *contentViewController = nil;
                                                          if ([content isGetfunLesson]) {
                                                              contentViewController = [[GFLessonViewController alloc] initWithContent:content];
                                                          } else {
                                                              contentViewController = [[GFContentDetailViewController alloc] initWithContent:content preview:NO];
                                                          }
                                                          
                                                          if (contentViewController) {
                                                              [viewControllers addObject:contentViewController];
                                                          }
                                                          
                                                          NSNumber *rootCommentId = message.relatedData.relatedCommentInfo.rootCommentId;
                                                          if (rootCommentId) {
                                                              GFCommentDetailViewController *commentDetailViewController = [[GFCommentDetailViewController alloc] initWithRootCommentId:rootCommentId contentId:contentId];
                                                              [viewControllers addObject:commentDetailViewController];
                                                          }
                                                          
                                                          if ([viewControllers count] > 0) {
                                                              GFNavigationController *navController = [[GFNavigationController alloc] init];
                                                              navController.viewControllers = viewControllers;
                                                              
                                                              [weakSelf displayViewController:navController];
                                                          }
                                                      }else if([errorMessage length] > 0){
                                                          [MBProgressHUD showHUDWithTitle:errorMessage duration:kCommonHudDuration inView:self.window];
                                                      }
                                                  } failure:^(NSUInteger taskId, NSError *error) {
                                                      //
                                                  }];
            }
            break;
        }
            // 对于活动和通知消息，需要解析linkURL
        case GFMessageTypeActivity:
        case GFMessageTypeNotify: {
            [GFNetworkManager markClickedMessage:message.messageDetail.relatedId];
            
            NSString *linkUrl = message.messageDetail.linkUrl;
            [[AppDelegate appDelegate] handleGetfunLinkUrl:linkUrl];
            
            break;
        }
            //对于关注消息，跳转到相应个人页
        case GFMessageTypeFollow:{
            NSNumber *userId = message.messageDetail.relatedUserId;
            if (userId) {
                GFProfileViewController *viewControllerToDisplay = [[GFProfileViewController alloc] initWithUserID:userId];                
                [self displayViewController:[[GFNavigationController alloc] initWithRootViewController:viewControllerToDisplay]];
            }
            
            break;
        }
    }
}

- (void)displayViewController:(UIViewController *)viewControllerToDisplay {
    UIViewController *topViewController = [[AppDelegate appDelegate] topViewController];
    if (topViewController && viewControllerToDisplay) {
        
        [topViewController presentViewController:viewControllerToDisplay
                                        animated:YES
                                      completion:^{
                                          
                                      }];
    }
}

- (UIViewController *)topViewController {
    return [self findTopViewController:self.containerViewController.selectedViewController];
}

- (UIViewController *)findTopViewController:(UIViewController *)viewController {
    
    UIViewController *topVC = viewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        topVC = [[(UINavigationController *)viewController viewControllers] lastObject];
        return [self findTopViewController:topVC];
    } else if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
        return [self findTopViewController:topVC];
    } else {
        return topVC;
    }
}

#pragma mark - Private methods
- (void)initNetworkMonitor {
    __weak typeof(self) weakSelf = self;
    [GFNetworkStatusUtil setNetworkStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [weakSelf networkStatusChanged:status];
    }];
    [GFNetworkStatusUtil startMonitoring];
}

- (void)setupUmengAnalytics {
    [MobClick startWithAppkey:kUMengAppKey reportPolicy:BATCH channelId:nil];
    [MobClick setLogEnabled:YES];
    [MobClick setAppVersion:APP_VERSION];
    [MobClick setEncryptEnabled:YES];
    [MobClick setCrashReportEnabled:NO];
}

- (void)initTalkingData {
    [TalkingDataAppCpa init:kTalkingDataAppID withChannelId:@"AppStore"];
}

- (void)initDDLogger {
    // 控制台输出
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // 日志文件输出
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60*60*24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    DDLogError(@"错误");
    DDLogWarn(@"警告");
    DDLogInfo(@"信息");
    DDLogDebug(@"调试");
    DDLogVerbose(@"详细");
}

- (void)initAPNS {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    } else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                                                                             categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)refreshGetfunTokenCompletion:(void (^)())completion {
    
    if (self.isRefreshingToken) return;
    
    self.isRefreshingToken = YES;
    
    if ([GFAccountManager sharedManager].refreshToken) {
        [GFAccountManager refreshTokenSuccess:^{
            self.isRefreshingToken = NO;
            
            if (completion) {
                completion();
            }
            
        } failure:^{
            self.isRefreshingToken = NO;
        }];
    } else {
        [GFAccountManager anonymousLoginSuccess:^{
            self.isRefreshingToken = NO;
            
            if (completion) {
                completion();
            }
            
        } failure:^{
            self.isRefreshingToken = NO;
        }];
    }
}

- (void)initRootViewController {
    
    NSString *lastVersion = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyLastLaunchVersionForUserGuide];
    NSString *lastBuild = [GFUserDefaultsUtil objectForKey:GFUserDefaultsKeyLastLaunchBuildForUserGuide];
    if (!lastVersion || !lastBuild) { // 第一次安装
        self.containerViewController = [[GFContainerViewController alloc]
                                        initWithViewControllers:@[self.userGuideViewController,
                                                                  self.interestGuideViewController,
                                                                  [[GFNavigationController alloc] initWithRootViewController:self.homeContainerViewController]]];
    } else {
        BOOL interestSelected = [GFUserDefaultsUtil boolForKey:GFUserDefaultsKeyInterestSelected];
        //由于是否选择兴趣的特性为1.3版本才加入，因此要对1.2版本前做兼容
        if (!interestSelected && [lastVersion compare:@"1.2.0" options:NSNumericSearch] != NSOrderedDescending) {
            //1.2版本之前lastVersion<=1.2,interestSelected必为NO
            self.containerViewController = [[GFContainerViewController alloc]
                                            initWithViewControllers:@[self.startupAdViewController,
                                                                      [[GFNavigationController alloc] initWithRootViewController:self.homeContainerViewController]]];
        } else if (interestSelected) {
            self.containerViewController = [[GFContainerViewController alloc]
                                            initWithViewControllers:@[self.startupAdViewController,
                                                                      [[GFNavigationController alloc] initWithRootViewController:self.homeContainerViewController]]];
        }else {
            self.containerViewController = [[GFContainerViewController alloc]
                                            initWithViewControllers:@[self.startupAdViewController,
                                                                      self.interestGuideViewController,
                                                                      [[GFNavigationController alloc] initWithRootViewController:self.homeContainerViewController]]];
        }

    }
    self.window.rootViewController = self.containerViewController;
}

- (void)doClearAPNsMessageCount {
    [GFNetworkManager clearAPNsMessageCount];
}

#pragma mark - 网络状态
- (void)networkStatusChanged:(AFNetworkReachabilityStatus)status {
    
    switch (status) {
        case AFNetworkReachabilityStatusUnknown: {
            //
            break;
        }
        case AFNetworkReachabilityStatusNotReachable: {
            [MBProgressHUD showHUDWithTitle:@"网络不可用" duration:kCommonHudDuration];
            break;
        }
        case AFNetworkReachabilityStatusReachableViaWWAN: {
            
            break;
        }
        case AFNetworkReachabilityStatusReachableViaWiFi: {
            
            break;
        }
    }
}
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[YYImageCache sharedCache].memoryCache removeAllObjects];
    [[YYImageCache sharedCache].diskCache removeAllObjects];
}
@end
