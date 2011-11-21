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
    if (self.userIsInMiddleOfEnteringNumber && ![@"0" isEqualToString:self.display.text]) { // no need to enter integers with leading zeroes
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInMiddleOfEnteringNumber = YES;
    }
}

- (IBAction)enterPressed {
    NSString *numberString = self.display.text;
    double value = [numberString doubleValue];
    if (!value && ![@"0" isEqualToString:numberString]) {
        [self.brain pushVariable:numberString];
    } else {
        [self.brain pushOperand:value];
    }
    self.userIsInMiddleOfEnteringNumber = NO;
    [self logMessageToBrain:numberString];
}

- (void)performOperationAndDisplayResult:(NSString *)op
{
    double result = [self.brain performOperation:op];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self logMessageToBrain:[op stringByAppendingString:@"="]];

}

- (NSString *)negateNumberString:(NSString *)number
{
    if ([number hasPrefix:@"-"]) {
        number = [number substringFromIndex:1];
    } else {
        number = [@"-" stringByAppendingString:number];
    }
    return number;
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = sender.currentTitle;
    if (self.userIsInMiddleOfEnteringNumber) {
        if (![@"+/-" isEqualToString:operation]) {
            [self enterPressed];
        } else {
            self.display.text = [self negateNumberString:self.display.text];
            return;
        }
    }
    [self performOperationAndDisplayResult:operation];
}

- (IBAction)decimalPressed {
    NSString *DOT = @".";
    
    if (self.userIsInMiddleOfEnteringNumber && [self.display.text rangeOfString:DOT].location == NSNotFound) {
        self.display.text = [self.display.text stringByAppendingString:DOT];
    } else if (!self.userIsInMiddleOfEnteringNumber) {
        self.display.text = DOT;
    }
    self.userIsInMiddleOfEnteringNumber = YES;
}

- (IBAction)clearPressed {
    self.stackDisplay.text = @"";
    self.display.text = @"0";   
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

- (IBAction)undoPressed {
    [self backspacePressed];
    if ([@"0" isEqualToString:self.display.text]) {
        self.display.text = [[NSNumber numberWithDouble:[CalculatorBrain runProgram:self.brain.program]] stringValue];
    }
    if (!self.userIsInMiddleOfEnteringNumber) {
        [self.brain undo];
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = sender.currentTitle;
    self.display.text = variable;
    [self enterPressed];
}

@end
