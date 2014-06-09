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
    CBUUID *characteristicQuaternionUUID = [CBUUID UUIDWithString:QUATUUID];
    self.testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicQuaternionUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    self.testBluetooth = [[OpenSpatialBluetooth alloc] init];
    self.testDelegate =  [[OpenSpatialTestDelegate alloc] init];
    self.testBluetooth.delegate  = self.testDelegate;
    
    self.bluetoothMock = [OCMockObject partialMockForObject:self.testBluetooth];
    
    [[[self.bluetoothMock stub] andReturnValue:OCMOCK_VALUE((BOOL){TRUE})] isSubscribedToEvent:[OCMArg any] forPeripheral:[OCMArg any]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

 -(void)testQuaternion
 {
     NSDictionary* quaternionDic =
     @{ X : @0.3, Y : @0.03, Z : @0.847, W : @0.2 };
     const char* pointer1  = [OpenSpatialDecoder createQuatPointer:quaternionDic];
     NSData *data = [NSData dataWithBytes:pointer1 length:QUATSIZE];
     self.testCharacteristic.value = data;
     NSArray *rotationEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
     XCTAssertEqualWithAccuracy([rotationEvents[0] getQuaternion].x, 0.3, 0.000001, @"The Quaternion x value doesn't match the x value entered in the dictionary.");
     XCTAssertEqualWithAccuracy([rotationEvents[0] getQuaternion].y, 0.03, 0.000001, @"The Quaternion y value doesn't match the y value entered in the dictionary.");
     XCTAssertEqualWithAccuracy([rotationEvents[0] getQuaternion].z, 0.847, 0.000001, @"The Quaternion z value doesn't match the z value entered in the dictionary.");
     XCTAssertEqualWithAccuracy([rotationEvents[0] getQuaternion].w, 0.2, 0.000001, @"The Quaternion w value doesn't match the w value entered in the dictionary.");
 }

@end