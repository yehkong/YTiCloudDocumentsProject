//
//  ICloudDocument.h
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/26.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ICloudDocument : UIDocument

@property(nonatomic, strong) NSData *fileData;//文件保存的数据

-(instancetype)initWithFileURL:(NSURL *)url WithContent:(NSData*)fileData;

@end
