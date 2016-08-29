# iOS与JS交互的几种方式
* JavaScriptCore：iOS7之后出现的，学习成本不高，是适配iOS7的首选。
* 拦截协议：拦截协议需要双方共同协商为协议规定一套准则，在交互中要遵循该准则。拦截协议不需要引入任何框架，适合多个平台使用。协议可以如此定义：`schemes://model/action?{参数1}={数值1}&{参数2}={数值2}&... `。
* 第三方框架WebViewJavaScriptBridge：基于拦截协议进行的封装，学习成本相对JavaScriptCore较高，使用不如JavaScriptCore方便。
* WKWebView：iOS8之后出现的。

# iOS7之前，Objective-C调用JavaScript代码
iOS7以前，Objective-C调用JavaScript的方式只有一种，就是通过UIWebView对象的stringByEvaluatingJavaScriptFromString:方法。

* `stringByEvaluatingJavaScriptFromString:`方法只能在`主线程`执行

```objc
dispatch_queue_t queue = dispatch_get_main_queue();
dispatch_async(queue, ^{
        [self.webView stringByEvaluatingJavaScriptFromString:@"var javascript = 1 + 2"];
});  
```

* 通过`stringByEvaluatingJavaScriptFromString:`方法可以简单地调用系统提供的JavaScript方法

```objc
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"%@", title);
}
```

# iOS7之前，JavaScript调用Objective-C
* URL请求拦截。

在Objective-C代码里设置UIWebViewDelegate代理，实现代理方法

```objc
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
```
解释：该方法可以监听到UIWebView中发出的URL请求，通过与H5协商一个URL通信协议，来拦截指定的URL，做相应的操作，并阻止此链接的跳转。

例子：
html代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    <div style="margin-top: 10px">
        <input type="button" value="callPhone" onclick="callPhone()">
    </div>
</body>

<script>
    // 声明一个名为callPhone的js函数，其会发出一个链接为nativejs://callPhone的请求
    function callPhone() {
        window.location.href = 'nativejs://callPhone';
    }

</script>

</html>

```
objc代码

```objc
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
```

* 监听Cookie。

详见参考链接的`原生与H5的交互`一文。

# iOS7之后，JavaScriptCore的引入，使得Objective-C与JavaScript的交互更为容易
## JavaScriptCore中常见的几种类型
* JSContext：代表JS的执行环境，通过`evaluateScript:`方法就可以执行JS方法。
* JSValue：封装了JS与ObjC中对应的模型，以及调用JS的API等。
* JSExport：一个协议，通过遵守此协议，可以定义我们自己的协议，在协议中声明的API都会在JS中暴露出来，能被JS调用。
* JSManagedValue：对JSValue的封装，用来管理数据和方法的类，可以解决JS和Objective-C代码循环引用的问题。
* JSVirtualMachine：处理线程相关，使用较少。

## Objective-C调用JavaScript

```objc
/**
 *  网页加载完毕时被调用
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView{
	// 获取当前JS执行环境
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *alertJS = @"alert('Hello JS!')"; //准备执行的JS代码
    // 通过evaluateScript:方法调用JS的alert
    [context evaluateScript:alertJS];
}
```

## JavaScript 调用 Objective-C
* 直接调用JS（不适用于实战项目中）。
  
  例子1：
  objc代码
  
  ```objc
  // 获取当前JS执行环境
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // context直接执行JS代码。
    [context evaluateScript:@"var num = 10"];
    [context evaluateScript:@"var squareFunc = function(value) { return value * value }"];
    // 计算正方形的面积
    JSValue *squareArea = [context evaluateScript:@"squareFunc(num)"];
    NSLog(@"squareArea：%@", squareArea.toNumber);
    
    // 也可以通过下标的方式获取到JS函数
    JSValue *squareFunc = context[@"squareFunc"];
    JSValue *squareArea2 = [squareFunc callWithArguments:@[@"20"]];
    NSLog(@"squareArea2：%@", squareArea2.toNumber);
  ```
  
  例子2：
	html代码
	
	```html 
	<div style="margin-top: 10px">
        <input type="button" value="log" onclick="log('测试')">
    </div>
	```  
	objc代码
	
 	```objc
/**
 * 网页加载完毕时被调用
 */ 
 - (void)webViewDidFinishLoad:(UIWebView   *)webView{
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

	```
  
* 在ObjC中通过JSContext注入模型，然后调用模型的方法。（重要，项目一般用该方式）

第一步：需要声明一个与JS进行交互的协议（NativeApisProtocol），要求该协议遵守JSExport协议。
第二步：新建一个模型（NativeAPIs），要求该模型遵守NativeApisProtocol协议。一般而言，需要在NativeAPIs模型中声明一个JSContext属性，便于与JS交互。
第三步：实现该模型（NativeAPIs），即在NativeAPIs.m文件中实现NativeApisProtocol协议中定义的方法。
第四步：在ViewController.m的`-webViewDidFinishLoad:方法`中获取当前JS执行环境（self.jsContext），然后将NativeAPIs模型注入到JS执行环境。

注意：NativeApisProtocol协议中定义的方法是在子线程中执行的，如果在所定义的方法中需要修改界面或者跳转之类的，需要通过GCD回主线程操作。

缺陷：通过参考链接的`JavaScript和Objective-C交互的那些事(续)`可知，在`-webViewDidFinishLoad:方法`中注入NativeAPIs模型存在一定的问题，因为这时候网页还没加载完，JavaScript若开始调用Objective-C代码（即NativeApisProtocol协议中定义的方法），会出现调用不到方法的问题。
解决方法：在每次创建JSContext环境的时候，都注入NativeAPIs模型到JSContext环境中。更加具体的方法可以参考第三方库[UIWebView-TS_JavaScriptContext](https://github.com/TomSwift/UIWebView-TS_JavaScriptContext)。通过引入`UIWebView+TS_JavaScriptContext`，让`ViewController`遵守`TSWebViewDelegate`协议，实现代理协议中的方法`-webView:didCreateJavaScriptContext:`，以此获取JSContext环境。

objc代码 

```objc
/*--  NativeAPIs.h  ---*/ 

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

// 声明与JS交互的协议
@protocol NativeApisProtocol <JSExport> // 遵守JSExport协议

// 调用系统相机
- (void)callCamera;

// 调用系统分享
- (void)share:(NSString *)shareInfo;

// 打开宁波手机阅读
- (void)openNBPhoneReader;

@end

@interface NativeAPIs : NSObject <NativeApisProtocol>

@property(weak, nonatomic) JSContext *jsContext;

@end

/*--------------------------------------------*/

/*--  NativeAPIs.m --*/ 

/*--  省略，具体看Demo源码 --*/

/*--------------------------------------------*/

// ViewController.m

/*-- 省略前面的代码 --*/

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"网页加载完毕------");
    
    // 获取JS上下文运行环境
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NativeAPIs *nativeAPIs = [[NativeAPIs alloc] init];
    // 将NativeAPIs模型注入JS
    self.jsContext[@"NativeApis"] = nativeAPIs;
    nativeAPIs.jsContext = self.jsContext;
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息: %@", exceptionValue);
    };
}

