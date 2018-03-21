//
//  ICloudFileListController.m
//  IcloudProject
//
//  Created by yetaiwen on 2018/2/26.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import "ICloudFileListController.h"
#import "ICloudManager.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuickLook/QuickLook.h>

#define CloudManager [ICloudManager shardiCloudManager]

@interface ICloudFileListController ()<UITableViewDelegate,UITableViewDataSource,ICloudManagerDelegate,QLPreviewControllerDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *fileList;//iCloud Documents文件列表

@property (nonatomic, strong) NSArray *documents;//导入文件

@property (nonatomic, strong) NSURL *fileUrl;//预览的文件

@end

@implementation ICloudFileListController

#pragma mark - ViewController Metrod

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setToolbarHidden:NO];
    
    UIBarButtonItem *creatItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createFile:)];
    UIBarButtonItem *importItem = [[UIBarButtonItem alloc]initWithTitle:@"导入" style:UIBarButtonItemStylePlain target:self action:@selector(importAction:)];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashFile:)];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[creatItem,spaceItem,importItem,spaceItem,deleteItem];
    
    [CloudManager loadiCloudDirectory];
    CloudManager.delegate = self;
    
    _documents = @[@"Text Document1.txt",
                   @"Text Document2.txt",
                   @"Text Document3.txt",
                   @"Text Document4.rtf",
                   @"Image Document.jpg",
                   @"PDF Document.pdf",
                   @"HTML Document.html",
                   @"Video.m4v"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Method

/**
 新建文件(暂时支持txt文件，后续完善)
 */
- (void)createFile:(UIBarButtonItem*)sender
{
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"输入文件名" message:@"目前只支持文本文件,后续完善" preferredStyle:UIAlertControllerStyleAlert];
    [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入文件名称";
    }];
    [alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入文件内容";
    }];
    [alertCtl addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self controlBarBtnsEnable:NO];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:indicatorView];
        indicatorView.center = self.view.center;
        [indicatorView startAnimating];
        NSString *name = alertCtl.textFields.firstObject.text;
        NSString *content = alertCtl.textFields.lastObject.text;
        [CloudManager creatFolderWithPath:name content:[content dataUsingEncoding:NSUTF8StringEncoding]];
        //FIXME:待优化
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [CloudManager loadiCloudDirectory];
            [indicatorView stopAnimating];
            [self controlBarBtnsEnable:YES];
        });
        
    }]];
    [self presentViewController:alertCtl animated:YES completion:nil];
    
}

/**
 导入文件
 */
- (void)importAction:(UIBarButtonItem*)sender
{
    [self controlBarBtnsEnable:NO];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:indicatorView];
    indicatorView.center = self.view.center;
    [indicatorView startAnimating];
    
    NSURL *url = getDocumentUrlWithPath(nil);
    for (NSString *documentName in self.documents)
    {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:documentName]
                                                toPath:[url.path stringByAppendingPathComponent:documentName]
                                                 error:nil];
    }
    //FIXME:待优化
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CloudManager loadiCloudDirectory];
        [indicatorView stopAnimating];
        
        [self controlBarBtnsEnable:YES];
    });
}

/**
 删除文件
 */
- (void)trashFile:(UIBarButtonItem*)sender
{
    [self controlBarBtnsEnable:NO];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:indicatorView];
    indicatorView.center = self.view.center;
    [indicatorView startAnimating];
    
    NSURL *url = getDocumentUrlWithPath(nil);
    for (NSString *documentName in self.documents)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[url.path stringByAppendingPathComponent:documentName] error:nil];
    }
    //FIXME:待优化
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CloudManager loadiCloudDirectory];
        
        [indicatorView stopAnimating];
        [self controlBarBtnsEnable:YES];
    });
    
}


- (void)controlBarBtnsEnable:(BOOL)enable
{
    for (UIBarButtonItem *item in self.toolbarItems) {
        item.enabled = enable;
    }
}

#pragma mark - tableView datasource & delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dic = self.fileList[indexPath.row];
    cell.textLabel.text= [dic objectForKey:NSMetadataItemFSNameKey];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = self.fileList[indexPath.row];
    _fileUrl = [info objectForKey:NSMetadataItemURLKey];
    NSString *fileFormat = _fileUrl.pathExtension.uppercaseString;
    NSLog(@"%@",[info objectForKey:NSMetadataItemContentTypeKey]);
    [self openFileWithExtension:fileFormat];
}

/**
 预览文件

 @param extension 文件扩展名
 */
-(void)openFileWithExtension:(NSString*)extension
{
    if ([QLPreviewController canPreviewItem:_fileUrl]) {
        QLPreviewController *preview = [[QLPreviewController alloc]init];
        preview.dataSource = self;
        [self presentViewController:preview animated:YES completion:nil];
    }else if ([@[@"MP4",@"MOV",@"M4V"] containsObject:extension]) {
            MPMoviePlayerViewController* Mpplayer = [[MPMoviePlayerViewController alloc]initWithContentURL:_fileUrl];
            [self presentViewController:Mpplayer animated:YES completion:nil];
    }else{
        NSLog(@"展示不支持,后续完善");
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - ICloudManagerDelegate Method

-(void)iCloudDatasourceUpdate:(NSArray *)datasource
{
    [self.fileList removeAllObjects];
    if (!self.fileList) {
        self.fileList = [[NSMutableArray alloc]initWithArray:datasource];
    }else{
        [self.fileList addObjectsFromArray:datasource];
    }
    [self.tableView reloadData];
}

#pragma mark - QLPreviewControllerDataSource Method

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return _fileUrl;
}

@end
