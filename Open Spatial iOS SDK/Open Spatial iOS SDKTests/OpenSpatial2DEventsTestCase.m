//
//  OpenSpatial2DEventsTestCase.m
//  Open Spatial iOS SDKTests
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "OpenSpatialDecoder.h"
#import "OpenSpatialBluetooth.h"
#import "ButtonEvent.h"
#import "PointerEvent.h"
#import "OpenSpatialTestDelegate.h"

#define OS2DSIZE 6
#define QUATSIZE 12
#define GESTSIZE 2

@interface OpenSpatial2DEventsTestCase : XCTestCase

@property CBMutableCharacteristic *testCharacteristic;
@property OpenSpatialBluetooth *testBluetooth;
@property OpenSpatialTestDelegate *testDelegate;

@property id bluetoothMock;

@end

@implementation OpenSpatial2DEventsTestCase

- (void)setUp
{
    [super setUp];
    CBUUID *characteristicOpenSpatial2DUUID = [CBUUID UUIDWithString:OS2DUUID];
    self.testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicOpenSpatial2DUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    self.testBluetooth = [[OpenSpatialBluetooth alloc] init];
    self.testDelegate =  [[OpenSpatialTestDelegate alloc] init];
    self.testBluetooth.delegate  = self.testDelegate;
    
    self.bluetoothMock = [OCMockObject partialMockForObject:self.testBluetooth];
    
    [[[self.bluetoothMock stub] andReturnValue:OCMOCK_VALUE((BOOL){TRUE})] isSubscribedToEvent:[OCMArg any] forPeripheral:[OCMArg any]];
}

- (void)tearDown
{
    self.testCharacteristic = nil;
    self.testBluetooth = nil;
    self.bluetoothMock = nil;
    [super tearDown];
}

-(void)testLeftPressCase
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @LTOUCHPRESSED, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_DOWN , @"The Left Press Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @NOPRESS, SLIDE : @0, TACTILE : @0 };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_UP , @"The Left Press Up didn't match.");
}

-(void)testRightPressCase
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @RTOUCHPRESSED, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH2_DOWN , @"The Right Press Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @NOPRESS, SLIDE : @0, TACTILE : @0 };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH2_UP , @"The Right Press Up didn't match.");
}

-(void)testBothTouchPressCase
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @BOTHTOUCHPRESSED, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_DOWN , @"The Left Press Down didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], TOUCH2_DOWN, @"The Right Press Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @NOPRESS, SLIDE : @0, TACTILE : @0 };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_UP , @"The Left Press Up didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], TOUCH2_UP , @"The Right Press Up didn't match.");
}

-(void)testSlideHoldPressed
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @SLIDEHOLDPRESSED, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], SCROLL_TOUCH_DOWN , @"The Scroll Press Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @NOPRESS, SLIDE : @0, TACTILE : @0 };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], SCROLL_TOUCH_UP , @"The Slide Press Up didn't match.");
}

-(void)testSlideHoldAndLeftTouchPressed
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @SLIDEHOLDLTOUCH, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_DOWN , @"The Left Press Down didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], SCROLL_TOUCH_DOWN, @"The Scroll Press Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @NOPRESS, SLIDE : @0, TACTILE : @0 };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_UP , @"The Left Press Up didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], SCROLL_TOUCH_UP , @"The Slide Press Up didn't match.");
}

-(void)testSlideHoldAndRightTouchPressed
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @SLIDEHOLDRTOUCH, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH2_DOWN , @"The Right Press Down didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], SCROLL_TOUCH_DOWN, @"The Scroll Press Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @NOPRESS, SLIDE : @0, TACTILE : @0 };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH2_UP , @"The Right Press Up didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], SCROLL_TOUCH_UP , @"The Slide Press Up didn't match.");
}

-(void)testAll3Press
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @ALL3PRESSED, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_DOWN , @"The Left Press Down didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], TOUCH2_DOWN, @"The Right Press Down didn't match.");
    XCTAssertEqual([openSpatial2DEvents[2] getButtonEventType], SCROLL_TOUCH_DOWN , @"The Scroll Press Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @NOPRESS, SLIDE : @0, TACTILE : @0 };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TOUCH1_UP , @"The Left Press Up didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], TOUCH2_UP , @"The Right Press Up didn't match.");
    XCTAssertEqual([openSpatial2DEvents[2] getButtonEventType], SCROLL_TOUCH_UP , @"The Slide Press Up didn't match.");
}

-(void)testLeftTactilePress
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @0, TACTILE : @LTACTPRESSED };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TACTILE1_DOWN , @"The Left Tactile Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @0, TACTILE : @NOPRESS };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TACTILE1_UP, @"The Left Tactile Up didn't match.");
}

-(void)testRightTactilePress
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @0, TACTILE : @RTACTPRESSED };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TACTILE2_DOWN , @"The Right Tactile Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @0, TACTILE : @NOPRESS };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TACTILE2_UP, @"The Right Tactile Up didn't match.");
}

-(void)testBothTactilePress
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @0, TACTILE : @BOTHTACTPRESSED };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TACTILE1_DOWN , @"The Left Tactile Down didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], TACTILE2_DOWN, @"The Right Tactile Down didn't match.");
    
    openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @0, TACTILE : @NOPRESS };
    openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], TACTILE1_UP , @"The Left Tactile Up didn't match.");
    XCTAssertEqual([openSpatial2DEvents[1] getButtonEventType], TACTILE2_UP, @"The Right Tactile Up didn't match.");
}

-(void)testGreaterThanSlideVal
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @1, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], SCROLL_UP , @"The Scroll Up didn't match.");
}

-(void)testLessThanSlideVal
{
    NSDictionary* openSpatial2DDic =
    @{ X : @0, Y : @0, TOUCH : @0, SLIDE : @15, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    XCTAssertEqual([openSpatial2DEvents[0] getButtonEventType], SCROLL_DOWN , @"The Scroll Down didn't match.");
}

-(void)testPointer
{
    NSDictionary* openSpatial2DDic =
    @{ X : @22, Y : @39, TOUCH : @0, SLIDE : @0, TACTILE : @0 };
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:OS2DSIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.bluetoothMock testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    
    for(NSObject *n in openSpatial2DEvents)
    {
        if([n class] == [PointerEvent class])
        {
            XCTAssertEqual([(PointerEvent*)n getXValue], 22 , @"The X value didn't match.");
            XCTAssertEqual([(PointerEvent*)n getYValue], 39 , @"The Y value didn't match.");
        }
    }
}

@end
