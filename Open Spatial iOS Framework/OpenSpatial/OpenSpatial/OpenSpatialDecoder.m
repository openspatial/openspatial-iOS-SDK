//
//  OpenSpatialDecoder.m
//  NodLabs
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import "OpenSpatialDecoder.h"

@implementation OpenSpatialDecoder


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
