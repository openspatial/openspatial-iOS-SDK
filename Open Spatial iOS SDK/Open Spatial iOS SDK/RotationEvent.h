//
//  RotationEvent.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface RotationEvent : NSObject 

@property CMQuaternion quat;
@property (nonatomic, assign) CBPeripheral* peripheral;

/*
 * Sets the quaternion for the rotation event
 */
-(void)setQuaternion:(CMQuaternion)tempQuat;

/*
 * Returns the quaternion of the rotation event
 */
-(CMQuaternion)getQuaternion;

@end