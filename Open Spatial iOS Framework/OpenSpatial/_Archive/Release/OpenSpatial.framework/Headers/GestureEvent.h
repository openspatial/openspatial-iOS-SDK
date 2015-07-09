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
    NONE = -1,
    SWIPE_DOWN = 0,
    SWIPE_LEFT = 1,
    SWIPE_RIGHT = 2,
    SWIPE_UP = 3,
    CW = 4,
    CCW = 5,
    SLIDER_LEFT = 6,
    SLIDER_RIGHT = 7,
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
