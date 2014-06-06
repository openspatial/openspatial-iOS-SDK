//
//  TouchView.m
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

CGPoint lastPoint;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    lastPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint current = [touch locationInView:self];
    int xdiff = current.x - lastPoint.x;
    int ydiff = current.y - lastPoint.y;
    lastPoint = current;
    [self.delegate sendCoordinates:xdiff y:ydiff];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    int xdiff = 0;
    int ydiff = 0;
    lastPoint.x = 0;
    lastPoint.y = 0;
    [self.delegate sendCoordinates:xdiff y:ydiff];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}


@end
