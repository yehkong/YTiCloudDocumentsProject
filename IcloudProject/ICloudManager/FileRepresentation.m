//
//  FileRepresentation.m
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/28.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import "FileRepresentation.h"

@implementation FileRepresentation

-(instancetype)init
{
    if (self = [self initWithUrl:nil]) {
    }
   return self;
}

-(instancetype)initWithUrl:(NSURL *)url
{
    if (self = [super init]) {
        _url = url;
    }
    return self;
}
@end

