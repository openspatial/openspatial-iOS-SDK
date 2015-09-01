//
//  OpenSpatialBluetooth.m
//  Open Spatial iOS SDK
//
//  Reads HID information from the ring's open spatial service
//  Because Apple is annoying and doesnt let you read HID directly
//  If you aren't the system
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import "OpenSpatialBluetooth.h"

@interface NodDevice ()

@end

@implementation NodDevice

@end

@interface OpenSpatialBluetooth()  <CBCentralManagerDelegate, CBPeripheralDelegate>

-(void)updateOData:(CBPeripheral*)peripheral;
-(void)toggleOData:(BOOL)value withName:(NSString*)peripheralName forEventTypes:(NSMutableArray*)eventTypesToToggle;
@end

@implementation OpenSpatialBluetooth

#pragma mark Singleton Methods

+ (id)sharedBluetoothServ {
    static OpenSpatialBluetooth *sharedBluetoothServ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBluetoothServ = [[self alloc] init];
    });
    return sharedBluetoothServ;
}

- (id)init {
    if (self = [super init]) {
        self.foundPeripherals = [[NSMutableArray alloc] init];
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.connectedPeripherals = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/*******************************************************************************************
 *                                                                                         *
 *                             Scanning / Connecting Services                              *
 *                                                                                         *
 *                                                                                         *
 *******************************************************************************************/

/*
 * Scans for for only peripherals with the Open Spatial UUID adding all peripherals to the peripherals array.
 */
- (void) scanForPeripherals {
    NSLog(@"Scanning");
    [self.foundPeripherals removeAllObjects];
    CBUUID* hidUUID = [CBUUID UUIDWithString:@"1812"];
    CBUUID* osUUID = [CBUUID UUIDWithString:OS_UUID];
    CBUUID* nUUID = [CBUUID UUIDWithString:NCONTROL_UUID];
    NSArray* services = @[hidUUID, osUUID, nUUID];
    
    self.pairedPeripherals = [NSMutableArray arrayWithArray:
                              [self.centralManager retrieveConnectedPeripheralsWithServices:services]];
    if([self.delegate respondsToSelector:@selector(didFindNewPairedDevice:)]) {
        [self.delegate didFindNewPairedDevice:self.pairedPeripherals];
    }
}

/*
 * State must be on to initiate scan this method is called after the initialization that occurs
 * in scanForPeripherals
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if(central.state == CBCentralManagerStatePoweredOn) {
        if([self.connectedPeripherals count] > 0) {
            [self.connectedPeripherals removeAllObjects];
        }
    }
    else
    {
        NSLog(@"Bluetooth Off");
        if([self.delegate respondsToSelector:@selector(didDisconnectFromNod:)]) {
            NSArray *allConnectedRingNames = [self.connectedPeripherals allKeys];
            for(NSString *ringNameString in allConnectedRingNames) {
                [self.connectedPeripherals removeObjectForKey:ringNameString];
                [self.delegate didDisconnectFromNod:ringNameString];
            }
        }
    }
}

-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if(![self.foundPeripherals containsObject:peripheral]) {
        [self.foundPeripherals addObject:peripheral];
        if(self.delegate) {
            if([self.delegate respondsToSelector:@selector(didFindNewScannedDevice:)]) {
                [self.delegate didFindNewScannedDevice:self.foundPeripherals];
            }
        }
    }
}

/*
 * Connect to a peripheral device store as connected device, also stops scan
 */
-(void) connectToPeripheral: (CBPeripheral *) peripheral {
    [self.centralManager stopScan];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

/*
 * When device is connected set connected bool to true
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if([self.connectedPeripherals objectForKey:peripheral.name]) {
    } else {
        NodDevice* dev = [[NodDevice alloc] init];
        NSDictionary* eventDictionary = @{BUTTON: @FALSE, POSITION2D: @FALSE, POSE6D: @FALSE, GESTURE: @FALSE, MOTION6D: @FALSE, ANALOG: @FALSE, BATTERY: @FALSE, ODACCELEROMETER: @FALSE, ODANALOG: @FALSE, ODBUTTON: @FALSE, ODCOMPASS: @FALSE, ODEULER: @FALSE, ODGESTURE: @FALSE, ODGYRO: @FALSE, ODRELATIVEXY: @FALSE, ODSLIDER: @FALSE, ODTRANSLATION: @FALSE};
        peripheral.delegate = self;
        dev.BTPeripheral = peripheral;
        dev.subscribedTo = [NSMutableDictionary dictionaryWithDictionary:eventDictionary];
        [self.connectedPeripherals setObject:dev forKey:peripheral.name];
        NSLog(@"Connect for 1st Time");
    }
    [self getServicesForConnectedDevice: peripheral];
    
    NSLog(@"Connected to %@", peripheral.name);
}

/*
 * Disconnect from a peripheral device
 */
-(void)disconnectFromPeripheral: (CBPeripheral *)peripheral {
    forceOff = true;
    [self.centralManager cancelPeripheralConnection:peripheral];
    [self unsubscribeFromAllEvents:peripheral.name];
}

/*
 * Fails to connect to peripheral
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if(reconnect) {
        if([self.delegate respondsToSelector:@selector(didDisconnectFromNod:)]) {
            [self.connectedPeripherals removeObjectForKey:peripheral.name];
            [self.delegate didDisconnectFromNod:peripheral.name];
        }
        reconnect = false;
    }
}

/*
 * Returns an Array Containing the names of all the services associated with a device
 */
-(void) getServicesForConnectedDevice:(CBPeripheral *)peripheral {
    if(peripheral) {
        NSLog(@"Discovering Services, %@", peripheral.delegate);
        [peripheral discoverServices:nil];
    }
}

/*
 * Delegate Method for discovering services prints service to log
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    ((NodDevice*)[self.connectedPeripherals objectForKey:peripheral.name]).servicesCount = 0;
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered Service %@", service);
        [self getCharacteristics:service peripheral:peripheral];
    }
}

/*
 * Gets characteristics of a specfied service
 */
-(void) getCharacteristics: (CBService*) serv peripheral:(CBPeripheral *)peripheral {
    [peripheral discoverCharacteristics:nil forService:serv];
}

/*
 * Delegate Method for discovering characteristics prints all characteristics to log
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *) service error:(NSError *)error {
    int countChars = 0;
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheral.name];
    dev.servicesCount++;
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"%@",characteristic.UUID.UUIDString);
        if([service.UUID.UUIDString isEqualToString:OS_UUID]) {
            if([characteristic.UUID.UUIDString isEqualToString:POSITION2D_UUID]) {
                dev.position2DCharacteristic = characteristic;
                countChars++;
            }
            if([characteristic.UUID.UUIDString isEqualToString:POSE6D_UUID]) {
                dev.pose6DCharacteristic = characteristic;
                countChars++;
            }
            if([characteristic.UUID.UUIDString isEqualToString:GEST_UUID]) {
                dev.gestureCharacteristic = characteristic;
                countChars++;
            }
            if([characteristic.UUID.UUIDString isEqualToString:BUTTON_UUID]) {
                dev.buttonCharacteristic = characteristic;
                countChars++;
            }
            if([characteristic.UUID.UUIDString isEqualToString:MOTION6D_UUID]) {
                dev.motion6DCharacteristic = characteristic;
                countChars++;
            }
            if([characteristic.UUID.UUIDString isEqualToString:ANALOG_UUID]) {
                dev.analogCharacteristic = characteristic;
                countChars++;
            }
            if([characteristic.UUID.UUIDString isEqualToString:ODATA_UUID]) {
                dev.oDataCharacteristic = characteristic;
                countChars++;
            }
            if([characteristic.UUID.UUIDString isEqualToString:OCONTROL_UUID]) {
                dev.oControlCharacteristic = characteristic;
                countChars++;
            }
            NSLog(@"Count Chars: %d", countChars);
            if(service.characteristics.count == countChars) {
                if([self.delegate respondsToSelector:@selector(didConnectToNod:)]) {
                    [self.delegate didConnectToNod:peripheral];
                    NSLog(@"Connected - Delegate Method Fired");
                }
            }
        }
        else if([service.UUID.UUIDString isEqualToString:BATTERY_SERVICE_UUID]) {
            if([characteristic.UUID.UUIDString isEqualToString:BATTERY_STATUS_CHAR_UUID]) {
                dev.batteryCharacteristic = characteristic;
            }
        }
    }
    
    if(peripheral.services.count == dev.servicesCount) {
        [self performSelector:@selector(updateOData:) withObject:peripheral afterDelay:2.0];
    }
}

-(void)updateOData:(CBPeripheral*)peripheral {
    [self unsubscribeFromAllEvents:peripheral.name];
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheral.name];
    [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
    NSMutableArray* objectsToTurnOff = [[NSMutableArray alloc] init];
    
    // Old OpenSpatial Specifications
    
    if([[dev.subscribedTo valueForKey:BUTTON] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_BUTTON_EVENT_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_BUTTON_EVENT_TAG)];
    }
    if([[dev.subscribedTo valueForKey:POSITION2D] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RELATIVE_XY_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_RELATIVE_XY_TAG)];
    }
    if([[dev.subscribedTo objectForKey:POSE6D] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_TRANSLATIONS_TAG), @(OS_EULER_ANGLES_TAG), nil]];
    } else {
        [objectsToTurnOff
         addObjectsFromArray:[[NSArray alloc] initWithObjects:@(OS_TRANSLATIONS_TAG), @(OS_EULER_ANGLES_TAG), nil]];
    }
    if([[dev.subscribedTo objectForKey:GESTURE] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_SLIDER_GESTURE_TAG), @(OS_DIRECTION_GESTURE_TAG), nil]];
    } else {
        [objectsToTurnOff
         addObjectsFromArray:[[NSArray alloc] initWithObjects:@(OS_DIRECTION_GESTURE_TAG), @(OS_SLIDER_GESTURE_TAG), nil]];
    }
    if([[dev.subscribedTo objectForKey:MOTION6D] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RAW_ACCELEROMETER_TAG), @(OS_RAW_GYRO_TAG), nil]];
    } else {
        [objectsToTurnOff
         addObjectsFromArray:[[NSArray alloc] initWithObjects:@(OS_RAW_GYRO_TAG), @(OS_RAW_ACCELEROMETER_TAG), nil]];
    }
    if([[dev.subscribedTo objectForKey:ANALOG] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_ANALOG_DATA_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_ANALOG_DATA_TAG)];
    }
    
    // New Open Spatial Specifications
    
    if([[dev.subscribedTo objectForKey:ODACCELEROMETER] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RAW_ACCELEROMETER_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_RAW_ACCELEROMETER_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODANALOG] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_ANALOG_DATA_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_ANALOG_DATA_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODBUTTON] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_BUTTON_EVENT_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_BUTTON_EVENT_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODCOMPASS] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RAW_COMPASS_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_RAW_COMPASS_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODEULER] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_EULER_ANGLES_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_EULER_ANGLES_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODGESTURE] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_DIRECTION_GESTURE_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_DIRECTION_GESTURE_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODGYRO] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RAW_GYRO_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_RAW_GYRO_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODRELATIVEXY] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RELATIVE_XY_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_RELATIVE_XY_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODSLIDER] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_SLIDER_GESTURE_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_SLIDER_GESTURE_TAG)];
    }
    if([[dev.subscribedTo objectForKey:ODTRANSLATION] boolValue]) {
        [self toggleOData:TRUE withName:peripheral.name
            forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_TRANSLATIONS_TAG), nil]];
    } else {
        [objectsToTurnOff addObject:@(OS_TRANSLATIONS_TAG)];
    }
    
    //            [self toggleOData:FALSE withName:peripheral.name forEventTypes:objectsToTurnOff];
}

/*!
 * Toggles the oData stream for the specified types of data
 *
 * @param peripheralName - the name of the peripheral that will have the oData stream toggled for specified events
 * @param eventTypesToToggle - an array with the event types to toggle
 */
-(void)toggleOData:(BOOL)value withName:(NSString*)peripheralName forEventTypes:(NSMutableArray*)eventTypesToToggle {
    uint8_t enableDisable = (value) ? OCONTROL_ENABLE_DATA : OCONTROL_DISABLE_DATA;
    for(int i=0; i < eventTypesToToggle.count; i++) {
        NSMutableData* data = [[NSMutableData alloc] init];
        [data appendBytes:&enableDisable length:sizeof(enableDisable)];
        int eventType = [[eventTypesToToggle objectAtIndex:i] intValue];
        [data appendBytes:&eventType length:sizeof(eventType)];
        [((NodDevice*)[self.connectedPeripherals objectForKey:peripheralName]).BTPeripheral writeValue:data forCharacteristic:((NodDevice*)[self.connectedPeripherals objectForKey:peripheralName]).oControlCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

-(void)subscribeToEvents:(NSString *)peripheralName forEventTypes:(NSMutableArray*)eventTypesToToggle {
    [self toggleOData:TRUE withName:peripheralName forEventTypes:eventTypesToToggle];
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
        for (int i=0; i < eventTypesToToggle.count; i++) {
            switch ((ODataTag)[eventTypesToToggle objectAtIndex:i]) {
                case OS_RAW_ACCELEROMETER_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODACCELEROMETER];
                }
                case OS_ANALOG_DATA_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODANALOG];
                }
                case OS_BUTTON_EVENT_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODBUTTON];
                }
                case OS_RAW_COMPASS_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODCOMPASS];
                }
                case OS_EULER_ANGLES_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODEULER];
                }
                case OS_DIRECTION_GESTURE_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODGESTURE];
                }
                case OS_RAW_GYRO_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODGYRO];
                }
                case OS_RELATIVE_XY_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODRELATIVEXY];
                }
                case OS_SLIDER_GESTURE_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODSLIDER];
                }
                case OS_TRANSLATIONS_TAG: {
                    [dev.subscribedTo setValue:@TRUE forKey:ODTRANSLATION];
                }
            }
        }
    }
}

