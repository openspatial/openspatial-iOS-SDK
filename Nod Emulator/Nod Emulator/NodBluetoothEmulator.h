//
//  NodBluetoothEmulator.h
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define OSUUID @"00000002-0000-1000-8000-a0e5e9000000"
#define OS2DUUID @"00000200-0000-1000-8000-a0e5e9000000"
#define QUATUUID @"00000205-0000-1000-8000-a0e5e9000000"
#define GESTUUID @"00000204-0000-1000-8000-A0E5E9000000"

#define OS2DSIZE 6
#define QUATSIZE 12
#define GESTSIZE 2

@interface NodBluetoothEmulator : NSObject <CBPeripheralManagerDelegate>

@property CBPeripheralManager* periphMan;
@property NSMutableArray* services;
@property CBMutableCharacteristic* os2dChar;
@property CBMutableCharacteristic* rawQuatChar;
@property CBMutableCharacteristic* gestChar;

+(id) sharedEmulator;
-(void) sendOS2D: (NSData*) data;
-(void) sendRawQuat: (NSData*) data;
-(void) sendGesture: (NSData*) data;

@end
