//
//  JLTDelayOperation.h
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/25/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLTDelayOperation : NSOperation

@property (readonly) NSTimeInterval delay;

+ (instancetype)delayOperationWithDelay:(NSTimeInterval)delay;

@end

@interface NSBlockOperation (JLTDelayOperation)

+ (NSArray *)blockOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block;

@end

@interface NSOperationQueue (JLTDelayOperation)

- (NSArray *)addOperationWithDelay:(NSTimeInterval)delay andBlock:(void (^)(void))block;

@end