-(void)unsubscribeFromEvents:(NSString *)peripheralName forEventTypes:(NSMutableArray*)eventTypesToToggle {
    [self toggleOData:FALSE withName:peripheralName forEventTypes:eventTypesToToggle];
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    for (int i=0; i < eventTypesToToggle.count; i++) {
        switch ((ODataTag)[eventTypesToToggle objectAtIndex:i]) {
            case OS_RAW_ACCELEROMETER_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODACCELEROMETER];
            }
            case OS_ANALOG_DATA_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODANALOG];
            }
            case OS_BUTTON_EVENT_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODBUTTON];
            }
            case OS_RAW_COMPASS_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODCOMPASS];
            }
            case OS_EULER_ANGLES_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODEULER];
            }
            case OS_DIRECTION_GESTURE_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODGESTURE];
            }
            case OS_RAW_GYRO_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODGYRO];
            }
            case OS_RELATIVE_XY_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODRELATIVEXY];
            }
            case OS_SLIDER_GESTURE_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODSLIDER];
            }
            case OS_TRANSLATIONS_TAG: {
                [dev.subscribedTo setValue:@FALSE forKey:ODTRANSLATION];
            }
        }
    }
}

-(void)unsubscribeFromAllEvents: (NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    NSMutableArray* eventTypes = [[NSMutableArray alloc] initWithObjects:@(OS_RAW_ACCELEROMETER_TAG), @(OS_RAW_GYRO_TAG), @(OS_RAW_COMPASS_TAG), @(OS_EULER_ANGLES_TAG), @(OS_TRANSLATIONS_TAG), @(OS_ANALOG_DATA_TAG), @(OS_RELATIVE_XY_TAG), @(OS_DIRECTION_GESTURE_TAG), @(OS_SLIDER_GESTURE_TAG), @(OS_BUTTON_EVENT_TAG), nil];
    [self toggleOData:FALSE withName:peripheralName forEventTypes:eventTypes];
    if(dev) {
        [dev.BTPeripheral setNotifyValue:NO forCharacteristic:dev.oDataCharacteristic];
    }
}

