//
//  KryAppOrderFiles.m
//  KryAppOrderFiles
//
//  Created by karthrine on 2021/9/9.
//

#import "KryAppOrderFiles.h"
#import <dlfcn.h>
#import <libkern/OSAtomicQueue.h>
#import <pthread.h>

 

//定义原子队列
static OSQueueHead symbolList = OS_ATOMIC_QUEUE_INIT;

//定义符号结构体
typedef struct{
    void *pc;
    void *next;
} SYNode;


 

// 二进制重排使用
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
  static uint32_t N;  // Counter for the guards.Á
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;
}


void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {

    void *PC = __builtin_return_address(0);
    //创建结构体!
   SYNode * node = malloc(sizeof(SYNode));
    *node = (SYNode){PC,NULL};

    //加入结构!
    OSAtomicEnqueue(&symbolList, node, offsetof(SYNode, next));
}


extern void kryAppOrderFiles(void(^completion)(NSString *orderFilePath)) {

    NSMutableArray<NSString *> * symbolNames = [NSMutableArray array];

    while (YES) {
       SYNode * node = OSAtomicDequeue(&symbolList, offsetof(SYNode, next));

        if (node == NULL) {
            break;
        }
        Dl_info info = {0};
        dladdr(node->pc, &info);
//        printf("%s \n",info.dli_sname);
        NSString * name = @(info.dli_sname);
        free(node);

        BOOL isObjc = [name hasPrefix:@"+["]||[name hasPrefix:@"-["];
        NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
        //是否去重??
        [symbolNames addObject:symbolName];
    }


    NSEnumerator * enumerator = [symbolNames reverseObjectEnumerator];
    NSMutableArray * funcs = [NSMutableArray arrayWithCapacity:symbolNames.count];
    NSString * name;
    //去重!
    while (name = [enumerator nextObject]) {
        if (![funcs containsObject:name]) {
            [funcs addObject:name];
        }
    }
    [funcs removeObject:[NSString stringWithFormat:@"%s",__FUNCTION__]];

    NSString * funcStr = [funcs componentsJoinedByString:@"\n"];

    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"app.order"];

    NSData * fileContents = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
    
    
    if (completion){
        completion(success?filePath:nil);
    };

}
