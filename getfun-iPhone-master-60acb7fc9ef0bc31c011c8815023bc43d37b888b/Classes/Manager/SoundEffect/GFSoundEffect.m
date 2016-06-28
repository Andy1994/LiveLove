//
//  GFSoundEffect.m
//  GetFun
//
//  Created by zhouxiangzhong on 16/2/6.
//  Copyright © 2016年 17GetFun. All rights reserved.
//

#import "GFSoundEffect.h"
#import <AVFoundation/AVFoundation.h>

@interface GFSoundEffect ()

+ (instancetype)soundEffect;

@end

@implementation GFSoundEffect
+ (instancetype)soundEffect {
    static GFSoundEffect *soundEffect;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        soundEffect = [[GFSoundEffect alloc] init];
    });
    return soundEffect;
}

+ (void)playSoundEffect:(GFSoundEffectType)type {
    [[GFSoundEffect soundEffect] doPlaySoundType:type];
}

- (void)doPlaySoundType:(GFSoundEffectType)type {
    
    NSURL *soundFile = nil;
    switch (type) {
        case GFSoundEffectTypePublish: {
            soundFile = [[NSBundle mainBundle] URLForResource:@"publish" withExtension:@"wav"];
            break;
        }
        case GFSoundEffectTypeSuccess: {
            soundFile = [[NSBundle mainBundle] URLForResource:@"success" withExtension:@"wav"];
            break;
        }
        case GFSoundEffectTypeMessage: {
            soundFile = [[NSBundle mainBundle] URLForResource:@"getfunNotification" withExtension:@"wav"];
            break;
        }
        case GFSoundEffectTypeFun: {
            soundFile = [[NSBundle mainBundle] URLForResource:@"fun" withExtension:@"wav"];
            break;
        }
            
        default:
            break;
    }
    
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundFile), &soundID);
    AudioServicesPlaySystemSound(soundID);
}
@end
