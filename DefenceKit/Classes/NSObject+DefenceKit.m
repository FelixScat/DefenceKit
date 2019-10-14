//
//  NSObject+DefenceKit.m
//  AppSplitKit
//
//  Created by Felix on 2019/9/29.
//

#import "DefenceKit.h"
#import <objc/runtime.h>
#include <signal.h>
#include <execinfo.h>

#pragma GCC diagnostic ignored "-Wunused-function"

@implementation NSObject (DefenceKit)

static NSUncaughtExceptionHandler *previousExceptionHandler;

static NSString *DKProtectClassName = @"DK_Protect_Class";

static void DK_ShowError(NSString *title, NSString *message, dispatch_block_t block) {
    
    BOOL holdOn = true;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
//    [alert.view setTintColor:UIColor.orangeColor];
    [alert addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIPasteboard generalPasteboard] setString:message];
        [alert dismissViewControllerAnimated:true completion:nil];
//        holdOn = false;
    }]];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelStatusBar;
    window.hidden = false;
    window.backgroundColor = UIColor.clearColor;
    UIViewController *controller = [UIViewController new];
    controller.view.backgroundColor = UIColor.orangeColor;
    window.rootViewController = controller;

    [controller presentViewController:alert animated:false completion:nil];
    
    
//    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
//    [vc presentViewController:alert animated:true completion:nil];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
//    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    NSArray *allModes = CFBridgingRelease(CFRunLoopCopyAllModes(runLoop));
    while (holdOn) {
        for (NSString *mode in allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
//    CFRelease(allModes);
}

static UIViewController * topViewController() {
    UIViewController *resultVC;
    resultVC = _topViewController([[UIApplication sharedApplication].keyWindow rootViewController]);
    while (resultVC.presentedViewController) {
        resultVC = _topViewController(resultVC.presentedViewController);
    }
    return resultVC;
}

static UIViewController * _topViewController(UIViewController *vc) {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return _topViewController([(UINavigationController *)vc topViewController]);
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return _topViewController([(UITabBarController *)vc selectedViewController]);
    } else {
        return vc;
    }
    return nil;
}


static void MyAccessHandleException(NSException *exception) {
    // 堆栈信息
    NSArray *stackSymbols = [exception callStackSymbols];
    // 异常原因
    NSString *reason = [exception reason];
    // 名称
    NSString *name = [exception name];

    
    NSString *info = [NSString stringWithFormat:@"An exception occurred\n \
                      Exception Report:\n \
                      Exception Name：%@\n \
                      Exception Reason：%@\n \
                      Stack Symbols：\n%@", name, reason, stackSymbols];
    NSLog(@"%@",info);
    
    DK_ShowError(@"Error", info, nil);
    
    if (previousExceptionHandler) {
        previousExceptionHandler(exception);
    }
}

static void SignalExceptionHandler(int sig) {
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Call Stack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }
    NSLog(@"%@", mstr);
    DK_ShowError(@"Error", mstr, nil);
}

void InstallSignalHandler(void)
{
    signal(SIGHUP, SignalExceptionHandler);
    signal(SIGINT, SignalExceptionHandler);
    signal(SIGQUIT, SignalExceptionHandler);
    
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}

static void registerUncaughtExceptionHandler() {
    
    previousExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&MyAccessHandleException);
}

static void dk_swizzleInstanceMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static void dk_swizzleClassMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(cls, originalSelector);
    Method swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        #if DK_CRASH_ENABLE
        registerUncaughtExceptionHandler();
        InstallSignalHandler();
        #else
        dk_swizzleInstanceMethod(self, @selector(forwardingTargetForSelector:), @selector(dk_forwardingTargetForSelector:));
        dk_swizzleClassMethod(self, @selector(forwardingTargetForSelector:), @selector(dk_forwardingTargetForSelector:));
        #endif
    });
}

- (id)dk_forwardingTargetForSelector:(SEL)aSelector {
    
    
    Class dk_class = NSClassFromString(DKProtectClassName);
    if (!dk_class) {
        dk_class = objc_allocateClassPair([NSObject class], DKProtectClassName.UTF8String, 0);
        objc_registerClassPair(dk_class);
    }
    
    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"__"]) {
        return [self dk_forwardingTargetForSelector:aSelector];
    }
    
    class_addMethod(dk_class, aSelector, [self dk_safe_implementation:aSelector], [NSStringFromSelector(aSelector) UTF8String]);
    Class Protect = [dk_class class];
    id obj = [[Protect alloc] init];
    return obj;
}

+ (id)dk_forwardingTargetForSelector:(SEL)aSelector {
    
    Class dk_class = NSClassFromString(DKProtectClassName);
    if (!dk_class) {
        dk_class = objc_allocateClassPair([NSObject class], DKProtectClassName.UTF8String, 0);
        objc_registerClassPair(dk_class);
    }
    
    NSString *className = NSStringFromClass([self class]);
    if ([className hasPrefix:@"__"]) {
        return [self dk_forwardingTargetForSelector:aSelector];
    }
    
    class_addMethod(dk_class, aSelector, [self dk_safe_implementation:aSelector], [NSStringFromSelector(aSelector) UTF8String]);
    Class Protect = [dk_class class];
    id obj = [[Protect alloc] init];
    return obj;
}

- (IMP)dk_safe_implementation:(SEL)aSelector
{
    IMP imp = imp_implementationWithBlock(^()                                    {
        NSLog(@"DK Warn :: \nMethod Has Not Been Implement :: %@ %@",NSStringFromClass([self class]) , NSStringFromSelector(aSelector));
    });
    return imp;
}

@end
