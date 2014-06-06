//
//  OpenSpatialTestDelegate.m
//  Open Spatial SDK
//
//  Created by Neel Bhoopalam on 6/2/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
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
