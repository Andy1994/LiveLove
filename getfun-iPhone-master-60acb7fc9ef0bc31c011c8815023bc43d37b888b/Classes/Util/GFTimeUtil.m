//
//  GFTimeUtil.m
//  GetFun
//
//  Created by zhouxz on 15/12/25.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFTimeUtil.h"

@implementation GFTimeUtil
+ (NSString *)getfunStyleTimeFromTimeInterval:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return [self getfunStyleTimeFromDate:date];
}

+ (NSString *)getfunStyleTimeFromDate:(NSDate *)date {
    
    NSTimeInterval seconds = 0 - (NSInteger)[date timeIntervalSinceNow];
    NSString *dateResult = @"未知";
    if (seconds < 60) {
        dateResult = @"刚刚";
    } else if (seconds >= 60 && seconds < 3600) {
        dateResult = [NSString stringWithFormat:@"%@分钟前", @((NSInteger)seconds / 60)];
    } else if (seconds >= 3600 && seconds < 86400) {
        dateResult = [NSString stringWithFormat:@"%@小时前", @((NSInteger)seconds / 3600)];
    }else if (seconds >= 86400 && seconds < 86400*2) {
        dateResult = @"昨天";
    }
    else if (seconds >= 86400*2 && seconds < 86400*3) {
        dateResult = @"前天";
    }
    else {
        dateResult = [[date description] substringToIndex:10];
    }
    
    return dateResult;
    
}

+ (NSString *)getfunStyleTimeFromDateString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [GFTimeUtil getfunStyleTimeFromDate:[formatter dateFromString:dateString]];
}

@end
