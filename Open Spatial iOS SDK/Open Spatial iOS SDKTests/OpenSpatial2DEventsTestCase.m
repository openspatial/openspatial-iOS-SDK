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
    CBUUID *characteristicOpenSpatial2DUUID = [CBUUID UUIDWithString:POS2D_UUID];
    self.testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicOpenSpatial2DUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    self.testBluetooth = [[OpenSpatialBluetooth alloc] init];
    self.testDelegate =  [[OpenSpatialTestDelegate alloc] init];
    self.testBluetooth.delegate  = self.testDelegate;

}

- (void)tearDown
{
    self.testCharacteristic = nil;
    self.testBluetooth = nil;
    self.bluetoothMock = nil;
    [super tearDown];
}



-(void)testPointer
{
    NSDictionary* openSpatial2DDic =
    @{ X : @22, Y : @39};
    const char* openSpatial2DPointer  = [OpenSpatialDecoder createPos2DPointer:openSpatial2DDic];
    NSData *dataOpenSpatial2D = [NSData dataWithBytes:openSpatial2DPointer length:POS2D_SIZE];
    self.testCharacteristic.value = dataOpenSpatial2D;
    NSArray *openSpatial2DEvents = [self.testBluetooth testBluetoothCharacteristic:self.testCharacteristic andPeripheral:nil];
    
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
