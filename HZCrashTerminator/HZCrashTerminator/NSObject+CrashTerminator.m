//
//  NSObject+CrashTerminator.m
//  HZCrashTerminator
//
//  Created by clouder on 2019/5/8.
//  Copyright © 2019 hurricaner. All rights reserved.
//

#import "NSObject+CrashTerminator.h"

#pragma mark ------------------------------------  NSObject -------

static void *NSObjectKVOProxyKey = &NSObjectKVOProxyKey;

@implementation NSObject (CrashTerminator)

#pragma load
+(void)load
{
    if (!kOPEN_CT) {
        NSLog(@"CrashTerminator  close !");
        return;
    }
    NSLog(@"CrashTerminator  open !");
    [self openCrashTerminator];
}

+ (void)openCrashTerminator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            //Dictionary
            [self swizzlingInstance:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(initWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"hz_initWithObjects:forKeys:count:")];
            [self swizzlingInstance:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(dictionaryWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"hz_dictionaryWithObjects:forKeys:count:")];
            [self swizzlingInstance:objc_getClass("__NSDictionaryM") orginalMethod:@selector(setObject:forKey:) replaceMethod:NSSelectorFromString(@"hz_setObject:forKey:")];
            
            
            //Array
            [self swizzlingInstance:objc_getClass("__NSArray0") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"hz_emptyObjectAtIndex:")];
            [self swizzlingInstance:objc_getClass("__NSPlaceholderArray") orginalMethod:@selector(initWithObjects:count:) replaceMethod:NSSelectorFromString(@"hz_initWithObjects:count:")];
            [self swizzlingInstance:objc_getClass("__NSArrayI") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"hz_objectAtIndex:")];
            [self swizzlingInstance:objc_getClass("__NSArrayI") orginalMethod:@selector(objectAtIndexedSubscript:) replaceMethod:NSSelectorFromString(@"hz_anyObjectAtIndex:")];
            /** 可变数组 */
            [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(addObject:) replaceMethod:NSSelectorFromString(@"hz_addObject:")];
            [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(insertObject:atIndex:) replaceMethod:NSSelectorFromString(@"hz_insertObject:atIndex:")];
            [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"hz_objectAtIndex:")];
            [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(insertObject:atIndex:) replaceMethod:NSSelectorFromString(@"hz_mutableInsertObject:atIndex:")];
            [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(addObject:) replaceMethod:NSSelectorFromString(@"hz_mutableAddObject:")];
            /** 只有一个元素 */
            [self swizzlingInstance:objc_getClass("__NSSingleObjectArrayI") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"hz_singleObjectIndex:")];
            [self swizzlingInstance:objc_getClass("__NSSingleObjectArrayI") orginalMethod:@selector(insertObject:atIndex:) replaceMethod:NSSelectorFromString(@"hz_singleInsertObject:atIndex:")];
            [self swizzlingInstance:objc_getClass("__NSSingleObjectArrayI") orginalMethod:@selector(addObject:) replaceMethod:NSSelectorFromString(@"hz_singleAddObject:")];
            
            
            //String
            [self swizzlingInstance:objc_getClass("NSPlaceholderString") orginalMethod:@selector(initWithString:) replaceMethod:NSSelectorFromString(@"hz_initWithString:")];
            [self swizzlingInstance:objc_getClass("__NSCFConstantString") orginalMethod:@selector(hasSuffix:) replaceMethod:NSSelectorFromString(@"hz_hasSuffix:")];
            [self swizzlingInstance:objc_getClass("__NSCFConstantString") orginalMethod:@selector(hasPrefix:) replaceMethod:NSSelectorFromString(@"hz_hasPrefix:")];
            [self swizzlingInstance:objc_getClass("NSPlaceholderMutableString") orginalMethod:@selector(initWithString:) replaceMethod:NSSelectorFromString(@"hz_initWithString:")];
            
            
            //Timer
            [self swizzlingClass:objc_getClass("NSTimer") replaceClassMethod:NSSelectorFromString(@"scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:") withMethod:NSSelectorFromString(@"hz_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:")];
            [self swizzlingClass:objc_getClass("NSTimer") replaceClassMethod:@selector(timerWithTimeInterval:target:selector:userInfo:repeats:) withMethod:NSSelectorFromString(@"hz_timerWithTimeInterval:target:selector:userInfo:repeats:")];
            
            
            //Notification
            [self swizzlingInstance:objc_getClass("NSNotificationCenter") orginalMethod:NSSelectorFromString(@"addObserver:selector:name:object:") replaceMethod:NSSelectorFromString(@"hz_addObserver:selector:name:object:")];
            [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"dealloc") replaceMethod:NSSelectorFromString(@"hz_dealloc")];
            
            
            //KVO该逻辑在 xcode9.2 真机测试会 crash
            [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"addObserver:forKeyPath:options:context:") replaceMethod:NSSelectorFromString(@"hz_addObserver:forKeyPath:options:context:")];
            [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"removeObserver:forKeyPath:") replaceMethod:NSSelectorFromString(@"hz_removeObserver:forKeyPath:")];
        }
    });
}


