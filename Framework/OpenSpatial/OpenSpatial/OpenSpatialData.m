//
//  OpenSpatialData.m
//  OpenSpatial.framework
//
//  Created by Neel on 8/11/15.
//  Copyright (c) 2015 Nod Labs. All rights reserved.
//

#import "OpenSpatialData.h"

@implementation OpenSpatialData

-(instancetype)initForPeripheral:(CBPeripheral*)device withDataType:(ODataTag) dataType {
    if(self = [super init]) {
        self.peripheral = device;
        self.dataType = dataType;
        self.timeStamp = [NSDate date];
    }
    return self;
}
@end

@implementation AccelerometerData
-(instancetype)initForPeripheral:(CBPeripheral *)device x:(float)x y:(float)y z:(float)z {
    if(self = [super initForPeripheral:device withDataType:OS_RAW_ACCELEROMETER_TAG]) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}
@end

@implementation AnalogData
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(int)x withY:(int)y withTrigger:(int)trigger {
    if(self = [super initForPeripheral:device withDataType:OS_ANALOG_DATA_TAG]) {
        self.x = x;
        self.y = y;
        self.trigger = trigger;
    }
    return self;
}
@end

@implementation ButtonData
-(instancetype)initForPeripheral:(CBPeripheral *)device withButtonID:(int)buttonID withButtonState:(ButtonState)buttonState {
    if(self = [super initForPeripheral:device withDataType:OS_BUTTON_EVENT_TAG]) {
        self.buttonID = buttonID;
        self.buttonState = buttonState;
    }
    return self;
}
@end

@implementation CompassData
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(int)x withY:(int)y withZ:(int)z {
    if(self = [super initForPeripheral:device withDataType:OS_RAW_COMPASS_TAG]) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}
@end

@implementation EulerData
-(instancetype)initForPeripheral:(CBPeripheral *)device withRoll:(float)roll withPitch:(float)pitch withYaw:(float)yaw {
    if(self = [super initForPeripheral:device withDataType:OS_EULER_ANGLES_TAG]) {
        self.roll = roll;
        self.pitch = pitch;
        self.yaw = yaw;
    }
    return self;
}
@end

@implementation GestureData
-(instancetype)initForPeripheral:(CBPeripheral *)device withGestureType:(GestureType)gestureType {
    if(self = [super initForPeripheral:device withDataType:OS_DIRECTION_GESTURE_TAG]) {
        self.gestureType = gestureType;
    }
    return self;
}
@end

@implementation GyroscopeData
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(float)x withY:(float)y withZ:(float)z {
    if(self = [super initForPeripheral:device withDataType:OS_RAW_GYRO_TAG]) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}
@end

@implementation RelativeXYData
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(int)x withY:(int)y {
    if(self = [super initForPeripheral:device withDataType:OS_RELATIVE_XY_TAG]) {
        self.x = x;
        self.y = y;
    }
    return self;
}
@end

@implementation SliderData
-(instancetype)initForPeripheral:(CBPeripheral *)device withSliderType:(SliderType)sliderType {
    if(self = [super initForPeripheral:device withDataType:OS_SLIDER_GESTURE_TAG]) {
        self.sliderType = sliderType;
    }
    return self;
}
@end

@implementation TranslationData
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(float)x withY:(float)y withZ:(float)z {
    if(self = [super initForPeripheral:device withDataType:OS_TRANSLATIONS_TAG]) {
        self.x = x;
        self.y = y;
        self.z = z;
    }
    return self;
}
@end