//
//  OpenSpatialDecoder.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 5/29/14.
//  Copyright (c) 2014 Neel Bhoopalam. All rights reserved.
//

/*
 *  This class decodes an openspatial pointer sent as a byte
 *  array. The function will return an array containing useful
 *  values from the openspatial pointer
 *
 *  The decodeOpenSpatialPointer returns a dictionary containing keys:
 *      "x" = x coordinate
 *      "y" = y coordinate
 *      "touch" = touch value
 *                  0 = no touch
 *                  1 = touch left
 *                  2 = touch right
 *                  3 = touch left+right
 *                  4 = hold slider
 *                  5 = touch left+slider
 *                  6 = touch right+slider
 *                  7 = touch all
 *      "slide" = Slider Value
 *                  Value from 0-15
 *      "tactile = Tactile
 *                  0 = no touch
 *                  1 = left tactile
 *                  2 = right tactile
 *                  3 = both tacticle
 *
 *  The decodeRawQuatPointer returns a dictionary containing keys:
 *      "x" = x quaternion value
 *      "y" = y quaternion value
 *      "z" = z quaternion value
 *      "w" = w quaternion value
 * 
 *  The decodeGestPointer retruns a dictionary container keys:
 *      "gest" = gesture value
 *
 *
 *  The create values are used to create a pointer to data for
 *  either OS2D, Quaternions or Gestures. The bytes reffered to by
 *  the pointer are formatted according to the Open Spatial specification
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