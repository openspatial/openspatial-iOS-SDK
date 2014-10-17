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

@interface OpenSpatialBluetooth()  <CBCentralManagerDelegate, CBPeripheralDelegate>

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
        self.modeMapping = [[NSMutableDictionary alloc] init];
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
 * Scans for for only peripherals with the Open Spatial UUID adding all peripherals to the peripherals array
 */
- (void) scanForPeripherals
{
    NSLog(@"Scanning");
    [self.foundPeripherals removeAllObjects];
    [self.centralManager retrieveConnectedPeripherals];
}

/*
 * State must be on to initiate scan this method is called after the initialization that occurs
 * in scanForPeripherals
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state == CBCentralManagerStatePoweredOn)
    {
        if([self.connectedPeripherals count] > 0)
        {
            [self.connectedPeripherals removeAllObjects];
        }
    }
    else
    {
        NSLog(@"Bluetooth Off");
    }
}

/*
 * Helper method for peripheral scanning, each time a peripheral is found add it to the
 * peripheral array
 */
-(void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    self.foundPeripherals = peripherals;
    if([self.delegate respondsToSelector:@selector(didFindNewDevice:)])
    {
        NSLog(@"Delegate method called/");

        [self.delegate didFindNewDevice:peripherals];
    }
}

/*
 * Connect to a peripheral device store as connected device, also stops scan
 */
-(void) connectToPeripheral: (CBPeripheral *) peripheral
{
    [self.centralManager stopScan];
    [self.ConnectedServices removeAllObjects];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

/*
 * When device is connected set connected bool to true
 */
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSDictionary* temp = @{BUTTON: @FALSE, POINTER: @FALSE, ROTATION: @FALSE, GESTURE: @FALSE};
    NSMutableDictionary* booleans = [NSMutableDictionary dictionaryWithDictionary:temp];
    [self.connectedPeripherals setObject:booleans forKey:peripheral];
    NSLog(@"Connected to %@", peripheral.name);
    peripheral.delegate = self;

    [self getServicesForConnectedDevice: peripheral];
}

/*
 * Returns an Array Containing the names of all the services associated with a device
 */
-(void) getServicesForConnectedDevice:(CBPeripheral *)peripheral
{
    if(peripheral)
    {
        NSLog(@"Discovering Services, %@", peripheral.delegate);
        [peripheral discoverServices:nil];
    }
}

/*
 * Helper Method for discovering services prints service to log
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services)
    {
        NSLog(@"Discovered service %@", service);
        if([[service.UUID UUIDString] isEqualToString:OS_UUID])
        {
            [self getCharacteristics:service peripheral:peripheral];
        }
    }
}

/*
 * Gets characteristics of a specfied service
 */
-(void) getCharacteristics: (CBService*) serv peripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverCharacteristics:nil forService:serv];
}

int countChars = 0;
/*
 * Helper Method for discovering characteristics prints all characteristics to log
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)
service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"%@",characteristic.UUID.UUIDString);
        
        if([characteristic.UUID.UUIDString isEqualToString:POS2D_UUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            countChars++;
        }
        if([characteristic.UUID.UUIDString isEqualToString:TRANS3D_UUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            countChars++;
        }
        if([characteristic.UUID.UUIDString isEqualToString:GEST_UUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            countChars++;
        }
        if([characteristic.UUID.UUIDString isEqualToString:BUTTON_UUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            countChars++;
        }
    }
    if(countChars == 4)
    {
        [self.delegate didConnectToNod:peripheral];
        countChars = 0; 
    }
}

/*
 *  Temporary method for mode switch from iOS while app is not ready
 */
-(void) setMode:(uint8_t)modeNumber forDeviceNamed:(NSString *)name
{
    NSMutableData* val = [[NSMutableData alloc] init];
    [val appendBytes:&modeNumber length:sizeof(modeNumber)];
    NSArray* keys = [self.connectedPeripherals allKeys];

    for(CBPeripheral* p in keys)
    {
        if([p.name isEqualToString:name])
        {
            [p writeValue:val forCharacteristic:[self.modeMapping objectForKey:name]
                                                        type:CBCharacteristicWriteWithResponse];
        }
    }


}

-(BOOL)isSubscribedToEvent:(NSString *)type forPeripheral:(NSString *)peripheralName
{
    NSArray* keys = [self.connectedPeripherals allKeys];
    for(CBPeripheral* p in keys)
    {
        if([p.name isEqualToString:peripheralName])
        {
            if([type isEqualToString:BUTTON])
            {
                return [[[self.connectedPeripherals objectForKey:p] objectForKey:BUTTON] boolValue];
            }
            else if([type isEqualToString:POINTER])
            {
                return [[[self.connectedPeripherals objectForKey:p] objectForKey:POINTER] boolValue];
            }
            else if([type isEqualToString:ROTATION])
            {
                return [[[self.connectedPeripherals objectForKey:p] objectForKey:ROTATION] boolValue];
            }
            else if([type isEqualToString:GESTURE])
            {
                return [[[self.connectedPeripherals objectForKey:p] objectForKey:GESTURE] boolValue];
            }
        }
    }
    return FALSE;
}

