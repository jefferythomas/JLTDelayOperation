//
//  JLTDelayOperation.m
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/25/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import "JLTDelayOperationSubclass.h"

typedef NS_OPTIONS(NSUInteger, JLTDelayOperationState) {
    JLTDelayOperationStateExecuting = 1 << 0,
    JLTDelayOperationStateFinished  = 1 << 1,
    JLTDelayOperationStateCancelled = 1 << 2,
};

@interface JLTDelayOperation ()
@property (atomic) JLTDelayOperationState jlt_state;
@end

#pragma mark -

@implementation JLTDelayOperation

- (void)finish
{
    if (self.finished) {
        return;
    }

    self.jlt_state = JLTDelayOperationStateFinished;
}

#pragma mark NSOperation overrides

- (void)start
{
    NSAssert(!self.executing, @"-start called on an executing operation.");
    NSAssert(self.finished == self.cancelled,
             self.finished ?
             @"-start called on a finished non-cancelled operation." :
             @"-start called on a non-finished cancelled operation (impossible).");

    if (self.finished) {
        return;
    }

    self.jlt_state = JLTDelayOperationStateExecuting;
    [self main];
}

- (void)main
{
    NSAssert(self.executing, @"-main called on a non-executing operation.");
    NSAssert(!self.cancelled, @"-main called on a cancelled operation.");
    NSAssert(!self.finished, @"-main called on a finished operation.");

    dispatch_queue_t dispatchQueue = [self jlt_dispatchQueue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatchQueue, ^{
        if (!self.cancelled) {
            [self finish];
        }
    });
}

- (void)cancel
{
    if (self.finished) {
        return;
    }

    self.jlt_state = JLTDelayOperationStateFinished | JLTDelayOperationStateCancelled;
}

#pragma mark Private

- (dispatch_queue_t)jlt_dispatchQueue
{
    NSOperationQueue *queue = [NSOperationQueue currentQueue];

    if (queue == nil) {
        // If this operation was started outside any operation queue, then
        // return a dispatch queue for it to execute in.
        return dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
    }

    return queue.underlyingQueue;
}

#pragma mark Memory lifecycle

+ (instancetype)delayOperationWithDelay:(NSTimeInterval)delay
{
    return [[self alloc] initWithDelay:delay];
}

- (instancetype)initWithDelay:(NSTimeInterval)delay
{
    self = [super init];
    if (self) {
        _delay = delay;
    }
    return self;
}

#pragma mark Properties

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.jlt_state & JLTDelayOperationStateExecuting;
}

- (BOOL)isFinished
{
    return self.jlt_state & JLTDelayOperationStateFinished;
}

- (BOOL)isCancelled
{
    return self.jlt_state & JLTDelayOperationStateCancelled;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSArray *keyPaths = @[@"isExecuting", @"executing",
                          @"isFinished",  @"finished",
                          @"isCancelled", @"cancelled"];

    if ([keyPaths containsObject:key]) {
        return [NSSet setWithObject:@"jlt_state"];
    }

    return nil;
}

@end

#pragma mark -

@implementation NSBlockOperation (JLTDelayOperation)

+ (NSArray *)blockOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block
{
    JLTDelayOperation *delayOperation = [JLTDelayOperation delayOperationWithDelay:delay];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:block];

    [blockOperation addDependency:delayOperation];

    return @[delayOperation, blockOperation];
}

@end

#pragma mark -

@implementation NSOperationQueue (JLTDelayOperation)

- (JLTDelayOperation *)addOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block
{
    JLTDelayOperation *delayOperation = [JLTDelayOperation delayOperationWithDelay:delay];
    [self addOperation:delayOperation];

    [self addOperationDependentOnOperation:delayOperation withBlock:block];

    return delayOperation;
}

- (void)addOperationDependentOnOperation:(NSOperation *)operation withBlock:(void (^)(void))block
{
    NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:block];
    [blockOperation addDependency:operation];
    [self addOperation:blockOperation];
}

@end
