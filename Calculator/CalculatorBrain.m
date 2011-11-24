//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Jeffrey Lam on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
+ (id)popOperandOffProgramStack:(NSMutableArray *)stack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSSet *)multiplicationAndDivision
{
    return [NSSet setWithObjects:@"*", @"/", nil];
}

+ (NSSet *)twoOperandOperators
{
    NSMutableSet *mutableSet = [[self multiplicationAndDivision] mutableCopy];
    [mutableSet unionSet:[NSSet setWithObjects:@"+", @"-", nil]];
    return mutableSet;
}

+ (NSSet *)oneOperandOperators
{
    return [NSSet setWithObjects:@"sin", @"cos", @"sqrt", @"+/-", nil];
}

+ (NSSet *)zeroOperandOperators
{
    return [NSSet setWithObjects:@"π", nil];
}

+ (NSSet *)operators
{
    NSMutableSet *ops = [NSMutableSet setWithSet:[self twoOperandOperators]];
    [ops unionSet:[self oneOperandOperators]];
    [ops unionSet:[self zeroOperandOperators]];
    return ops;
}

+ (BOOL)isMultiplicationOrDivision:(NSString *)op
{
    return [[self multiplicationAndDivision] containsObject:op];
}

+ (BOOL)is2OperandOperation:(NSString *)operation
{
    return [[self twoOperandOperators] containsObject:operation];
}

+ (BOOL)is1OperandOperation:(NSString *)operation
{
    return [[self oneOperandOperators] containsObject:operation];
}

+ (BOOL)is0OperandOperation:(NSString *)operation
{
    return [[self zeroOperandOperators] containsObject:operation];
}

+ (BOOL)isVariable:(NSString *)variable
{
    NSSet *VARIABLES = [NSSet setWithObjects:@"x", @"y", @"z", nil];
    return [VARIABLES containsObject:variable];
}

+ (BOOL)isOperation:(NSString *)operation
{
    return [[self operators] containsObject:operation];
}

+ (BOOL)isEnclosedByParentheses:(NSString *)description
{
    return ([@"(" isEqualToString:[description substringToIndex:1]] &&[@")" isEqualToString:[description substringFromIndex:([description length] - 1)]]);
}

