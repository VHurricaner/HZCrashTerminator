//
//  NSObject+CrashTerminator.h
//  HZCrashTerminator
//
//  Created by clouder on 2019/5/8.
//  Copyright © 2019 hurricaner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <pthread.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CrashTerminator)

+ (void)openCrashTerminator;
+ (BOOL)swizzlingInstanceMethod:(SEL _Nullable)originalSelector  replaceMethod:(SEL _Nullable)replaceSelector;

@end


#define kOPEN_CT  NO

@interface CrashProxy : NSObject

@property (nonatomic,copy) NSString * _Nullable crashMsg;

- (void)getCrashMsg;

@end




#pragma mark ------  NSDictionary -------
@interface NSDictionary (CrashTerminator)

@end

#pragma mark ------  NSMutableDictionary -------
@interface NSMutableDictionary (CrashTerminator)

@end


#pragma mark ------ NSArray ---------
@interface NSArray (CrashTerminator)

@end


#pragma mark ------ NSMutableArray --------
@interface NSMutableArray (CrashTerminator)

@end


#pragma mark ------ NSString  -----------
@interface NSString (CrashTerminator)

@end


#pragma mark ------ NSMutableString  ---------
@interface NSMutableString (CrashTerminator)

@end


#pragma mark ------  CTWeakProxy -----------
@interface CTWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype _Nullable)initWithTarget:(id _Nullable)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype _Nullable)proxyWithTarget:(id _Nullable)target;

@end


#pragma mark ------ NSTimer -----------
@interface NSTimer (CrashTerminator)

@end


#pragma mark ------ KVOProxy ---------
@class CPKVOInfo;
@interface KVOProxy : NSObject

-(BOOL)addKVOinfo:(id _Nullable)object info:(CPKVOInfo *_Nullable)info;
-(void)removeKVOinfo:(id _Nullable)object keyPath:(NSString *_Nullable)keyPath block:(void(^_Nullable)(void)) block;
-(void)removeAllObserve;
@end

typedef void (^CPKVONotificationBlock)(id _Nullable observer, id _Nullable object, NSDictionary<NSKeyValueChangeKey, id> * _Nullable change);



#pragma mark ------ CPKVOInfo ----------
@interface CPKVOInfo : NSObject

- (instancetype _Nullable )initWithKeyPath:(NSString *_Nullable)keyPath options:(NSKeyValueObservingOptions)options context:(void *_Nullable)context;

@end

NS_ASSUME_NONNULL_END
