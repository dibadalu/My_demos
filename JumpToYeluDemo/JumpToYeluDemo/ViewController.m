//
//  ViewController.m
//  JumpToYeluDemo
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


- (IBAction)jumpToYelu:(id)sender {
    NSURL *appURL = [NSURL URLWithString:@"yelu://"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL])
    {
        [[UIApplication sharedApplication] openURL:appURL];
    }
}

@end
