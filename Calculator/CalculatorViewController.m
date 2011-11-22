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
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize stackDisplay = _stackDisplay;
@synthesize variablesDisplay = _variablesDisplay;
@synthesize userIsInMiddleOfEnteringNumber = _userIsInMiddleOfEnteringNumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)logMessageToBrain
{
    self.stackDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
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
    [self logMessageToBrain];
}

- (void)performOperationAndDisplayResult:(NSString *)op
{
    double result = [self.brain performOperation:op];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self logMessageToBrain];

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

- (void)updateVariablesDisplay
{
    self.variablesDisplay.text = @"";
    for (id key in [CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        if ([key isKindOfClass:[NSString class]]) {
            id value = [self.testVariableValues valueForKey:(NSString *)key];
            if ([value isKindOfClass:[NSNumber class]]) {
                self.variablesDisplay.text = [self.variablesDisplay.text stringByAppendingString:[key stringByAppendingString:[@" = " stringByAppendingString:[(NSNumber *)value stringValue]]]];
                self.variablesDisplay.text = [self.variablesDisplay.text stringByAppendingString:@" "];
            }
        }
    }
}

- (IBAction)testVariablesValuesPressed:(UIButton *)sender {
    NSString *testCase = sender.currentTitle;
    if ([@"Test 1" isEqualToString:testCase]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:-1.1], @"x", [NSNumber numberWithDouble:.1], @"y", [NSNumber numberWithDouble:1], @"nonexistent", nil];
    } else if ([@"Test 2" isEqualToString:testCase]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:-0.0], @"x", [NSNumber numberWithDouble:-1], @"y", [NSNumber numberWithDouble:2], @"z", nil];
    } else if ([@"Test 3" isEqualToString:testCase]) {
        self.testVariableValues = nil;
    }
    // update both main and variables displays
    [self updateVariablesDisplay];
}


@end
