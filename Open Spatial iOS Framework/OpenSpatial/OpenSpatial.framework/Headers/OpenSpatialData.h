//
//  OpenSpatialData.h
//  OpenSpatial
//
//  Created by Neel Bhoopalam on 8/11/15.
//  Copyright (c) 2015 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "OpenSpatialConstants.h"

typedef enum ButtonState {
    DOWN,
    UP,
} ButtonState;

typedef enum GestureType {
    GESTURE_RIGHT            = 0x1,
    GESTURE_LEFT             = 0x2,
    GESTURE_DOWN             = 0x3,
    GESTURE_UP               = 0x4,
    GESTURE_CLOCKWISE        = 0x5,
    GESTURE_COUNTERCLOCKWISE = 0x6,
} GestureType;

typedef enum SliderType {
    SLIDE_DOWN = 0x1,
    SLIDE_UP   = 0x2,
} SliderType;

/**
 * The base class for all OpenSpatialData events.
 */
@interface OpenSpatialData : NSObject
/**
 * The OpenSpatial device that reported the data.
 */
@property CBPeripheral* peripheral;
/**
 * The {@code ODataTag} of the OpenSpatialData
 */
@property ODataTag dataType;
/**
 *  The NSDate at object creation.
 */
@property NSDate* timeStamp;
/**
 *  Create an {@code OpenSpatialEvent} with a given type.
 *
 *  @param device   The source of the data being reported.
 *  @param dataType The type of the data.
 */
-(instancetype)initForPeripheral:(CBPeripheral*)device withDataType:(ODataTag) dataType;
@end

/**
 * Contains raw accelerometer in units of G.
 */
@interface AccelerometerData : OpenSpatialData
/**
 * Accelerometer reading about x axis.
 */
@property float x;
/**
 * Accelerometer reading about y axis.
 */
@property float y;
/**
 * Accelerometer reading about z axis.
 */
@property float z;
/**
 *  Create a new {@code AccelerometerData} of the specified type
 *
 *  @param device Device {@link CBPeripheral} that sent this data
 *  @param x      Accelerometer reading in the x direction (in G's)
 *  @param y      Accelerometer reading in the y direction (in G's)
 *  @param z      Accelerometer reading in the z direction (in G's)
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device x:(float)x y:(float)y z:(float)z;
@end

/**
 * Contains the offset values of any analog buttons or actuators an OpenSpatial device may have.
 */
@interface AnalogData : OpenSpatialData
/**
 * The x value for {@code AnalogData}
 */
@property int x;
/**
 *  The y value for {@code AnalogData}
 */
@property int y;
/**
 *  The trigger value for {@code AnalogData}
 */
@property int trigger;
/**
 *  Create a new {@code AnalogData} of the specified type
 *
 *  @param device  Device {@link CBPeripheral} that sent this data
 *  @param x       X value for {@code AnalogData}
 *  @param y       Y value for {@code AnalogData}
 *  @param trigger Trigger value for {@code AnalogData}
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(int)x withY:(int)y withTrigger:(int)trigger;
@end

/**
 * Contains a report of a button entering a new state.
 */
@interface ButtonData : OpenSpatialData
/**
 * The button identifier of the {@code ButtonData}
 */
@property int buttonID;
/**
 * The {@link ButtonState} the button has entered
 */
@property ButtonState buttonState;
/**
 *  Create a new {@code ButtonData} of the specified type
 *
 *  @param device      Device {@link CBPeripheral} that sent this data
 *  @param buttonID    Identifier of the specific button on the device
 *  @param buttonState Refers to the up or down state of the {@code ButtonData}
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withButtonID:(int)buttonID withButtonState:(ButtonState)buttonState;
@end

/**
 * Contains the raw, unprocessed readings from the compass/magnetometer of 
 * an OpenSpatial device in units of uT.
 */
@interface CompassData : OpenSpatialData
/**
 * Compass reading in the x axis (in uT)
 */
@property int x;
/**
 * Compass reading in the y axis (in uT)
 */
@property int y;
/**
 * Compass reading in the z axis (in uT)
 */