```

html代码

```html
<html>

/*-- 省略无关紧要的代码，具体见Demo --*/

<body>
    <div style="margin-top: 10px">
        <input type="button" value="CallCamera" onclick="NativeApis.callCamera()">
    </div>
    <div style="margin-top: 50px">
        <input type="button" value="Share" onclick="callShare()">
    </div>
    <div style="margin-top: 50px">
        <input type="button" value="OpenReader" onclick="NativeApis.openNBPhoneReader()">
    </div>
</body>

<script>
    // 声明一个名为picCallback的函数，其参数为photo
    var picCallback =  function (photo) {
        alert(photo);
    }

    // 声明一个名为callShare的函数
    var callShare = function () {
        var shareInfo = JSON.stringify(
                                      { "title": "objc&js的交互",
                                        "desc": "就是那些事"}
                                      );
        // 调用原生的share方法
        NativeApis.share(shareInfo);
    }

    // 声明一个名为shareCallback的函数
    var shareCallback =  function () {
        alert('success');
    }

</script>

</html>

```


# 参考链接
[iOS与JS交互实战篇(ObjC版)](http://mp.weixin.qq.com/s?__biz=MzIzMzA4NjA5Mw==&mid=214063688&idx=1&sn=903258ec2d3ae431b4d9ee55cb59ed89#rd)

[UIWebView 与 JS 交互（1）：Objective-C 调用 Javascript](http://blog.oneapm.com/apm-tech/534.html)

[原生与H5的交互](http://tunnycoder.com/iOS/0014.html)

[Objective-C与JavaScript交互的那些事](http://www.jianshu.com/p/f896d73c670a)

[JavaScript和Objective-C交互的那些事(续)](http://www.jianshu.com/p/939db6215436)

[JavaScriptCore在实际项目中的使用的坑](http://blog.csdn.net/u011296699/article/details/50435559)

[UIWebView中Objective-C与JavaScript交互](http://www.beyondabel.com/blog/2016/03/03/oc-to-js/)

[UIWebView加载本地HTML文件](http://zhangbuhuai.com/uiwebview-load-local-html/)

[OC与JS的交互](http://blog.qiji.tech/archives/6751#jsoc)

[iOS中JavaScript和OC交互](http://blog.devzeng.com/blog/ios-uiwebview-interaction-with-javascript.html)

[UIWebView-TS_JavaScriptContext](https://github.com/TomSwift/UIWebView-TS_JavaScriptContext)

[关于UIWebView的总结](http://blog.devtang.com/2012/03/24/talk-about-uiwebview-and-phonegap/)

[iOS JavaScriptCore使用](http://liuyanwei.jumppo.com/2016/04/03/iOS-JavaScriptCore.html)