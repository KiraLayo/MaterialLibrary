//
//  main.m
//  @synchronized
//
//  Created by yp-tc-m-2548 on 2021/4/19.
//  Copyright © 2021 yp-tc-m-2548. All rights reserved.
//

#import <Foundation/Foundation.h>

// 自定义类效果同样
void synchronized() {
    NSObject *obj = [NSObject new];
    // arc/mrc 1
    NSLog(@"%@", @(CFGetRetainCount((__bridge CFTypeRef)(obj))));
    @synchronized (obj) {
        // arc 2
        // mrc 1
        NSLog(@"%@", @(CFGetRetainCount((__bridge CFTypeRef)(obj))));
    }
}

void synchronizedToNil(){
    NSObject *obj = [NSObject new];
    NSObject *ptrObj = obj;
    // arc 2
    // mrc 1
    NSLog(@"%@", @(CFGetRetainCount((__bridge CFTypeRef)(ptrObj))));
    @synchronized (obj) {
        obj = nil;
        // arc 2
        // mac 1
        NSLog(@"%@", @(CFGetRetainCount((__bridge CFTypeRef)(ptrObj))));
    }
}

int main(int argc, char * argv[]) {
    synchronizedToNil();
}
