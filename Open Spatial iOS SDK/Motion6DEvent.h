//
//  Motion6DEvent.h
//  Open Spatial iOS SDK
//
//  Created by Khwaab Dave on 3/17/15.
//  Copyright (c) 2015 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Motion6DEvent : NSObject

@property float xAccel;
@property float yAccel;
@property float zAccel;
@property float xGyro;
@property float yGryo;
@property float zGryo;
@property (nonatomic, assign) CBPeripheral* peripheral;

@end
