//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Jeffrey Lam on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (void)clear;
- (void)undo;
- (void)pushVariable:(NSString *)variable;

@property (nonatomic, readonly) id program;
+ (NSSet *)twoOperandOperators;
+ (NSSet *)oneOperandOperators;
+ (NSSet *)zeroOperandOperators;
+ (NSSet *)operators;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (BOOL)is2OperandOperation:(NSString *)operation;
+ (BOOL)is1OperandOperation:(NSString *)operation;
+ (BOOL)is0OperandOperation:(NSString *)operation;
+ (BOOL)isVariable:(NSString *)variable;
+ (BOOL)isOperation:(NSString *)operation;
@end
