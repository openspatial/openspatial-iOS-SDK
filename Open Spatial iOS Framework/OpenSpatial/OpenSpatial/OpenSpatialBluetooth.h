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
#import "Position2DEvent.h"
#import "Pose6DEvent.h"
#import "GestureEvent.h"
#import "Motion6DEvent.h"
#import "AnalogEvent.h"

#define OS_UUID @"00000002-0000-1000-8000-A0E5E9000000"
#define POSITION2D_UUID @"00000206-0000-1000-8000-A0E5E9000000"
#define POSE6D_UUID @"00000205-0000-1000-8000-A0E5E9000000"
#define GEST_UUID @"00000208-0000-1000-8000-A0E5E9000000"
#define BUTTON_UUID @"00000207-0000-1000-8000-A0E5E9000000"
#define MOTION6D_UUID @"00000209-0000-1000-8000-A0E5E9000000"
#define ANALOG_UUID @"0000020C-0000-1000-8000-A0E5E9000000"

#define ODATA_UUID @"0000020B-0000-1000-8000-A0E5E9000000"
#define OCONTROL_UUID @"0000020A-0000-1000-8000-A0E5E9000000"

#define NCONTROL_UUID @"00000004-0000-1000-8000-A0E5E9000000"
#define MODE_SWITCH_CHAR @"00000400-0000-1000-8000-A0E5E9000000"

#define BATTERY_SERVICE_UUID @"180F"
#define BATTERY_STATUS_CHAR_UUID @"2A19"

#define BUTTON @"button"
#define POSITION2D @"position2D"
#define GESTURE @"gesture"
#define POSE6D @"pose6D"
#define MOTION6D @"motion6D"
#define BATTERY @"battery"
#define ANALOG @"analog"

#define ODATA @"odata"
#define OCONTROL @"ocontrol"

@interface NodDevice : NSObject

@property CBPeripheral* BTPeripheral;
@property CBCharacteristic* gestureCharacteristic;
@property CBCharacteristic* pose6DCharacteristic;
@property CBCharacteristic* position2DCharacteristic;
@property CBCharacteristic* buttonCharacteristic;
@property CBCharacteristic* motion6DCharacteristic;
@property CBCharacteristic* batteryCharacteristic;
@property CBCharacteristic* analogCharacteristic;
@property CBCharacteristic* oControlCharacteristic;
@property CBCharacteristic* oDataCharacteristic;
@property NSMutableDictionary* subscribedTo;
@property int servicesCount;
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
 called when a position2D event is fired from Nod
 */
-(void)position2DEventFired: (Position2DEvent *) position2DEvent;
/*!
 called when a pose6D event is fired from Nod
 */
-(void)pose6DEventFired: (Pose6DEvent *) pose6DEvent;
/*!
 called when a gesture event is fired from Nod
 */
-(void)gestureEventFired: (GestureEvent *) gestureEvent;
/*!
 called when a motion6D event is fired from Nod
 */
-(void)motion6DEventFired: (Motion6DEvent *) motion6DEvent;
/*!
 called when a analog event is fired from Nod
 */
-(void)analogEventFired: (AnalogEvent *) analogEvent;

/*!
 called when a Nod is connected to from connectToPeripheral
 */
- (void) didConnectToNod: (CBPeripheral*) peripheral;

/*!
 called when a Nod disconnects from device
 */
- (void) didDisconnectFromNod: (NSString *)peripheral;

/*
 called when a new Nod is found from scanForPeripherals
 */
- (void) didFindNewScannedDevice: (NSArray*) peripherals;
- (void) didFindNewPairedDevice: (NSArray*) peripherals;

/*
 called when battery level is updated on Nod
*/
- (void) didReadBatteryLevel:(NSInteger) level forRingNamed:(NSString*) name;

@end

@interface OpenSpatialBluetooth: NSObject {
    BOOL reconnect;
    BOOL forceOff;
}

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
 * Disconnect from peripheral device
 * @param peripheral - the peripheral that the central manager will disconnect from
 */
-(void)disconnectFromPeripheral: (CBPeripheral *)peripheral;

/*!
 * Returns an Array Containing the names of all the services associated with a device
 * @param peripheral
 */
-(void) getServicesForConnectedDevice:(CBPeripheral *)peripheral;

/*!
 * Method used in unit tests to ensure that characteristic and data being sent by a peripheral device is being captured
 *
 * @param characteristic - the characteristic that is passed through the function to determine which events to execute upon
 * @param peripheral - the peripheral that is passed through the function so that user can know which peripheral device executed which events
 */
-(NSArray *)testBluetoothCharacteristic:(CBCharacteristic *)characteristic andPeripheral:(CBPeripheral *)peripheral;

/*!
 * Subscribes the specified peripheral device to the pose6D events
 *
 * @param peripheralName - the name of the peripheral that will connect to pose6D events
 */
-(void)subscribeToPose6DEvents:(NSString *)peripheralName;
-(void)unsubscribeFromPose6DEvents: (NSString *)peripheralName;

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
-(void)subscribeToPosition2DEvents:(NSString *)peripheralName;
-(void)unsubscribeFromPosition2DEvents: (NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to motion6D events
 *
 * @param peripheralName - the name of the peripheral that will connect to motion6D events
 */
-(void)subscribeToMotion6DEvents:(NSString *)peripheralName;
-(void)unsubscribeFromMotion6DEvents: (NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to battery level updates
 *
 * @param peripheralName - the name of the peripheral that will broadcast battery level updates
 */
- (void)subscribeToBatteryLevel:(NSString *)peripheralName;
-(void)unsubscribeFromBatteryLevel:(NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to analog events
 *
 * @param peripheralName - the name of the peripheral that will connect to analog events
 */
-(void)subscribeToAnalogEvents:(NSString *)peripheralName;
-(void)unsubscribeFromAnalogEvents: (NSString *)peripheralName;

/*!
 * Subscribes the specified peripheral device to oData events
 *
 * @param peripheralName - the name of the peripheral that will connect to oData events
 */
-(void)subscribeToODataEvents:(NSString *)peripheralName forEventTypes:(NSMutableArray*)eventTypesToToggle;
-(void)unsubscribeFromODataEvents: (NSString *)peripheralName;

/*!
 * Toggles the oData stream for the specified types of data
 *
 * @param peripheralName - the name of the peripheral that will have the oData stream toggled for specified events
 * @param eventTypesToToggle - an array with the event types to toggle
 */
-(void)toggleOData:(BOOL)value withName:(NSString*)peripheralName forEventTypes:(NSMutableArray*)eventTypesToToggle;

/*
 * Read battery level function
 * @param peripheralName - the name of the peripheral that will get the battery level
 */
-(void) readBatteryLevel:(NSString*)peripheralName;

@end


