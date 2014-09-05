//
//  SliderView.m
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import "SliderView.h"
#import "ViewController.h"

@implementation SliderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup
{
    UISwipeGestureRecognizer* lSwipe = [[UISwipeGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(leftSwipe:)];
    UISwipeGestureRecognizer* rSwipe = [[UISwipeGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(rightSwipe:)];
    lSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    rSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    UILongPressGestureRecognizer *LPGRec = [[UILongPressGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(longPress:)];
    LPGRec.minimumPressDuration = .3;
    [self addGestureRecognizer:LPGRec];
    [self addGestureRecognizer:lSwipe];
    [self addGestureRecognizer:rSwipe];
}

-(void) leftSwipe: (UIGestureRecognizer*) sender
{
    [((ViewController*)(self.parent)) leftSlidePressed];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0.8;
    }];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0.3;
    }];
}

-(void) rightSwipe: (UIGestureRecognizer*) sender
{
    [((ViewController*)(self.parent)) rightSlidePressed];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1.0;
    }];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0.3;
    }];
}

-(void) longPress: (UIGestureRecognizer*) sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        [((ViewController*)(self.parent)) SlideHoldPressed];
        [UIView animateWithDuration:.3 animations:^{
            self.backgroundColor = [ViewController colorWithHexString:@"F54029"];
        }];
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        [((ViewController*)(self.parent)) SlideHoldPressed];
        [UIView animateWithDuration:.3 animations:^{
            self.backgroundColor = [ViewController colorWithHexString:@"00A6DE"];
        }];
    }
}

@end
