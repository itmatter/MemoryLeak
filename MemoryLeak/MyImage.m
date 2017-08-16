//
//  MyImage.m
//  MemoryLeak
//
//  Created by 李礼光 on 2017/8/16.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "MyImage.h"

@implementation MyImage


- (void)dealloc {
    NSLog(@"MyImage dealloc");
}
@end
