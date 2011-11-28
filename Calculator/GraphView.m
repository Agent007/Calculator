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
@synthesize dotMode = _dotMode;

#define DEFAULT_SCALE 1.0 //self.contentScaleFactor;

- (void)setup
{
    // TODO check that origin and scale weren't set to ridiculously large numbers from previous session, perhaps on a different device type (iPad/iPhone) with a different content scale
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
        
        // this doesn't seem to adversely affect performance according to time profiler
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
        
        // this doesn't seem to adversely affect performance according to time profiler
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:scale forKey:@"scale"];
        [defaults synchronize];
    }
}

- (void)setDotMode:(BOOL)dotMode
{
    _dotMode = dotMode;
    [self setNeedsDisplay];
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
    BOOL firstPointHasBeenEstablished = NO;
    CGFloat maxPixelWidth = bounds.size.width * self.contentScaleFactor;
    for (int pixelWidth = 0; pixelWidth < maxPixelWidth; pixelWidth++) {
        CGFloat x = (pixelWidth - origin.x)/scale;
        id output = [self calculateOutputValueForInputValue:x];
        if ([output isKindOfClass:[NSNumber class]]) {
            CGFloat y = [output floatValue];
            CGFloat height = origin.y - y*scale;
            if (self.dotMode) {
                CGContextFillRect(context, CGRectMake(pixelWidth, height, 1,1));
                firstPointHasBeenEstablished = YES;
            } else if (!firstPointHasBeenEstablished) {
                CGContextMoveToPoint(context, pixelWidth, height);
                firstPointHasBeenEstablished = YES;
            } else {
                CGContextAddLineToPoint(context, pixelWidth, height);
            }
        }
    }
    if (self.dotMode) {
        [[UIColor redColor] setFill];
        CGContextDrawPath(context, kCGPathFill); // TODO why does this draw dots as black instead of red?
    } else {
        [[UIColor redColor] setStroke];
        CGContextDrawPath(context, kCGPathStroke);
    }
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
