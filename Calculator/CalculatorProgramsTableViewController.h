//
//  CalculatorProgramsTableViewController.h
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorProgramsTableViewController;

@protocol CalculatorProgramsTableViewControllerDelegate <NSObject> // added <NSObject> after lecture so we can do respondsToSelector: on the delegate
@optional
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                 choseProgram:(id)program;
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                               deletedProgram:(id)program; // added after lecture to support deleting from table
@end

@interface CalculatorProgramsTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *programs; // of CalculatorBrain programs
@property (nonatomic, weak) id <CalculatorProgramsTableViewControllerDelegate> delegate;
@end
