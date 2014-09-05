//
//  OpenSpatialTestDelegate.h
//  Open Spatial iOS SDKTests
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "OpenSpatialBluetooth.h"

@interface OpenSpatialTestDelegate : NSObject <OpenSpatialBluetoothDelegate>

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent;
-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent;
-(RotationEvent *)rotationEventFired: (RotationEvent *) rotationEvent;
-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent;

@end
