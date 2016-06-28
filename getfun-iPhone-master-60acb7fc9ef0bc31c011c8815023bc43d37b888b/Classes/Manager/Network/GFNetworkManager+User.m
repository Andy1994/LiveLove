//
//  GFNetworkManager+User.m
//  getfun
//
//  Created by zhouxz on 15/11/10.
//  Copyright © 2015年 getfun. All rights reserved.
//

#import "GFNetworkManager+User.h"
#import "GFUserMTL.h"
#import "GFAccountManager.h"
#import "TalkingDataAppCpa.h"

#define GF_API_QUERY_VERIFICATION_CODE ApiAddress(@"/api/user/sendVerifyCode")
#define GF_API_CHECK_VERIFICATION_CODE ApiAddress(@"/api/user/verifyMobile")
#define GF_API_REGISTER_USER ApiAddress(@"/api/user/addUser")
#define GF_API_UPDATE_PROFILE ApiAddress(@"/api/user/addInfo")
#define GF_API_RESET_PASSWORD ApiAddress(@"/api/user/resetPassword")
#define GF_API_CHANGE_PASSWORD ApiAddress(@"/api/user/changePassword")
#define GF_API_LOGIN_USER ApiAddress(@"/api/authenticate")
#define GF_API_ANONYMOUS_LOGIN ApiAddress(@"/api/user/addDeviceUser")
#define GF_API_LOGOUT_USER ApiAddress(@"/api/logout")
#define GF_API_QUERY_PROFILE ApiAddress(@"/api/user/userInfo")
#define GF_API_QUERY_COLLEGES ApiAddress(@"/api/user/getChinaCollegesByProvince")
#define GF_API_QUERY_DEPARTMENTS ApiAddress(@"/api/user/getDepartmentsByCollege")
//#define GF_API_UPDATE_SHARE_LOCATION ApiAddress(@"/api/user/updateShareLocation")
#define GF_API_USER_FEEDBACK ApiAddress(@"/api/feedback/add")
#define GF_API_UPDATE_AVATAR ApiAddress(@"/api/user/updateAvatar")
#define GF_API_UPDATE_NICKNAME ApiAddress(@"/api/user/updateNickName")
#define GF_API_UPDATE_BIRTHDAY ApiAddress(@"/api/user/updateBirthday")
#define GF_API_UPDATE_GENDER ApiAddress(@"/api/user/updateSex")
#define GF_API_UPDATE_PROVINCE_AND_CITY ApiAddress(@"/api/user/updateProvinceAndCity")
#define GF_API_UPDATE_COLLEGE_DEPARTMENT_ENROLLTIME ApiAddress(@"/api/user/updateCollegeAndDepartment")
#define GF_API_JOINT_LOGIN ApiAddress(@"/api/jointLogin")
#define GF_API_USER_ADD_INTERESTS ApiAddress(@"/api/user/addInterests")
#define GF_API_USER_REMOVE_INTERESTS  ApiAddress(@"/api/user/removeInterests")

#define GF_API_UPDATE_ACCEPT_MESSAGE    ApiAddress(@"/api/user/updateSwitchStatus")

@implementation GFNetworkManager (User)