/*
 * Subscribes to rotation events for the given device
 */
-(void)subscribeToPose6DEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@TRUE forKey:POSE6D];
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
        [self toggleOData:TRUE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_TRANSLATIONS_TAG),@(OS_EULER_ANGLES_TAG), nil]];
    }
}

-(void)unsubscribeFromPose6DEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@NO forKey:POSE6D];
        [self toggleOData:FALSE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_TRANSLATIONS_TAG),@(OS_EULER_ANGLES_TAG), nil]];
    }
}

/*
 * Subscribes to gesture events for the given device
 */
-(void)subscribeToGestureEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@TRUE forKey:GESTURE];
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
        [self toggleOData:TRUE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_DIRECTION_GESTURE_TAG),@(OS_SLIDER_GESTURE_TAG), nil]];
    }
}
-(void)unsubscribeFromGestureEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@NO forKey:GESTURE];
        [self toggleOData:FALSE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_DIRECTION_GESTURE_TAG),@(OS_SLIDER_GESTURE_TAG), nil]];
    }
}

/*
 * Subscribes to button events for the given device
 */
-(void)subscribeToButtonEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@TRUE forKey:BUTTON];
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
        [self toggleOData:TRUE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_BUTTON_EVENT_TAG), nil]];
    }
}
-(void)unsubscribeFromButtonEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@NO forKey:BUTTON];
        [self toggleOData:FALSE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_BUTTON_EVENT_TAG), nil]];
    }
}

