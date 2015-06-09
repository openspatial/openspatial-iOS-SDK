//
//  GestureEvennt.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*!
 * The different gesture event types a gesture event can hold
 */
typedef enum GestureEventType {
    SWIPE_DOWN,
    SWIPE_LEFT,
    SWIPE_RIGHT,
    SWIPE_UP,
    CW,
    CCW,
    SLIDER_LEFT,
    SLIDER_RIGHT,
} GestureEventType;

@interface GestureEvent : NSObject 

@property (nonatomic, assign) GestureEventType eventNum;
@property (nonatomic, assign) CBPeripheral* peripheral;

/*!
 * Sets the type of the gesture event
 * @param gestureEType - the type of the gesture event that it will take on
 */
-(void)setGestureEventType:(GestureEventType)gestureEType;

/*!
 * Returns the type of the gesture event
 */
-(GestureEventType)getGestureEventType;
@end
