//
//  ButtonEvent.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 5/29/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/*
 * The different button event types a button event can hold
 */
typedef enum ButtonEventType {
    TOUCH1_DOWN,
    TOUCH1_UP,
    TOUCH2_DOWN,
    TOUCH2_UP,
    TACTILE1_DOWN,
    TACTILE1_UP,
    TACTILE2_DOWN,
    TACTILE2_UP,
    SCROLL_UP,
    SCROLL_DOWN,
    SCROLL_TOUCH_DOWN,
    SCROLL_TOUCH_UP
} ButtonEventType;


@interface ButtonEvent : NSObject

@property (nonatomic, assign) ButtonEventType myButtonEventNum;
@property (nonatomic, assign) CBPeripheral* peripheral;

/*
 * Sets the type of the button event
 * @param buttonEType - the type of the button event that it will take on
 */
-(void)setButtonEventType:(ButtonEventType)buttonEType;

/*
 * Returns the type of a button event
 */
-(ButtonEventType)getButtonEventType;

@end