/*
 * Subscribes to pointer events for the given device
 */
-(void)subscribeToPosition2DEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@TRUE forKey:POSITION2D];
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
        [self toggleOData:TRUE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RELATIVE_XY_TAG), nil]];
    }
}
-(void)unsubscribeFromPosition2DEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@NO forKey:POSITION2D];
        [self toggleOData:FALSE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RELATIVE_XY_TAG), nil]];
    }
}

/*
 * Subscribes to motion6D events for the given device
 */
-(void)subscribeToMotion6DEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@TRUE forKey:MOTION6D];
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
        [self toggleOData:TRUE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RAW_ACCELEROMETER_TAG),@(OS_RAW_GYRO_TAG), nil]];
    }
}
-(void)unsubscribeFromMotion6DEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@NO forKey:MOTION6D];
        [self toggleOData:FALSE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_RAW_ACCELEROMETER_TAG),@(OS_RAW_GYRO_TAG), nil]];
    }
}

/*
 * Subscribes to analog events for the given device
 */
-(void)subscribeToAnalogEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@TRUE forKey:ANALOG];
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.oDataCharacteristic];
        [self toggleOData:TRUE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_ANALOG_DATA_TAG), nil]];
    }
}
-(void)unsubscribeFromAnalogEvents:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.subscribedTo setValue:@NO forKey:ANALOG];
        [self toggleOData:FALSE withName:peripheralName forEventTypes:[[NSMutableArray alloc] initWithObjects:@(OS_ANALOG_DATA_TAG), nil]];
    }
}

