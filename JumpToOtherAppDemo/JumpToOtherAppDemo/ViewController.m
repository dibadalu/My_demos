//
//  ViewController.m
//  JumpToOtherAppDemo
//
//  Created by 陈泽嘉 on 16/8/24.
//  Copyright © 2016年 dibadalu. All rights reserved.
//

#import "ViewController.h"

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

# pragma mark - action

- (IBAction)openSettingOptions:(id)sender {
    NSLog(@"跳转到设置选项");
    /*
     打开Wifi设置
     URL:prefs:root=WIFI
     打开蓝牙服务
     URL:prefs:root=Bluetooth
     */
    // 打开具体的设置选项
    NSURL *appURL = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL])
    {
        [[UIApplication sharedApplication] openURL:appURL];
    }
}


- (IBAction)openOtherApp:(id)sender {
    NSLog(@"跳转到宁波手机阅读");
    /*
     宁波手机阅读：
     https://itunes.apple.com/cn/app/ning-bo-shou-ji-yue-du/id590210090?mt=8
     GoetheBook
     */
    
    // 打开宁波手机阅读，需要先设置LSApplicationQueriesSchemes的白名单（具体看info.plist）
    NSURL *appURL = [NSURL URLWithString:@"GoetheBook://"]; // GoetheBook通过该应用的ipa获取得知
    if ([[UIApplication sharedApplication] canOpenURL:appURL])
    {
        [[UIApplication sharedApplication] openURL:appURL];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ning-bo-shou-ji-yue-du/id590210090?mt=8"]];
    }
    
}


- (IBAction)openOtherApp2:(id)sender {
    NSLog(@"跳转到我的天气");
    /*
     我的天气：
     https://itunes.apple.com/cn/app/wo-tian-qi-myweather-shi-ri/id1003715695?mt=8
     clover-myweather
     */
    
    // 需要先到info.plist中的LSApplicationQueriesSchemes中设置目标应用的白名单
    NSURL *appURL = [NSURL URLWithString:@"clover-myweather://"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL])
    {
        [[UIApplication sharedApplication] openURL:appURL];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/wo-tian-qi-myweather-shi-ri/id1003715695?mt=8"]];
    }
    
}

@end