//在进行方法swizzing时候，一定要注意类簇 ，比如 NSArray NSDictionary 等。
+ (BOOL)swizzlingInstanceMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector
{
    return [self swizzlingInstance:self orginalMethod:originalSelector replaceMethod:replaceSelector];
}

+(BOOL)swizzlingInstance:(Class)clz orginalMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector{
    
    Method original = class_getInstanceMethod(clz, originalSelector);
    Method replace = class_getInstanceMethod(clz, replaceSelector);
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSelector,
                    method_getImplementation(replace),
                    method_getTypeEncoding(replace));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            replaceSelector,
                            method_getImplementation(original),
                            method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, replace);
    }
    return YES;
}

+ (BOOL)swizzlingClass:(Class)klass replaceClassMethod:(SEL)methodSelector1 withMethod:(SEL)methodSelector2
{
    if (!klass || !methodSelector1 || !methodSelector2) {
        NSLog(@"Nil Parameter(s) found when swizzling.");
        return NO;
    }
    
    Method method1 = class_getClassMethod(klass, methodSelector1);
    Method method2 = class_getClassMethod(klass, methodSelector2);
    if (method1 && method2) {
        IMP imp1 = method_getImplementation(method1);
        IMP imp2 = method_getImplementation(method2);
        
        Class classMeta = object_getClass(klass);
        if (class_addMethod(classMeta, methodSelector1, imp2, method_getTypeEncoding(method2))) {
            class_replaceMethod(classMeta, methodSelector2, imp1, method_getTypeEncoding(method1));
        } else {
            method_exchangeImplementations(method1, method2);
        }
        return YES;
    } else {
        NSLog(@"Swizzling Method(s) not found while swizzling class %@.", NSStringFromClass(klass));
        return NO;
    }
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-protocol-method-implementation"
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([NSStringFromClass([self class]) hasPrefix:@"_"] || [self isKindOfClass:NSClassFromString(@"UITextInputController")] || [NSStringFromClass([self class]) hasPrefix:@"UIKeyboard"] || [methodName isEqualToString:@"dealloc"]) {
        
        return nil;
    }
    
    CrashProxy * crashProxy = [CrashProxy new];
    crashProxy.crashMsg =[NSString stringWithFormat:@"CrashTerminator: [%@ %p %@]: unrecognized selector sent to instance",NSStringFromClass([self class]),self,NSStringFromSelector(aSelector)];
    class_addMethod([CrashProxy class], aSelector, [crashProxy methodForSelector:@selector(getCrashMsg)], "v@:");
    
    return crashProxy;
}
#pragma clang diagnostic pop


#pragma KVC Protect
-(void)setNilValueForKey:(NSString *)key
{
    NSLog(@"need log msg");
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"need log msg");
}

- (nullable id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"need log msg");
    return self;
}

#pragma NSNotification
-(void)hz_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject
{
    [observer setIsNSNotification:YES];
    [self hz_addObserver:observer selector:aSelector name:aName object:anObject];
}

