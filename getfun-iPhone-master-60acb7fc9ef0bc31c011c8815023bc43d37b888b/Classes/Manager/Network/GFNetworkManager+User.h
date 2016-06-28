//
//  GFNetworkManager+User.h
//  getfun
//
//  Created by zhouxz on 15/11/10.
//  Copyright © 2015年 getfun. All rights reserved.
//

#import "GFNetworkManager.h"
#import "GFUserMTL.h"
#import "GFProfileMTL.h"
#import "GFCollegeMTL.h"
#import "GFMetaInfoMTL.h"

/**
 *  用户相关网络请求接口
 */
@interface GFNetworkManager (User)

#pragma mark - 验证码
/**
 *  通过短信获取验证码
 *
 *  @param mobile       手机号
 *  @param existedUser  是否认为是已注册的用户(分别用于注册、取回密码)
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */

+ (NSUInteger)queryVerificationCodeForMobile:(NSString *)mobile
                         existedUserSupposed:(BOOL)existedUser
                                     success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                                     failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  向服务器校验验证码
 *
 *  @param verificationCode 验证码
 *  @param mobile           手机号
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)checkVerificationCode:(NSString *)verificationCode
                             mobile:(NSString *)mobile
                            success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *token))success
                            failure:(void (^)(NSUInteger taskId, NSError *error))failure;

#pragma mark - 注册、登录
/**
 *  手机号注册新用户
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskId
 *
 *  @see checkVerificationCode:mobile:success:failure:
 *  @notice. parameters需提供以下参数
 参数名        类型	是否可为空   含义      备注
 token      String	否	手机号验证通过后返回给客户端的token
 mobile     String	否	手机号码
 password	String	否	密码
 nickName	String	是	昵称
 sex        String	是	性别	UNKNOWN("未知性别"), MALE("男"), FEMALE("女")
 birthday	long	是	生日	毫秒表示的时间戳
 provinceId	int     是	所在地省份，用整形数字表示，如：1-表示北京
 cityId     int     是	所在地地市，用整形数字表示，结合province字段，如：1-表示北京的东城区
 avatar     String	是	头像图片的URL
 */
+ (NSUInteger)registerUserWithParameters:(NSDictionary *)parameters
                                 success:(void (^)(NSUInteger taskId, NSInteger code, NSString * apiErrorMessage, NSString *refreshToken, NSString *accessToken, GFUserMTL *userInfo))success
                                 failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  第三方授权登录(注册)
 *
 *  @param type     账户类型
 *  @param uid      第三方用户id(openid或uid)
 *  @param unionId  unionId
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)jointLogin:(GFLoginType)type
                     uid:(NSString *)uid
                 unionId:(NSString *)unionId
                 success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, BOOL firstLogin, NSString *refreshToken, NSString *accessToken, GFUserMTL * userInfo))success
                 failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  第三方授权注册完善用户信息(第一次登录时注册)
 *
 *  @param parameters
 *  @param success
 *  @param failure
 *
 *  @return taskID
 *  @notice. parameters需提供以下参数
 参数名        类型	是否可为空   含义      备注
 nickName	String	是         昵称
 sex        String	是         性别       UNKNOWN("未知性别"), MALE("男"), FEMALE("女")
 birthday	long	是         生日       毫秒表示的时间戳
 provinceId	int     是         所在地省份  用整形数字表示，如：1-表示北京
 cityId     int     是         所在地地市  用整形数字表示，结合province字段，如：1-表示北京的东城区
 avatar	    String	是         头像图片的URL
 */
+(NSUInteger)updateProfileWithParameters:(NSDictionary *)parameters
                                 success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFUserMTL *user))success
                                 failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  登录
 *
 *  @param usePassword  是否适用密码.
 *  @param user         用户名(暂定为手机号)
 *  @param password     密码
 *  @param refreshToken refreshToken
 *  @param success
 *  @param failure
 *
 *  @return taskId
 *  @notice 登录方式为usePassword时, user和password不可为空; 否则, refreshToken不可为空
 */
