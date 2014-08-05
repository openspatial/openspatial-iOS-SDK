//
//  OpenSpatialDecoder.m
//  enimai-ios
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import "OpenSpatialDecoder.h"

@implementation OpenSpatialDecoder

+(NSDictionary*) decodePos2DPointer: (const uint8_t*) opSpcPtr
{
    short int x = (opSpcPtr[1] << 8) | opSpcPtr[0];
    short int y = (opSpcPtr[3] << 8) | opSpcPtr[2];

    NSDictionary* retDic = @{ X : @(x),
                            Y : @(y),
                            };
    return retDic;
}

+(void*) createPos2DPointer:(NSDictionary *)OSData
{
    NSMutableData* data = [[NSMutableData alloc] init];
    short int x = [[OSData objectForKey:X] shortValue];
    short int y = [[OSData objectForKey:Y] shortValue];
    [data appendBytes:&x length:sizeof(x)];
    [data appendBytes:&y length:sizeof(y)];
   
    const char* ret = [data bytes];
    return ret;
}


+(NSDictionary*) decode3DTransPointer: (const uint8_t*) opSpcPtr
{
    short int x = opSpcPtr[0] | (opSpcPtr[1] << 8);
    short int y = opSpcPtr[2] | (opSpcPtr[3] << 8);
    short int z = opSpcPtr[4] | (opSpcPtr[5] << 8);

    int roll = opSpcPtr[6] | (opSpcPtr[7] << 8);
    float rollf = (roll << 16);
    int pitch = opSpcPtr[8] | (opSpcPtr[9] << 8);
    float pitchf = (pitch << 16);
    int yaw = opSpcPtr[10] | (opSpcPtr[11] << 8);
    float yawf = (yaw << 16);

    rollf = rollf / (1 << 29);
    pitchf = pitchf / (1 << 29);
    yawf = yawf / (1 << 29);

    NSDictionary* retDic = @{ X : @(x),
                              Y : @(y),
                              Z : @(z),
                              ROLL : @(rollf),
                              PITCH : @(pitchf),
                              YAW : @(yawf),
                              };
    return retDic;
}

+(void*) create3DTransPointer: (NSDictionary*) OSData
{
    float x = [[OSData objectForKey:X] floatValue];
    float y = [[OSData objectForKey:Y] floatValue];
    float z = [[OSData objectForKey:Z] floatValue];
    float roll = [[OSData objectForKey:ROLL] floatValue];
    float pitch = [[OSData objectForKey:PITCH] floatValue];
    float yaw = [[OSData objectForKey:YAW] floatValue];

    int16_t xt = x * (1 << 16);
    int16_t yt = y * (1 << 16);
    int16_t zt = z * (1 << 16);
    int16_t rollt = roll * (1 << 13);
    int16_t pitcht = pitch * (1 << 13);
    int16_t yawt = yaw * (1 << 13);

    NSMutableData* data = [[NSMutableData alloc] initWithCapacity:12];
    [data appendBytes:&xt length:sizeof(xt)];
    [data appendBytes:&yt length:sizeof(yt)];
    [data appendBytes:&zt length:sizeof(zt)];
    [data appendBytes:&rollt length:sizeof(rollt)];
    [data appendBytes:&pitcht length:sizeof(pitcht)];
    [data appendBytes:&yawt length:sizeof(yawt)];


    return [data bytes];
}


+(NSDictionary*) decodeButtonPointer:(const uint8_t *)opSpcPtr
{
    short button = opSpcPtr[0] | (opSpcPtr[1] << 8);
    short touch0 = (button & 0x3);
    short touch1 = (button >> 2) & 0x3;
    short touch2 = (button >> 4) & 0x3;
    short tact0 =  (button >> 6) & 0x3;
    short tact1 =  (button >> 8) & 0x3;

    NSDictionary* retDic = @{ TOUCH_0 : @(touch0),
                               TOUCH_1 : @(touch1),
                               TOUCH_2 : @(touch2),
                               TACTILE_0 : @(tact0),
                               TACTILE_1 : @(tact1),
                              };
    return retDic;
}

+(void*) createButtonPointer:(NSDictionary *)OSData
{
    short touch0 = [[OSData objectForKey:TOUCH_0] shortValue];
    short touch1 = [[OSData objectForKey:TOUCH_1] shortValue];
    short touch2 = [[OSData objectForKey:TOUCH_2] shortValue];
    short tact0 = [[OSData objectForKey:TACTILE_0] shortValue];
    short tact1 = [[OSData objectForKey:TACTILE_1] shortValue];
    
    short button = touch0 | touch1 << 2 | touch2  << 4 | tact0 << 6 | tact1 << 8;
    NSData* data = [NSData dataWithBytes:&button length:sizeof(button)];
    return [data bytes];
}

+(NSDictionary*) decodeGestPointer: (const uint8_t*) opSpcPtr
{
    short opCode = opSpcPtr[0] | opSpcPtr[1] << 8;
    char data = opSpcPtr[2];

    NSDictionary* retDic = @{ GEST_OPCODE : @(opCode),
                              GEST_DATA : @(data),
                              };
    return retDic;
}

+(void*) createGestPointer: (NSDictionary*) OSData
{
    NSMutableData* data = [[NSMutableData alloc] init];
    short opCode = [[OSData objectForKey:GEST_OPCODE] shortValue];
    char dataV = [[OSData objectForKey:GEST_DATA] charValue];
    [data appendBytes:&opCode length:sizeof(opCode)];
    [data appendBytes:&dataV length:sizeof(dataV)];
    return [data bytes];
}


@end