// TODO insert commas
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description;
    
    id top = [stack lastObject];
    if (top) {
        [stack removeLastObject];
        if ([top isKindOfClass:[NSNumber class]]) {
            description = [top stringValue];
        } else if ([top isKindOfClass:[NSString class]]) {
            NSString *op = top;
            if ([self is2OperandOperation:op]) {
                NSString *secondOperand = [self descriptionOfTopOfStack:stack];
                NSString *format = @"(%@ %@ %@)";
                if ([self isMultiplicationOrDivision:op]) {
                    format = @"%@ %@ %@";
                }
                NSString *firstOperand = [self descriptionOfTopOfStack:stack];
                description = [NSString stringWithFormat:format, firstOperand, op, secondOperand];
            } else if ([self is1OperandOperation:op]) {
                NSString *topDescription = [self descriptionOfTopOfStack:stack];
                NSString *format = @"%@(%@)";
                if ([self isEnclosedByParentheses:topDescription]) {
                    format = @"%@%@";
                }
                if ([@"+/-" isEqualToString:op]) {
                    op = @"-";
                }
                description = [NSString stringWithFormat:format, op, topDescription];
            } else { //if ([self is0OperandOperation:op] || [self isVariable:op]) {
                description = op;
            }
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSString *description = [self descriptionOfTopOfStack:stack];
    if ([self isEnclosedByParentheses:description]) {
        NSRange range;
        range.location = 1;
        range.length = [description length] - 2;
        description = [description substringWithRange:range];
    }
    return description;
}

- (void)pushOperand:(double)operand;
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

+ (id)errorMessageOrVariable:(NSString *)op
{
    id result;
    if ([self isVariable:op]) {
        result = [NSNumber numberWithDouble:0];
    } else {
        result = op;
    }
    return result;
}

+ (id)resultOf2OperandOperation:(NSString *)op onStack:(NSMutableArray *)stack
{
    id result;
    id op2 = [self popOperandOffProgramStack:stack];
    id op1 = [self popOperandOffProgramStack:stack];
    if (!op1 || !op2) {
        result = @"Error: missing operand";
    } else if ([op1 isKindOfClass:[NSNumber class]] && [op2 isKindOfClass:[NSNumber class]]) {
        if ([@"+" isEqualToString:op]) {
            result = [NSNumber numberWithDouble:([op1 doubleValue] + [op2 doubleValue])];
        } else if ([@"*" isEqualToString:op]) {
            result = [NSNumber numberWithDouble:([op1 doubleValue] * [op2 doubleValue])];
        } else if ([@"-" isEqualToString:op]) {
            result = [NSNumber numberWithDouble:([op1 doubleValue] - [op2 doubleValue])];
        } else if ([@"/" isEqualToString:op]) {
            double divisorValue = [op2 doubleValue];
            if (!divisorValue) {
                result = @"Error: divide by zero";
            } else {
                result = [NSNumber numberWithDouble:([op1 doubleValue] / divisorValue)];
            }
        }
    } else if ([op1 isKindOfClass:[NSString class]]) {
        result = [self errorMessageOrVariable:op1];
    } else if ([op2 isKindOfClass:[NSString class]]) {
        result = [self errorMessageOrVariable:op2];
    }
    return result;
}

+ (id)resultOf1OperandOperation:(NSString *)op onStack:(NSMutableArray *)stack
{
    id result;
    id op1 = [self popOperandOffProgramStack:stack];
    if (!op1) {
        result = @"Error: missing operand";
    } else if ([op1 isKindOfClass:[NSNumber class]]) {
        if ([@"sin" isEqualToString:op]) {
            result = [NSNumber numberWithDouble:sin([op1 doubleValue])];
        } else if ([@"cos" isEqualToString:op]) {
            result = [NSNumber numberWithDouble:cos([op1 doubleValue])];
        } else if ([@"sqrt" isEqualToString:op]) {
            double value = [op1 doubleValue];
            if (value < 0) {
                result = @"Error: root of negative number";
            } else {
                result = [NSNumber numberWithDouble:sqrt(value)];
            }
        } else if ([@"+/-" isEqualToString:op]) {
            result = [NSNumber numberWithDouble:(-1 * [op1 doubleValue])];
        }
    } else {
        result = [self errorMessageOrVariable:op1];
    }
    return result;
}

+ (id)popOperandOffProgramStack:(NSMutableArray *)stack
{
    //double result = 0;
    id result;// = [NSNumber numberWithDouble:0];
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        //result = [topOfStack doubleValue];
        result = topOfStack;
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([[[self class] operators] member:topOfStack]) {
            NSString *operation = topOfStack;
            if ([self is2OperandOperation:operation]) {
                result = [self resultOf2OperandOperation:operation onStack:stack];
            } else if ([self is1OperandOperation:operation]) {
                result = [self resultOf1OperandOperation:operation onStack:stack];
            } else if ([@"π" isEqualToString:operation]) {
                result = [NSNumber numberWithDouble:M_PI];
            }
        } else { // else it may be a variable or error message
            result = topOfStack;
        }
    }
    
    return result;
}

- (id)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

- (void)clear
{
    [self.programStack removeAllObjects];
}

- (void)undo
{
    [self.programStack removeLastObject];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

+ (id)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack = program;
    NSSet *variables = [self variablesUsedInProgram:program];
    if (variables) {
        stack = [program mutableCopy];
        for (int i = 0; i < [stack count]; i++) {
            id element = [stack objectAtIndex:i];
            if ([variables containsObject:element] && [variableValues objectForKey:element]) {
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:element]];
            }
        }
    }
    return [self runProgram:stack];
}


+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSSet *variables;
    if ([program isKindOfClass:[NSArray class]]) {
        NSArray *stack = [program copy];
        for (id element in stack) {
            if ([element isKindOfClass:[NSString class]]) {
                NSString *elementString = element;
                if (![self isOperation:elementString] && [self isVariable:elementString]) {
                    if (!variables) {
                        variables = [NSSet setWithObject:elementString]; 
                    } else {
                        variables = [variables setByAddingObject:elementString];
                    }
                }
            }
        }
    }
    return variables;
}

@end
