//
//  GFUserGuideFirstView.m
//  GetFun
//
//  Created by zhouxz on 15/12/14.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import "GFUserGuideFirstView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface GFUserGuideFirstView ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation GFUserGuideFirstView
- (MPMoviePlayerController *)moviePlayerController {
    if (!_moviePlayerController) {
        NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString* videoPath = [resourcePath stringByAppendingPathComponent:@"getfun.m4v"];
        _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        _moviePlayerController.view.frame = self.bounds;
        _moviePlayerController.view.backgroundColor = [UIColor clearColor];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
        _moviePlayerController.scalingMode = MPMovieScalingModeAspectFill;
        _moviePlayerController.shouldAutoplay = NO;
        [_moviePlayerController prepareToPlay];
    }
    return _moviePlayerController;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.moviePlayerController.view];
    }
    return self;
}

- (void)playVideo {
    [self.moviePlayerController play];
}

- (void)dealloc {
    [_moviePlayerController stop];
    [_moviePlayerController.view removeFromSuperview];
    _moviePlayerController = nil;
}
@end
