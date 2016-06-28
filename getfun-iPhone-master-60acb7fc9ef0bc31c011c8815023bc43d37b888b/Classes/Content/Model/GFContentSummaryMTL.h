//
//  GFContentSummaryMTL.h
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "GFVoteItemMTL.h"

@interface GFContentSummaryMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *contentId;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) GFContentType type;

@end

@interface GFContentSummaryArticleMTL : GFContentSummaryMTL

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, strong) NSArray *pictureSummary;

@end

@interface GFContentSummaryVoteMTL : GFContentSummaryMTL
@property (nonatomic, strong)   NSArray<GFVoteItemMTL *> *voteItems;
@end

@interface GFContentSummaryLinkMTL : GFContentSummaryMTL

@property (nonatomic, copy)   NSString *url;
@property (nonatomic, copy)   NSString *urlTitle;
@property (nonatomic, copy)   NSString *urlSummary;
@property (nonatomic, copy)   NSString *urlImageUrl;
@property (nonatomic, assign) BOOL hasVideo;

@end

@interface GFContentSummaryPictureMTL : GFContentSummaryMTL

@property (nonatomic, copy) NSArray *pictureSummary;

@end