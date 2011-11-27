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
- (id)performOperation:(NSString *)operation;
- (void)clear;
- (void)undo;
- (void)pushVariable:(NSString *)variable;

/**
 *
 * This will be a property list.
 */
@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