/*
 * Subscribes to rotation events for the given device
 */
-(void)subscribeToRotationEvents:(NSString *)peripheralName
{
    NSArray* keys = [self.connectedPeripherals allKeys];
    
    for(CBPeripheral* p in keys)
    {
        if([p.name isEqualToString:peripheralName])
        {
            [ (NSDictionary*)[self.connectedPeripherals objectForKey:p] setValue:@TRUE forKey:ROTATION];
        }
    }
}

/*
 * Subscribes to gesture events for the given device
 */
-(void)subscribeToGestureEvents:(NSString *)peripheralName
{
    NSArray* keys = [self.connectedPeripherals allKeys];
    
    for(CBPeripheral* p in keys)
    {
        if([p.name isEqualToString:peripheralName])
        {
            [ [self.connectedPeripherals objectForKey:p] setValue:@TRUE forKey:GESTURE];
        }
    }
}

/*
 * Subscribes to button events for the given device
 */
-(void)subscribeToButtonEvents:(NSString *)peripheralName
{
    NSArray* keys = [self.connectedPeripherals allKeys];
    
    for(CBPeripheral* p in keys)
    {
        if([p.name isEqualToString:peripheralName])
        {
            [ [self.connectedPeripherals objectForKey:p] setValue:@TRUE forKey:BUTTON];
        }
    }
}

/*
 * Subscribes to pointer events for the given device
 */
-(void)subscribeToPointerEvents:(NSString *)peripheralName
{
    NSArray* keys = [self.connectedPeripherals allKeys];
    
    for(CBPeripheral* p in keys)
    {
        if([p.name isEqualToString:peripheralName])
        {
            [ [self.connectedPeripherals objectForKey:p] setValue:@TRUE forKey:POINTER];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"Disconnected: %@", error);
    [self connectToPeripheral:peripheral];
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
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:
                     (CBCharacteristic *)characteristic error:(NSError *)error
{
    // Checks if the characteristic is the open spatial 2d characteristic
    if([characteristic.UUID.UUIDString isEqualToString:POS2D_UUID])
    {
        [self pos2DFunction:characteristic peripheral:peripheral];
    }
    
    // Checks if the characteristic is the quaternion characteristic
    if([characteristic.UUID.UUIDString isEqualToString:TRANS3D_UUID])
    {
        [self trans3DFunction:characteristic peripheral:peripheral];
    }
    
    // Checks if the characteristic is the gesture characteristic
    if([characteristic.UUID.UUIDString isEqualToString:GEST_UUID])
    {
        [self gestureFunction:characteristic peripheral:peripheral];
    }

    // Checks if the characteristic is the button characteristic
    if([characteristic.UUID.UUIDString isEqualToString:BUTTON_UUID])
    {
        [self buttonFunction:characteristic peripheral:peripheral];
    }
}

/*
 * Method for testing that mimics the above didUpdateValueForCharacteristic method
 */
-(NSArray *)testBluetoothCharacteristic:(CBCharacteristic *)characteristic andPeripheral:(CBPeripheral *)peripheral
{
    NSArray* array;
    // Checks if the characteristic is the open spatial 2d characteristic
    if([characteristic.UUID.UUIDString isEqualToString:POS2D_UUID])
    {
        NSLog(@"Pos2D");
        array = [self pos2DFunction:characteristic peripheral:peripheral];
    }

    // Checks if the characteristic is the quaternion characteristic
    if([characteristic.UUID.UUIDString isEqualToString:TRANS3D_UUID])
    {
        NSLog(@"trans3d");
        array = [self trans3DFunction:characteristic peripheral:peripheral];
    }

    // Checks if the characteristic is the gesture characteristic
    if([characteristic.UUID.UUIDString isEqualToString:GEST_UUID])
    {
        NSLog(@"gesture");
        array = [self gestureFunction:characteristic peripheral:peripheral];
    }

    // Checks if the characteristic is the button characteristic
    if([characteristic.UUID.UUIDString isEqualToString:BUTTON_UUID])
    {
        NSLog(@"Button");
        array = [self buttonFunction:characteristic peripheral:peripheral];
    }
    return array;
}

/*
 * Method that handles the Open Spatial 2D events
 */
-(NSArray *)pos2DFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodePos2DPointer:bytePtr];
    
    short int x = [[OSData objectForKey:X] shortValue];
    short int y = [[OSData objectForKey:Y] shortValue];
    
    NSMutableArray *openSpatial2DEvents = [[NSMutableArray alloc] init];

    PointerEvent *pEvent = [[PointerEvent alloc] init];
    [pEvent setPointerEventCoordinates:x andY:y];
    pEvent.peripheral = peripheral;
    [openSpatial2DEvents addObject:pEvent];

    if([self isSubscribedToEvent:POINTER forPeripheral:[peripheral name]])
    {
        [self.delegate pointerEventFired:pEvent];
    }
    
    // For testing purposes
    return openSpatial2DEvents;
}

