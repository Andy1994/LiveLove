//
//  GFUserDefaultsUtil.h
//  GetFun
//
//  Created by zhouxz on 15/11/30.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFUserDefaultsUtil : NSObject

+ (void)setObject:(id)value forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)setBool:(BOOL)value forKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;

+ (void)setInteger:(NSInteger)value forKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key;

+ (void)setUInteger:(NSUInteger)value forKey:(NSString *)key;
+ (NSUInteger)uintegerForKey:(NSString *)key;

@end
