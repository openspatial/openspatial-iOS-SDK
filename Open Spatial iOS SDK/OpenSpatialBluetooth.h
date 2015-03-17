//
//  OpenSpatialBluetooth.h
//  Open Spatial iOS SDK
//
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <CoreBluetooth/CoreBluetooth.h>
#import "OpenSpatialDecoder.h"

#import "ButtonEvent.h"
#import "PointerEvent.h"
#import "RotationEvent.h"
#import "GestureEvent.h"
#import "Motion6DEvent.h"

#define OS_UUID @"00000002-0000-1000-8000-A0E5E9000000"
#define POS2D_UUID @"00000206-0000-1000-8000-A0E5E9000000"
#define TRANS3D_UUID @"00000205-0000-1000-8000-A0E5E9000000"
#define GEST_UUID @"00000208-0000-1000-8000-A0E5E9000000"
#define BUTTON_UUID @"00000207-0000-1000-8000-A0E5E9000000"
#define MOTION6D_UUID @"00000209-0000-1000-8000-A0E5E9000000"

#define NCONTROL_UUID @"00000004-0000-1000-8000-A0E5E9000000"
#define MODE_SWITCH_CHAR @"00000400-0000-1000-8000-A0E5E9000000"

#define BUTTON @"button"
#define POINTER @"pointer"
#define GESTURE @"gesture"
#define ROTATION @"rotation"
#define MOTION @"motion"

#define POS2D_SIZE 4
#define TRANS3D_SIZE 12
#define GEST_SIZE 5x
#define BUTTON_SIZE 2

#define POINTER_MODE 0x00
#define GAME_MODE 0x01
#define THREE_D_MODE 0x02
#define FREE_POINTER_MODE 0x03

@interface NodDevice : NSObject

@property CBPeripheral* BTPeripheral;
@property CBCharacteristic* gestureCharacteristic;
@property CBCharacteristic* pose6DCharacteristic;
@property CBCharacteristic* pointerCharacteristic;
@property CBCharacteristic* buttonCharacteristic;
@property CBCharacteristic* motion6DCharacteristic;
@property NSMutableDictionary* subscribedTo;

@end
/*!
 Delegate for the OpenSpatialBluetooth object implementing classes will
 recieve OpenSpatialEvents
 */
@protocol OpenSpatialBluetoothDelegate <NSObject>

/*!
 called when a button event is fired from Nod
 */
-(void)buttonEventFired: (ButtonEvent *) buttonEvent;
/*!
 called when a pointer event is fired from Nod
 */
-(void)pointerEventFired: (PointerEvent *) pointerEvent;
/*!
 called when a rotation event is fired from Nod
 */
-(void)rotationEventFired: (RotationEvent *) rotationEvent;
/*!
 called when a gesture event is fired from Nod
 */
-(void)gestureEventFired: (GestureEvent *) gestureEvent;
/*!
 called when a motion6D event is fired from Nod
 */
-(void)motion6DEventFired: (Motion6DEvent *) motion6DEvent;

/*!
 called when a Nod is connected to from connectToPeripheral
 */
- (void) didConnectToNod: (CBPeripheral*) peripheral;
/*
 called when a new Nod is found from scanForPeripherals
 */
- (void) didFindNewScannedDevice: (NSArray*) peripherals;
- (void) didFindNewPairedDevice: (NSArray*) peripherals;

@end

@interface OpenSpatialBluetooth: NSObject

@property CBCentralManager *centralManager;
@property NSMutableArray *foundPeripherals;
@property NSMutableArray *pairedPeripherals;
@property NSMutableDictionary *connectedPeripherals;
@property id<OpenSpatialBluetoothDelegate> delegate;

/*!
 Singleton constructor method
 */
+(id) sharedBluetoothServ;
-(id) delegate;
/*!
 sets the delegate
 */
-(void) setDelegate:(id<OpenSpatialBluetoothDelegate>)newDelegate;

/*!
 * Scans for for only peripherals with the Open Spatial UUID adding all peripherals to the peripherals array
 */
-(void) scanForPeripherals;

/*!
 * Connect to a peripheral device store as connected device, also stops scan
 * @param peripheral - the peripheral that the central manager will connect to
 */
-(void) connectToPeripheral: (CBPeripheral *) peripheral;

/*!
 * Returns an Array Containing the names of all the services associated with a device
 * @param peripheral
 */
-(void) getServicesForConnectedDevice:(CBPeripheral *)peripheral;

/*!
 * Checks to see if user subscribed to certain set of events
 * @param type - the string that is used to check for a certain event
 * @param peripheralName - the name of the peripheral that is compared to in the dictionary
 */
-(BOOL)isSubscribedToEvent:(NSString *)type forPeripheral:(NSString *)peripheralName;


/*!
 * Method used in unit tests to ensure that characteristic and data being sent by a peripheral device is being captured
 *
 * @param characteristic - the characteristic that is passed through the function to determine which events to execute upon
 * @param peripheral - the peripheral that is passed through the function so that user can know which peripheral device executed which events
 */
-(NSArray *)testBluetoothCharacteristic:(CBCharacteristic *)characteristic andPeripheral:(CBPeripheral *)peripheral;

/*!
 * Subscribes the specified peripheral device to the rotation events
 *
 * @param peripheralName - the name of the peripheral that will connect to rotation events
 */
-(void)subscribeToRotationEvents:(NSString *)peripheralName;
-(void)unsubscribeFromRotationEvents: (NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to gesture events
 *
 * @param peripheralName - the name of the peripheral that will connect to gesture events
 */
-(void)subscribeToGestureEvents:(NSString *)peripheralName;
-(void)unsubscribeFromGestureEvents: (NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to button events
 *
 * @param peripheralName - the name of the peripheral that will connect to button events
 */
-(void)subscribeToButtonEvents:(NSString *)peripheralName;
-(void)unsubscribeFromButtonEvents: (NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to pointer events
 *
 * @param peripheralName - the name of the peripheral that will connect to pointer events
 */
-(void)subscribeToPointerEvents:(NSString *)peripheralName;
-(void)unsubscribeFromPointerEvents: (NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to motion6D events
 *
 * @param peripheralName - the name of the peripheral that will connect to motion6D events
 */
-(void)subscribeToMotion6DEvents:(NSString *)peripheralName;
-(void)unsubscribeFromMotion6DEvents: (NSString *)peripheralName;

@end


