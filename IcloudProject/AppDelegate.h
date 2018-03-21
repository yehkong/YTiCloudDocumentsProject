//
//  AppDelegate.h
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/25.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSURL* getDocumentUrlWithPath(NSString *path);
extern NSString * const ubiquityIndentifier;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

