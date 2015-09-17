//
//  OpenSpatialBluetooth.h
//  Open Spatial iOS SDK
//
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <CoreBluetooth/CoreBluetooth.h>
#import "OpenSpatialDecoder.h"
#import "OpenSpatialData.h"
#import "OpenSpatialConstants.h"

#import "ButtonEvent.h"
#import "Position2DEvent.h"
#import "Pose6DEvent.h"
#import "GestureEvent.h"
#import "Motion6DEvent.h"
#import "AnalogEvent.h"

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
 called when OpenSpatialData is fired from Nod device
 */
-(void)openSpatialDataFired: (OpenSpatialData *) openSpatialData;

/*!
 called when a button event is fired from Nod
 */
-(void)buttonEventFired:(ButtonEvent *) buttonEvent DEPRECATED_ATTRIBUTE;
/*!
 called when a position2D event is fired from Nod
 */
-(void)position2DEventFired:(Position2DEvent *) position2DEvent DEPRECATED_ATTRIBUTE;
/*!
 called when a pose6D event is fired from Nod
 */
-(void)pose6DEventFired:(Pose6DEvent *) pose6DEvent DEPRECATED_ATTRIBUTE;
/*!
 called when a gesture event is fired from Nod
 */
-(void)gestureEventFired:(GestureEvent *) gestureEvent DEPRECATED_ATTRIBUTE;
/*!
 called when a motion6D event is fired from Nod
 */
-(void)motion6DEventFired:(Motion6DEvent *) motion6DEvent DEPRECATED_ATTRIBUTE;
/*!
 called when a analog event is fired from Nod
 */
-(void)analogEventFired:(AnalogEvent *) analogEvent DEPRECATED_ATTRIBUTE;

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
 * Subscribes the specified peripheral device to the pose6D events
 *
 * @param peripheralName - the name of the peripheral that will connect to pose6D events
 */
-(void)subscribeToPose6DEvents:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;
-(void)unsubscribeFromPose6DEvents: (NSString *)peripheralName DEPRECATED_ATTRIBUTE;

/*!
 * Subscribes the specified peripheral device to gesture events
 *
 * @param peripheralName - the name of the peripheral that will connect to gesture events
 */
-(void)subscribeToGestureEvents:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;
-(void)unsubscribeFromGestureEvents: (NSString *)peripheralName DEPRECATED_ATTRIBUTE;

/*!
 * Subscribes the specified peripheral device to button events
 *
 * @param peripheralName - the name of the peripheral that will connect to button events
 */
-(void)subscribeToButtonEvents:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;
-(void)unsubscribeFromButtonEvents: (NSString *)peripheralName DEPRECATED_ATTRIBUTE;

/*!
 * Subscribes the specified peripheral device to pointer events
 *
 * @param peripheralName - the name of the peripheral that will connect to pointer events
 */
-(void)subscribeToPosition2DEvents:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;
-(void)unsubscribeFromPosition2DEvents: (NSString *)peripheralName DEPRECATED_ATTRIBUTE;

/*!
 * Subscribes the specified peripheral device to motion6D events
 *
 * @param peripheralName - the name of the peripheral that will connect to motion6D events
 */
-(void)subscribeToMotion6DEvents:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;
-(void)unsubscribeFromMotion6DEvents: (NSString *)peripheralName DEPRECATED_ATTRIBUTE;

/*!
 * Subscribes the specified peripheral device to battery level updates
 *
 * @param peripheralName - the name of the peripheral that will broadcast battery level updates
 */
- (void)subscribeToBatteryLevel:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;
-(void)unsubscribeFromBatteryLevel:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;

/*!
 * Subscribes the specified peripheral device to analog events
 *
 * @param peripheralName - the name of the peripheral that will connect to analog events
 */
-(void)subscribeToAnalogEvents:(NSString *)peripheralName DEPRECATED_ATTRIBUTE;
-(void)unsubscribeFromAnalogEvents: (NSString *)peripheralName DEPRECATED_ATTRIBUTE;

/*!
 * Subscribes the specified peripheral device to events
 *
 * @param peripheralName - the name of the peripheral
 * @param eventTypesToToggle - an array of the event types that will be subscribed to
 */
-(void)subscribeToEvents:(NSString *)peripheralName forEventTypes:(NSArray*)eventTypesToToggle;

/*!
 * Unsubscribes the specified peripheral device to events
 *
 * @param peripheralName - the name of the peripheral
 * @param eventTypesToToggle - an array of the event types that the device will unsubscribe from
 */
-(void)unsubscribeFromEvents:(NSString *)peripheralName forEventTypes:(NSArray*)eventTypesToToggle;

/*!
 * Unsubscribes the specified peripheral device from all oData events
 *
 * @param peripheralName - the name of the peripheral
 */
-(void)unsubscribeFromAllEvents:(NSString *)peripheralName;

/*
 * Read battery level function
 * @param peripheralName - the name of the peripheral that will get the battery level
 */
-(void) readBatteryLevel:(NSString*)peripheralName;
@end


