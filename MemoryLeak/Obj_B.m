//
//  Obj_B.m
//  MemoryLeak
//
//  Created by 李礼光 on 2017/8/16.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "Obj_B.h"

@implementation Obj_B

- (void)dealloc {
    NSLog(@"Obj B dealloc");
}

@end
