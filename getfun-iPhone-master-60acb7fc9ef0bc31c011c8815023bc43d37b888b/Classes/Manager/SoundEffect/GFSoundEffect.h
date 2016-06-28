//
//  GFSoundEffect.h
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GFSoundEffectType) {
    GFSoundEffectTypePublish = 0, //点击发布按钮
    GFSoundEffectTypeSuccess = 1, //刷新成功
    GFSoundEffectTypeMessage = 2, //消息通知
    GFSoundEffectTypeFun = 3, //点击Fun按钮
};

@interface GFSoundEffect : NSObject

+ (void)playSoundEffect:(GFSoundEffectType)type;

@end
