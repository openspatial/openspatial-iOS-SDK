//
//  RotationEvent.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
    #import <CoreMotion/CoreMotion.h>
#endif
#import <CoreBluetooth/CoreBluetooth.h>

/*!
 Class which represents a Pose6D event containing x,y,z,yaw,pitch,roll
 */
@interface RotationEvent : NSObject 

@property float x;
@property float y;
@property float z;
@property float roll;
@property float pitch;
@property float yaw;
@property (nonatomic, assign) CBPeripheral* peripheral;


@end