//
//  main.m
//  GCD
//
//  Created by yp-tc-m-2548 on 2021/4/20.
//  Copyright © 2021 yp-tc-m-2548. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, char * argv[]) {
    dispatch_queue_t queue = dispatch_queue_create("com.demo", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    NSLog(@"%@", NSThread.currentThread);
    dispatch_sync(queue, ^{
        NSLog(@"2");
        NSLog(@"%@", NSThread.currentThread);
    });
    NSLog(@"3");
    NSLog(@"%@", NSThread.currentThread);
}
