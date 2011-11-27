//
//  GraphView.m
//  Calculator
//
//  Created by Jeffrey Lam on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"
#import "CalculatorBrain.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;

#define DEFAULT_SCALE 1.0 //self.contentScaleFactor;

- (void)setup
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _origin.x = [defaults floatForKey:@"origin.x"];
    _origin.y = [defaults floatForKey:@"origin.y"];
    _scale = [defaults floatForKey:@"scale"];
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (CGPoint)origin
{
    if (!(_origin.x && _origin.y)) { // Let's make the default be the center of the view
        _origin.x = self.bounds.origin.x + self.bounds.size.width/2;
        _origin.y = self.bounds.origin.y + self.bounds.size.height/2;
    }
    return _origin;
}

- (void)setOrigin:(CGPoint)origin
{
    if ((_origin.x != origin.x) && (_origin.y != origin.y)) {
        _origin = origin;
        [self setNeedsDisplay];
        
        // TODO try setting defaults in view close to improve performance
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:origin.x forKey:@"origin.x"];
        [defaults setFloat:origin.y forKey:@"origin.y"];
        [defaults synchronize];
    }
}

- (CGFloat)scale
{
    if (!_scale) {
        _scale = DEFAULT_SCALE;
    }
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
        
        // TODO try setting defaults in view close to improve performance
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:scale forKey:@"scale"];
        [defaults synchronize];
    }
}

- (id)calculateOutputValueForInputValue:(CGFloat)x
{
    return [CalculatorBrain runProgram:self.dataSource.calculatorProgram usingVariableValues:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:x] forKey:@"x"]];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint origin = self.origin;
    CGRect bounds = rect;//self.bounds;
    CGFloat scale = self.scale;
    
    [AxesDrawer drawAxesInRect:bounds originAtPoint:origin scale:scale];
    
    /* Plot graph */
    CGContextBeginPath(context);
    CGFloat maxPixelWidth = bounds.size.width * self.contentScaleFactor;
    for (int pixelWidth = 0; pixelWidth < maxPixelWidth; pixelWidth++) {
        CGFloat x = (pixelWidth - origin.x)/scale;
        id output = [self calculateOutputValueForInputValue:x];
        if ([output isKindOfClass:[NSNumber class]]) {
            CGFloat y = [output floatValue];
            CGFloat height = origin.y - y*scale;
            if (0 == pixelWidth) {
                CGContextMoveToPoint(context, 0, height);
            }
            CGContextAddLineToPoint(context, pixelWidth, height);
        }
    }
    [[UIColor redColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);
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
