//
//  DKViewController.m
//  DefenceKit
//
//  Created by Felix on 09/28/2019.
//  Copyright (c) 2019 Felix. All rights reserved.
//

#import "DKViewController.h"


@interface DKViewController ()

+ (void)somemethod;

@end

@implementation DKViewController

- (void)uncaughtException {
    
    NSObject *obj = [DKViewController new];
    [obj performSelector:NSSelectorFromString(@"somemethod")];
    
    
//    [self performSelectorInBackground:@selector(refreshUI) withObject:nil];
    
//    NSDictionary *dic = @{@"asd": [NSNull null]};
//    id obj = [dic objectForKey:@"asd"];
//    NSLog(@"%lu", (unsigned long)[[obj firstObject] length]);
    
//    NSArray *ar = @[@1, @2];
//    NSLog(@"%@", [ar objectAtIndex:123]);
    
//    [ar insertObject:@123 atIndex:123];
    
//    NSArray *arr = [NSArray array];

    
}

- (void)refreshUI {
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)signalException {
    
    // pointer being freed was not allocated
    id p = @{};
    free((__bridge void *)(p));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self uncaughtException];
//    [self signalException];
}

@end
