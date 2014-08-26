//
//  ViewController.h
//  JLTDelayOperationDemo
//
//  Created by Jeffery Thomas on 8/25/14.
//  Copyright (c) 2014 JLT Source. No rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *commandButton;
@property (weak, nonatomic) IBOutlet UILabel *queueStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *queueCommandButton;

- (IBAction)execCommand:(id)sender;
- (IBAction)execQueueCommand:(id)sender;

@end

