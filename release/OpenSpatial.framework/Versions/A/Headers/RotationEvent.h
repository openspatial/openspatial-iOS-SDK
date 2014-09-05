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

@property float x;
@property float y;
@property float z;
@property float roll;
@property float pitch;
@property float yaw;
@property (nonatomic, assign) CBPeripheral* peripheral;


@end