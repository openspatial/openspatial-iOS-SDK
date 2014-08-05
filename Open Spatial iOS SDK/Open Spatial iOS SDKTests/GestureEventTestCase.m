//
//  GestureEventTestCase.m
//  Open Spatial iOS SDKTests
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "OpenSpatialDecoder.h"
#import "OpenSpatialBluetooth.h"
#import "GestureEvent.h"
#import "OpenSpatialTestDelegate.h"

#define OS2DSIZE 6
#define QUATSIZE 12
#define GESTSIZE 2

@interface GestureEventTestCase : XCTestCase

@property CBMutableCharacteristic *testCharacteristic;
@property OpenSpatialBluetooth *testBluetooth;
@property OpenSpatialTestDelegate *testDelegate;

@end

@implementation GestureEventTestCase

- (void)setUp
{
    [super setUp];
    CBUUID *characteristicGestureUUID = [CBUUID UUIDWithString:GEST_UUID];
    self.testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicGestureUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    self.testBluetooth = [[OpenSpatialBluetooth alloc] init];
    self.testDelegate =  [[OpenSpatialTestDelegate alloc] init];
    self.testBluetooth.delegate  = self.testDelegate;

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testGestureUp
{
    NSDictionary* gestureDic =
    @{ GEST_OPCODE : @G_OP_DIRECTION, GEST_DATA : @GUP};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GEST_SIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_UP, @"The Gesture Up didn't match.");
}

-(void)testGestureDown
{
    NSDictionary* gestureDic =
    @{ GEST_OPCODE : @G_OP_DIRECTION, GEST_DATA : @GDOWN};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GEST_SIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_DOWN, @"The Gesture Down didn't match.");
}

-(void)testGestureLeft
{
    NSDictionary* gestureDic =
    @{ GEST_OPCODE : @G_OP_DIRECTION, GEST_DATA : @GLEFT};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GEST_SIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_LEFT, @"The Gesture Left didn't match.");
}

-(void)testGestureRight
{
    NSDictionary* gestureDic =
    @{ GEST_OPCODE : @G_OP_DIRECTION, GEST_DATA : @GRIGHT};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GEST_SIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_RIGHT, @"The Gesture Right didn't match.");
}

-(void)testTwistCW
{
    NSDictionary* gestureDic =
    @{ GEST_OPCODE : @G_OP_DIRECTION, GEST_DATA : @GCW};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GEST_SIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], CW, @"The Gesture Up didn't match.");
}

-(void)testTiwstCCW
{
    NSDictionary* gestureDic =
    @{ GEST_OPCODE : @G_OP_DIRECTION, GEST_DATA : @GCCW};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GEST_SIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], CCW, @"The Gesture Up didn't match.");
}

@end