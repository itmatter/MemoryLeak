//
//  ViewController.m
//  MemoryLeak
//
//  Created by 李礼光 on 2017/8/15.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "ViewController.h"
#import "Obj_A.h"
#import "Obj_B.h"
#import "TestViewController.h"
#import "MyImage.h"
#define TLog(prefix,Obj) {NSLog(@"对象内存地址：%p, 对象本身：%p, 指向对象：%@, --> %@",&Obj,Obj,Obj,prefix);}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self objProblem1];
//    [self objProblem2];
//    [self objProblem3];
//    [self objProblem4];
//    [self objProblem5];
    
//    [self blockProblem1];
//    [self blockProblem2];
//    [self blockProblem3];

    
    [self imgaeProblem1];
    
//    [self timerMethod];
//    [self setupButton];
    
    
}


#pragma mark - 对象间引用__weak和__strong
- (void)objProblem1 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    Obj_A *obj_a = [[Obj_A alloc]init];
    Obj_B *obj_b = [[Obj_B alloc]init];
    obj_a.obj = obj_b;
    obj_b.obj = obj_a;
    NSLog(@"最简单的例子");
    NSLog(@"这里面对象A应用对象B,对象B引用对象A,两者之间相互强应用.所以会导致内存泄露");
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
}

- (void)objProblem2 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    NSLog(@"__weak会不会改善内存泄漏问题?");
    Obj_A *obj_a = [[Obj_A alloc]init];
    Obj_B *obj_b = [[Obj_B alloc]init];
    __weak typeof(obj_a) weakObjA = obj_a;

    TLog(@"obj_a", obj_a);
    TLog(@"obj_b", obj_b);
    TLog(@"weakObjA", weakObjA);

    weakObjA.obj = obj_b;
    obj_b.obj = weakObjA;
    
    NSLog(@"weakObjA设置为nil");

    weakObjA = nil;
    TLog(@"obj_a", obj_a);
    TLog(@"obj_b", obj_b);
    TLog(@"weakObjA", weakObjA);
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

}

- (void)objProblem3 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    Obj_A *obj = [[Obj_A alloc]init];
    __weak Obj_A *weakObj = obj;

    TLog(@"obj", obj);
    TLog(@"weakObj", weakObj);
    
    void(^testBlock)() = ^(){
        TLog(@"weakObj - block", weakObj);
    };
    testBlock();
    NSLog(@"obj设置为nil");
    obj = nil;
    TLog(@"obj", obj);
    testBlock();
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    //总结 :
    // 1.当obj设置为nil之后,weakObj在block中失去了引用的对象,所以不会导致内存泄露
    // 2.__weak注意使用场景,用于__block
}

- (void)objProblem4 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    Obj_A *obj = [[Obj_A alloc]init];
    __weak Obj_A *weakObj = obj;

    TLog(@"obj", obj);
    TLog(@"weakObj", weakObj);
    
    void(^testBlock)() = ^(){
        __strong Obj_A *strongObj = weakObj;
        TLog(@"weakObj - block", weakObj);
        TLog(@"strongObj - block", strongObj);
    };
    
    testBlock();
    NSLog(@"obj设置为nil");
    obj = nil;
    TLog(@"obj", obj);
    TLog(@"weakObj", weakObj);

    testBlock();
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    //从上面例子我们看到即使在 block 内部用 strong 强引用了外面的 weakObj ，但是一旦 obj 释放了之后，
    //内部的 strongObj 同样会变成 nil，那么这种写法又有什么意义呢？
}

- (void)objProblem5 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    Obj_A *obj = [[Obj_A alloc]init];
    __weak Obj_A *weakObj = obj;
    TLog(@"obj", obj);
    TLog(@"weakObj", weakObj);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start---");
        __strong Obj_A *strongObj = weakObj;
        TLog(@"weakObj - block", weakObj);
        TLog(@"strongObj - block", strongObj);
        sleep(5);
        TLog(@"weakObj - block", weakObj);
        TLog(@"strongObj - block", strongObj);
        NSLog(@"end----");
    });
    sleep(1);
    NSLog(@"*************");
    NSLog(@"After 1s obj设置为nil");
    obj = nil;
    TLog(@"obj", obj);
    TLog(@"weakObj", weakObj);
    NSLog(@"*************");

    
    sleep(10);
    NSLog(@"After 10s");
    TLog(@"obj", obj);
    TLog(@"weakObj", weakObj);
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    
    //代码中使用 sleep 来保证代码执行的先后顺序。从结果中我们可以看到，只要 block 部分执行了，即使我们中途释放了 obj，block 内部依然会继续强引用它。
    //对比上面代码，也就是说 block 内部的 __strong 会在执行期间进行强引用操作，保证在 block 内部 strongObj 始终是可用的。
    //这种写法非常巧妙，既避免了循环引用的问题，又可以在 block 内部持有该变量。
    

}


#pragma mark - Block

