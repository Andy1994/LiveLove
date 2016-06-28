//
//  GFUserMTL.h
//  GetFun
//
//  Created by muhuaxin on 15/11/12.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
@class GFProfessionMTL;

@interface GFUserMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, strong) NSNumber *birthday;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, strong) NSNumber *provinceId;
@property (nonatomic, copy) NSString *provinceName;
@property (nonatomic, strong) NSNumber *cityId;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, strong) NSNumber *collegeId;
@property (nonatomic, copy) NSString *collegeName;
@property (nonatomic, strong) NSNumber *departmentId;
@property (nonatomic, copy) NSString *departmentName;
@property (nonatomic, strong) NSNumber *enrollTime;
@property (nonatomic, assign) GFUserGender gender;
@property (nonatomic, assign) BOOL shareLocation;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSArray<GFProfessionMTL *> *professions; //职业头衔

@end

@interface GFProfessionInfoMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name; //名称，比如“影评人”
@property (nonatomic, copy) NSString *iconUrl; //icon的url

@end

@interface GFProfessionUserInfoMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *addTime; //添加时间

@end

// GFUserMTL中的职业头衔
@interface GFProfessionMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) GFProfessionInfoMTL *info;
@property (nonatomic, strong) GFProfessionUserInfoMTL *userInfo;

@end