/*
 * Subscribes to battery level events for the given device
 */
- (void)subscribeToBatteryLevel:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.batteryCharacteristic];
        [dev.subscribedTo setValue:@TRUE forKey:BATTERY];
        
        // Called to ensure that it updates the value in the beginning
        [dev.BTPeripheral readValueForCharacteristic:dev.batteryCharacteristic];
    }
}
-(void)unsubscribeFromBatteryLevel:(NSString *)peripheralName {
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev) {
        [dev.BTPeripheral setNotifyValue:NO forCharacteristic:dev.batteryCharacteristic];
        [dev.subscribedTo setValue:@NO forKey:BATTERY];
    }
}

/*
 *  Disconnection Handler (if forceOff is true, it will disconnect from Nod, otherwise
 *  it will try to reconnect)
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected: %@", error);
    if(forceOff){
        forceOff = false;
        if([self.delegate respondsToSelector:@selector(didDisconnectFromNod:)]) {
            [self.connectedPeripherals removeObjectForKey:peripheral.name];
            [self.delegate didDisconnectFromNod:peripheral.name];
        }
    }
    else {
        if([self.delegate respondsToSelector:@selector(didDisconnectFromNod:)]) {
        [self.delegate didDisconnectFromNod:peripheral.name];
        [self connectToPeripheral:peripheral];
        reconnect = true;
        }
    }
}

/*******************************************************************************************
 *                                                                                         *
 *                                  Pointer BLE Services                                   *
 *                                                                                         *
 *                                                                                         *
 *******************************************************************************************/

/*
 * Called from subscription to open spacial service pointer characteristic
 * Interpret data and send a coordinate to the view controller which will draw the pointer
 * If ring is clicked send a click pressed message, when click is released set a click release message
 * Include state machine for all cases,
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // Checks if the characteristic is the position2D characteristic
    if([characteristic.UUID.UUIDString isEqualToString:POSITION2D_UUID]) {
        [self position2DFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the pose6D characteristic
    if([characteristic.UUID.UUIDString isEqualToString:POSE6D_UUID]) {
        [self pose6DFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the gesture characteristic
    if([characteristic.UUID.UUIDString isEqualToString:GEST_UUID]) {
        [self gestureFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the button characteristic
    if([characteristic.UUID.UUIDString isEqualToString:BUTTON_UUID]) {
        [self buttonFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the motion6D characteristic
    if([characteristic.UUID.UUIDString isEqualToString:MOTION6D_UUID]) {
        [self motion6DFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the motion 6d characteristic
    if([characteristic.UUID.UUIDString isEqualToString:ANALOG_UUID]) {
        [self analogFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the battery status characteristic
    if([characteristic.UUID.UUIDString isEqualToString:BATTERY_STATUS_CHAR_UUID]) {
        [self batteryFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the oData characteristic
    if([characteristic.UUID.UUIDString isEqualToString:ODATA_UUID]) {
        [self oDataFunction:characteristic peripheral:peripheral];
    }
}

/*
 * Method for testing that mimics the above didUpdateValueForCharacteristic method
 */
