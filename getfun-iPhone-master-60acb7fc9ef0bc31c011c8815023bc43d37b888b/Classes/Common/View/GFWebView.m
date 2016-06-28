//
//  GFWebView.m
//  GetFun
//
//  Created by zhouxz on 16/1/20.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFWebView.h"
#import "GFAccountManager.h"
@implementation GFWebView
- (instancetype)init {
    if (self = [super init]) {
        [self setUserAgent];
    }
    return self;
}

+(instancetype)shareWithFrame:(CGRect)frame
{
    static GFWebView *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] initWithFrame:frame];
    });
    return shareInstance;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUserAgent];
    }
    return self;
}

- (void)setUserAgent {
    NSString* secretAgent = [self stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *agent = [NSString stringWithFormat:@"Getfun App iOS %@", APP_VERSION];
    if ([secretAgent rangeOfString:agent].location == NSNotFound) {
        secretAgent = [secretAgent stringByAppendingString:agent];
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc]
                                initWithObjectsAndKeys:secretAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}


- (void)setCookieIfNeeded:(NSString *)url {
    if ([url rangeOfString:@"17getfun.com"].location != NSNotFound) {
        
        NSDictionary *param = @{
                                @"channel_id" : @"app store",
                                @"device_model" : [UIDevice gf_device_model],
                                @"device_no" : [UIDevice gf_idfv],
                                @"access_token" : [GFAccountManager sharedManager].accessToken
                                };
        // 设置cookie
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSString *key in [param allKeys]) {
            NSString *value = [param objectForKey:key];
            
            NSMutableDictionary *properties = [[NSMutableDictionary alloc] initWithCapacity:0];
            [properties setObject:key forKey:NSHTTPCookieName];
            [properties setObject:value forKey:NSHTTPCookieValue];
            [properties setObject:@".17getfun.com" forKey:NSHTTPCookieDomain];
            [properties setObject:@"/" forKey:NSHTTPCookiePath];
            [properties setObject:[[NSDate date] dateByAddingTimeInterval:600]  forKey:NSHTTPCookieExpires];
            NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
            [storage setCookie:cookie];
        }
        
    }
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    //return [super canPerformAction:action withSender:sender];
    return (action == @selector(copy:) || action == @selector(select:));
    //return NO;
}

@end
