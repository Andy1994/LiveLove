//
//  NSString+Getfun.h
//  getfun
//
//  Created by zhouxz on 15/11/11.
//  Copyright © 2015年 getfun. All rights reservedh.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GFValidateType) {
    GFValidateTypePhoneNumber,  // 合法手机号码
    GFValidateTypeNickName,     // 昵称，由数字、26个英文字母或者下划线组成的字符串
    GFValidateTypePassword,     // 密码:密码至少为6-16个字符且不含空格
    GFValidateTypeEmail,        // Email
    GFValidateTypeURL,          // URL
    GFValidateTypeNumber,       // 纯数字
    GFValidateTypeCharacter     // 字符类型
};

typedef NS_ENUM(NSUInteger, GFImageProcessMode) {
    GFImageProcessModeMaxLongEdgeAdaptiveShortEdgeAspect, //限定缩略图的长边最大值，短边自适应，等比缩放不裁剪，只有第一个参数有效
    GFImageProcessModeAdaptiveLongEdgeMaxShortEdgeAspect, //限定缩略图的短边最大值，长边自适应，等比缩放不裁剪，只有第二个参数有效
    GFImageProcessModeMaxLongEdgeMaxShortEdgeAspect,//限定缩略图的长边和短边最大值，等比缩放不裁剪，两个参数均有效
    
    GFImageProcessModeMinWidthMinHeightCut, //限定缩略图的长边和短边最小值，等比缩放，居中裁剪，两个参数均有效
    GFImageProcessModeMinEqualWHCut,//限定缩略图的宽高最小值，且二者值相等。等比缩放，居中裁剪，只有第一个参数有效
    
    GFImageProcessModeMaxWidthAdaptiveHeightAspect, //限定缩略图的宽最大值，高自适应，等比缩放不裁剪，只有第一个参数有效
    GFImageProcessModeAdaptiveWidthMaxHeightAspect, //限定缩略图的高最大值，宽自适应，等比缩放不裁剪，只有第二个参数有效
    GFImageProcessModeMaxWidthMaxHeightAspect,//限定缩略图的宽和高最大值，等比缩放不裁剪，两个参数均有效
    
    GFImageProcessModeMinWidthMinHeightAspect, //限定缩略图的宽和高最小值，等比缩放不裁剪
    GFImageProcessModeMinEqualWidthHeightAspect, //限定缩略图的宽高的最小值，且二者相等，等比缩放不裁剪，只有第一个参数有效
    
    GFImageProcessModeMinLongEdgeMinShortEdgeAspect, //限定缩略图的长边和短边最小值，等比缩放不裁剪
    GFImageProcessModeMinEqualEdgeAspect, //限定缩略图的短边和长边的最小值，且二者相等，等比缩放不裁剪，只有第一个参数有效
    
    GFImageProcessModeMinLongEdgeMinShortEdgeCut, //限定缩略图的长边和短边最小值，等比缩放，居中裁剪
    GFImageProcessModeMinEqualEdgeCut, //限定缩略图的短边和长边限定最小值，且二者相等，等比缩放，居中裁剪，只有第一个参数有效
};

/**
 *  不同情况下图片规范标准
 */
typedef NS_ENUM(NSUInteger, GFImageStandardizedType) {
    /**
     *  feed流一张图片
     */
    GFImageStandardizedTypeFeedOnePicture,
    /**
     *  feed流两张图片
     */
    GFImageStandardizedTypeFeedTwoPictures,
    /**
     *  feed流三张及以上图片
     */
    GFImageStandardizedTypeFeedThreePictures,
    /**
     *  投票视图（feed流和详情页）
     */
    GFImageStandardizedTypeVote,
    /**
     *  feed流链接帖
     */
    GFImageStandardizedTypeFeedLink,
    /**
     *  评论下feed流
     */
    GFImageStandardizedTypeFeedComment,
    /**
     *  Fun下的feed流
     */
    GFImageStandardizedTypeFeedFun,
    
    
    /**
     * feed流头像
     */
    GFImageStandardizedTypeAvatarFeed,
    /**
     *  个人页头像
     */
    GFImageStandardizedTypeAvatarProfile,
    /**
     *  消息中心头像
     */
    GFImageStandardizedTypeAvatarMessage,
    /**
     *  粉丝关注列表头像
     */
    GFImageStandardizedTypeAvatarFollower,
    /**
     *  Get帮头像
     */
    GFImageStandardizedTypeAvatarGroup,
    
    /**
     *  收藏标签图
     */
    GFImageStandardizedTypeCollectedTag,
    /**
     *  收藏标签列表
     */
    GFImageStandardizedTypeCollectedTagList,
    /**
     *  热门标签图
     */
    GFImageStandardizedTypeHotTag,
    
    /**
     *  图文详情页
     */
    GFImageStandardizedTypeContentDetailArticle,
    /**
     *  图帖详情页
     */
    GFImageStandardizedTypeContentDetailPicture,
    
    /**
     *  大图查看
     */
    GFImageStandardizedTypeLargePicuture,
};

/**
 *  NSString自定义类别
 */
@interface NSString (Getfun)

- (BOOL)gf_isValidType:(GFValidateType)type;

/**
 *  根据不同模式从七牛获取指定宽高或者长短边的图片
 *
 *  @param w    宽或长边
 *  @param h    高或短边
 *  @param mode 图片处理模式
 *
 *  @return 处理后的url字符串
 */
- (NSString *)gf_urlAppendWithHorizontalEdge:(NSUInteger)w verticalEdge:(NSUInteger)h mode:(GFImageProcessMode)mode;

- (NSString *)gf_urlAppendWithHorizontalEdge:(NSUInteger)w verticalEdge:(NSUInteger)h mode:(GFImageProcessMode)mode convertGIF:(BOOL)convert;

/**
 *  图片裁剪规范
 *
 *  @param w              宽
 *  @param h              高
 *  @param type           规范类型
 *  @param isGifConverted gif是否转成jpg
 *
 *  @return 规范标准化且可以被直接转为url的字符串
 */
- (NSString *)gf_urlStandardizedWithType:(GFImageStandardizedType)type gifConverted:(BOOL)isGifConverted;


/** 
 *  取第一个符合正则的子串
 *
 *  @param pattern 正则表达式
 *
 *  @return 子串
 */
- (NSString *)subStringWithPattern:(NSString *)pattern;

/*
 *  根据字符串返回对应的分享类型
 *
 *  @return
 */
- (GFShareType)gf_shareType;

- (NSDictionary *)urlQueryToDictionary;

@end
