//
//  NativeAPIs.m
//  ObjcAndJSDemo
//
//  Created by 陈泽嘉 on 16/8/27.
//  Copyright © 2016年 dibadalu. All rights reserved.
//

#import "NativeAPIs.h"

@interface NativeAPIs () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation NativeAPIs

#pragma mark - NativeApisProtocol

- (void)callCamera{
    NSLog(@"调用系统相机");
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    picker.sourceType = sourceType;
    
    [self.vc presentViewController:picker animated:YES completion:^{
        NSLog(@"------------打开相机");
    }];
    
}

- (void)CallPhotoLibrary{
    NSLog(@"调用系统相册-----");
    
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = NO;
    
    [self.vc presentViewController:pickerImage animated:YES completion:^{
        NSLog(@"------------打开相册");
    }];
    
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

#pragma mark - UIImagePickerControllerDelegate

// 选中照片后该方法被调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"didFinishPickingMediaWithInfo");
    
    // 关闭UIImagePickerController控制器，并通过Block回调处理所拍照片
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"-------------在这里处理照片，上传到服务器或者直接显示到界面上");
        
        NSLog(@"\n info: %@", info);
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {// 来自相机
            NSLog(@"--------处理来自相机的照片");
            // 从info中取出照片的拍摄时间
            NSString *dateTimeStr;
            dateTimeStr = info[@"UIImagePickerControllerMediaMetadata"][@"{TIFF}"][@"DateTime"];
            dateTimeStr = [dateTimeStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            dateTimeStr = [dateTimeStr stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSLog(@"%@", dateTimeStr);
            
            // 获取info中的原始图片
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            //        NSLog(@"%@", image);
            
            /*-- 上传图片或保存到手机中 --*/
            
            // 将照片保存到手机
            NSString *imageName = [NSString stringWithFormat:@"%@.png", dateTimeStr];
            [self saveImage:image withName:imageName];
            
        }else{
            NSLog(@"--------处理来自相册的照片");
            
            // 获取info中的原始图片
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            /*-- 上传图片 --*/
        }

    }];
}

// 点击“取消”按钮时该方法被调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"imagePickerControllerDidCancel-----");
    [picker dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Custom method

// 保存图片
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName]; // 获取沙盒目录
    [imageData writeToFile:fullPath atomically:NO]; // 将图片写入文件
    
    //将选择的图片显示出来
    //    [self.photoImage setImage:[UIImage imageWithContentsOfFile:fullPath]];
    
    //将图片保存到disk
    UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil, nil);
}

@end

