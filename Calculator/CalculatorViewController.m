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
    if (!self.userIsInMiddleOfEnteringNumber && [@"π" isEqualToString:[self.brain.program lastObject]]) {  // We prefer to display pi symbol in brain log display when user presses enter button immediately after pi button
        [self.brain pushVariable:@"π"];
    } else {
        NSString *numberString = self.display.text;
        double value = [numberString doubleValue];
        if (!value && ![@"0" isEqualToString:numberString]) {
            [self.brain pushVariable:numberString];
        } else {
            [self.brain pushOperand:value];
        }
    }
    self.userIsInMiddleOfEnteringNumber = NO;
    [self logMessageToBrain];
}

- (void)updateDisplayResult:(id)result
{
    self.display.text = [NSString stringWithFormat:@"%@", result];
}

- (void)performOperationAndDisplayResult:(NSString *)op
{
    [self updateDisplayResult:[self.brain performOperation:op]];
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
    self.userIsInMiddleOfEnteringNumber = NO;
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
    self.variablesDisplay.text = @"";
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

- (void)updateVariablesDisplay
{
    self.variablesDisplay.text = @"";
    for (NSString *key in [CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        NSNumber *value = [self.testVariableValues valueForKey:key];
        if (value) {
            self.variablesDisplay.text = [self.variablesDisplay.text stringByAppendingString:[key stringByAppendingString:[@" = " stringByAppendingString:[value stringValue]]]];
            self.variablesDisplay.text = [self.variablesDisplay.text stringByAppendingString:@" "];
        }
    }
}

- (IBAction)undoPressed {
    [self backspacePressed];
    if (!self.userIsInMiddleOfEnteringNumber) {
        [self.brain undo];
        [self logMessageToBrain];
        [self updateDisplayResult:[CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
        [self updateVariablesDisplay];
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = sender.currentTitle;
    self.display.text = variable;
    [self enterPressed];
}

- (IBAction)testVariablesValuesPressed:(UIButton *)sender {
    //self.userIsInMiddleOfEnteringNumber = YES;
    NSString *testCase = sender.currentTitle;
    if ([@"Test 1" isEqualToString:testCase]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:-1.1], @"x", [NSNumber numberWithDouble:.1], @"y", [NSNumber numberWithDouble:1], @"nonexistent", nil];
    } else if ([@"Test 2" isEqualToString:testCase]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:-0.0], @"x", [NSNumber numberWithDouble:-1], @"y", [NSNumber numberWithDouble:2], @"z", nil];
    } else if ([@"Test 3" isEqualToString:testCase]) {
        self.testVariableValues = nil;
    }
    // update displays
    if ([CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        [self updateVariablesDisplay];
        [self updateDisplayResult:[CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
    }
}

@end
