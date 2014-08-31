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
@property (atomic) NSTimer *timer;
@property (atomic) JLTDelayOperationState jlt_state;
@end

#pragma mark -

@implementation JLTDelayOperation

- (void)finish
{
    if (self.finished) {
        return;
    }

    [self expireDelay];
    self.jlt_state = JLTDelayOperationStateFinished;
}

- (void)expireDelay
{
    [self.timer invalidate];
    self.timer = nil;
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

    self.timer = [NSTimer timerWithTimeInterval:self.delay
                                         target:self
                                       selector:@selector(jlt_fireTimer:)
                                       userInfo:nil
                                        repeats:NO];

    // NOTE: The main run loop is always running, so it a good place to run the
    //       timer. Starting the timer on the current run loop would require
    //       maintaining that run loop.
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)cancel
{
    if (self.finished) {
        return;
    }

    [self expireDelay];
    self.jlt_state = JLTDelayOperationStateFinished | JLTDelayOperationStateCancelled;
}

#pragma mark Private

- (void)jlt_fireTimer:(NSTimer *)timer
{
    [self finish];
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

- (NSArray *)addOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block
{
    NSArray *operations = [NSBlockOperation blockOperationWithDelay:delay andBlock:block];

    [self addOperations:operations waitUntilFinished:NO];

    return operations;
}

@end