-(void)hz_dealloc
{
    if ([self isNSNotification]) {
        NSLog(@"[Notification] need log msg");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [self hz_dealloc];
}

static const char *isNSNotification = "isNSNotification";

-(void)setIsNSNotification:(BOOL)yesOrNo
{
    objc_setAssociatedObject(self, isNSNotification, @(yesOrNo), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isNSNotification
{
    NSNumber *number = objc_getAssociatedObject(self, isNSNotification);;
    return  [number boolValue];
}

#pragma KVO
- (void)hz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
    CPKVOInfo * kvoInfo = [[CPKVOInfo alloc] initWithKeyPath:keyPath options:options context:context];
    __weak typeof(self) wkself = self;
    if([self.KVOProxy addKVOinfo:wkself info:kvoInfo]){
        [self hz_addObserver:self.KVOProxy forKeyPath:keyPath options:options context:context];
    }else{
        NSLog(@"KVO is more");
    }
}

- (void)hz_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    NSLog(@"hz_removeObserver");
    [self.KVOProxy removeKVOinfo:self keyPath:keyPath block:^{
        [self hz_removeObserver:observer forKeyPath:keyPath];
    }];
}

- (KVOProxy *)KVOProxy
{
    id proxy = objc_getAssociatedObject(self, NSObjectKVOProxyKey);
    
    if (nil == proxy) {
        proxy = [[KVOProxy alloc] init];
        self.KVOProxy = proxy;
    }
    
    return proxy;
}

- (void)setKVOProxy:(KVOProxy *)proxy
{
    objc_setAssociatedObject(self, NSObjectKVOProxyKey, proxy, OBJC_ASSOCIATION_ASSIGN);
}

@end







#pragma mark ------------------------------------  CrashProxy -------

@implementation CrashProxy

- (void)getCrashMsg{
    NSLog(@"%@",_crashMsg);
}

@end




#pragma mark ------------------------------------  NSDictionary  ------

@implementation NSDictionary (CrashTerminator)

- (instancetype)hz_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            NSLog(@"need log msg");
            
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return  [self hz_initWithObjects:safeObjects forKeys:safeKeys count:j];
}


+ (instancetype)hz_dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            NSLog(@"need log msg");
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return [self hz_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end


#pragma mark ------------------------------------  NSMutableDictionary ----------

@implementation NSMutableDictionary (CrashTerminator)

- (void)hz_setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey{
    if (!anObject || !aKey) {
        NSLog(@"need log msg");
        return;
    }
    [self hz_setObject:anObject forKey:aKey];
}

@end


#pragma mark ------------------------------------  NSArray  --------

@implementation NSArray (CrashTerminator)

- (instancetype)hz_initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        if (objects == NULL) {
            continue;
        }
        id obj = objects[i];
        if (!obj) {
            NSLog(@"need log msg");
            continue;
        }
        safeObjects[j] = obj;
        j++;
    }
    return [self hz_initWithObjects:safeObjects count:j];
}

- (id)hz_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        NSLog(@"need log msg");
        return nil;
    }
    return [self hz_objectAtIndex:index];
}

/**
 空:nil 或 count = 0
 */
- (id)hz_emptyObjectAtIndex:(NSInteger)index{
    NSLog(@"数组 = nil 或者 count = 0 返回 nil %s",__FUNCTION__);
    return nil;
}

- (id)hz_anyObjectAtIndex:(NSInteger)index{
    if (index >= self.count || index < 0) {
        NSLog(@"取值时: 索引越界,返回 nil %s",__FUNCTION__);
        return nil;
    }
    id obj = [self hz_anyObjectAtIndex:index];
    if ([obj isKindOfClass:[NSNull class]]) {
        NSLog(@"取值时: 取出的元素类型为 NSNull 类型,返回 nil %s",__FUNCTION__);
        return nil;
    }
    return obj;
}

- (id)hz_singleObjectIndex:(NSInteger)index{
    if (index >= self.count || index < 0) {
        NSLog(@"数组中只有一个元素, 取值时: 索引越界, 返回 nil %s",__FUNCTION__);
        return nil;
    }
    id obj = [self hz_singleObjectIndex:index];
    if ([obj isKindOfClass:[NSNull class]]) {
        NSLog(@"数组中只有一个元素, 取值时: 元素类型为 NSNull 类型, 返回 nil %s",__FUNCTION__);
        return nil;
    }
    return obj;
}