+ (NSUInteger)queryVerificationCodeForMobile:(NSString *)mobile
                         existedUserSupposed:(BOOL)existedUser
                                     success:(void (^)(NSUInteger, NSInteger, NSString *))success
                                     failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_VERIFICATION_CODE
                                                    parameters:@{@"mobile":mobile,
                                                                 @"flag":existedUser ? @1 : @0}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)checkVerificationCode:(NSString *)verificationCode
                             mobile:(NSString *)mobile
                            success:(void (^)(NSUInteger, NSInteger, NSString *, NSString *))success
                            failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_CHECK_VERIFICATION_CODE
                                                    parameters:@{@"mobile":mobile,
                                                                 @"code":verificationCode}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSString *token = [responseObject objectForKey:@"token"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, token);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)registerUserWithParameters:(NSDictionary *)parameters
                                 success:(void (^)(NSUInteger, NSInteger, NSString *, NSString *, NSString *, GFUserMTL *))success
                                 failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_REGISTER_USER
                                                    parameters:parameters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSString *refreshToken = [responseObject objectForKey:@"refresh_token"];
                                                           NSString *accessToken = [responseObject objectForKey:@"access_token"];
                                                           NSDictionary *userDic = [responseObject objectForKey:@"user"];
                                                           GFUserMTL *userInfo = [MTLJSONAdapter modelOfClass:[GFUserMTL class] fromJSONDictionary:userDic error:nil];
                                                           
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, refreshToken, accessToken, userInfo);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)jointLogin:(GFLoginType)type
                     uid:(NSString *)uid
                 unionId:(NSString *)unionId
                 success:(void (^)(NSUInteger, NSInteger, NSString *, BOOL, NSString *, NSString *, GFUserMTL *))success
                 failure:(void (^)(NSUInteger, NSError *))failure {
    
    if ((type!=GFLoginTypeQQ && type!=GFLoginTypeWechat && type!= GFLoginTypeWeiBo) || !uid || [uid length] == 0) {
        return 0;
    }
    
    NSString *typeString = nil;
    if (type == GFLoginTypeQQ) {
        typeString = @"QQ";
    } else if (type == GFLoginTypeWechat) {
        typeString = @"WEIXIN";
    } else if (type == GFLoginTypeWeiBo) {
        typeString = @"WEIBO";
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    [parameters setObject:typeString forKey:@"type"];
    [parameters setObject:uid forKey:@"uid"];
    if (unionId) {
        [parameters setObject:unionId forKey:@"unionId"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_JOINT_LOGIN
                                                    parameters:parameters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           BOOL firstLogin = [[responseObject objectForKey:@"loginFirstTime"] boolValue];
                                                           NSString *refreshToken = [responseObject objectForKey:@"refresh_token"];
                                                           NSString *accessToken = [responseObject objectForKey:@"access_token"];
                                                           NSDictionary *userDict = [responseObject objectForKey:@"user"];
                                                           GFUserMTL *userMTL = [MTLJSONAdapter modelOfClass:[GFUserMTL class] fromJSONDictionary:userDict error:nil];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, firstLogin, refreshToken, accessToken, userMTL);
                                                           }
                                                           
                                                           if (firstLogin && userMTL.userId) {
                                                               NSString *userIdString = [NSString stringWithFormat:@"%@", userMTL.userId];
                                                               [TalkingDataAppCpa onRegister:userIdString];
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)updateProfileWithParameters:(NSDictionary *)parameters
                                  success:(void (^)(NSUInteger, NSInteger, NSString *, GFUserMTL *))success
                                  failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_PROFILE
                                                    parameters:parameters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSDictionary *userDict = [responseObject objectForKey:@"user"];
                                                           GFUserMTL *userMTL = [MTLJSONAdapter modelOfClass:[GFUserMTL class] fromJSONDictionary:userDict error:nil];
                                                           
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, userMTL);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)loginWithOption:(BOOL)usePassword
                         user:(NSString *)user
                     password:(NSString *)password
                 refreshToken:(NSString *)refreshToken
                      success:(void (^)(NSUInteger, NSInteger, NSString *, NSString *, NSString *, GFUserMTL *))success
                      failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_LOGIN_USER
                                                    parameters:@{@"grantType":usePassword ? @"password" : @"refresh_token",
                                                                 @"userName":user ? user : @"",
                                                                 @"password":password ? password : @"",
                                                                 @"refresh_token":refreshToken ? refreshToken : @""}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSString *refreshToken = [responseObject objectForKey:@"refresh_token"];
                                                           NSString *accessToken = [responseObject objectForKey:@"access_token"];
                                                           NSDictionary *userDic = [responseObject objectForKey:@"user"];
                                                           GFUserMTL *userInfo = [MTLJSONAdapter modelOfClass:[GFUserMTL class] fromJSONDictionary:userDic error:nil];
                                                           
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, refreshToken, accessToken, userInfo);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)anonymousLoginSuccess:(void (^)(NSUInteger, NSInteger, NSString *, NSString *))success
                            failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_ANONYMOUS_LOGIN
                                                    parameters:@{@"deviceNo" : [UIDevice gf_idfv]}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *refreshToken = [responseObject objectForKey:@"refresh_token"];
                                                           NSString *accessToken = [responseObject objectForKey:@"access_token"];
                                                           if (success) {
                                                               success(taskId, code, refreshToken, accessToken);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    
    return taskId;
}