@property int z;
/**
 *  Create a new {@code CompassData} of the specified type
 *
 *  @param device device {@link CBPeripheral} that sent this data
 *  @param x      Compass reading in the x axis
 *  @param y      Compass reading in the y axis
 *  @param z      Compass reading in the z axis
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(int)x withY:(int)y withZ:(int)z;
@end

/**
 * Contains the rotation of the Openspatial device in 3D space. The rotation axis used is x-y-z. 
 * The coordinate orientation is right handed with z facing up. All angles are in radians.
 */
@interface EulerData : OpenSpatialData
/**
 * Roll value in radians
 */
@property float roll;
/**
 * Pitch value in radians
 */
@property float pitch;
/**
 * Yaw value in radians
 */
@property float yaw;
/**
 *  Create a new {@code EulerData} object
 *
 *  @param device The device that emitted the Euler values.
 *  @param roll   The rotation about the x axis
 *  @param pitch  The rotation about the y axis
 *  @param yaw    The rotation about the z axis
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withRoll:(float)roll withPitch:(float)pitch withYaw:(float)yaw;
@end

/**
 * Contains gesture information being detected by an OpenSpatial device.
 */
@interface GestureData : OpenSpatialData
/**
 * The {@code GestureType} of the gesture that is being reported
 */
@property GestureType gestureType;
/**
 *  Create a new {@code GestureData} of the specified type
 *
 *  @param device      The device that emitted the Euler values.
 *  @param gestureType The {@code GestureType} of gesture being reported.
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withGestureType:(GestureType)gestureType;
@end

/**
 * Contains the raw, unprocessed readings from the gyroscope of an OpenSpatial device in
 * radians/second.
 */
@interface GyroscopeData : OpenSpatialData
/**
 * Gyroscope reading about the x axis
 */
@property float x;
/**
 * Gyroscope reading about the y axis
 */
@property float y;
/**
 * Gyroscope reading about the z axis
 */
@property float z;
/**
 *  Create a new {@code GyroscopeData} of the specified type
 *
 *  @param device The device reporting the gyroscopic data.
 *  @param x      The raw gyroscope reading about the x axis.
 *  @param y      The raw gyroscope reading about the y axis.
 *  @param z      The raw gyroscope reading about the z axis.
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(float)x withY:(float)y withZ:(float)z;
@end

/**
 * Provides a consumer with planar deltas about the the x and y axis. It is similar in 
 * nature to the output of pointing devices such as computer mice or
 * trackpads.
 */
@interface RelativeXYData : OpenSpatialData
/**
 * Relative translation in the x axis
 */
@property int x;
/**
 * Relative translation in the y axis
 */
@property int y;
/**
 *  Create a new {@code RelativeXYData}
 *
 *  @param device The device that emitted the relative x and y values
 *  @param x      The relative translation in the x axis
 *  @param y      The relative translation in the y axis
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(int)x withY:(int)y;
@end

/**
 * Reports a slider action.
 */
@interface SliderData : OpenSpatialData
/**
 * The type of slider event that is being reported
 */
@property SliderType sliderType;
/**
 *  Create a new {@code SliderData} object
 *
 *  @param device     The device reporting the gyroscopic data.
 *  @param sliderType The {@link SliderType} reported.
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withSliderType:(SliderType)sliderType;
@end

/**
 * Contains the delta translation reported by an OpenSpatial device.
 */
@interface TranslationData : OpenSpatialData
/**
 * Translation reading in the x axis
 */
@property float x;
/**
 * Translation reading in the y axis
 */
@property float y;
/**
 * Translation reading in the z axis
 */
@property float z;
/**
 *  Create a new {@code TranslationData} object
 *
 *  @param device The device reporting the gyroscopic data.
 *  @param x      The reported translation in the x direction.
 *  @param y      The reported translation in the y direction.
 *  @param z      The reported translation in the z direction.
 */
-(instancetype)initForPeripheral:(CBPeripheral *)device withX:(float)x withY:(float)y withZ:(float)z;
@end