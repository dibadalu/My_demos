//
//  NativeAPIs.m
//  ObjcAndJSDemo
//
//  Created by 陈泽嘉 on 16/8/27.
//  Copyright © 2016年 dibadalu. All rights reserved.
//

#import "NativeAPIs.h"

@implementation NativeAPIs

#pragma mark - NativeApisProtocol

- (void)callCamera{
    NSLog(@"调用系统相机");
    
    /*----此处省略调用系统相机拍照并得到照片的过程---*/
    
    // 得到一张名为20160824_photo.jpg的照片后，回调js的函数picCallback，将图片传到web端
    
    JSValue *picCallback = self.jsContext[@"picCallback"];
    [picCallback callWithArguments:@[@"20160824_photo.jpg"]];
    
}

- (void)share:(NSString *)shareInfo{
    NSLog(@"shareInfo: %@", shareInfo);
    
    /*----此处省略调用系统分享的过程---*/
    
    // 分享成功后，回调js的函数shareCallback
    
    JSValue *shareCallback = self.jsContext[@"shareCallback"];
    [shareCallback callWithArguments:nil];
    
}

- (void)openNBPhoneReader{
    // 打开宁波手机阅读，需要先设置LSApplicationQueriesSchemes的白名单（具体看info.plist）
    NSURL *appURL = [NSURL URLWithString:@"GoetheBook://"]; // GoetheBook通过该应用的ipa获取得知
    if ([[UIApplication sharedApplication] canOpenURL:appURL])
    {
        [[UIApplication sharedApplication] openURL:appURL];
    }else{
        // 主线程执行
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示下载" message:@"下载宁波手机阅读？" delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"确定", nil];
            [alertView show];
        });
    }
}

#pragma mark - alertView delegate

//根据被点击按钮的索引处理点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clickButtonAtIndex:%ld", (long)buttonIndex);
    if(buttonIndex == 0){
        NSLog(@"取消------");
        return;
    }else if(buttonIndex == 1){
        NSLog(@"确定------");
        // 添加延迟操作，消除警告
        dispatch_after(0.2, dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ning-bo-shou-ji-yue-du/id590210090?mt=8"]];
        });
    }
}

@end



/*
 // 适用于iOS9之后的alertView
 
 // 主线程执行
 dispatch_async(dispatch_get_main_queue(), ^{
 // 创建提示框
 UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示下载" message:@"下载宁波手机阅读？" preferredStyle:UIAlertControllerStyleAlert];
 
 UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 NSLog(@"确定------");
 // 添加延迟操作，消除警告
 dispatch_after(0.2, dispatch_get_main_queue(), ^{
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ning-bo-shou-ji-yue-du/id590210090?mt=8"]];
 });
 
 }];
 UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * __nonnull action) {
 NSLog(@"取消------");
 }];
 [alertVc addAction:action1];
 [alertVc addAction:action2];
 
 [self presentViewController:alertVc animated:YES completion:nil];
 
 });
 */

