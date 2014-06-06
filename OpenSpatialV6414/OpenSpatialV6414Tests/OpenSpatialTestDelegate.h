//
//  OpenSpatialTestDelegate.h
//  Open Spatial SDK
//
//  Created by Neel Bhoopalam on 6/2/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSpatialBluetooth.h"

@interface OpenSpatialTestDelegate : NSObject <OpenSpatialBluetoothDelegate>

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent;
-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent;
-(RotationEvent *)rotationEventFired: (RotationEvent *) rotationEvent;
-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent;

@end
