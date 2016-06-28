//
//  NSDate+Getfun.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/3/23.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "NSDate+Getfun.h"

@implementation NSDate (Getfun)

+ (NSTimeInterval)todayReferenceTime {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[[NSDate alloc] init]];
    
    //  today
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
    return [today timeIntervalSince1970];
}

@end
