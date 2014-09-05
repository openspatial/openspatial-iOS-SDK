//
//  PointerEvent.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PointerEvent : NSObject 

@property (nonatomic, assign) short int xVal;
@property (nonatomic, assign) short int yVal;
@property (nonatomic, assign) CBPeripheral* peripheral;

/*
 * Sets the coordinates of the pointer event
 * @param tempX - the x value that will be set for the pointer event
 * @param tempY - the y value that will be set for the pointer event
 */
-(void)setPointerEventCoordinates:(short int)tempX andY:(short int)tempY;

/*
 * Returns the x value for the pointer event
 */
-(short int)getXValue;

/*
 * Returns the y value for the pointer event
 */
-(short int)getYValue;

@end
