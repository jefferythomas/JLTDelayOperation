//
//  JLTDelayOperation.m
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/25/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import "JLTDelayOperation.h"

typedef NS_OPTIONS(NSUInteger, JLTDelayOperationState) {
    JLTDelayOperationStateExecuting = 1 << 0,
    JLTDelayOperationStateFinished  = 1 << 1,
    JLTDelayOperationStateCancelled = 1 << 2,
};

@interface NSTimer (JLTDelayOperation)
+ (instancetype)scheduledTimerOnRunLoop:(NSRunLoop *)runLoop
                       withTimeInterval:(NSTimeInterval)timeInterval
                                 target:(id)target
                               selector:(SEL)selector
                               userInfo:(id)userInfo
                                repeats:(BOOL)yesOrNo;
@end

#pragma mark -

@interface JLTDelayOperation ()
@property JLTDelayOperationState jlt_state;
@property NSTimer *jlt_timer;
@end

#pragma mark -

@implementation JLTDelayOperation

- (void)start
{
    if (self.cancelled) {
        NSAssert(!self.executing && self.finished, @"Operation cancelled, but it's not in the proper state");
        return;
    }

    NSAssert(!self.executing && !self.finished, @"Operation started, but it's not in the proper state");
    self.jlt_state = JLTDelayOperationStateExecuting;

    self.jlt_timer = [NSTimer scheduledTimerOnRunLoop:[NSRunLoop mainRunLoop]
                                     withTimeInterval:self.delay
                                               target:self
                                             selector:@selector(jlt_fireTimer:)
                                             userInfo:nil
                                              repeats:NO];

    [self main]; // Leaving room for subclasses.
}

- (void)main
{
    // Does nothing, but a subclass might.
}

- (void)cancel
{
    [self.jlt_timer invalidate]; self.jlt_timer = nil;
    self.jlt_state = JLTDelayOperationStateFinished | JLTDelayOperationStateCancelled;
}

#pragma mark Private

- (void)jlt_finish
{
    self.jlt_timer = nil;
    self.jlt_state = JLTDelayOperationStateFinished;
}

- (void)jlt_fireTimer:(NSTimer *)timer
{
    [self jlt_finish];
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

#pragma mark -

@implementation NSTimer (JLTDelayOperation)

+ (instancetype)scheduledTimerOnRunLoop:(NSRunLoop *)runLoop
                       withTimeInterval:(NSTimeInterval)timeInterval
                                 target:(id)target
                               selector:(SEL)selector
                               userInfo:(id)userInfo
                                repeats:(BOOL)yesOrNo
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval
                                             target:target
                                           selector:selector
                                           userInfo:userInfo
                                            repeats:yesOrNo];

    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];

    return timer;
}

@end
