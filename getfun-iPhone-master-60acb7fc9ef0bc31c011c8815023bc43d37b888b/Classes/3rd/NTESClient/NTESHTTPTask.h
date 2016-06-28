//
//  NTESHTTPTask.h
//  NTESClient
//
//  Created by yanruichen on 15-8-6.
//  Copyright (c) 2015年 akin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESHTTPTask : NSObject
@property(readonly, nonatomic) NSUInteger identifier;
-(void)resume;
-(void)suspand;
-(void)cancel;
@end
