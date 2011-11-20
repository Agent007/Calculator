//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Jeffrey Lam on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInMiddleOfEnteringNumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize stackDisplay = _stackDisplay;
@synthesize userIsInMiddleOfEnteringNumber = _userIsInMiddleOfEnteringNumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)pushStackDisplay:(NSString *)op
{
    self.stackDisplay.text = [self.stackDisplay.text stringByAppendingString:op];
}

- (void)logMessageToBrain:(NSString *)msg
{
    [self pushStackDisplay:msg];
    [self pushStackDisplay:@" "];
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInMiddleOfEnteringNumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInMiddleOfEnteringNumber = YES;
    }
}

- (IBAction)enterPressed {
    NSString *numberString = self.display.text;
    [self.brain pushOperand:[numberString doubleValue]];
    self.userIsInMiddleOfEnteringNumber = NO;
    [self logMessageToBrain:numberString];
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    NSString *operation = sender.currentTitle;
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self logMessageToBrain:operation];
}

- (IBAction)decimalPressed {
    NSString *DOT = @".";
    
    if (self.userIsInMiddleOfEnteringNumber && [self.display.text rangeOfString:DOT].location == NSNotFound) {
        self.display.text = [self.display.text stringByAppendingString:DOT];
    } else if (!self.userIsInMiddleOfEnteringNumber) {
        self.display.text = DOT;
    }
    self.userIsInMiddleOfEnteringNumber = YES;
    [self pushStackDisplay:DOT];
}

- (IBAction)clearPressed {
    self.stackDisplay.text = self.display.text = @"";
    [self.brain clear];
}

- (IBAction)backspacePressed {
    if (self.userIsInMiddleOfEnteringNumber) {
        self.display.text = [self.display.text substringToIndex:([self.display.text length] - 1)];
        if ([self.display.text length] == 0) {
            self.display.text = @"0";
            self.userIsInMiddleOfEnteringNumber = NO;
        }
    }
}

@end
