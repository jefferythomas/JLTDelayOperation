//
//  JLTDelayOperationSubclass.h
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/29/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import "JLTDelayOperation.h"

@interface JLTDelayOperation (JLTDelayOperationProtected)

@property (atomic) NSTimer *timer; ///> The timer used for the delay duration.

/*!
 @brief Finish execution of the operation.
 
 This is to be done once the delay duration has expired.
 */
- (void)finish;

/*!
 @brief Expire the tracking of the delay duration.
 
 Expiring the tracking is done either when the operation has finished or when
 the operation is cancelled.
 */
- (void)expireDelay;

@end
