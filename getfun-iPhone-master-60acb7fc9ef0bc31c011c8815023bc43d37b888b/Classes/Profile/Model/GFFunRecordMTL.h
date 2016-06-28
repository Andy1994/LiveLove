//
//  GFFunRecordMTL.h
//  GetFun
//
//  Created by zhouxz on 15/12/10.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFUserMTL.h"
#import "GFCommentMTL.h"
#import "GFContentMTL.h"

/**
 *  fun操作的对象类型
 */
typedef NS_ENUM(NSInteger, GFFunType) {
    /**
     *  内容
     */
    GFFunTypeContent = 1,
    /**
     *  评论
     */
    GFFunTypeComment = 2
};
NSString *funTypeKey(GFFunType type);
GFFunType funType(NSString *key);

@interface GFFunRecordMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) GFFunType funType;
@property (nonatomic, strong) GFCommentMTL *extendComment;
@property (nonatomic, strong) GFContentMTL *content;

@end