+ (NSUInteger)loginWithOption:(BOOL)usePassword
                         user:(NSString *)user
                     password:(NSString *)password
                 refreshToken:(NSString *)refreshToken
                      success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *refreshToken, NSString *accessToken, GFUserMTL * userInfo))success
                      failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  匿名登录
 *
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)anonymousLoginSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSString *refreshToken, NSString *accessToken))success
                            failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  退出登录
 *
 *  @param clientId 个推clientId
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)logoutWithGeTuiClientId:(NSString *)clientId
                              success:(void (^)(NSUInteger taskId, NSInteger code, NSString *refreshToken, NSString *accessToken))success
                              failure:(void (^)(NSUInteger taskId, NSError *error))failure;


#pragma mark - 修改
/**
 *  重置密码
 *
 *  @param mobile   电话号码
 *  @param token    token
 *  @param password 新密码
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)resetPassword:(NSString *)mobile
                      token:(NSString *)token
                   password:(NSString *)password
                    success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                    failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  修改密码
 *
 *  @param originPassword 原始密码
 *  @param password       新密码
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)changeOriginPassword:(NSString *)originPassword
                        toPassword:(NSString *)password
                           success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                           failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  是否共享位置
 *
 *  @param shareLocation 是否共享
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
//+ (NSUInteger)updateShareLocation:(BOOL)shareLocation
//                          success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
//                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  修改头像
 *
 *  @param avatarStoreKey 七牛返回的头像图片storeKey
 *  @param success
 *  @param failure
 *
 *  @return
 */
+ (NSUInteger)updateAvatar:(NSString *)avatarStoreKey
                   success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSString *avatarURL))success
                   failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  更新用户昵称(仅在用户昵称为空的情况下可以更新一次)
 *
 *  @param nickName 昵称
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)updateNickname:(NSString *)nickName
                     success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                     failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  更新出生日期
 *
 *  @param birthday 出生日期
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)updateBirthday:(NSDate *)birthday
                     success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                     failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  更新性别
 *
 *  @param gender  性别: "MALE" - 男 "FEMALE" - 女
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)updateGender:(GFUserGender)gender
                   success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                   failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  更新所在地
 *
 *  @param provinceId 省份id
 *  @param cityId     城市id
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)updateProvince:(NSNumber *)provinceId
                        city:(NSNumber *)cityId
                     success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                     failure:(void (^)(NSUInteger taskId, NSError *error))failure;

/**
 *  更新学校信息
 *
 *  @param collegeId    学校id
 *  @param departmentId 院系id
 *  @param enrollTime   入学时间
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)updateCollege:(NSNumber *)collegeId
                 department:(NSNumber *)departmentId
                 enrollTime:(NSDate *)enrollTime
                    success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                    failure:(void (^)(NSUInteger taskId, NSError *error))failure;
#pragma mark - 查询

/**
 *  查询用户信息
 *
 *  @param userID  用户ID
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryProfileForUser:(NSNumber *)userID
                          success:(void (^)(NSUInteger taskId, NSInteger code, GFProfileMTL * profileMTL))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;


/**
 *  查询高校信息
 *
 *  @param provinceID 省份id
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)queryCollegeWithProvinceID:(NSNumber *)provinceID
                                 success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, NSArray<GFCollegeMTL *> * colleges))success
                                 failure:(void (^)(NSUInteger taskId, NSError *error))failure;
#pragma mark - 反馈
/**
 *  用户反馈
 *
 *  @param content 反馈内容
 *  @param mobile  联系方式
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)addFeedbackContent:(NSString *)content
                          mobile:(NSString *)mobile
                         success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                         failure:(void (^)(NSUInteger taskId, NSError *error))failure;


/**
 *  用户选择兴趣
 *
 *  @param tagIdList 用户选择的兴趣的ID列表
 *  @param success
 *  @param failure
 *
 *  @return taskId
 */
+ (NSUInteger)addUserInterestTags: (NSArray<NSNumber *> *)tagIdList
                          success:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                          failure:(void (^)(NSUInteger taskId, NSError *error))failure;

// 获取用户的扩展信息（目前是推送设置相关)
+ (NSUInteger)queryMetaInfoSuccess:(void (^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage, GFMetaInfoMTL *metaInfo))success
                           failure:(void (^)(NSUInteger taskId, NSError *error))failure;
// 设置消息提醒开关
+ (NSUInteger)updateAcceptPushMessageSetting:(BOOL)accept
                                        type:(GFAcceptMessageType)type
                                     success:(void(^)(NSUInteger taskId, NSInteger code, NSString *apiErrorMessage))success
                                     failure:(void(^)(NSUInteger taskId, NSError *error))failure;
@end
