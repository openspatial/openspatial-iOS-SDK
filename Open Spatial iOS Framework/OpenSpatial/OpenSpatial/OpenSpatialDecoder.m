//
//  OpenSpatialDecoder.m
//  NodLabs
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import "OpenSpatialDecoder.h"

@implementation OpenSpatialDecoder

+(NSDictionary*) decodePos2DPointer: (const uint8_t*) opSpcPtr {
    short int x = opSpcPtr[0] | (opSpcPtr[1] << 8);
    short int y = opSpcPtr[2] | (opSpcPtr[3] << 8);

    NSDictionary* retDic = @{ X : @(x),
                              Y : @(y),
                            };
    return retDic;
}

+(void*) createPos2DPointer:(NSDictionary *)OSData {
    NSMutableData* data = [[NSMutableData alloc] init];
    short int x = [[OSData objectForKey:X] shortValue];
    short int y = [[OSData objectForKey:Y] shortValue];
    [data appendBytes:&x length:sizeof(x)];
    [data appendBytes:&y length:sizeof(y)];
   
    const char* ret = [data bytes];
    return (char*)ret;
}

+(NSDictionary*) decodePose6DPointer: (const uint8_t*) opSpcPtr {
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

+(void*) createPose6DPointer: (NSDictionary*) OSData {
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

    return (char*)[data bytes];
}

+(NSDictionary*) decodeButtonPointer:(const uint8_t *)opSpcPtr {
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

+(void*) createButtonPointer:(NSDictionary *)OSData {
    short touch0 = [[OSData objectForKey:TOUCH_0] shortValue];
    short touch1 = [[OSData objectForKey:TOUCH_1] shortValue];
    short touch2 = [[OSData objectForKey:TOUCH_2] shortValue];
    short tact0 = [[OSData objectForKey:TACTILE_0] shortValue];
    short tact1 = [[OSData objectForKey:TACTILE_1] shortValue];
    
    short button = touch0 | touch1 << 2 | touch2  << 4 | tact0 << 6 | tact1 << 8;
    NSData* data = [NSData dataWithBytes:&button length:sizeof(button)];
    return (char*)[data bytes];
}

+(NSDictionary*) decodeGestPointer: (const uint8_t*) opSpcPtr {
    short opCode = opSpcPtr[0] | opSpcPtr[1] << 8;
    char data = opSpcPtr[2];

    NSDictionary* retDic = @{ GEST_OPCODE : @(opCode),
                              GEST_DATA : @(data),
                              };
    return retDic;
}

+(void*) createGestPointer: (NSDictionary*) OSData {
    NSMutableData* data = [[NSMutableData alloc] init];
    short opCode = [[OSData objectForKey:GEST_OPCODE] shortValue];
    char dataV = [[OSData objectForKey:GEST_DATA] charValue];
    [data appendBytes:&opCode length:sizeof(opCode)];
    [data appendBytes:&dataV length:sizeof(dataV)];
    return (char*)[data bytes];
}

+(NSDictionary*) decodeMot6DPointer:(const uint8_t *)opSpcPtr {
    short int x = opSpcPtr[0] | (opSpcPtr[1] << 8);
    float xf = ((float) x) / 8192;
    short int y = opSpcPtr[2] | (opSpcPtr[3] << 8);
    float yf = ((float)y )/ 8192;
    short int z = opSpcPtr[4] | (opSpcPtr[5] << 8);
    float zf = ((float)z) / 8192;
    
    short x2 = opSpcPtr[6] | (opSpcPtr[7] << 8);
    float x2f = (((float)x2)/16.4) * (M_PI/180);
    short y2 = opSpcPtr[8] | (opSpcPtr[9] << 8);
    float y2f = (((float)y2)/16.4) * (M_PI/180);
    short z2 = opSpcPtr[10] | (opSpcPtr[11] << 8);
    float z2f = (((float)z2)/16.4) * (M_PI/180);
    
    NSDictionary* retDic = @{ XA : @(xf),
                              YA : @(yf),
                              ZA : @(zf),
                              XG : @(x2f),
                              YG : @(y2f),
                              ZG : @(z2f),
                              };
    return retDic;
}

+(NSDictionary*) decodeAnalogPointer:(const uint8_t *)opSpcPtr {
    short int x = (opSpcPtr[1] << 8) | opSpcPtr[0];
    short int y = (opSpcPtr[3] << 8) | opSpcPtr[2];
    short int trigger = (opSpcPtr[5] << 8) | opSpcPtr[4];
    
    NSDictionary* retDic = @{ X : @(x),
                              Y : @(y),
                              TRIGGER : @(trigger),
                              };
    return retDic;
}

uint8_t touches[] = {
    TOUCH0_DOWN,
    TOUCH1_DOWN,
    TOUCH2_DOWN,
    TACTILE0_DOWN,
    TACTILE1_DOWN,
    TACTILE2_DOWN,
    TACTILE3_DOWN,
};

uint8_t releases[] = {
    TOUCH0_UP,
    TOUCH1_UP,
    TOUCH2_UP,
    TACTILE0_UP,
    TACTILE1_UP,
    TACTILE2_UP,
    TACTILE3_UP,
};

+(NSArray*) decodeODataPointer:(const uint8_t *)opSpcPtr length:(int)length {
    int processed = 0;
    NSMutableArray* eventDataArray = [[NSMutableArray alloc] init];
    while(processed < length) {
        uint8_t tag = opSpcPtr[processed];
        processed++;
        if(tag == OS_RAW_ACCELEROMETER_TAG) {
            short int x = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            float xf = ((float) x) / 8192;
            short int y = opSpcPtr[processed + 2] | (opSpcPtr[processed + 3] << 8);
            float yf = ((float)y )/ 8192;
            short int z = opSpcPtr[processed + 4] | (opSpcPtr[processed + 5] << 8);
            float zf = ((float)z) / 8192;
            
            NSDictionary* retDic = @{ @"type" : @"accelerometer",
                                      XA : @(xf),
                                      YA : @(yf),
                                      ZA : @(zf),
                                      };
            [eventDataArray addObject:retDic];
            processed +=6;
        }
        if(tag == OS_RAW_GYRO_TAG) {
            short xGyro = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            float x2f = (((float)xGyro)/16.4) * (M_PI/180);
            short yGyro = opSpcPtr[processed + 2] | (opSpcPtr[processed + 3] << 8);
            float y2f = (((float)yGyro)/16.4) * (M_PI/180);
            short zGyro = opSpcPtr[processed + 4] | (opSpcPtr[processed + 5] << 8);
            float z2f = (((float)zGyro)/16.4) * (M_PI/180);
            
            NSDictionary* retDic = @{ @"type" : @"gyro",
                                           XG : @(x2f),
                                           YG : @(y2f),
                                           ZG : @(z2f),
                                      };
            [eventDataArray addObject:retDic];
            processed +=6;
        }
        if(tag == OS_RAW_COMPASS_TAG) {
        }
        if(tag == OS_EULER_ANGLES_TAG) {
            int roll = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            int pitch = opSpcPtr[processed + 2] | (opSpcPtr[processed + 3] << 8);
            int yaw = opSpcPtr[processed + 4] | (opSpcPtr[processed + 5] << 8);
            float rollf = (roll << 16);
            float pitchf = (pitch << 16);
            float yawf = (yaw << 16);
            rollf = rollf / (1 << 29);
            pitchf = pitchf / (1 << 29);
            yawf = yawf / (1 << 29);
            NSDictionary* dic = @{ @"type" : @"euler",
                                      ROLL : @(rollf),
                                     PITCH : @(pitchf),
                                       YAW : @(yawf)
                                          };
            [eventDataArray addObject:dic];
            processed += 6;
        }
        if(tag == OS_TRANSLATIONS_TAG) {
            short int x = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            short int y = opSpcPtr[processed + 2] | (opSpcPtr[processed + 3] << 8);
            short int z = opSpcPtr[processed + 4] | (opSpcPtr[processed + 5] << 8);
            
            NSDictionary* retDic = @{ @"type" : @"translations",
                                            X : @(x),
                                            Y : @(y),
                                            Z : @(z)
                                      };
            [eventDataArray addObject:retDic];
            processed +=6;
        }
        if(tag == OS_ANALOG_DATA_TAG) {
            int x = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            int y = opSpcPtr[processed + 2] | (opSpcPtr[processed + 3] << 8);
            int trigger = opSpcPtr[processed + 4] | (opSpcPtr[processed + 5] << 8);
            NSDictionary* dic = @{ @"type" : @"analog",
                                   X : @(x),
                                   Y : @(y),
                                   TRIGGER : @(trigger)};
            [eventDataArray addObject:dic];
            processed+=6;
        }
        if(tag == OS_RELATIVE_XY_TAG) {
            short int x = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            short int y = opSpcPtr[processed + 2] | (opSpcPtr[processed + 3] << 8);
            
            NSDictionary* retDic = @{ @"type" : @"relativexy",
                                      X : @(x),
                                      Y : @(y),
                                      };
            [eventDataArray addObject:retDic];
            processed+=4;
        }
        if (tag == OS_DIRECTION_GESTURE_TAG) {
            char directionGestureData = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            NSDictionary* retDic = @{   @"type" : @"directionGesture",
                                      GEST_DATA : @(directionGestureData)
                                        };
            [eventDataArray addObject:retDic];
            processed+=2;
        }
        if (tag == OS_SLIDER_GESTURE_TAG) {
            char slideData = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            NSDictionary* retDic = @{   @"type" : @"sliderGesture",
                                      GEST_DATA : @(slideData)
                                         };
            [eventDataArray addObject:retDic];
            processed+=2;
        }
        if (tag == OS_BUTTON_EVENT_TAG) {
            uint8_t UP_DOWN_MASK = (uint8_t)(1 << 7);
            char buttonCode = opSpcPtr[processed] | (opSpcPtr[processed + 1] << 8);
            ButtonState state = (buttonCode & UP_DOWN_MASK) != 0 ? UP : DOWN;
            uint8_t buttonID = (buttonCode & ~UP_DOWN_MASK);
            
            NSDictionary* retDic = @{        @"type" : @"button",
                                      @"buttonState" : @(state),
                                      @"buttonID"    : @(buttonID),
                                      };
            [eventDataArray addObject:retDic];
            processed+=2;
        }
        if(tag == OS_BOUNDARY_TAG) {
            /* No data; end of data group */
        }
        if(tag == OS_HEARTBEAT_TAG) {
            /* No data; "I am alive" */
        }
        if(tag == OS_NULL_TAG) {
            /* No data; filler */
        }
    }
    return eventDataArray;
}
@end
