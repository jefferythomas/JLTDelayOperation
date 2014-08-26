//
//  JLTDelayOperation.h
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/25/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLTDelayOperation : NSOperation

@property (nonatomic) NSTimeInterval delay;

+ (instancetype)delayOperationWithDelay:(NSTimeInterval)delay;

@end
