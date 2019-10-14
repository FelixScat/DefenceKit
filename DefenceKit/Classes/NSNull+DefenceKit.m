//
//  NSNull+DefenceKit.m
//  DefenceKit
//
//  Created by Felix on 2019/10/12.
//

#import <objc/runtime.h>
#import "DefenceKit.h"

@implementation NSNull (DefenceKit)

#if !DK_CRASH_ENABLE

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    @synchronized ([self class]) {
        
        NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
        if (!sig) {
            
            static NSMutableSet *classsList = nil;
            static NSMutableDictionary *sigCache = nil;
            if (sigCache == nil) {
                classsList = [[NSMutableSet alloc] init];
                sigCache = [[NSMutableDictionary alloc] init];
                
                int numClasses = objc_getClassList(NULL, 0);
                Class *classes = (Class *)malloc(sizeof(Class) * (unsigned long)numClasses);
                numClasses = objc_getClassList(classes, numClasses);
                
                NSMutableSet *exclude = [NSMutableSet set];
                for (int i = 0; i < numClasses; i++) {
                    
                    Class anyClass = classes[i];
                    Class superClass = class_getSuperclass(anyClass);
                    while (superClass) {
                        if (superClass == [NSObject class]) {
                            [classsList addObject:anyClass];
                            break;
                        }
                        [exclude addObject:NSStringFromClass(superClass)];
                        superClass = class_getSuperclass(superClass);
                    }
                }
                
                for (Class anyClass in exclude) {
                    [classsList removeObject:anyClass];
                }
                
                free(classes);
            }
            
            // imp cache
            NSString *selectorString = NSStringFromSelector(aSelector);
            sig = sigCache[selectorString];
            
            if (!sig) {
                for (Class anyClass in classsList) {
                    if ([anyClass instancesRespondToSelector:aSelector]) {
                        sig = [anyClass instanceMethodSignatureForSelector:aSelector];
                        break;
                    }
                }
                sigCache[selectorString] = sig?:[NSNull null];
            } else if ([sig isKindOfClass:[NSNull class]]) {
                sig = nil;
            }
        }
        return sig;
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

#endif

@end
