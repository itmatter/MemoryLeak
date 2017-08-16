//
//  Obj_A.h
//  MemoryLeak
//
//  Created by 李礼光 on 2017/8/16.
//  Copyright © 2017年 LG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Obj_B;

@interface Obj_A : NSObject

@property (nonatomic, strong) Obj_B *obj;
@property (nonatomic, strong) NSString *text;
@end
