//
//  NativeAPIs.h
//  ObjcAndJSDemo
//
//  Created by 陈泽嘉 on 16/8/27.
//  Copyright © 2016年 dibadalu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

// 声明与js交互的协议
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