+ (NSUInteger)logoutWithGeTuiClientId:(NSString *)clientId
                              success:(void (^)(NSUInteger, NSInteger, NSString *, NSString *))success
                              failure:(void (^)(NSUInteger, NSError *))failure {
    if (!clientId) {
        clientId = @"";
    }
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_LOGOUT_USER
                                                    parameters:@{
                                                                 @"clientId" : clientId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *refreshToken = [responseObject objectForKey:@"refresh_token"];
                                                           NSString *accessToken = [responseObject objectForKey:@"access_token"];
                                                           if (success) {
                                                               success(taskId, code, refreshToken, accessToken);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)resetPassword:(NSString *)mobile
                      token:(NSString *)token
                   password:(NSString *)password
                    success:(void (^)(NSUInteger, NSInteger, NSString *))success
                    failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_RESET_PASSWORD
                                                    parameters:@{@"token":token,
                                                                 @"mobile":mobile,
                                                                 @"password":password}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)changeOriginPassword:(NSString *)originPassword
                        toPassword:(NSString *)password
                           success:(void (^)(NSUInteger, NSInteger, NSString *))success
                           failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_CHANGE_PASSWORD
                                                    parameters:@{
                                                                 @"oldPassword" : originPassword,
                                                                 @"newPassword" : password
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

//+ (NSUInteger)updateShareLocation:(BOOL)shareLocation
//                          success:(void (^)(NSUInteger, NSInteger, NSString *))success
//                          failure:(void (^)(NSUInteger, NSError *))failure {
//    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_SHARE_LOCATION
//                                                    parameters:@{
//                                                                 @"shareLocation" : [NSNumber numberWithBool:shareLocation]
//                                                                 }
//                                                       success:^(NSUInteger taskId, id responseObject) {
//                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
//                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
//                                                           if (success) {
//                                                               success(taskId, code, apiErrorMessage);
//                                                           }
//                                                       } failure:^(NSUInteger taskId, NSError *error) {
//                                                           if (failure) {
//                                                               failure(taskId, error);
//                                                           }
//                                                       }];
//    return taskId;
//}

+ (NSUInteger)updateAvatar:(NSString *)avatarStoreKey
                   success:(void (^)(NSUInteger, NSInteger, NSString *, NSString *))success
                   failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_AVATAR
                                                    parameters:@{
                                                                 @"avatar" : avatarStoreKey
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSString *avatarURL = [responseObject objectForKey:@"avatar"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, avatarURL);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)updateNickname:(NSString *)nickName
                     success:(void (^)(NSUInteger, NSInteger, NSString *))success
                     failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_NICKNAME
                                                    parameters:@{
                                                                 @"nickName" : nickName
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)updateBirthday:(NSDate *)birthday
                     success:(void (^)(NSUInteger, NSInteger, NSString *))success
                     failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_BIRTHDAY
                                                    parameters:@{
                                                                 @"birthday" : [NSNumber numberWithLongLong:[birthday timeIntervalSince1970] * 1000]
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)updateGender:(GFUserGender)gender
                   success:(void (^)(NSUInteger, NSInteger, NSString *))success
                   failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_GENDER
                                                    parameters:@{
                                                                 @"sex" : (gender == GFUserGenderMale ? @"MALE" : @"FEMALE")
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    
    return taskId;
}

+ (NSUInteger)updateProvince:(NSNumber *)provinceId
                        city:(NSNumber *)cityId
                     success:(void (^)(NSUInteger, NSInteger, NSString *))success
                     failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_PROVINCE_AND_CITY
                                                    parameters:@{
                                                                 @"provinceId" : provinceId,
                                                                 @"cityId" : cityId
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)updateCollege:(NSNumber *)collegeId
                 department:(NSNumber *)departmentId
                 enrollTime:(NSDate *)enrollTime
                    success:(void (^)(NSUInteger, NSInteger, NSString *))success
                    failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (collegeId) {
        [parameters setObject:collegeId forKey:@"collegeId"];
    }
    if (departmentId) {
        [parameters setObject:departmentId forKey:@"departmentId"];
    }
    if (enrollTime) {
        [parameters setObject:[NSNumber numberWithLongLong:[enrollTime timeIntervalSince1970] * 1000] forKey:@"enrollTime"];
    }
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_COLLEGE_DEPARTMENT_ENROLLTIME
                                                    parameters:parameters
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}



+ (NSUInteger)queryProfileForUser:(NSNumber *)userID
                          success:(void (^)(NSUInteger, NSInteger, GFProfileMTL *))success
                          failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_PROFILE
                                                    parameters:@{
                                                                 @"userId" : userID
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           
                                                           GFProfileMTL *profileMTL = nil;
                                                           NSDictionary *profileDict = [responseObject mtl_dictionaryByRemovingEntriesWithKeys:[NSSet setWithObjects:@"code", @"apiErrorMessage", nil]];
                                                           if (profileDict) {
                                                               profileMTL = [MTLJSONAdapter modelOfClass:[GFProfileMTL class] fromJSONDictionary:profileDict error:nil];
                                                           }

                                                           if (success) {
                                                               success(taskId, code, profileMTL);
                                                           }
                                                           
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)queryCollegeWithProvinceID:(NSNumber *)provinceID
                                 success:(void (^)(NSUInteger, NSInteger, NSString *, NSArray<GFCollegeMTL *> * colleges))success
                                 failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_QUERY_COLLEGES
                                                    parameters:@{
                                                                 @"provinceId" : provinceID
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           NSArray *jsonColleges = [responseObject objectForKey:@"dataList"];
                                                           NSArray<GFCollegeMTL *> *colleges = [MTLJSONAdapter modelsOfClass:[GFCollegeMTL class] fromJSONArray:jsonColleges error:nil];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage, colleges);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)addFeedbackContent:(NSString *)content
                          mobile:(NSString *)mobile
                         success:(void (^)(NSUInteger, NSInteger, NSString *))success
                         failure:(void (^)(NSUInteger, NSError *))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_USER_FEEDBACK
                                                    parameters:@{
                                                                 @"content" : content,
                                                                 @"mobile" : mobile
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)addUserInterestTags:(NSArray<NSNumber *> *)tagIdList
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure {
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_USER_ADD_INTERESTS
                                                    parameters:@{@"tagId" : tagIdList}
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

+ (NSUInteger)queryMetaInfoSuccess:(void (^)(NSUInteger, NSInteger, NSString *, GFMetaInfoMTL *))success
                           failure:(void (^)(NSUInteger, NSError *))failure {
    return 0;
}

+ (NSUInteger)updateAcceptPushMessageSetting:(BOOL)accept
                                        type:(GFAcceptMessageType)type
                                     success:(void (^)(NSUInteger, NSInteger, NSString *))success
                                     failure:(void (^)(NSUInteger, NSError *))failure {
    
    NSUInteger taskId = [[GFNetworkManager sharedManager] POST:GF_API_UPDATE_ACCEPT_MESSAGE
                                                    parameters:@{
                                                                 @"switchName" : acceptMessageTypeKey(type),
                                                                 @"switchStatus" : (accept ? @"ON" : @"OFF")
                                                                 }
                                                       success:^(NSUInteger taskId, id responseObject) {
                                                           NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                                                           NSString *apiErrorMessage = [responseObject objectForKey:@"apiErrorMessage"];
                                                           if (success) {
                                                               success(taskId, code, apiErrorMessage);
                                                           }
                                                       } failure:^(NSUInteger taskId, NSError *error) {
                                                           if (failure) {
                                                               failure(taskId, error);
                                                           }
                                                       }];
    return taskId;
}

@end
