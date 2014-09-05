//
//  RotationEventTestCase.m
//  Open Spatial iOS SDKTests
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "OpenSpatialDecoder.h"
#import "OpenSpatialBluetooth.h"
#import "RotationEvent.h"
#import "OpenSpatialTestDelegate.h"

#define OS2DSIZE 6
#define QUATSIZE 12
#define GESTSIZE 2

@interface RotationEventTestCase : XCTestCase

@property CBMutableCharacteristic *testCharacteristic;

@property OpenSpatialBluetooth *testBluetooth;
@property OpenSpatialTestDelegate *testDelegate;

@property NSMutableDictionary *testConnectedPeripherals;

@property id bluetoothMock;

@end

@implementation RotationEventTestCase

- (void)setUp
{
    [super setUp];
    CBUUID *characteristicQuaternionUUID = [CBUUID UUIDWithString:TRANS3D_UUID];
    self.testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicQuaternionUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    self.testBluetooth = [[OpenSpatialBluetooth alloc] init];
    self.testDelegate =  [[OpenSpatialTestDelegate alloc] init];
    self.testBluetooth.delegate  = self.testDelegate;

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

 -(void)test3D
{
     NSDictionary* quaternionDic =
     @{ X : @0.3, Y : @0.03, Z : @0.847, ROLL : @0.349, PITCH : @0.494, YAW : @0.294};
     const char* pointer1  = [OpenSpatialDecoder create3DTransPointer:quaternionDic];
     NSData *data = [NSData dataWithBytes:pointer1 length:QUATSIZE];
     self.testCharacteristic.value = data;
     NSArray *rotationEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
     RotationEvent* rot = [rotationEvents objectAtIndex:0];
     XCTAssertEqualWithAccuracy(rot.x, 0.3, 0.001, @"The Quaternion x value doesn't match the x value entered in the dictionary.");
     XCTAssertEqualWithAccuracy(rot.y, 0.03, 0.001, @"The Quaternion y value doesn't match the y value entered in the dictionary.");
     XCTAssertEqualWithAccuracy(rot.z, 0.847, 0.001, @"The Quaternion z value doesn't match the z value entered in the dictionary.");
     XCTAssertEqualWithAccuracy(rot.roll, 0.349, 0.001, @"The Quaternion roll value doesn't match the roll value entered in the dictionary.");
     XCTAssertEqualWithAccuracy(rot.pitch, 0.494, 0.001, @"The Quaternion pitch value doesn't match the pitch value entered in the dictionary.");
     XCTAssertEqualWithAccuracy(rot.yaw, 0.294, 0.001, @"The Quaternion yaw value doesn't match the yaw value entered in the dictionary.");
 }

@end