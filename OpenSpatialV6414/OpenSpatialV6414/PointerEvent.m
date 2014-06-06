//
//  PointerEvent.m
//  Open Spatial SDK
//
//  Created by Neel Bhoopalam on 5/29/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
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
