//
//  GFContentInfoMTL.h
//  GetFun
//
//  Created by zhouxz on 15/11/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFContentInfoMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *contentId;
@property (nonatomic, assign) GFContentType type;

@property (nonatomic, strong) NSNumber *createTime;

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, copy)   NSString *address;
@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, strong) NSNumber *viewCount;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *forwardCount;
@property (nonatomic, strong) NSNumber *shareCount;
@property (nonatomic, strong) NSNumber *collectCount;
@property (nonatomic, strong) NSNumber *funCount;
@property (nonatomic, strong) NSNumber *specialCount;
@property (nonatomic, strong) NSNumber *pullCount;
@property (nonatomic, assign) GFContentStatus status;

@end
