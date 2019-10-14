//
//  NSMutableArray+DefenceKit.m
//  DefenceKit
//
//  Created by Felix on 2019/10/14.
//

#import <objc/runtime.h>

@implementation NSMutableArray (DefenceKit)

#if !DK_CARSH_ENABLE

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


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //  immutable
        dk_swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(dk_objectAtIndex:));
        dk_swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndexedSubscript:), @selector(dk_objectAtIndexedSubscript:));
    });
}

- (id)dk_objectAtIndex:(NSUInteger)index {
    if (index > self.count) {
        return nil;
    }
    return [self dk_objectAtIndex:index];
}

- (id)dk_objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx > self.count) {
        return nil;
    }
    return [self dk_objectAtIndexedSubscript:idx];
}

#endif

@end
