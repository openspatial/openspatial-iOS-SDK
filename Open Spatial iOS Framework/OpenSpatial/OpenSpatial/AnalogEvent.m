//
//  AnalogEvent.m
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/22/15.
//  Copyright (c) 2015 Nod Labs. All rights reserved.
//


#import "AnalogEvent.h"

@implementation AnalogEvent

-(void)setAnalogEventCoordinatesAndData:(short int)tempX andY:(short int)tempY andTrigger:(short int)tempTrigger
{
    self.xVal = tempX;
    self.yVal = tempY;
    self.triggerVal = tempTrigger;
}

-(short int)getXValue
{
    return self.xVal;
}

-(short int)getYValue
{
    return self.yVal;
}

-(short int)getTriggerValue
{
    return self.triggerVal;
}

@end
