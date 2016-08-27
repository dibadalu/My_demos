//
//  ViewController.m
//  Objc&jsDemo
//
//  Created by 陈泽嘉 on 16/8/26.
//  Copyright © 2016年 dibadalu. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(weak, nonatomic) JSContext *jsContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.webView.delegate = self;
    
    // 加载网页
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//    [self.webView loadRequest:request];
    
    // 加载预置的网页
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
//    NSURL *url = [NSURL URLWithString:htmlPath];
//    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:htmlString baseURL:url];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    NSURLRequest *urlReques = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlReques];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

/**
 *  在一个网页开始加载一个frame前被调用
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"shouldStartLoadWithRequest-------");
    
    NSString *urlString = request.URL.absoluteString;
    NSRange range = [urlString rangeOfString:@"nativejs://"];
    if (range.location != NSNotFound) { // 拦截URL协议头是nativejs的链接
        NSLog(@"执行原生调用相机的方法");
        return NO;// 阻止此链接的跳转
    }
    return YES;
}

/**
 *  网页加载完毕时被调用
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    /*--  1. stringByEvaluatingJavaScriptFromString只能在主线程执行  --*/
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    dispatch_async(queue, ^{
//        [webView stringByEvaluatingJavaScriptFromString:@"var javascript = 1 + 2"];
//    });
    
    /*-- 2.通过stringByEvaluatingJavaScriptFromString可以调用一些系统提供的JavaScript方法，并取得返回值。 --*/
//    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    NSLog(@"%@", title);

    
    /*-- 3、在加载的html里插入代码，并执行 --*/
//    BOOL isExist = [[webView stringByEvaluatingJavaScriptFromString:@"typeof alertTest == \'function\';"] isEqualToString:@"true"];
//    if (!isExist) {
//        [webView stringByEvaluatingJavaScriptFromString:
//         @"var script = document.createElement('script');"
//         "script.type = 'text/javascript';"
//         "script.text = \"function alertTest(str) { "
//         "alert(str)"
//         "}\";"
//         "document.getElementsByTagName('head')[0].appendChild(script);"];
//        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"alertTest('%@');", @"test"]];
//    }
    
    /*-- 4.通过JavaScriptCore，Objective-C调用JavaScript --*/
//    // 获取当前JS执行环境
//    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    NSString *alertJS = @"alert('Hello JS!')"; //准备执行的JS代码
//    // 通过evaluateScript:方法调用JS的alert
//    [context evaluateScript:alertJS];
    
    
    /*-- 直接调用JavaScript 例子1 --*/
//    // 获取当前JS执行环境
//    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    // context直接执行JS代码。
//    [context evaluateScript:@"var num = 10"];
//    [context evaluateScript:@"var squareFunc = function(value) { return value * value }"];
//    // 计算正方形的面积
//    JSValue *squareArea = [context evaluateScript:@"squareFunc(num)"];
//    NSLog(@"squareArea：%@", squareArea.toNumber);
//    
//    // 也可以通过下标的方式获取到JS函数
//    JSValue *squareFunc = context[@"squareFunc"];
//    JSValue *squareArea2 = [squareFunc callWithArguments:@[@"20"]];
//    NSLog(@"squareArea2：%@", squareArea2.toNumber);
    
    
    /*-- 直接调用JavaScript 例子2 --*/
    // 获取当前JS执行环境
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 直接调用JS代码
    context[@"log"] = ^(){
        // 取出JS方法的参数
        NSArray *args = [JSContext currentArguments];
        for (id obj in args) {
            NSLog(@"%@",obj); // 打印JS方法接收到的所有参数
        }
    };
    
}


@end
