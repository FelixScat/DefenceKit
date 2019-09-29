//
//  NSObject+DefenceKit.m
//  AppSplitKit
//
//  Created by Felix on 2019/9/29.
//

#import "NSObject+DefenceKit.h"

@implementation NSObject (DefenceKit)

static NSUncaughtExceptionHandler *previousExceptionHandler;

static void MyAccessHandleException(NSException *exception)
{
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    // 出现异常的原因
    NSString *reason = [exception reason];
    // 异常名称
    NSString *name = [exception name];
    //这里拿到了崩溃原因和异常名称后，就把信息保存在本地，等待下次启动程序的时候把信息发送到服务器，因为异常捕获是在主线程中完成的，所以在获取到异常崩溃信息后不能立马把信息发送到服务器，因为网络请求是异步的，主线程会直接崩溃，网络请求发送不出去.
    if (previousExceptionHandler) {
        previousExceptionHandler(exception);
    }
}

static void registerHandler() {
    
    previousExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&MyAccessHandleException);
}

+ (void)load {
    
    registerHandler();
}

@end
