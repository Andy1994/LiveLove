//
//  NTESHTTPTask.m
//  NTESClient
//
//  Created by yanruichen on 15-8-6.
//  Copyright (c) 2015年 akin. All rights reserved.
//

#import <objc/runtime.h>
#import "NTESHTTPTask.h"

@interface NTESHTTPTask ()
@property(assign, nonatomic) NSUInteger identifier;
/**
 *  由于这个对象只可在HTTPClient中产生，client发送的请求在block生命周期结束前不会释放被block引用的对象，因此这个task会随着请求完成而自动释放
 */
@property(strong, nonatomic) NSURLSessionDataTask *task;
@end

@implementation NTESHTTPTask

-(void)setTask:(NSURLSessionDataTask *)task {
    _task = task;
    self.identifier = _task.taskIdentifier;
}

-(void)suspand {
    [self.task suspend];
}
-(void)resume {
    [self.task resume];
}
-(void)cancel {
    [self.task cancel];
}
@end


