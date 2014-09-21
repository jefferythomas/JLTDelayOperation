//
//  JLTDelayOperationSubclass.h
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/29/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import "JLTDelayOperation.h"

@interface JLTDelayOperation (JLTDelayOperationProtected)

/*!
 @brief Finish execution of the operation.
 
 This is to be done once the delay duration has expired.
 */
- (void)finish;

@end
