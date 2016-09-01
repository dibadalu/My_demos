// 记录一些代码

#warning 适用于iOS9之后的alertView

 // 主线程执行
 dispatch_async(dispatch_get_main_queue(), ^{
 // 创建提示框
 UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示下载" message:@"下载宁波手机阅读？" preferredStyle:UIAlertControllerStyleAlert];
 
 UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 NSLog(@"确定------");
 // 添加延迟操作，消除警告
 dispatch_after(0.2, dispatch_get_main_queue(), ^{
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ning-bo-shou-ji-yue-du/id590210090?mt=8"]];
 });
 
 }];
 UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * __nonnull action) {
 NSLog(@"取消------");
 }];
 [alertVc addAction:action1];
 [alertVc addAction:action2];
 
 [self presentViewController:alertVc animated:YES completion:nil];
 
 });


#warning 将self 变为 weakSelf

__weak typeof(self) weakSelf = self;


#warning 回调JS函数，传参数到web

// 回调js的函数picCallback，将图片传到web端
JSValue *picCallback = self.jsContext[@"picCallback"];
[picCallback callWithArguments:@[@"有来自相册的照片"]];

