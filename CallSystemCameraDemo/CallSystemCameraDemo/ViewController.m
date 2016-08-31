//
//  ViewController.m
//  CallSystemCameraDemo
//
//  Created by 陈泽嘉 on 16/8/31.
//  Copyright © 2016年 dibadalu. All rights reserved.
//

#import "ViewController.h"
#import "ZXUploadImage.h"

@interface ViewController ()

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

#pragma mark - Action method

- (IBAction)buttonOnClick:(id)sender {
     [ZXUPLOAD_IMAGE showActionSheetInFatherViewController:self delegate:self];
}


#pragma mark - ZXUploadImageDelegate

- (void)uploadImageToServerWithImage:(UIImage *)image {
    //在这里处理得到的image
    NSLog(@"uploadImageToServerWithImage---%@", image);
}

@end
