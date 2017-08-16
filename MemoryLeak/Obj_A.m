//
//  Obj_A.m
//  MemoryLeak
//
//  Created by 李礼光 on 2017/8/16.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "Obj_A.h"

@implementation Obj_A


- (void)dealloc {
    NSLog(@"Obj A dealloc");
}

@end
