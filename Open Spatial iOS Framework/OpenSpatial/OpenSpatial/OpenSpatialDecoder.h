//
//  OpenSpatialDecoder.h
//  Nod Labs
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

/*!
 *  This class decodes an openspatial pointer sent as a byte
 *  array. The function will return an array containing useful
 *  values from the openspatial pointer
 *
 *  The decode2DPOSPointer method returns a dictionary containing keys:
 *      "x" = x coordinate
 *      "y" = y coordinate
 *
 *  The decode3DTransPointer method returns a dictionary containing keys:
 *      "x" = x translation value
 *      "y" = y translation value
 *      "z" = z translation value
 *      "pitch" = pitch value
 *      "roll" = roll value
 *      "yaw" = yaw value
 * 
 *  The decodeGestPointer method retuns a dictionary containing keys:
 *      "gest" = gesture op code (determines the gesture type)
 *      "data" = gesture data
 *
 *      op code values are listed below in the format G_OP_XXXXXX
 *      gesture values are listed below op codes
 *
 *  The decodeButtonPointer method returns dictionary containing keys:
 *      "touch0" = the value of touch0
 *      "touch1" = the value of touch1
 *      "touch2" = the value of touch2
 *      "tactile0" = the value of tactile0
 *      "tactile1" = the value of tactile1
 *
 *      touch values are defined in BUTTON_UNUSED, BUTTON_UP, BUTTON_DOWN
 *
 *  The create values are used to create a pointer to data for
 *  either 2D, 3D, Buttons, or Gestures. The bytes reffered to by
 *  the pointer are formatted according to the Open Spatial specification
 */

#import <Foundation/Foundation.h>
#import "ButtonEvent.h"

#define X @"x"
#define Y @"y"
#define Z @"z"
#define TRIGGER @"trigger"
#define ROLL @"roll"
#define PITCH @"pitch"
#define YAW @"yaw"
#define TOUCH_0 @"touch0"
#define TOUCH_1 @"touch1"
#define TOUCH_2 @"touch2"
#define TACTILE_0 @"tactile0"
#define TACTILE_1 @"tactile1"
#define GEST_OPCODE @"gest"
#define GEST_DATA @"data"
#define G_OP_SCROLL 0x0001
#define G_OP_DIRECTION 0x0002
#define GRIGHT 0x01
#define GLEFT 0x02
#define GDOWN 0x03
#define GUP 0x04
#define GCW 0x05
#define GCCW 0x06
#define SLIDE_LEFT 0x01
#define SLIDE_RIGHT 0x02
#define BUTTON_UNUSED 0
#define BUTTON_UP 2
#define BUTTON_DOWN 1
#define XA @"accelerometer x"
#define YA @"accelerometer y"
#define ZA @"accelerometer z"
#define XG @"gyroscope x"
#define YG @"gyroscope y"
#define ZG @"gyroscope y"

typedef enum ODataTag {
    OS_RAW_ACCELEROMETER_TAG = 0x20, /* 3x int16: x y z */
    OS_RAW_GYRO_TAG          = 0x21, /* 3x int16: x y z */
    OS_RAW_COMPASS_TAG       = 0x22, /* 3x int16: x y z */
    OS_EULER_ANGLES_TAG      = 0x23, /* 3x int16: roll pitch yaw */
    OS_TRANSLATIONS_TAG      = 0x24, /* 3x int16: x y z */
    OS_ANALOG_DATA_TAG       = 0x25, /* 3X int16: x y z */
    OS_RELATIVE_XY_TAG       = 0x10, /* 2x int16: deltax deltay */
    OS_DIRECTION_GESTURE_TAG = 0xa0, /* 1x uint8: enumeration */
    OS_SLIDER_GESTURE_TAG    = 0xa1, /* 1x uint8: enumeration */
    OS_BUTTON_EVENT_TAG      = 0xa2, /* 1x uint8: button_number */
    OS_BOUNDARY_TAG          = 0x9d, /* No data; end of related data group */
    OS_HEARTBEAT_TAG         = 0x9e, /* No data; "I am alive" */
    OS_NULL_TAG              = 0x9f, /* No data; filler */
} ODataTag;

typedef enum OControlAction{
    OCONTROL_GET_PARAMETER = 0,
    OCONTROL_SET_PARAMETER = 1,
    OCONTROL_GET_ID = 2,
    OCONTROL_GET_PARAMETER_RANGE = 3,
    OCONTROL_ENABLE_DATA = 4,
    OCONTROL_DISABLE_DATA = 5,
} OControlAction;


@interface OpenSpatialDecoder : NSObject

/*!
 Decode 2D Data from Nod
 */
+(NSDictionary*) decodePos2DPointer: (const uint8_t*) opSpcPtr;
/*!
 Create a fake 2D data packet for testing
 */
+(void*) createPos2DPointer:(NSDictionary*) OSData;
/*!
 Decode Pose6D (3D) Data from Nod
 */
+(NSDictionary*) decodePose6DPointer: (const uint8_t*) opSpcPtr;
/*!
 Create a fake Pose6D (3D) data packet for testing
 */
+(void*) createPose6DPointer: (NSDictionary*) OSData;
/*!
 Decode Button Data from Nod
 */
+(NSDictionary*) decodeButtonPointer: (const uint8_t*) opSpcPtr;
/*!
 Create a fake Button data packet for testing
 */
+(void*) createButtonPointer: (NSDictionary*) OSData;
/*!
 Decode Gesture Data from Nod
 */
+(NSDictionary*) decodeGestPointer: (const uint8_t*) opSpcPtr;
/*!
 Create a fake Gesture data packet for testing
 */
+(void*) createGestPointer: (NSDictionary*) OSData;
/*!
 Decode Motion6D Data from Nod
 */
+(NSDictionary*) decodeMot6DPointer: (const uint8_t*) opSpcPtr;
/*!
 Decode Analog Data from Nod
 */
+(NSDictionary*) decodeAnalogPointer:(const uint8_t *)opSpcPtr;
/*!
 Decode oData returns an array of dictionaries, which will contain
 each event packed into oData, each dictionary will have a "type" key
 to determine the type;
 */
+(NSArray*) decodeODataPointer:(const uint8_t *)opSpcPtr length:(int) length;
@end