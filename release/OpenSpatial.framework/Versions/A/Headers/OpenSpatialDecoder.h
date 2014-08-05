//
//  OpenSpatialDecoder.h
//  enimai-ios
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

/*
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

#define X @"x"
#define Y @"y"
#define Z @"z"
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

@interface OpenSpatialDecoder : NSObject

+(NSDictionary*) decodePos2DPointer: (const uint8_t*) opSpcPtr;
+(void*) createPos2DPointer:(NSDictionary*) OSData;
+(NSDictionary*) decode3DTransPointer: (const uint8_t*) opSpcPtr;
+(void*) create3DTransPointer: (NSDictionary*) OSData;
+(NSDictionary*) decodeButtonPointer: (const uint8_t*) opSpcPtr;
+(void*) createButtonPointer: (NSDictionary*) OSData;
+(NSDictionary*) decodeGestPointer: (const uint8_t*) opSpcPtr;
+(void*) createGestPointer: (NSDictionary*) OSData;

@end