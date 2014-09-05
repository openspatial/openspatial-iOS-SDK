//
//  OpenSpatialTestDelegate.m
//  Open Spatial iOS SDKTests
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//


#import "OpenSpatialTestDelegate.h"

@implementation OpenSpatialTestDelegate

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent
{
    return buttonEvent;
}

-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent
{
    return pointerEvent;
}

-(RotationEvent *)rotationEventFired: (RotationEvent *) rotationEvent
{
    return rotationEvent;
}

-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent
{
    return gestureEvent;
}

@end
