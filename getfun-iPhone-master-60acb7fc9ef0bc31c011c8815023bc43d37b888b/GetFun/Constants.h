//
//  Constants.h
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#import <UIKit/UIKit.h>
#import <CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelAll;
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

static NSString *kGetfunAppID = @"1064353190";

static const NSInteger kQueryDataCount = 20;
static const NSInteger kQueryHomeDataCount = 6;
static const NSTimeInterval kCommonHudDuration = 1.0f;

// 性别
typedef NS_ENUM(NSInteger, GFUserGender) {
    GFUserGenderUnknown    = 0,
    GFUserGenderMale       = 1,
    GFUserGenderFemale     = 2
};
NSString *userGenderKey(GFUserGender gender);
GFUserGender userGender(NSString *key);

typedef NS_ENUM(NSInteger, GFPictureFormat) {
    GFPictureFormatUnknown = 0,
    GFPictureFormatJPEG = 1,
    GFPictureFormatGIF = 2,
    GFPictureFormatPNG = 3
};
NSString *unifiedFormatKey(NSString *key);
NSString *pictureFormatKey(GFPictureFormat format);
GFPictureFormat pictureFormat(NSString *key);

// 帖子类型
// 之前的版本对内容数据有缓存，这里的值绝对不可以修改，否则会导致内容类型解析混乱!
typedef NS_ENUM(NSUInteger, GFContentType) {
    GFContentTypeUnknown = 1,
    GFContentTypeArticle = 2,
    GFContentTypeVote = 3,
    GFContentTypeLink = 4,
    GFContentTypePicture = 5,
    GFContentTypeTag = 6
};
NSString * contentTypeKey(GFContentType type);
GFContentType contentType(NSString *key);

// 帖子状态
typedef NS_ENUM(NSUInteger, GFContentStatus) {
    GFContentStatusUnknown = 0, // 未知
    GFContentStatusPoor = 1, //未审核或水帖
    GFContentStatusNormal = 2, //内容正常
    GFContentStatusRefused = 3, //内容审核未通过
    GFContentStatusDeleted = 4, //内容已被用户删除
};
NSString *contentStatusKey(GFContentStatus status);
GFContentStatus contentStatus(NSString *key);

//Get帮审核状态
typedef NS_ENUM(NSUInteger, GFGroupAuditStatus) {
    GFGroupAuditStatusUnknown = 0, //未知
    GFGroupAuditStatusAuditing = 1, //未审核
    GFGroupAuditStatusPass = 2, //审核通过
    GFGroupAuditStatusRefuse = 3, //
    GFGroupAuditStatusRefuseName = 4, //名称不合法
    GFGroupAuditStatusRefuseImg = 5, //头像不合法
    GFGroupAuditStatusRefuseDescription = 6, //描述不合法
};
NSString *groupAuditStatusKey(GFGroupAuditStatus status);
GFGroupAuditStatus groupAuditStatus(NSString *key);

typedef NS_ENUM(NSUInteger, GFUserAction) {
    GFUserActionUnknown = 0,
    GFUserActionPublish = 1,
    GFUserActionCheckin = 2,
};
NSString *userActionKey(GFUserAction action);
GFUserAction userAction(NSString *key);

/**
 *  消息
 */

// 基本消息类型
typedef NS_ENUM(NSUInteger, GFBasicMessageType) {
    GFBasicMessageTypeUnknown       = 0,
    GFBasicMessageTypeAudit         = 0x10, // 审核相关消息
    GFBasicMessageTypeComment       = 0x20, // 评论相关消息
    GFBasicMessageTypeFun           = 0x30, // Fun相关消息
    GFBasicMessageTypeParticipate   = 0x40, // 参与相关消息(目前就是投票贴相关)
    
    GFBasicMessageTypeActivity      = 0x50, // 活动
    GFBasicMessageTypeNotify        = 0x60, // 通知
    GFBasicMessageTypeFollow        = 0x70, // 有人关注
};
NSString * basicMessageTypeKey(GFBasicMessageType type);
GFBasicMessageType basicMessageType(NSString *key);

