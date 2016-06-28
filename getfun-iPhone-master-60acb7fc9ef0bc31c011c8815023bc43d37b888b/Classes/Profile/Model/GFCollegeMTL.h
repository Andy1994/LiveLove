//
//  GFCollegeMTL.h
//  GetFun
//
//  Created by zhouxz on 15/12/11.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFCollegeMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *collegeId;
@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *countryId;
@property (nonatomic, strong) NSNumber *provinceId;

@end