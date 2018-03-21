//
//  FileRepresentation.h
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/28.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

/**
暂时未使用，代表某一文件
 */

#import <Foundation/Foundation.h>

@interface FileRepresentation : NSObject

@property (nonatomic, strong) NSURL *url;

-(instancetype)initWithUrl:(NSURL*)url NS_DESIGNATED_INITIALIZER;

@end
