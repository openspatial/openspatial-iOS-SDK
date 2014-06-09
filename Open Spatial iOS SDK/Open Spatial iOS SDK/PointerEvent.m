//
//  PointerEvent.m
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//


#import "PointerEvent.h"

@implementation PointerEvent

-(void)setPointerEventCoordinates:(short int)tempX andY:(short int)tempY
{
    self.xVal = tempX;
    self.yVal = tempY;
}

-(short int)getXValue
{
    return self.xVal;
}

-(short int)getYValue
{
    return self.yVal;
}

@end