- (void)blockProblem1 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    Obj_A *obj = [[Obj_A alloc]init];
    __block Obj_A *blockObj = obj;

    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);

    NSLog(@"obj设置为nil");
    obj = nil;
    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);
    
    void(^testBlock)() = ^(){
        NSLog(@"***********开始block***********");
        TLog(@"blockObj - block",blockObj);
        Obj_A *obj2 = [[Obj_A alloc]init];
        TLog(@"obj2",obj2);
        NSLog(@"将blockObj = obj2,只要blockObj不再应用obj,那么obj则释放");
        blockObj = obj2;
        TLog(@"blockObj - block",blockObj);
        NSLog(@"***********结束block***********");
    };
    
    NSLog(@"设置block内容之后");
    
    TLog(@"blockObj\n--------------------",blockObj);
    
    NSLog(@"运行block");
    testBlock();
    TLog(@"blockObj\n--------------------",blockObj);
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    //可以看到在 block 声明前后 blockObj 的内存地址是有所变化的，这涉及到 block 对外部变量的内存管理问题，大家可以看扩展阅读中的几篇文章，对此有较深入的分析。
    //这里可以注意到,虽然没有执行block,但是里面设置blockObj之后,已经对blockObj进行操作了,改变了其内存地址.
}

- (void)blockProblem2 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    Obj_A *obj = [[Obj_A alloc]init];
    __block Obj_A *blockObj = obj;

    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);

    
    NSLog(@"obj设置为nil");
    obj = nil;
    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);
    NSLog(@"设置block内容");
    
    void(^testBlock)() = ^(){
        TLog(@"blockObj - block",blockObj);
    };
    
    obj = nil;
    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);
    
    NSLog(@"运行block");
    testBlock();
    TLog(@"blockObj",blockObj);
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    //注意Obj A dealloc,是在整个方法结束之后.
    //当外部 obj 指向 nil 的时候，obj 理应被释放，但实际上 blockObj 依然强引用着 obj，obj 其实并没有被真正释放。因此使用 __block 并不能避免循环引用的问题。
   
}

//但是我们可以通过手动释放 blockObj 的方式来释放 obj，这就需要我们在 block 内部将要退出的时候手动释放掉 blockObj ，如下这种形式

- (void)blockProblem3 {
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

    Obj_A *obj = [[Obj_A alloc]init];
    __block Obj_A *blockObj = obj;

    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);

    NSLog(@"obj设置为nil");
    obj = nil;
    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);
    NSLog(@"设置block内容");
    
    void(^testBlock)() = ^(){
        TLog(@"blockObj - block",blockObj);
        NSLog(@"blockObj设置为nil");
        blockObj = nil;
    };
    NSLog(@"obj设置为nil");
    obj = nil;
    TLog(@"obj",obj);
    TLog(@"blockObj\n----------",blockObj);
    NSLog(@"运行block");
    testBlock();
    TLog(@"blockObj",blockObj);
    NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    
    //这里也就是提前手动释放block引用的对象
    //这种形式既能保证在 block 内部能够访问到 obj，又可以避免循环引用的问题，但是这种方法也不是完美的，其存在下面几个问题
    
    //必须记住在 block 底部释放掉 block 变量，这其实跟 MRC 的形式有些类似了，不太适合 ARC
    //当在 block 外部修改了 blockObj 时，block 内部的值也会改变，反之在 block 内部修改 blockObj 在外部再使用时值也会改变。
    //这就需要在写代码时注意这个特性可能会带来的一些隐患
    //__block 其实提升了变量的作用域，在 block 内外访问的都是同一个 blockObj 可能会造成一些隐患
}


/***
 总结
 
 __weak 本身是可以避免循环引用的问题的，但是其会导致外部对象释放了之后，block 内部也访问不到这个对象的问题，我们可以通过在 block 内部声明一个 __strong 的变量来指向 weakObj，使外部对象既能在 block 内部保持住，又能避免循环引用的问题。
 
 __block 本身无法避免循环引用的问题，但是我们可以通过在 block 内部手动把 blockObj 赋值为 nil 的方式来避免循环引用的问题。另外一点就是 __block 修饰的变量在 block 内外都是唯一的，要注意这个特性可能带来的隐患。
 
 */


#pragma mark - 2.定时器
- (void)timerMethod {
    //2.timer是否持有self，我们一般要执行一个timer的时候会用(NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti  target:(id)aTarget  selector:(SEL)aSelector  userInfo:(id)userInfo  repeats:(BOOL)yesOrNo
    //这里的aTarget一般是self，这时候就需要注意了，如果在你退出的时候这个timer还在执行的话由于这个timer会持有self，所以delloc也不会调用，这里可以用weakSelf代替self也是没有问题的。
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(sayHello)
                                                   userInfo:nil
                                                    repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];

}


- (void)sayHello {
    NSLog(@"hello");
}

#pragma mark - 图片
- (void)imgaeProblem1 {
    NSLog(@"imageProblem1");
    MyImage *image1 = (MyImage *)[MyImage imageNamed:@"1.png"];
    TLog(@"image1", image1);
    image1 = nil;
    MyImage *image2 = (MyImage *)[MyImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"1.png" ofType:@""]];
    TLog(@"image2", image2);
    image2 = nil;
}


#pragma mark - 其他

- (void)setupButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"控制器跳转" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.frame = CGRectMake(0, 0, 100, 44);
    btn.center = self.view.center;
    [self.view addSubview:btn];
}

- (void)btnClick {
    TestViewController *vc = [[TestViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
