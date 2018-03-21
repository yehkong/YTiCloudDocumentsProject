//
//  ICloudManager.h
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/26.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICloudManagerDelegate;

@interface ICloudManager : NSObject

@property(nonatomic, weak) id<ICloudManagerDelegate> delegate;

+(instancetype)shardiCloudManager;

/**
 加载iCloud Documents文件列表
 */
-(void)loadiCloudDirectory;

/**
 新建文件

 @param fileName 文件名称
 @param data 文件内容
 @return 是否新建成功
 */
-(BOOL)creatFolderWithPath:(NSString *)fileName content:(NSData*)data;

@end

@protocol ICloudManagerDelegate

@optional

-(void)iCloudDatasourceUpdate:(NSArray*)datasource;

@end

