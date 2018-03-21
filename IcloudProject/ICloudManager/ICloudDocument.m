//
//  ICloudDocument.m
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/26.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import "ICloudDocument.h"

@interface ICloudDocument()

@end

@implementation ICloudDocument

-(instancetype)initWithFileURL:(NSURL *)url WithContent:(NSData *)kFileData
{
    if (self = [super initWithFileURL:url]) {
        _fileData = [kFileData copy];
    }
    return self;
}


#pragma mark - overwrite method

-(id)contentsForType:(NSString *)typeName error:(NSError * *)outError
{
    NSLog(@"---写---%@",typeName);
    return _fileData;
}

-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * *)outError
{
    NSLog(@"---读---%@",typeName);
    _fileData = contents;
    return YES;
}


@end
