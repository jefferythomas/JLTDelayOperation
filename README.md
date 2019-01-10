## JLTDelayOperation

The `JLTDelayOperation` class is a no-op `NSOperation` which allows dependent
operations to delay their start.

An instance of a `JLTDelayOperation` is created is a delay duration. Once
started, the instance will execute for at least that duration. After the delay
has expired, the instance will finish. The instance can be cancelled any time
up until it has finished.

### Examples

#### Basic Usage

The simplest way to get a delay operation is create an instance.

    JLTDelayOperation *delayOperation = [JLTDelayOperation delayOperationWithDelay:5.0];

The simplest way to execute the operation is to start it.

    JLTDelayOperation *delayOperation = [JLTDelayOperation delayOperationWithDelay:5.0];
    [delayOperation start];

This will perform a no-op operation which will finish after 5 seconds. This is
useful as a way to delay the start of other operations.

    JLTDelayOperation *delayOperation = [JLTDelayOperation delayOperationWithDelay:5.0];
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog("perform operation");
    }];

    [operation addDependency:delayOperation];

    NSOperationQueue *operationQueue = [[OperationQueue alloc] init];
    [operationQueue addOperations:@[delayOperation, operation] waitUntilFinished:NO];

#### Delay the start of multiple operations

Any number of operations can be delayed by a single `JLTDelayOperation`.

    JLTDelayOperation *delayOperation = [JLTDelayOperation delayOperationWithDelay:5.0];
    NSOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{ NSLog("1"); }];
    NSOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{ NSLog("2"); }];
    NSOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{ NSLog("3"); }];

    [operation1 addDependency:delayOperation];
    [operation2 addDependency:delayOperation];
    [operation3 addDependency:delayOperation];

    NSOperationQueue *operationQueue = [[OperationQueue alloc] init];
    [operationQueue addOperations:@[delayOperation, operation1, operation2, operation3]
                waitUntilFinished:NO];

#### Easy Delayed Block Operation

A block operation can be created with a delay using the `NSBlockOperation`
category method `-blockOperationWithDelay:andBlock:`.

    NSArray *operations = [NSBlockOperation blockOperationWithDelay:5.0 andBlock:^{
        NSLog("perform block operation");
    }];

    NSOperationQueue *operationQueue = [[OperationQueue alloc] init];
    [operationQueue addOperations:operations waitUntilFinished:NO];

Notice that an array of operations is returned. The array is a pair of
operations. The first operation is a `JLTDelayOperation` instance, the second
operation is an `NSBlockOperation` instance.

#### Easy Delayed Block Operation in an Operation Queue

An operation queue can add a block operation with a delay using the
`NSOperationQueue` category method `-addOperationWithDelay:andBlock:`.

    NSOperationQueue *operationQueue = [[OperationQueue alloc] init];

    JLTDelayOperation *delayOperation = [operationQueue addOperationWithDelay:5.0 andBlock:^{
        NSLog("perform block operation");
    }];

Here a `JLTDelayOperation` instance is returned. This instance can be used to
add multiple operations to the operation queue using the category method
`-addOperationDependentOnOperation:withBlock:`.

    NSOperationQueue *operationQueue = [[OperationQueue alloc] init];

    JLTDelayOperation *delayOperation = [operationQueue addOperationWithDelay:5.0 andBlock:^{
        NSLog("1");
    }];

    [operationQueue addOperationDependentOnOperation:delayOperation withBlock:^{
        NSLog("2");
    };

    [operationQueue addOperationDependentOnOperation:delayOperation withBlock:^{
        NSLog("3");
    };
