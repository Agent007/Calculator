//
//  GraphView.m
//  Calculator
//
//  Created by Jeffrey Lam on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;

#define DEFAULT_SCALE 1.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGPoint)origin
{
    // TODO get user preference origin
    if (!(_origin.x && _origin.y)) {
        _origin.x = self.bounds.origin.x + self.bounds.size.width/2;
        _origin.y = self.bounds.origin.y + self.bounds.size.height/2;
    }
    return _origin;
}

- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
    [self setNeedsDisplay];
}

- (CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
    size *= self.scale; // scale is percentage of full view size
    
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint newOrigin = [gesture locationInView:self];
        self.origin = CGPointMake(newOrigin.x, newOrigin.y);
    }
}

@end
