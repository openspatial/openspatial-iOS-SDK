//
//  OpenSpatialDecoder.h
//  enimai-ios
//
//  Copyright (c) 2014 ënimai Inc. All rights reserved.
//

/*
 *  This class decodes an openspatial pointer sent as a byte
 *  array. The function will return an array containing useful
 *  values from the openspacial pointer
 * 
 *  The decodeOpenSpatialPointer returns an array containing:
 *      Array[0] = x coordinate
 *      Array[1] = y coordinate
 *      Array[2] = touch value
 *                  0 = no touch
 *                  1 = touch right
 *                  2 = touch left
 *                  Finish Specification later...
 *      Array[3] = Slider Value
 *                  Value from 0-256? (need to make sure)
 *                  Value increases from swipe to right
 *                  Decreases on swipe to left
 *      Array[4] = Tactile
 */

#import <Foundation/Foundation.h>

#define X @"x"
#define Y @"y"
#define Z @"z"
#define W @"w"
#define TOUCH @"touch"
#define SLIDE @"slide"
#define TACTILE @"tactile"
#define GEST @"gest"
#define GUP 0x52
#define GDOWN 0x51
#define GLEFT 0x50
#define GRIGHT 0x4f

@interface OpenSpatialDecoder : NSObject

+(NSDictionary*) decodeOpenSpatialPointer: (const uint8_t*) opSpcPtr;
+(void*) createPointer:(NSDictionary*) OSData;
+(NSDictionary*) decodeRawQuatPointer: (const uint8_t*) opSpcPtr;
+(void*) createQuatPointer: (NSDictionary*) OSData;
+(NSDictionary*) decodeGestPointer: (const uint8_t*) opSpcPtr;
+(void*) createGestPointer: (NSDictionary*) OSData;

@end