/**
 插入
 */
- (void)hz_singleInsertObject:(id)object atIndex:(NSUInteger)index{
    if (object) {
        [self hz_singleInsertObject:object atIndex:index];
    }else{
        //数组中有一个元素时,判断下真实类型,如果是NSArray,则不添加
        Class superClass = self.superclass;
        NSString *superClassStr = NSStringFromClass(superClass);
        if (![superClassStr isEqualToString:@"NSArray"]) {
            NSLog(@"数组中只有一个元素, 并且数组真实类型为NSMutableArray 插入值: 元素类型为 nil, %s",__FUNCTION__);
            [self hz_singleInsertObject:[NSNull null] atIndex:index];
        }else{
            NSLog(@"真实类型是NSArray,什么都不做 %s",__FUNCTION__);
        }
    }
}

-(void)hz_singleAddObject:(id)object{
    if (object) {
        [self hz_singleAddObject:object];
    }else{
        //数组中有一个元素时,判断下真实类型,如果是NSArray,则不添加
        Class superClass = self.superclass;
        NSString *superClassStr = NSStringFromClass(superClass);
        if (![superClassStr isEqualToString:@"NSArray"]) {
            NSLog(@"数组中只有一个元素, 并且数组真实类型为NSMutableArray 插入值: 元素类型为 nil, %s",__FUNCTION__);
            [self hz_singleAddObject:[NSNull null]];
        }else{
            NSLog(@"真实类型是NSArray,什么都不做 %s",__FUNCTION__);
        }
    }
}


@end


#pragma mark ------------------------------------  NSMutableArray  ---------

@implementation NSMutableArray (CrashTerminator)

- (void)hz_addObject:(id)anObject
{
    if(nil == anObject){
        NSLog(@"need log msg");
        return ;
    }
    [self hz_addObject:anObject];
}

- (void)hz_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if(nil == anObject){
        NSLog(@"need log msg");
        return ;
    }
    [self hz_insertObject:anObject atIndex:index];
}

- (id)hz_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        NSLog(@"need log msg");
        return nil;
    }
    return [self hz_objectAtIndex:index];
}

- (void)hz_mutableInsertObject:(id)object atIndex:(NSUInteger)index{
    if (object) {
        [self hz_mutableInsertObject:object atIndex:index];
    }else{
        NSLog(@"插入值时: 元素类型为 nil, %s",__FUNCTION__);
        [self hz_mutableInsertObject:[NSNull null] atIndex:index];
    }
}

-(void)hz_mutableAddObject:(id)object{
    if (object) {
        [self hz_mutableAddObject:object];
    }else{
        NSLog(@"插入值时: 元素类型为 nil, %s",__FUNCTION__);
        [self hz_mutableAddObject:[NSNull null]];
    }
}

@end



#pragma mark ------------------------------------  NSString -------------

@implementation NSString (CrashTerminator)

- (instancetype)hz_initWithString:(NSString *)aString
{
    if(nil == aString){
        NSLog(@"need log msg");
        return nil;
    }
    return [self hz_initWithString:aString];
}

- (BOOL)hz_hasPrefix:(NSString *)str
{
    if(nil == str){
        NSLog(@"need log msg");
        return NO;
    }
    return [self hz_hasPrefix:str];
}

- (BOOL)hz_hasSuffix:(NSString *)str
{
    if(nil == str){
        NSLog(@"need log msg");
        return NO;
    }
    return [self hz_hasSuffix:str];
}

@end



#pragma mark ------------------------------------  NSMutableString -------

@implementation NSMutableString (CrashTerminator)

- (instancetype)hz_initWithString:(NSString *)aString
{
    if(nil == aString){
        NSLog(@"need log msg");
        return nil;
    }
    return [self hz_initWithString:aString];
}

@end


