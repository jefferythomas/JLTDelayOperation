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
@end

@implementation ViewController

- (IBAction)execCommand:(id)sender
{
    if (self.jlt_delayOperation.finished) {
        self.jlt_delayOperation = nil;
    } else if (self.jlt_delayOperation.executing) {
        [self.jlt_delayOperation cancel];
    } else {
        [self.jlt_delayOperation start];
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
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
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial;
    [self addObserver:self forKeyPath:@"jlt_delayOperation.executing" options:options context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"jlt_delayOperation.executing"];

    [super viewWillDisappear:animated];
}

#pragma mark Properties

@synthesize jlt_delayOperation = _jlt_delayOperation;

- (JLTDelayOperation *)jlt_delayOperation
{
    if (_jlt_delayOperation == nil) {
        _jlt_delayOperation = [JLTDelayOperation delayOperationWithDelay:5.0];
    }
    return _jlt_delayOperation;
}

- (void)setJlt_delayOperation:(JLTDelayOperation *)jlt_delayOperation
{
    // Be sure to cancel the old operation when assigning a new one.  Wait until
    // the _jlt_delayOperation has been reassigned before calling cancel to
    // avoid an errant KVO cancel message.
    JLTDelayOperation *oldDelayOperation = _jlt_delayOperation;
    _jlt_delayOperation = jlt_delayOperation;
    [oldDelayOperation cancel];
}

@end
