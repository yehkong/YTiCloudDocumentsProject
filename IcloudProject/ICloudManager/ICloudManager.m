//
//  ICloudManager.m
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/26.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import "ICloudManager.h"
#import "ICloudDocument.h"
#import "AppDelegate.h"


@interface ICloudManager()
{
    NSMetadataQuery *_metaQuery;
}
@end

@implementation ICloudManager

+(instancetype)shardiCloudManager
{
    static ICloudManager *imanager = nil;
    if (!imanager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            imanager = [[ICloudManager alloc]init];
        });
    }
    return imanager;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
        //initialize iCloud Documents Files Structure
    }
    
    return self;
}

-(void)loadiCloudDirectory
{
    [_metaQuery stopQuery];
    _metaQuery = nil;
    _metaQuery = [[NSMetadataQuery alloc]init];
    _metaQuery.searchScopes = @[NSMetadataQueryUbiquitousDataScope];
    _metaQuery.notificationBatchingInterval = 15;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    _metaQuery.operationQueue = queue;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gatherFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:_metaQuery];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gatherFinish:) name:NSMetadataQueryDidUpdateNotification object:_metaQuery];
    [_metaQuery startQuery];
}

-(void)gatherFinish:(NSNotification*)nofification
{
    NSMetadataQuery *query = nofification.object;
    [query disableUpdates];
    NSLog(@"------resultCount:%lu",query.resultCount);
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSMetadataQueryDidUpdateNotification object:query];
    if (query.resultCount > 0) {
        NSArray *result = query.results;
        NSMutableArray *datasource = [NSMutableArray array];
        for (NSMetadataItem *item in result) {
            NSDictionary *dic = [item valuesForAttributes:@[NSMetadataItemFSNameKey,NSMetadataItemURLKey,NSMetadataItemFSContentChangeDateKey,NSMetadataItemFSSizeKey,NSMetadataItemContentTypeKey]];
            [datasource addObject:dic];
        }
        if (self.delegate) {
            [self.delegate iCloudDatasourceUpdate:[datasource copy]];
        }
    }
    [query enableUpdates];
}

-(BOOL)creatFolderWithPath:(NSString *)fileName content:(NSData*)data
{
    __block BOOL suc = NO;
    //TODO:暂时只支持文本文件，后续完善
    NSURL *url = getDocumentUrlWithPath([fileName stringByAppendingString:@".txt"]);
    ICloudDocument *document = [[ICloudDocument alloc]initWithFileURL:url WithContent:data];
    [document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            suc = YES;
        }else{
            [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                suc = success;
            }];
        }
    }];
    [document closeWithCompletionHandler:^(BOOL success) {
        
    }];
    return suc;
    
}

@end
