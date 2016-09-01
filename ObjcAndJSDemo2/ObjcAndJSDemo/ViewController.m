//
//  ViewController.m
//  ObjcAndJSDemo
//
//  Created by 陈泽嘉 on 16/8/24.
//  Copyright © 2016年 dibadalu. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "NativeAPIs.h"

@interface ViewController () <UIWebViewDelegate>

@property (strong, nonatomic) JSContext *jsContext;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1. 设置webView的代理
    self.webView.delegate = self;
    
    // 2. 加载预置的html网页
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    NSURLRequest *urlReques = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlReques];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"网页加载完毕------");
    
    // 获取JS上下文运行环境
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NativeAPIs *nativeAPIs = [[NativeAPIs alloc] init];
    // 将NativeAPIs模型注入JS
    self.jsContext[@"NativeApis"] = nativeAPIs;
    nativeAPIs.jsContext = self.jsContext;
    nativeAPIs.vc = self;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息: %@", exceptionValue);
    };
}


@end

