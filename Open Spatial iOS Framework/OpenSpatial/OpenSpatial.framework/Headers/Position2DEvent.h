//
//  Position2Devent.h
//  Open Spatial iOS SDK
//
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Position2DEvent : NSObject

@property (nonatomic, assign) short int xVal;
@property (nonatomic, assign) short int yVal;
@property (nonatomic, assign) CBPeripheral* peripheral;

/*!
 * Sets the coordinates of the position2D event
 * @param tempX - the x value that will be set for the position2D event
 * @param tempY - the y value that will be set for the position2D event
 */
-(void)setPosition2DEventCoordinates:(short int)tempX andY:(short int)tempY;

/*!
 * Returns the x value for the pointer event
 */
-(short int)getXValue;

/*!
 * Returns the y value for the pointer event
 */
-(short int)getYValue;

@end