-(NSArray *)testBluetoothCharacteristic:(CBCharacteristic *)characteristic andPeripheral:(CBPeripheral *)peripheral
{
    NSArray* array;
    // Checks if the characteristic is the position2D characteristic
    if([characteristic.UUID.UUIDString isEqualToString:POSITION2D_UUID])
    {
        NSLog(@"Position2D");
        array = [self position2DFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the pose6D characteristic
    if([characteristic.UUID.UUIDString isEqualToString:POSE6D_UUID])
    {
        NSLog(@"Pose6D");
        array = [self pose6DFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the gesture characteristic
    if([characteristic.UUID.UUIDString isEqualToString:GEST_UUID])
    {
        NSLog(@"Gesture");
        array = [self gestureFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the button characteristic
    if([characteristic.UUID.UUIDString isEqualToString:BUTTON_UUID])
    {
        NSLog(@"Button");
        array = [self buttonFunction:characteristic peripheral:peripheral];
    }
    // Checks if the characteristic is the motion6D characteristic
    if([characteristic.UUID.UUIDString isEqualToString:MOTION6D_UUID])
    {
        NSLog(@"Motion6D");
        array = [self motion6DFunction:characteristic peripheral:peripheral];
    }
    return array;
}

/*
 * Method that handles the Open Spatial 2D events
 */
-(NSArray *)position2DFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral DEPRECATED_ATTRIBUTE{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodePos2DPointer:bytePtr];
    NSMutableArray *position2DEvents = [[NSMutableArray alloc] init];

    Position2DEvent *pEvent = [[Position2DEvent alloc] init];
    pEvent.xVal = [[OSData objectForKey:X] shortValue];
    pEvent.yVal = [[OSData objectForKey:Y] shortValue];
    pEvent.peripheral = peripheral;
    [position2DEvents addObject:pEvent];

    if([self.delegate respondsToSelector:@selector(position2DEventFired:)]) {
        [self.delegate position2DEventFired:pEvent];
    }
    
    // For testing purposes only
    return position2DEvents;
}

-(NSArray *)pose6DFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral DEPRECATED_ATTRIBUTE {
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodePose6DPointer:bytePtr];
    NSMutableArray *pose6DEvent = [[NSMutableArray alloc] init];
    
    Pose6DEvent *p6DEvent = [[Pose6DEvent alloc] init];
    p6DEvent.x = [[OSData objectForKey:X] floatValue];
    p6DEvent.y = [[OSData objectForKey:Y] floatValue];
    p6DEvent.z = [[OSData objectForKey:Z] floatValue];
    p6DEvent.roll = [[OSData objectForKey:ROLL] floatValue];
    p6DEvent.pitch = [[OSData objectForKey:PITCH] floatValue];
    p6DEvent.yaw = [[OSData objectForKey:YAW] floatValue];
    p6DEvent.peripheral = peripheral;
    [pose6DEvent addObject:p6DEvent];

    if([self.delegate respondsToSelector:@selector(pose6DEventFired:)]) {
        [self.delegate pose6DEventFired:p6DEvent];
    }
    
    // For testing purposes only
    return pose6DEvent;
}

-(NSArray *)buttonFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral DEPRECATED_ATTRIBUTE {
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeButtonPointer:bytePtr];
    short touch0 = [[OSData objectForKey:TOUCH_0] shortValue];
    short touch1 = [[OSData objectForKey:TOUCH_1] shortValue];
    short touch2 = [[OSData objectForKey:TOUCH_2] shortValue];
    short tact0 = [[OSData objectForKey:TACTILE_0] shortValue];
    short tact1 = [[OSData objectForKey:TACTILE_1] shortValue];
    NSMutableArray* buttonEvents = [[NSMutableArray alloc] init];

    if(touch0 == BUTTON_UP) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH0_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(touch0 == BUTTON_DOWN) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH0_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    if(touch1 == BUTTON_UP) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH1_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(touch1 == BUTTON_DOWN) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH1_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    if(touch2 == BUTTON_UP) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH2_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(touch2 == BUTTON_DOWN) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH2_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    if(tact0 == BUTTON_UP) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE0_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(tact0 == BUTTON_DOWN) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE0_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }

    if(tact1 == BUTTON_UP) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE1_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(tact1 == BUTTON_DOWN) {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE1_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    
    for(ButtonEvent* bEvent in buttonEvents) {
        if([self.delegate respondsToSelector:@selector(buttonEventFired:)]) {
            [self.delegate buttonEventFired:bEvent];
        }
    }

    // For testing purposes only
    return buttonEvents;
}

-(NSArray *)gestureFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral DEPRECATED_ATTRIBUTE {
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeGestPointer:bytePtr];
    short gestureC = [[OSData objectForKey:GEST_OPCODE] shortValue];
    uint8_t gesture = [[OSData objectForKey:GEST_DATA] charValue];
    NSMutableArray *gestureEvent = [[NSMutableArray alloc] init];
    GestureEvent *gEvent = [[GestureEvent alloc] init];

    if(gestureC == G_OP_DIRECTION) {
        if(gesture == GUP) {
            [gEvent setGestureEventType:SWIPE_UP];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if (gesture == GDOWN) {
            [gEvent setGestureEventType:SWIPE_DOWN];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GLEFT) {
            [gEvent setGestureEventType:SWIPE_LEFT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GRIGHT) {
            [gEvent setGestureEventType:SWIPE_RIGHT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GCW) {
            [gEvent setGestureEventType:CW];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GCCW) {
            [gEvent setGestureEventType:CCW];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else {
            NSLog(@"No match found for gesture event.");
        }
    }
    else if(gestureC == G_OP_SCROLL) {
        if(gesture == SLIDE_LEFT) {
            [gEvent setGestureEventType:SLIDER_LEFT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == SLIDE_RIGHT) {
            [gEvent setGestureEventType:SLIDER_RIGHT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else {
            NSLog(@"No match found for gesture event.");
        }
    }
    else {
        NSLog(@"No match found for gesture event.");
    }

    if([self.delegate respondsToSelector:@selector(gestureEventFired:)]) {
        [self.delegate gestureEventFired:gEvent];
    }

    // For testing purposes only
    return gestureEvent;
}

-(NSArray *) motion6DFunction: (CBCharacteristic*) characteristic peripheral:(CBPeripheral*) peripheral DEPRECATED_ATTRIBUTE {
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeMot6DPointer:bytePtr];
    NSMutableArray *motion6DEvent = [[NSMutableArray alloc] init];
    Motion6DEvent* mEvent = [[Motion6DEvent alloc] init];
    mEvent.xAccel = [[OSData objectForKey:XA] floatValue];
    mEvent.yAccel = [[OSData objectForKey:YA] floatValue];
    mEvent.zAccel = [[OSData objectForKey:ZA] floatValue];
    mEvent.xGyro = [[OSData objectForKey:XG] floatValue];
    mEvent.yGyro = [[OSData objectForKey:YG] floatValue];
    mEvent.zGyro = [[OSData objectForKey:ZG] floatValue];
    mEvent.peripheral = peripheral;
    [motion6DEvent addObject:mEvent];
    
    if([self.delegate respondsToSelector:@selector(motion6DEventFired:)]) {
        [self.delegate motion6DEventFired:mEvent];
    }
    
    // For testing purposes only
    return motion6DEvent;
}

-(NSArray *) analogFunction: (CBCharacteristic*) characteristic peripheral:(CBPeripheral*) peripheral DEPRECATED_ATTRIBUTE {
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeAnalogPointer:bytePtr];
    NSMutableArray *analogEvents = [[NSMutableArray alloc] init];
    
    AnalogEvent *aEvent = [[AnalogEvent alloc] init];
    aEvent.xVal = [[OSData objectForKey:Y] shortValue];
    aEvent.yVal = [[OSData objectForKey:X] shortValue];
    aEvent.triggerVal = [[OSData objectForKey:TRIGGER] shortValue];
    aEvent.peripheral = peripheral;
    [analogEvents addObject:aEvent];
    
    if([self.delegate respondsToSelector:@selector(analogEventFired:)]) {
        [self.delegate analogEventFired:aEvent];
    }
    
    // For testing purposes only
    return analogEvents;
}

-(void) batteryFunction: (CBCharacteristic*) characteristic peripheral:(CBPeripheral*) peripheral {
    char* val2 = (char*)characteristic.value.bytes;
    int val = (int) val2[0];
    [self.delegate didReadBatteryLevel:val forRingNamed:peripheral.name];
}

-(void) oDataFunction: (CBCharacteristic*) characteristic peripheral:(CBPeripheral*) peripheral {
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSArray* OSArrayofDicts = [OpenSpatialDecoder decodeODataPointer:bytePtr length:sizeof(bytePtr)];
    
    for(int i=0; i < OSArrayofDicts.count; i++) {
        NSDictionary* eventDict = [OSArrayofDicts objectAtIndex:i];
        NSString* caseType = [eventDict objectForKey:@"type"];
        
        if([caseType isEqualToString:@"accelerometer"]) {
            AccelerometerData* accelData = [[AccelerometerData alloc] initForPeripheral:peripheral x:[[eventDict objectForKey:XA] floatValue] y:[[eventDict objectForKey:YA] floatValue] z:[[eventDict objectForKey:ZA] floatValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:accelData];
            }
        } else if([caseType isEqualToString:@"gyro"]) {
            GyroscopeData* gyroData = [[GyroscopeData alloc] initForPeripheral:peripheral withX:[[eventDict objectForKey:XG] floatValue] withY:[[eventDict objectForKey:YG] floatValue] withZ:[[eventDict objectForKey:ZG] floatValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:gyroData];
            }
        } else if([caseType isEqualToString:@"euler"]) {
            EulerData* eulerData = [[EulerData alloc] initForPeripheral:peripheral withRoll:[[eventDict objectForKey:ROLL] floatValue] withPitch:[[eventDict objectForKey:PITCH] floatValue] withYaw:[[eventDict objectForKey:YAW] floatValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:eulerData];
            }
        } else if([caseType isEqualToString:@"translations"]) {
            TranslationData* translationData = [[TranslationData alloc] initForPeripheral:peripheral withX:[[eventDict objectForKey:X] floatValue] withY:[[eventDict objectForKey:Y] floatValue] withZ:[[eventDict objectForKey:Z] floatValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:translationData];
            }
        } else if([caseType isEqualToString:@"analog"]) {
            AnalogData* analogData = [[AnalogData alloc] initForPeripheral:peripheral withX:[[eventDict objectForKey:Y] shortValue] withY:[[eventDict objectForKey:X] shortValue] withTrigger:[[eventDict objectForKey:TRIGGER] shortValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:analogData];
            }
        } else if([caseType isEqualToString:@"button"]) {
            ButtonData* buttonData = [[ButtonData alloc] initForPeripheral:peripheral withButtonID:[[eventDict objectForKey:@"buttonID"] intValue] withButtonState:[[eventDict objectForKey:@"buttonState"] charValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:buttonData];
            }
        } else if([caseType isEqualToString:@"relativexy"]) {
            RelativeXYData* relativeXYData = [[RelativeXYData alloc] initForPeripheral:peripheral withX:[[eventDict objectForKey:X] shortValue] withY:[[eventDict objectForKey:Y] shortValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:relativeXYData];
            }
        } else if ([caseType isEqualToString:@"directionGesture"]) {
            GestureData* gestureData = [[GestureData alloc] initForPeripheral:peripheral withGestureType:[[eventDict objectForKey:GEST_DATA] charValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:gestureData];
            }
        } else if ([caseType isEqualToString:@"sliderGesture"]) {
            SliderData* sliderData = [[SliderData alloc] initForPeripheral:peripheral withSliderType:[[eventDict objectForKey:GEST_DATA] charValue]];
            if([self.delegate respondsToSelector:@selector(openSpatialDataFired:)]) {
                [self.delegate openSpatialDataFired:sliderData];
            }
        }
    }
}

-(void)readBatteryLevel: (NSString *)peripheralName {
    [((NodDevice*)[self.connectedPeripherals objectForKey:peripheralName]).BTPeripheral
     readValueForCharacteristic:((NodDevice*)[self.connectedPeripherals objectForKey:peripheralName]).batteryCharacteristic];
}
@end