// 具体消息类型
typedef NS_ENUM(NSUInteger, GFMessageType) {
    GFMessageTypeUnknown        = GFBasicMessageTypeUnknown,
    GFMessageTypeAuditUser      = GFBasicMessageTypeAudit + 0x01,       // 审核用户
    GFMessageTypeAuditContent   = GFBasicMessageTypeAudit + 0x02,       // 审核帖子
    GFMessageTypeAuditComment   = GFBasicMessageTypeAudit + 0x03,       // 审核评论
    GFMessageTypeAuditGroup     = GFBasicMessageTypeAudit + 0x04,       // 审核Get帮
    GFMessageTypeComment        = GFBasicMessageTypeComment + 0x01,     // 评论帖子
    GFMessageTypeCommentReply   = GFBasicMessageTypeComment + 0x02,     // 回复评论
    GFMessageTypeFunContent     = GFBasicMessageTypeFun + 0x01,         // fun帖子
    GFMessageTypeFunComment     = GFBasicMessageTypeFun + 0x02,         // fun评论
    GFMessageTypeParticipate    = GFBasicMessageTypeParticipate + 0x01, // 参与(目前就是投票贴相关)
    GFMessageTypeFollow         = GFBasicMessageTypeFollow + 0x01,      // 有人关注
    GFMessageTypeActivity       = GFBasicMessageTypeActivity + 0x01,    // 活动
    GFMessageTypeNotify         = GFBasicMessageTypeNotify + 0x01,      // 通知
};
NSString * messageTypeKey(GFMessageType type);
GFMessageType messageType(NSString *key);

// 分享类型
typedef NS_ENUM(NSUInteger, GFShareType) {
    GFShareTypeQQ = 1,          // QQ好友QQ群
    GFShareTypeQZone = 2,       // QZone
    GFShareTypeWeChat = 3,      // 微信
    GFShareTypeTimeline = 4,    // 微信朋友圈
    GFShareTypeWeibo = 5,       // 新浪微博
};

// 账户类型. 在联合登录、用户信息以及accountmanager中使用
typedef NS_ENUM(NSUInteger, GFLoginType) {
    GFLoginTypeNone = 0,        // 未登录
    GFLoginTypeAnonymous = 1,   // 设备号匿名登录
    GFLoginTypeMobile = 2,      // 手机号+密码登录(用户名密码)
    GFLoginTypeWechat = 3,      // 微信登录
    GFLoginTypeQQ = 4,          // QQ登录
    GFLoginTypeWeiBo = 5        // 新浪微博登录
};

//当前用户和其它用户之间的关注关系
typedef NS_ENUM(NSUInteger, GFFollowState) {
    GFFollowStateNo = 1, //当前用户不关注Ta
    GFFollowStateFollowing = 2, //当前用户关注Ta，Ta不关注当前用户
    GFFollowStateFollowingEachOther = 3 //当前用户和Ta互相关注
};

// 设置是否启用消息通知的开关
typedef NS_ENUM(NSUInteger, GFAcceptMessageType) {
    GFAcceptMessageTypeSound        = 1 << 0,   // 声音音效开关
    GFAcceptMessageTypeContent      = 1 << 1,   // 精彩内容推送开关
    GFAcceptMessageTypeComment      = 1 << 2,   // 回复评论提醒开关
    GFAcceptMessageTypeFun          = 1 << 3,   // FUN提醒开关
    GFAcceptMessageTypeParticipate  = 1 << 4,   // 参与提醒开关(目前就是投票贴)
    GFAcceptMessageTypeNotify       = 1 << 5    // 系统通知开关
};
NSString * acceptMessageTypeKey(GFAcceptMessageType type);
GFAcceptMessageType acceptMessageType(NSString *key);

// GFContentMTL -> actionStatus:NSDictionary的key
extern NSString * const GFContentMTLActionStatusesKeyCollect;
extern NSString * const GFContentMTLActionStatusesKeyPublish;
extern NSString * const GFContentMTLActionStatusesKeySpecial;
extern NSString * const GFContentMTLActionStatusesKeyInit;
extern NSString * const GFContentMTLActionStatusesKeyFun;
extern NSString * const GFContentMTLActionStatusesKeyShare;
extern NSString * const GFContentMTLActionStatusesKeyComment;
extern NSString * const GFContentMTLActionStatusesKeyForward;
extern NSString * const GFContentMTLActionStatusesKeyView;
extern NSString * const GFContentMTLActionStatusesKeyCheckin;

