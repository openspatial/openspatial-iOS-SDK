//
//  OpenSpatialDecoder.m
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import "OpenSpatialDecoder.h"

@implementation OpenSpatialDecoder

+(NSDictionary*) decodeOpenSpatialPointer: (const uint8_t*) opSpcPtr
{
    short int x = (opSpcPtr[1] <<8) | opSpcPtr[0];
    short int y = (opSpcPtr[3] <<8) | opSpcPtr[2];
    uint8_t touch = opSpcPtr[4] & 0x0F;
    int8_t slide = (opSpcPtr[4] & 0xF0) >> 4;
    uint8_t tactile = opSpcPtr[5];

    NSDictionary* retDic = @{ X : @(x),
                            Y : @(y),
                            TOUCH : @(touch),
                            SLIDE : @(slide),
                            TACTILE : @(tactile)
                            };
    return retDic;
}

+(void*) createPointer:(NSDictionary *)OSData
{
    NSMutableData* data = [[NSMutableData alloc] init];
    short int x = [[OSData objectForKey:X] shortValue];
    short int y = [[OSData objectForKey:Y] shortValue];
    [data appendBytes:&x length:sizeof(x)];
    [data appendBytes:&y length:sizeof(y)];
    uint8_t touch = [[OSData objectForKey:TOUCH] charValue];
    uint8_t slide = [[OSData objectForKey:SLIDE] charValue];
    uint8_t touchslide = ((slide) << 4) | (touch);
    [data appendBytes:&touchslide length:sizeof(touchslide)];
    uint8_t tactile = [[OSData objectForKey:TACTILE] charValue];
    [data appendBytes:&tactile length:sizeof(tactile)];

    const char* ret = [data bytes];
    return ret;
}


+(NSDictionary*) decodeRawQuatPointer: (const uint8_t*) opSpcPtr
{
    int x = opSpcPtr[0] | (opSpcPtr[1] << 8) | (opSpcPtr[2] << 16);
    float xf = (x << 8) >> 8;
    int y = opSpcPtr[3] | (opSpcPtr[4] << 8) | (opSpcPtr[5] << 16);
    float yf = (y << 8) >> 8;
    int z = opSpcPtr[6] | (opSpcPtr[7] << 8) | (opSpcPtr[8] << 16);
    float zf = (z << 8) >> 8;
    int w = opSpcPtr[9] | (opSpcPtr[10] << 8) | (opSpcPtr[11] << 16);
    float wf = (w << 8) >> 8;

    xf = xf / (1 << 22);
    yf = yf / (1 << 22);
    zf = zf / (1 << 22);
    wf = wf / (1 << 22);

    NSDictionary* retDic = @{ X : @(xf),
                              Y : @(yf),
                              Z : @(zf),
                              W : @(wf),
                              };
    return retDic;
}

+(void*) createQuatPointer: (NSDictionary*) OSData
{
    float x = [[OSData objectForKey:X] floatValue];
    float y = [[OSData objectForKey:Y] floatValue];
    float z = [[OSData objectForKey:Z] floatValue];
    float w = [[OSData objectForKey:W] floatValue];

    int32_t xt = x * (1 << 22);
    int32_t yt = y * (1 << 22);
    int32_t zt = z * (1 << 22);
    int32_t wt = w * (1 << 22);

    NSMutableData* data = [[NSMutableData alloc] initWithCapacity:12];

    char* opSpcPtr = data.bytes;

    opSpcPtr[0] = (xt) & 0xff;
    opSpcPtr[1] = (xt >> 8) & 0xff;
    opSpcPtr[2] = (xt >> 16) & 0xff;

    opSpcPtr[3] = (yt) & 0xff;
    opSpcPtr[4] = (yt >> 8) & 0xff;
    opSpcPtr[5] = (yt >> 16) & 0xff;

    opSpcPtr[6] = (zt) & 0xff;
    opSpcPtr[7] = (zt >> 8) & 0xff;
    opSpcPtr[8] = (zt >> 16) & 0xff;

    opSpcPtr[9] =  (wt) & 0xff;
    opSpcPtr[10] = (wt >> 8) & 0xff;
    opSpcPtr[11] = (wt >> 16) & 0xff;

    return opSpcPtr;
}

+(NSDictionary*) decodeGestPointer: (const uint8_t*) opSpcPtr
{
    char gesture = opSpcPtr[1];
    NSDictionary* retDic = @{ GEST : @(gesture)};
    return retDic;
}

+(void*) createGestPointer: (NSDictionary*) OSData
{
    NSMutableData* data = [[NSMutableData alloc] init];
    char firstBit = 0x00;
    char gesture = [[OSData objectForKey:GEST] charValue];
    [data appendBytes:&firstBit length:sizeof(firstBit)];
    [data appendBytes:&gesture length:sizeof(gesture)];
    const char* ret = [data bytes];
    return ret;
}


@end
