//
//  ViewController.m
//  CallSystemFuncDemo
//
//  Created by 陈泽嘉 on 16/8/31.
//  Copyright © 2016年 dibadalu. All rights reserved.
//  参考链接：http://blog.csdn.net/u011918080/article/details/19404737

#import "ViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  - Action method

- (IBAction)callSystemCamera:(id)sender {
    NSLog(@"调用系统相机-----------");
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera; // 设置类型为相机
        //picker.showsCameraControls = NO;// 默认为YES
        picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//选择前置摄像头或后置摄像头
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
    else {
        NSLog(@"该设备无相机");
    }
}

- (IBAction)callSystemPhotoLibrary:(id)sender {
    NSLog(@"调用系统相册--------");
    
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = NO;
    [self presentViewController:pickerImage animated:YES completion:^{
    }];
    
}


#pragma mark - UIImagePickerControllerDelegate

// 选中照片后该方法被调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"didFinishPickingMediaWithInfo");
    
    __weak typeof(self) weakSelf = self;
    // 关闭UIImagePickerController控制器，并通过Block回调处理所拍照片
    [picker dismissViewControllerAnimated:YES completion:^{
        // 来自相机
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            NSLog(@"%@",info);
            
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
            [weakSelf saveImage:image withName:imageName];
        }
        
    }];
    
}

// 点击“取消”按钮时该方法被调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel-----");
    // 关闭UIImagePickerController控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
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
