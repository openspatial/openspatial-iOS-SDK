//
//  AnalogEvent.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/22/15.
//  Copyright (c) 2015 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AnalogEvent : NSObject

@property (nonatomic, assign) short int xVal;
@property (nonatomic, assign) short int yVal;
@property (nonatomic, assign) short int triggerVal;
@property (nonatomic, assign) CBPeripheral* peripheral;

/*!
 * Sets the coordinates of the pointer event
 * @param tempX - the x value that will be set for the analog event
 * @param tempY - the y value that will be set for the analog event
 * @param tempTrigger - the trigger value that will be set for the analog event
 */
-(void)setAnalogEventCoordinatesAndData:(short int)tempX andY:(short int)tempY andTrigger:(short int)tempTrigger;

/*!
 * Returns the x value for the analog event
 */
-(short int)getXValue;

/*!
 * Returns the y value for the analog event
 */
-(short int)getYValue;

/*!
 * Returns the trigger value for the analog event
 */
-(short int)getTriggerValue;

@end