#pragma mark ------------------------------------  CTWeakProxy  ------
@implementation CTWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[CTWeakProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end


#pragma mark ------------------------------------  NSTimer ----------

@implementation NSTimer (CrashTerminator)


+ (NSTimer *)hz_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
{
    NSLog(@"hz_scheduledTimerWithTimeInterval");
    return [self hz_scheduledTimerWithTimeInterval:ti target:[CTWeakProxy proxyWithTarget:aTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (NSTimer *)hz_timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    NSLog(@"hz_timerWithTimeInterval");
    return [self hz_timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}
@end



#pragma mark ------------------------------------  KVOProxy  -------

@implementation KVOProxy{
    pthread_mutex_t _mutex;
    NSMapTable<id, NSMutableSet<CPKVOInfo *> *> *_objectInfosMap;
}


- (instancetype)init
{
    self = [super init];
    if (nil != self) {
        
        _objectInfosMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];
        
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

-(BOOL)addKVOinfo:(id)object info:(CPKVOInfo *)info
{
    [self lock];
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    __block BOOL isHas = NO;
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([[info valueForKey:@"_keyPath"] isEqualToString:[obj valueForKey:@"_keyPath"]]){
            *stop = YES;
            isHas = YES;
        }
    }];
    if(isHas) {
        [self unlock];
        return NO ;
    }
    if(nil == infos){
        infos = [NSMutableSet set];
        [_objectInfosMap setObject:infos forKey:object];
    }
    [infos addObject:info];
    [self unlock];
    
    return YES;
}

-(void)removeKVOinfo:(id)object keyPath:(NSString *)keyPath block:(void(^)(void)) block
{
    [self lock];
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    __block CPKVOInfo *info;
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([keyPath isEqualToString:[obj valueForKey:@"_keyPath"]]){
            info = (CPKVOInfo *)obj;
            *stop = YES;
        }
    }];
    
    if (nil != info) {
        [infos removeObject:info];
        block();
        if (0 == infos.count) {
            [_objectInfosMap removeObjectForKey:object];
        }
    }
    [self unlock];
}

-(void)removeAllObserve
{
    if (_objectInfosMap) {
        NSMapTable *objectInfoMaps = [_objectInfosMap copy];
        for (id object in objectInfoMaps) {
            
            NSSet *infos = [objectInfoMaps objectForKey:object];
            if(nil==infos || infos.count==0) continue;
            [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                CPKVOInfo *info = (CPKVOInfo *)obj;
                [object removeObserver:self forKeyPath:[info valueForKey:@"_keyPath"]];
            }];
        }
        [_objectInfosMap removeAllObjects];
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    NSLog(@"KVOProxy - observeValueForKeyPath :%@",change);
    __block CPKVOInfo *info ;
    {
        [self lock];
        NSSet *infos = [_objectInfosMap objectForKey:object];
        [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([keyPath isEqualToString:[obj valueForKey:@"_keyPath"]]){
                info = (CPKVOInfo *)obj;
                *stop = YES;
            }
        }];
        [self unlock];
    }
    
    if (nil != info) {
        [object observeValueForKeyPath:keyPath ofObject:object change:change context:(__bridge void * _Nullable)([info valueForKey:@"_context"])];
    }
}

-(void)lock
{
    pthread_mutex_lock(&_mutex);
}

-(void)unlock
{
    pthread_mutex_unlock(&_mutex);
}

- (void)dealloc
{
    [self removeAllObserve];
    pthread_mutex_destroy(&_mutex);
    NSLog(@"KVOProxy dealloc");
}

@end




#pragma mark ------------------------------------------  CPKVOInfo ---------
@implementation CPKVOInfo{
@public
    NSString *_keyPath;
    NSKeyValueObservingOptions _options;
    SEL _action;
    void *_context;
    CPKVONotificationBlock _block;
}

- (instancetype)initWithKeyPath:(NSString *)keyPath
                        options:(NSKeyValueObservingOptions)options
                          block:(nullable CPKVONotificationBlock)block
                         action:(nullable SEL)action
                        context:(nullable void *)context
{
    self = [super init];
    if (nil != self) {
        _block = [block copy];
        _keyPath = [keyPath copy];
        _options = options;
        _action = action;
        _context = context;
    }
    return self;
}

- (instancetype)initWithKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    return [self initWithKeyPath:keyPath options:options block:NULL action:NULL context:context];
}

@end
