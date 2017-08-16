//
//  Obj_B.h
//  MemoryLeak
//
//  Created by 李礼光 on 2017/8/16.
//  Copyright © 2017年 LG. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Obj_A;

@interface Obj_B : NSObject

@property (nonatomic, strong) Obj_A *obj;

@end
