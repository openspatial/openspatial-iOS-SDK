//
//  NodBluetoothEmulator.h
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define OS_UUID @"00000002-0000-1000-8000-A0E5E9000000"
#define POS2D_UUID @"00000206-0000-1000-8000-A0E5E9000000"
#define TRANS3D_UUID @"00000205-0000-1000-8000-A0E5E9000000"
#define GEST_UUID @"00000208-0000-1000-8000-A0E5E9000000"
#define BUTTON_UUID @"00000207-0000-1000-8000-A0E5E9000000"
#define NOD_SERVICE_UUID @"00000004-0000-1000-8000-a0e5e9000000"
#define MODE_SWITCH_UUID @"00000400-0000-1000-8000-a0e5e9000000"

#define POS2D_SIZE 4
#define TRANS3D_SIZE 12
#define GEST_SIZE 5
#define BUTTON_SIZE 2

@interface NodBluetoothEmulator : NSObject <CBPeripheralManagerDelegate>

@property CBPeripheralManager* periphMan;
@property NSMutableArray* services;
@property CBMutableCharacteristic* os2dChar;
@property CBMutableCharacteristic* trans3DChar;
@property CBMutableCharacteristic* gestChar;
@property CBMutableCharacteristic* buttonChar;

+(id) sharedEmulator;
-(void) sendOS2D: (NSData*) data;
-(void) send3DTrans: (NSData*) data;
-(void) sendGesture: (NSData*) data;
-(void) sendButton: (NSData*) data;

@end