-(NSArray *)trans3DFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decode3DTransPointer:bytePtr];
    NSMutableArray *rotationEvent = [[NSMutableArray alloc] init];
    
    RotationEvent *rEvent = [[RotationEvent alloc] init];
    
    rEvent.x = [[OSData objectForKey:X] floatValue];
    rEvent.y = [[OSData objectForKey:Y] floatValue];
    rEvent.z = [[OSData objectForKey:Z] floatValue];
    rEvent.roll = [[OSData objectForKey:ROLL] floatValue];
    rEvent.pitch = [[OSData objectForKey:PITCH] floatValue];
    rEvent.yaw = [[OSData objectForKey:YAW] floatValue];

    rEvent.peripheral = peripheral;
    [rotationEvent addObject:rEvent];

    if([self isSubscribedToEvent:ROTATION forPeripheral:[peripheral name]])
    {
        [self.delegate rotationEventFired:rEvent];
    }
    
    // For testing purposes
    return rotationEvent;
}

-(NSArray *)buttonFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeButtonPointer:bytePtr];
    short touch0 = [[OSData objectForKey:TOUCH_0] shortValue];
    short touch1 = [[OSData objectForKey:TOUCH_1] shortValue];
    short touch2 = [[OSData objectForKey:TOUCH_2] shortValue];
    short tact0 = [[OSData objectForKey:TACTILE_0] shortValue];
    short tact1 = [[OSData objectForKey:TACTILE_1] shortValue];
    NSMutableArray* buttonEvents = [[NSMutableArray alloc] init];

    if(touch0 == BUTTON_UP)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH0_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(touch0 == BUTTON_DOWN)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH0_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }

    if(touch1 == BUTTON_UP)
    {   ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH1_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(touch1 == BUTTON_DOWN)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH1_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }

    if(touch2 == BUTTON_UP)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH2_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(touch2 == BUTTON_DOWN)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TOUCH2_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }

    if(tact0 == BUTTON_UP)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE0_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(tact0 == BUTTON_DOWN)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE0_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }

    if(tact1 == BUTTON_UP)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE1_UP];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }
    else if(tact1 == BUTTON_DOWN)
    {
        ButtonEvent* bEvent = [[ButtonEvent alloc] init];
        [bEvent setButtonEventType:TACTILE1_DOWN];
        bEvent.peripheral = peripheral;
        [buttonEvents addObject:bEvent];
    }

    if([self isSubscribedToEvent:BUTTON forPeripheral:[peripheral name]])
    {
        for(ButtonEvent* bEvent in buttonEvents)
        {
            [self.delegate buttonEventFired:bEvent];
        }
    }

    return buttonEvents;
}

-(NSArray *)gestureFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeGestPointer:bytePtr];
    short gestureC = [[OSData objectForKey:GEST_OPCODE] shortValue];
    uint8_t gesture = [[OSData objectForKey:GEST_DATA] charValue];
    NSMutableArray *gestureEvent = [[NSMutableArray alloc] init];
    GestureEvent *gEvent = [[GestureEvent alloc] init];

    if(gestureC == G_OP_DIRECTION)
    {
        if(gesture == GUP)
        {
            [gEvent setGestureEventType:SWIPE_UP];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if (gesture == GDOWN)
        {
            [gEvent setGestureEventType:SWIPE_DOWN];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GLEFT)
        {
            [gEvent setGestureEventType:SWIPE_LEFT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GRIGHT)
        {
            [gEvent setGestureEventType:SWIPE_RIGHT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GCW)
        {
            [gEvent setGestureEventType:CW];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == GCCW)
        {
            [gEvent setGestureEventType:CCW];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else
        {
            NSLog(@"No match found for gesture event.");
        }
    }
    else if(gestureC == G_OP_SCROLL)
    {
        if(gesture == SLIDE_LEFT)
        {
            [gEvent setGestureEventType:SLIDER_LEFT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else if(gesture == SLIDE_RIGHT)
        {
            [gEvent setGestureEventType:SLIDER_RIGHT];
            gEvent.peripheral = peripheral;
            [gestureEvent addObject:gEvent];
        }
        else
        {
            NSLog(@"No match found for gesture event.");
        }
    }
    else
    {
        NSLog(@"No match found for gesture event.");
    }

    if([self isSubscribedToEvent:GESTURE forPeripheral:[peripheral name]])
    {
        [self.delegate gestureEventFired:gEvent];
    }
    // FOR TESTING PURPOSES ONLY
    return gestureEvent;
}


@end
