//
//  JLTDelayOperation.h
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/25/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @brief The @c JLTDelayOperation class is a no-op @c NSOperation which allows
 dependent operations to delay their start.
 
 An instance of a @c JLTDelayOperation is created is a delay duration. Once
 started, the instance will execute for at least that duration. After the delay
 has expired, the instance will finish. The instance can be cancelled any time
 up until it has finished.
 */
@interface JLTDelayOperation : NSOperation

/*!
 The number of seconds to wait from the start of the operation to when the
 operation is marked as finished.
 */
@property (readonly) NSTimeInterval delay;

/*! Returns an initialized @c JLTDelayOperation object. */
+ (instancetype)delayOperationWithDelay:(NSTimeInterval)delay;

/*! Returns an initialized @c JLTDelayOperation object. */
- (instancetype)initWithDelay:(NSTimeInterval)delay;

@end

@interface NSBlockOperation (JLTDelayOperation)

/*!
 Creates a pair of @c NSOperation objects. The first operation is a
 @c JLTDelayOperation with the specified delay. The second operation is a
 @c NSBlockOperation with the specified block. The @c NSBlockOperation depends
 (@c -addDependency:) on the @c JLTDelayOperation.

 @returns a pair of @c NSOperation objects
 */
+ (NSArray *)blockOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block;

@end

@interface NSOperationQueue (JLTDelayOperation)

/*!
 Creates an operation and adds it to the operation queue. The operation will not
 start until after the specified delay. Returns a @c JLTDelayOperation instance
 so additional operations can be added with the same delay.

 @returns a @c JLTDelayOperation instance with the specified delay
 */
- (JLTDelayOperation *)addOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block;


/*!
 Creates an operation and adds it to the operation queue. The operation will not
 start until after the specified operation has finished.
 */
- (void)addOperationDependentOnOperation:(NSOperation *)operation withBlock:(void (^)(void))block;

@end
