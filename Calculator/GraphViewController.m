//
//  GraphViewController.m
//  Calculator
//
//  Created by Jeffrey Lam on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"

@interface GraphViewController() <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;

- (float)programForFaceView:(GraphView *)sender
{
    return 0.0;
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    // enable pinch gestures in the FaceView using its pinch: handler
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    // recognize a pan gesture and modify our Model
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    self.graphView.dataSource = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
