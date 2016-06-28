//
//  GFUserDefaultsUtil.m
//  GetFun
//
//  Created by zhouxz on 15/11/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFUserDefaultsUtil.h"

@implementation GFUserDefaultsUtil

+ (void)setObject:(id)value forKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)objectForKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return nil;
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setBool:(BOOL)value forKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)boolForKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return NO;
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return;
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key] ;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)integerForKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return 0;
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (void)setUInteger:(NSUInteger)value forKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:value] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)uintegerForKey:(NSString *)key {
    if (![GFUserDefaultsUtil isValidKey:key]) return 0.0f;
    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] unsignedIntegerValue];
}

#pragma mark - private
+ (BOOL)isValidKey:(NSString*)key {
    if (!key || [key length] == 0 || (NSNull *)key == [NSNull class]) {
        return FALSE;
    } else return TRUE;
}

@end
