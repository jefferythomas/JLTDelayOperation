//
//  ViewController.m
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/25/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import "ViewController.h"
#import "JLTDelayOperation.h"

@interface ViewController ()
@property (nonatomic) JLTDelayOperation *jlt_delayOperation;
@property (nonatomic) JLTDelayOperation *jlt_delayOperationInQueue;
@property (nonatomic) NSBlockOperation *jlt_blockOperationInQueue;
@property (nonatomic) NSOperationQueue *jlt_operationQueue;
@end

@implementation ViewController

- (IBAction)execCommand:(id)sender
{
    if (self.jlt_delayOperation.finished) {
        self.jlt_delayOperation = nil;
    } else if (self.jlt_delayOperation.executing) {
        [self.jlt_delayOperation cancel];
    } else {
        JLTDelayOperation *operation = [JLTDelayOperation delayOperationWithDelay:5.0];
        [operation start];
        self.jlt_delayOperation = operation;
    }
}

- (IBAction)execQueueCommand:(id)sender
{
    if ([self.jlt_delayOperationInQueue isFinished]) {
        self.jlt_delayOperationInQueue = nil;
        self.jlt_blockOperationInQueue = nil;
    } else if ([self.jlt_delayOperationInQueue isExecuting]) {
        [self.jlt_operationQueue cancelAllOperations];
    } else {
        NSArray *operations = [self.jlt_operationQueue addOperationWithDelay:5.0 andBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"YES");
            });
        }];

        self.jlt_delayOperationInQueue = operations[0];
        self.jlt_blockOperationInQueue = operations[1];
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"jlt_delayOperation.isExecuting"]) {
        if (self.jlt_delayOperation.cancelled) {
            self.stateLabel.text = @"Cancelled";
            [self.commandButton setTitle:@"Reset" forState:UIControlStateNormal];
        } else if (self.jlt_delayOperation.finished) {
            self.stateLabel.text = @"Finished";
            [self.commandButton setTitle:@"Reset" forState:UIControlStateNormal];
        } else if (self.jlt_delayOperation.executing) {
            self.stateLabel.text = @"Executing";
            [self.commandButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            self.stateLabel.text = @"Ready";
            [self.commandButton setTitle:@"Start" forState:UIControlStateNormal];
        }
    } else if ([keyPath isEqualToString:@"jlt_delayOperationInQueue.isExecuting"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.jlt_delayOperationInQueue isCancelled]) {
                self.queueStateLabel.text = @"Cancelled";
                [self.queueCommandButton setTitle:@"Reset" forState:UIControlStateNormal];
            } else if ([self.jlt_delayOperationInQueue isFinished]) {
                self.queueStateLabel.text = @"Finished";
                [self.queueCommandButton setTitle:@"Reset" forState:UIControlStateNormal];
            } else if ([self.jlt_delayOperationInQueue isExecuting]) {
                self.queueStateLabel.text = @"Executing";
                [self.queueCommandButton setTitle:@"Cancel" forState:UIControlStateNormal];
            } else {
                self.queueStateLabel.text = @"Ready";
                [self.queueCommandButton setTitle:@"Start" forState:UIControlStateNormal];
            }
        });
    }
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial;
    [self addObserver:self forKeyPath:@"jlt_delayOperation.isExecuting" options:options context:NULL];
    [self addObserver:self forKeyPath:@"jlt_delayOperationInQueue.isExecuting" options:options context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"jlt_delayOperation.isExecuting"];
    [self removeObserver:self forKeyPath:@"jlt_delayOperationInQueue.isExecuting"];

    [super viewWillDisappear:animated];
}

#pragma mark Properties

- (NSOperationQueue *)jlt_operationQueue
{
    if (_jlt_operationQueue == nil) {
        _jlt_operationQueue = [NSOperationQueue new];
    }

    return _jlt_operationQueue;
}

@end
