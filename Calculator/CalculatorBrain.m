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

+ (NSSet *)twoOperandOperators
{
    return [NSSet setWithObjects:@"+", @"*", @"-", @"/", nil];
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

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description;
    
    id top = [stack lastObject];
    if (top) {
        [stack removeLastObject];
    } else {
        description = @"0";
    }
    
    // TODO insert commas
    if ([top isKindOfClass:[NSNumber class]]) {
        description = [top stringValue];
        /*
        if ([stack count] > 0) {
         description = [description stringByAppendingString:@", "];
         description = [description stringByAppendingString:[self descriptionOfTopOfStack:stack]];
        }*/

    } else if ([top isKindOfClass:[NSString class]]) {
        NSString *op = top;
        if ([self is2OperandOperation:op]) {
            NSString *secondOperand = [self descriptionOfTopOfStack:stack];
            description = [NSString stringWithFormat:@"(%@ %@ %@)", [self descriptionOfTopOfStack:stack], op, secondOperand];
        } else if ([self is1OperandOperation:op]) {
            description = [NSString stringWithFormat:@"%@(%@)", op, [self descriptionOfTopOfStack:stack]];
        } else { //if ([self is0OperandOperation:op] || [self isVariable:op]) {
            description = op;
        }
    }
    /*
    if ([stack count] > 0) {
        description = [description stringByAppendingString:@", "];
        description = [description stringByAppendingString:[self descriptionOfTopOfStack:stack]];
    }*/
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self descriptionOfTopOfStack:stack];
}

- (void)pushOperand:(double)operand;
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([[[self class] operators] member:topOfStack]) {
            NSString *operation = topOfStack;
            if ([operation isEqualToString:@"+"]) {
                result = [self popOperandOffProgramStack:stack] +
                [self popOperandOffProgramStack:stack];
            } else if ([@"*" isEqualToString:operation]) {
                result = [self popOperandOffProgramStack:stack] *
                [self popOperandOffProgramStack:stack];
            } else if ([operation isEqualToString:@"-"]) {
                double subtrahend = [self popOperandOffProgramStack:stack];
                result = [self popOperandOffProgramStack:stack] - subtrahend;
            } else if ([operation isEqualToString:@"/"]) {
                double divisor = [self popOperandOffProgramStack:stack];
                if (divisor) result = [self popOperandOffProgramStack:stack] / divisor; // else return "infinity"
            } else if ([@"sin" isEqualToString:operation]) {
                result = sin([self popOperandOffProgramStack:stack]);
            } else if ([@"cos" isEqualToString:operation]) {
                result = cos([self popOperandOffProgramStack:stack]);
            } else if ([@"sqrt" isEqualToString:operation]) {
                result = sqrt([self popOperandOffProgramStack:stack]);
            } else if ([@"π" isEqualToString:operation]) {
                result = M_PI;
            } else if ([@"+/-" isEqualToString:operation]) {
                result = -1 * [self popOperandOffProgramStack:stack];
            }
        } // else it may be a variable
    }
    
    return result;
}

- (double)performOperation:(NSString *)operation
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

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
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
