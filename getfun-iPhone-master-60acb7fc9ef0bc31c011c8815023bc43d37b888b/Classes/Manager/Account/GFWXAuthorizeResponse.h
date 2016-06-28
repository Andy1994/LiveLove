//
//  GFWXAuthorizeResponse.h
//  GetFun
//
//  Created by zhouxz on 15/12/15.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFWXAuthorizeResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, assign) NSTimeInterval expires_in;
@property (nonatomic, copy) NSString *openid;
@property (nonatomic, copy) NSString *refresh_token;
@property (nonatomic, copy) NSString *scope;
@property (nonatomic, copy) NSString *unionid;

@end
