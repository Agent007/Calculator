//
//  GraphViewController.m
//  Calculator
//
//  Created by Jeffrey Lam on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController() < CalculatorProgramsTableViewControllerDelegate>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIPopoverController *popoverController; // added after lecture to prevent multiple popovers

@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize calculatorProgram = _calculatorProgram;
@synthesize popoverController;// = _popoverController; // already declared as ivar in UIViewController

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    _graphView.dataSource = self;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapRecognizer];
}

- (void)setCalculatorProgram:(id)calculatorProgram
{
    _calculatorProgram = calculatorProgram;
    [self.graphView setNeedsDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)addToFavorites {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *FAVORITES_KEY = @"CalculatorGraphViewController.Favorites";
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) {
        favorites = [NSMutableArray array];
    }
    id calculatorProgram = self.calculatorProgram;
    if (calculatorProgram) {
        [favorites addObject:calculatorProgram];
        [defaults setObject:favorites forKey:FAVORITES_KEY];
        [defaults synchronize];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"]) {
        // this if statement added after lecture to prevent multiple popovers
        // appearing if the user keeps touching the Favorites button over and over
        // simply remove the last one we put up each time we segue to a new one
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = popoverSegue.popoverController; // might want to be popover's delegate and self.popoverController = nil on dismiss?
        }
        NSString *FAVORITES_KEY = @"CalculatorGraphViewController.Favorites";
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                 choseProgram:(id)program
{
    self.calculatorProgram = program;
    // if you wanted to close the popover when a graph was selected
    // you could uncomment the following line
    // you'd probably want to set self.popoverController = nil after doing so
    // [self.popoverController dismissPopoverAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES]; // added after lecture to support iPhone
}

// added after lecture to support deletion from the table
// deletes the given program from NSUserDefaults (including duplicates)
// then resets the Model of the sender
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                               deletedProgram:(id)program
{
    NSString *deletedProgramDescription = [CalculatorBrain descriptionOfProgram:program];
    NSMutableArray *favorites = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *FAVORITES_KEY = @"CalculatorGraphViewController.Favorites";
    for (id program in [defaults objectForKey:FAVORITES_KEY]) {
        if (![[CalculatorBrain descriptionOfProgram:program] isEqualToString:deletedProgramDescription]) {
            [favorites addObject:program];
        }
    }
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
    sender.programs = favorites;
}

@end
