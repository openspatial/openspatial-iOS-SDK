//
//  GestureEventTestCase.m
//  OpenSpatialV6414
//
//  Created by Neel Bhoopalam on 6/5/14.
//  Copyright (c) 2014 NL. All rights reserved.
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
@property id bluetoothMock;

@end

@implementation GestureEventTestCase

- (void)setUp
{
    [super setUp];
    CBUUID *characteristicGestureUUID = [CBUUID UUIDWithString:GESTUUID];
    self.testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicGestureUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
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

-(void)testGestureUp
{
    NSDictionary* gestureDic =
    @{ GEST : @GUP};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GESTSIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_UP, @"The Gesture Up didn't match.");
}

-(void)testGestureDown
{
    NSDictionary* gestureDic =
    @{ GEST : @GDOWN};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GESTSIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_DOWN, @"The Gesture Down didn't match.");
}

-(void)testGestureLeft
{
    NSDictionary* gestureDic =
    @{ GEST : @GLEFT};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GESTSIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_LEFT, @"The Gesture Left didn't match.");
}

-(void)testGestureRight
{
    NSDictionary* gestureDic =
    @{ GEST : @GRIGHT};
    const char* pointer1  = [OpenSpatialDecoder createGestPointer:gestureDic];
    NSData *data = [NSData dataWithBytes:pointer1 length:GESTSIZE];
    self.testCharacteristic.value = data;
    NSArray *gestureEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([gestureEvents[0] getGestureEventType], SWIPE_RIGHT, @"The Gesture Right didn't match.");
}

@end