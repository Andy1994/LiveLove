//
//  GFContentDetailMTL.h
//  GetFun
//
//  Created by muhuaxin on 15/11/21.
//  Copyright © 2015年 17GetFun. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface GFContentDetailMTL : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *contentId;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *content; //对于图帖，Feed流使用title作为标题，详情页使用content作为标题
@property (nonatomic, assign) GFContentType type;

@end

@interface GFContentDetailArticleMTL : GFContentDetailMTL

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *summary;

@end

@interface GFContentDetailPictureMTL : GFContentDetailMTL

@property (nonatomic, strong) NSArray *pictureSummary;

@end

@interface GFContentDetailVoteMTL : GFContentDetailMTL

@property (nonatomic, copy)   NSString *imageUrl;
@property (nonatomic, strong) NSNumber *startTime;
@property (nonatomic, strong) NSNumber *endTime;
@property (nonatomic, strong) NSNumber *peopleLimited;
@property (nonatomic, strong) NSNumber *peopleInvolved;
@property (nonatomic, strong)   NSArray *voteItems;

@end


@interface GFContentDetailLinkMTL : GFContentDetailMTL

@property (nonatomic, copy)   NSString *url;
@property (nonatomic, copy)   NSString *urlTitle;
@property (nonatomic, copy)   NSString *urlImageUrl;
@property (nonatomic, copy)   NSString *urlContent;
@property (nonatomic, copy)   NSString *urlSummary;
@property (nonatomic, copy)   NSString *domainName;

@end
