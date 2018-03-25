# YTiCloudDocumentsProject
iCloud Documents应用项目，新建文件、导入文件到iCloud Documents中，删除iCloud Documens中文件，读取云端文件

序言：本文通过一个简单的项目工程的开发工作，浅谈一下iCloud开发。介绍博客地址：[iCloud开发案例](https://www.jianshu.com/p/20e1ebc585b6)
开发需求：把一些比较简单比较重要的文件保存在iCloud云盘中，以便在不同的iOS设备中共享使用。
集成开发过程：
* 1.  给工程配置iCloud capabilities:
> ![1.png](https://upload-images.jianshu.io/upload_images/2737326-dd57080261e14d10.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> 这里我勾选的是iCould Documents，另外还有两项Key-Value storage和CloudKit。其中Key-value storage是类似与userDefault一样，主要用于保存配置及状态。iCloud Documents主要用于保存文档文件等，CloudKit是苹果的一个框架,可以实现类似于数据库存储，可以在开发者中心配置CloudKit Dashboard，是后台中心。根据我们的需求，我们选择ICloud Documents进行开发。
这时候项目结构中会出现IcloudProject.entitlements文件，内容如下：
> ![2.png](https://upload-images.jianshu.io/upload_images/2737326-f9151a29dd3fbf5a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
从中了解到我们选择的Containers是Use default container,其indentifier是iCloud.+bundleid。当然我们也可以选择Specify custom containers，并且可以配置多个indentifier,代表多个container区域，每个Indentifier代表一个区域，类似于SandBox，用于保存文件。
* 2.  获取默认的根目录
我们要备份或者保存的文件就保存在这个文件夹或者其子文件夹下
```
//默认的icloud Documents容器的Indentifier
NSString * const ubiquityIndentifier = @"iCloud.com.0101.yetaiwen.IcloudProject";

//获取icloud Documents根文件夹或者子文件夹地址
NSURL* getDocumentUrlWithPath(NSString *path)
{
    NSURL *url = nil;
    url = [[NSFileManager defaultManager]URLForUbiquityContainerIdentifier:ubiquityIndentifier];
    NSLog(@"------url:%@",url);
    if (url && path) {
        url = [url URLByAppendingPathComponent:path];
        return url;
    }else if(!path) {
        return url;
    }else {
        NSLog(@"Please check out that iCloud had been signed in");
        return url;
    }
    return url;
}
```

* 3. 导入文件到iCloud账户中，及以上根目录下
```
    NSURL *url = getDocumentUrlWithPath(nil);
    for (NSString *documentName in self.documents)
    {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:documentName]
                                                toPath:[url.path stringByAppendingPathComponent:documentName]
                                                 error:nil];
    }
```
* 4. 通过简单封装的工具类去查询获取iCould账户下的文件列表
```
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
```
* 5.  在通知中获取到具体文件的信息并保存，以便在tableView中展示
```
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
```
* 5.  在打开iCoud文件时用到了UIDocument这个类，我们运用UIDocument的子类，并重写方法：
```
//写数据时，我们需要提供待写的Data
-(id)contentsForType:(NSString *)typeName error:(NSError * *)outError
{
    NSLog(@"---写---%@",typeName);
    return _fileData;
}
//读数据时，我们去处理系统返回的Data
-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError * *)outError
{
    NSLog(@"---读---%@",typeName);
    _fileData = contents;
    return YES;
}
```
> 从上面也可以看出，其实在线打开iCloud文件，其实是下载到了本地然后从本地打开文件。

PS：在iCloud使用过程中，iOS设备一定要登录了iCloud账号。否则，iCloud的存储路径返回为nil，无法完成相关的操作。

* 两种项目截图：
> ![4.png](https://upload-images.jianshu.io/upload_images/2737326-f56fa647ed3f0ed5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> ![3.png](https://upload-images.jianshu.io/upload_images/2737326-8f797433bac773cc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

