JLTDelayOperation
=================

The `JLTDelayOperation` class is a no-op `NSOperation` which allows dependent
operations to delay their start.

An instance of a `JLTDelayOperation` is created is a delay duration. Once
started, the instance will execute for at least that duration. After the delay
has expired, the instance will finish. The instance can be cancelled any time
up until it has finished.
