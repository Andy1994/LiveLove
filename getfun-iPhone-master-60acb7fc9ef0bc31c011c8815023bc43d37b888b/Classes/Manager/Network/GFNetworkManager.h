//
//  GFNetworkManager.h
//  getfun
//
//  Created by zhouxz on 15/11/10.
//  Copyright © 2015年 getfun. All rights reserved.
//

#import "NTESHTTPClient.h"

@interface GFNetworkManager : NTESHTTPClient

+ (void)gf_updateHTTPHeader;
+ (void)cancelTask:(NSUInteger)taskId;

@end
