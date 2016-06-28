//
//  GFVerifyButton.m
//  GetFun
//
//  Created by liupeng on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//
#import "GFVerifyButton.h"

#define GF_TOTAL_COUNT_DOWN_SECOND 60
@interface GFVerifyButton ()

@property (strong, nonatomic, readwrite) NSDate *startDate;
@property (strong, nonatomic, readwrite) NSTimer *timer;

@end

@implementation GFVerifyButton

#pragma mark - verify down method
- (void)startCountDown {
    self.startDate = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)reset {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.enabled = YES;
    }
}

-(void)timerFired {
    
    self.enabled = NO;
    
     CGFloat deltaTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
     NSInteger timeRemain = GF_TOTAL_COUNT_DOWN_SECOND - (NSInteger)(deltaTime+0.5);
    if (timeRemain <= 0.0f) {
        [self stop];
    } else {
        [self setTitle:[NSString stringWithFormat:@"%ld秒", (long)timeRemain] forState:UIControlStateDisabled];
    }
}

- (void)stop {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self setTitle:@"重新发送" forState:UIControlStateNormal];
        self.enabled = YES;
    }
}

@end
