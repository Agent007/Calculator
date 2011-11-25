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
- (float)programForFaceView:(GraphView *)sender;
@end

@interface GraphView : UIView

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat scale;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;


@end
