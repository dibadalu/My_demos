//
//  ZXUploadImage.h
//  CallSystemCameraDemo
//
//  Created by 陈泽嘉 on 16/8/31.
//  Copyright © 2016年 dibadalu. All rights reserved.
//  原文链接：http://www.jianshu.com/p/afca53b2da74/comments/3937152#comment-3937152

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 把单例方法定义为宏，使用起来更方便
#define ZXUPLOAD_IMAGE [ZXUploadImage shareUploadImage]

// 声明一个委托协议
@protocol ZXUploadImageDelegate <NSObject>
@optional
- (void)uploadImageToServerWithImage:(UIImage *)image;
@end

@interface ZXUploadImage : NSObject < UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIViewController *_fatherViewController;
}

@property (nonatomic, weak) id <ZXUploadImageDelegate> uploadImageDelegate;

// 单例方法
+ (ZXUploadImage *)shareUploadImage;

// 弹出选项的方法
- (void)showActionSheetInFatherViewController:(UIViewController *)fatherVC
                                     delegate:(id<ZXUploadImageDelegate>)aDelegate;

@end
