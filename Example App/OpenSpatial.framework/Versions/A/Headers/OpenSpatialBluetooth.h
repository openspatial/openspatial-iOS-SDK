//
//  OpenSpatialBluetooth.h
//  Open Spatial iOS SDK
//
//  Created by Neel Bhoopalam on 6/6/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <CoreBluetooth/CoreBluetooth.h>
#import "OpenSpatialDecoder.h"

#import "ButtonEvent.h"
#import "PointerEvent.h"
#import "RotationEvent.h"
#import "GestureEvent.h"

#define OSUUID @"00000002-0000-1000-8000-A0E5E9000000"
#define OS2DUUID @"00000200-0000-1000-8000-A0E5E9000000"
#define QUATUUID @"00000205-0000-1000-8000-A0E5E9000000"
#define GESTUUID @"00000204-0000-1000-8000-A0E5E9000000"

#define NOPRESS 0
#define LTOUCHPRESSED 1
#define RTOUCHPRESSED 2
#define BOTHTOUCHPRESSED 3

#define SLIDEHOLDPRESSED 4
#define SLIDEHOLDLTOUCH 5
#define SLIDEHOLDRTOUCH 6

#define ALL3PRESSED 7

#define LTACTPRESSED 1
#define RTACTPRESSED 2
#define BOTHTACTPRESSED 3

#define BUTTON @"button"
#define POINTER @"pointer"
#define GESTURE @"gesture"
#define ROTATION @"rotation"

@protocol OpenSpatialBluetoothDelegate <NSObject>

-(ButtonEvent *)buttonEventFired: (ButtonEvent *) buttonEvent;
-(PointerEvent *)pointerEventFired: (PointerEvent *) pointerEvent;
-(RotationEvent *)rotationEventFired: (RotationEvent *) rotationEvent;
-(GestureEvent *)gestureEventFired: (GestureEvent *) gestureEvent;

- (void) didConnectToNod: (CBPeripheral*) peripheral;
- (void) didFindNewDevice: (CBPeripheral*) peripheral;
@end

@interface OpenSpatialBluetooth: NSObject

@property CBCentralManager *centralManager;
@property NSMutableArray *foundPeripherals;

@property NSMutableDictionary *connectedPeripherals;

@property NSMutableArray *ConnectedServices;
@property id<OpenSpatialBluetoothDelegate> delegate;

+(id) sharedBluetoothServ;
-(id) delegate;
-(void) setDelegate:(id<OpenSpatialBluetoothDelegate>)newDelegate;

/*
 * Scans for for only peripherals with the Open Spatial UUID adding all peripherals to the peripherals array
 */
-(void) scanForPeripherals;

/*
 * Connect to a peripheral device store as connected device, also stops scan
 * @param peripheral - the peripheral that the central manager will connect to
 */
-(void) connectToPeripheral: (CBPeripheral *) peripheral;

/*
 * Returns an Array Containing the names of all the services associated with a device
 * @param peripheral
 */
-(void) getServicesForConnectedDevice:(CBPeripheral *)peripheral;

/*
 * Checks to see if user subscribed to certain set of events
 * @param type - the string that is used to check for a certain event
 * @param peripheralName - the name of the peripheral that is compared to in the dictionary
 */
-(BOOL)isSubscribedToEvent:(NSString *)type forPeripheral:(NSString *)peripheralName;


/*
 * Method used in unit tests to ensure that characteristic and data being sent by a peripheral device is being captured
 *
 * @param characteristic - the characteristic that is passed through the function to determine which events to execute upon
 * @param peripheral - the peripheral that is passed through the function so that user can know which peripheral device executed which events
 */
-(NSArray *)testBluetoothCharacteristic:(CBCharacteristic *)characteristic andPeripheral:(CBPeripheral *)peripheral;

/*
 * Subscribes the specified peripheral device to the rotation events
 *
 * @param peripheralName - the name of the peripheral that will connect to rotation events
 */
-(void)subscribeToRotationEvents:(NSString *)peripheralName;

/*
 * Subscribes the specified peripheral device to gesture events
 *
 * @param peripheralName - the name of the peripheral that will connect to gesture events
 */
-(void)subscribeToGestureEvents:(NSString *)peripheralName;

/*
 * Subscribes the specified peripheral device to button events
 *
 * @param peripheralName - the name of the peripheral that will connect to button events
 */
-(void)subscribeToButtonEvents:(NSString *)peripheralName;

/*
 * Subscribes the specified peripheral device to pointer events
 *
 * @param peripheralName - the name of the peripheral that will connect to pointer events
 */
-(void)subscribeToPointerEvents:(NSString *)peripheralName;

@end