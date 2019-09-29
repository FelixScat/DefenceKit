//
//  DKViewController.m
//  DefenceKit
//
//  Created by Felix on 09/28/2019.
//  Copyright (c) 2019 Felix. All rights reserved.
//

#import "DKViewController.h"

@interface DKViewController ()

@end

@implementation DKViewController

- (void)unexceptOperation {
    
    NSObject *obj = [NSObject new];
    [obj performSelector:NSSelectorFromString(@"greeting")];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self unexceptOperation];
}

@end
