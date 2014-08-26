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

@interface JLTDelayOperation ()
@property JLTDelayOperationState jlt_state;
@property NSTimer *jlt_timer;
@end

@implementation JLTDelayOperation

- (void)start
{
    if (self.cancelled) {
        NSAssert(!self.executing, @"");
        NSAssert(self.finished, @"");
        return;
    }

    NSAssert(!self.executing, @"");
    NSAssert(!self.finished, @"");

    self.jlt_state = JLTDelayOperationStateExecuting;
    self.jlt_timer = [self jlt_timerWithDelay:self.delay target:self selector:@selector(jlt_finish:)];

    [self main];
}

- (void)main
{
    // Does nothing!
}

- (void)cancel
{
    [self jlt_finish:self];
}

#pragma mark Private

- (void)jlt_finish:(id)sender
{
    [self.jlt_timer invalidate];
    self.jlt_timer = nil;

    if ([sender isKindOfClass:[NSTimer class]]) {
        self.jlt_state = JLTDelayOperationStateFinished;
    } else {
        self.jlt_state = JLTDelayOperationStateFinished | JLTDelayOperationStateCancelled;
    }
}

- (NSTimer *)jlt_timerWithDelay:(NSTimeInterval)delay target:(id)target selector:(SEL)sel
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:target selector:sel userInfo:nil repeats:NO];

    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop run]; // ensure the runLoop is going.

    return timer;
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

@implementation NSBlockOperation (JLTDelayOperation)

+ (NSArray *)blockOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block
{
    JLTDelayOperation *delayOperation = [JLTDelayOperation delayOperationWithDelay:delay];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:block];

    [blockOperation addDependency:delayOperation];

    return @[delayOperation, blockOperation];
}

@end

@implementation NSOperationQueue (JLTDelayOperation)

- (NSArray *)addOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block
{
    NSArray *operations = [NSBlockOperation blockOperationWithDelay:delay andBlock:block];

    [self addOperations:operations waitUntilFinished:NO];

    return operations;
}

@end