// GETFUN协议前缀定义
extern NSString * const GFGetfunRedirectLogin;            // 登录
extern NSString * const GFGetfunRedirectPreview;          // 预览
extern NSString * const GFGetfunRedirectDetail;           // 详情页
extern NSString * const GFGetfunRedirectGroup;            // get帮
extern NSString * const GFGetfunRedirectUser;             // 用户
extern NSString * const GFGetfunRedirectTag;              // 标签页面
extern NSString * const GFGetfunRedirectHome;             // 回到首页
extern NSString * const GFGetfunRedirectShare;            // 分享 getfun://share?title=xxx&shortTitle=xxx&desc=xxx&img=xxx&url=xxx

/**
 *  NSUserDefaults
 */
extern NSString * const GFUserDefaultsKeyForbiddenAutoLocatingWhenPublish;  // 发布时是否禁止自动获取地理位置
extern NSString * const GFUserDefaultsKeyGetfunIdentifierForVendor;         // getfun IDFV
extern NSString * const GFUserDefaultsKeyLastLaunchVersionForUserGuide;     // 上次运行时的app版本，用于确定是否显示用户引导页
extern NSString * const GFUserDefaultsKeyLastLaunchBuildForUserGuide;       // 同上。存储的是build号
extern NSString * const GFUserDefaultsKeyLoginType;                         // 当前登录用户的登录类型
extern NSString * const GFUserDefaultsKeyRefreshToken;                      // refresh token
extern NSString * const GFUserDefaultsKeyAccessToken;                       // access token
extern NSString * const GFUserDefaultsKeyLoginUserInfo;                     // 登录用户信息
extern NSString * const GFUserDefaultsKeyPublishArticleDraft;   // 发布的图文草稿
extern NSString * const GFUserDefaultsKeyPublishLinkDraft;      // 发布的链接草稿
extern NSString * const GFUserDefaultsKeyPublishVoteDraft;      // 发布的投票草稿
extern NSString * const GFUserDefaultsKeyPublishPictureDraft;   // 发布的图帖草稿
extern NSString * const GFUserDefaultsKeyMetaInfo;              // 用户扩展信息

extern NSString * const GFUserDefaultsKeyFeedAdQueryTime;   // 首页Feed流广告的获取时间
extern NSString * const GFUserDefaultsKeyFeedAdData;        // 首页Feed流广告数据

extern NSString * const GFUserDefaultsKeyReviewData;        // 用户评星数据
extern NSString * const GFUserDefaultsKeyInterestSelected;  // 标识用户是否已经选择兴趣

extern NSString * const GFUserDefaultsKeyShouldHidePictureBadge; // 标识用户是否已经选择发图片

/**
 *  third platform
 */
extern NSString * const kRedirectURI;       // 重定向URI
extern NSString * const kWXAppId;           // 微信 AppId
extern NSString * const kWXAppSecret;       // 微信 AppSecret
extern NSString * const kTencentAppId;      // QQ AppId
extern NSString * const kTencentAppKey;     // QQ AppKey
extern NSString * const kWeiboAppKey;       // 新浪微博 AppKey
extern NSString * const kWeiboAppSecret;    // 新浪微博 AppSecret
extern NSString * const kUMengAppKey;       // 友盟统计
extern NSString * const kAMapApiKey;        // 高德地图api key
extern NSString * const kGeTuiAppId;        // 个推AppId
extern NSString * const kGeTuiAppKey;       // 个推AppKey
extern NSString * const kGeTuiAppSecret;    // 个推AppSecret

/**
 *  notification
 */
// 定位
extern NSString * const GFNotificationLocationUpdated;          // 定位更新
// 发布
extern NSString * const GFNotificationPublishStateUpdate;       // 发布状态更新
extern NSString * const kPublishNotificationUserInfoKeyData;    // 发布消息通知中userInfo的key : data
extern NSString * const kPublishNotificationUserInfoKeyMsg;     // 发布消息通知中userInfo的key : msg
extern NSString * const kPublishNotificationUserInfoKeyOrigin;

// 消息系统
// 收到了新消息
extern NSString * const GFNotificationDidReceiveMessage;
// 删除了消息
extern NSString * const GFNotificationDidMessageDeleted;
// 消息已读状态改变
extern NSString * const GFNotificationDidMessageStatusChanged;
// 消息数据
extern NSString * const kMessageNotificationUserInfoKeyMsg;


// 账户
extern NSString * const GFNotificationLoginUserChanged;         // 用户退出登录、新用户登录
extern NSString * const GFNotificationAccessTokenChanged;       // access token变化

#endif /* Constants_h */
