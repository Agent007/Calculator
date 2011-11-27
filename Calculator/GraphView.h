//
//  GraphView.h
//  Calculator
//
//  Created by Jeffrey Lam on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
@property (nonatomic, strong) id calculatorProgram;
@end

@interface GraphView : UIView 

/**
 *
 * Coordinates, in this view's coordinate system, of the drawn axes' origin.
 *
 */
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat scale;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)tripleTap:(UITapGestureRecognizer *)gesture;

@end
