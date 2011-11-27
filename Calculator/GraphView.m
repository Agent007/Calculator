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

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // TODO figure out why it's still not redrawing upon autorotation
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
    // TODO get user preference origin
    if (!(_origin.x && _origin.y)) {
        _origin.x = self.bounds.origin.x + self.bounds.size.width/2;
        _origin.y = self.bounds.origin.y + self.bounds.size.height/2;
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _origin.x = [defaults floatForKey:@"origin.x"];
        _origin.y = [defaults floatForKey:@"origin.y"];
    }
    return _origin;
}

- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
    [self setNeedsDisplay];
    
    // TODO try setting defaults in view close 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:origin.x forKey:@"origin.x"];
    [defaults setFloat:origin.y forKey:@"origin.y"];
    [defaults synchronize];
}

- (CGFloat)scale
{
    if (!_scale) {
        return self.contentScaleFactor;
    } else {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"scale"];
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:scale forKey:@"scale"];
        [defaults synchronize];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint origin = self.origin;
    CGRect bounds = rect;//self.bounds; // neither makes a difference in fixing scaling and rotation
    CGFloat scale = self.scale;
    
    [AxesDrawer drawAxesInRect:bounds originAtPoint:origin scale:scale];
    
    // TODO scale correctly when pinching
    CGContextBeginPath(context);
    CGFloat scaleFactor = self.contentScaleFactor;
    //CGFloat scaleFactorTimesScale = scaleFactor * scale;
    //CGFloat scaleFactorDividedByScale = scaleFactor / scale;
    CGFloat scaledOriginX = origin.x * scaleFactor;//TimesScale;
    CGFloat scaledOriginY = origin.y * scaleFactor;//TimesScale;
    CGFloat maxPixelWidth = bounds.size.width * scaleFactor;//TimesScale;
    //CGFloat maxPixelHeight = bounds.size.height * scaleFactor;
    for (int pixelWidth = 0; pixelWidth < maxPixelWidth; pixelWidth++) {
        CGFloat x = (pixelWidth - scaledOriginX);
        CGFloat y = x; // TODO get program // x*x/scale ; x = CONSTANT;
        CGFloat height = (scaledOriginY - y)/scaleFactor;//DividedByScale;
        if (0 == pixelWidth) {
            CGContextMoveToPoint(context, 0, height);
        }
        CGContextAddLineToPoint(context, pixelWidth/scaleFactor, height);
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
