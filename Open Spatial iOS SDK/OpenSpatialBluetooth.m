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
 * Scans for for only peripherals with the Open Spatial UUID adding all peripherals to the peripherals array
 */
- (void) scanForPeripherals
{
    NSLog(@"Scanning");
    [self.foundPeripherals removeAllObjects];
    CBUUID* hidUUID = [CBUUID UUIDWithString:@"1812"];
    CBUUID* osUUID = [CBUUID UUIDWithString:OS_UUID];
    CBUUID* nUUID = [CBUUID UUIDWithString:NCONTROL_UUID];
    NSArray* services = @[hidUUID, osUUID, nUUID];
  //  [self.centralManager scanForPeripheralsWithServices:services options:nil];
    self.pairedPeripherals = [NSMutableArray arrayWithArray:
                              [self.centralManager retrieveConnectedPeripheralsWithServices:services]];
    if([self.delegate respondsToSelector:@selector(didFindNewPairedDevice:)])
    {
        NSLog(@"Delegate method called/");
        
        [self.delegate didFindNewPairedDevice:self.pairedPeripherals];
    }
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
 * Delegate method for peripheral scanning, each time a peripheral is found add it to the
 * peripheral array
 */
-(void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    self.pairedPeripherals = [NSMutableArray arrayWithArray:peripherals];
    if([self.delegate respondsToSelector:@selector(didFindNewPairedDevice:)])
    {
        NSLog(@"Delegate method called/");

        [self.delegate didFindNewPairedDevice:peripherals];
    }
}

-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(![self.foundPeripherals containsObject:peripheral])
    {
        [self.foundPeripherals addObject:peripheral];
        if(self.delegate)
        {
            if([self.delegate respondsToSelector:@selector(didFindNewScannedDevice:)])
            {
                [self.delegate didFindNewScannedDevice:self.foundPeripherals];
            }
        }
    }
}

/*
 * Connect to a peripheral device store as connected device, also stops scan
 */
-(void) connectToPeripheral: (CBPeripheral *) peripheral
{
    [self.centralManager stopScan];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

/*
 * When device is connected set connected bool to true
 */
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSDictionary* temp = @{BUTTON: @FALSE, POINTER: @FALSE, ROTATION: @FALSE, GESTURE: @FALSE, MOTION: @FALSE};
    peripheral.delegate = self;
    NodDevice* dev = [[NodDevice alloc] init];
    dev.BTPeripheral = peripheral;
    dev.subscribedTo = [NSMutableDictionary dictionaryWithDictionary:temp];
    [self.connectedPeripherals setObject:dev forKey:peripheral.name];
    NSLog(@"Connected to %@", peripheral.name);
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
 * Delegate Method for discovering services prints service to log
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

/*
 * Delegate Method for discovering characteristics prints all characteristics to log
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)
service error:(NSError *)error
{
    int countChars = 0;
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"%@",characteristic.UUID.UUIDString);
        
        if([characteristic.UUID.UUIDString isEqualToString:POS2D_UUID])
        {
            ((NodDevice*)[self.connectedPeripherals objectForKey:
                          peripheral.name]).pointerCharacteristic = characteristic;
            countChars++;
        }
        if([characteristic.UUID.UUIDString isEqualToString:TRANS3D_UUID])
        {
            ((NodDevice*)[self.connectedPeripherals objectForKey:
                          peripheral.name]).pose6DCharacteristic = characteristic;
            countChars++;
        }
        if([characteristic.UUID.UUIDString isEqualToString:GEST_UUID])
        {
            ((NodDevice*)[self.connectedPeripherals objectForKey:
                          peripheral.name]).gestureCharacteristic = characteristic;
            countChars++;
        }
        if([characteristic.UUID.UUIDString isEqualToString:BUTTON_UUID])
        {
            ((NodDevice*)[self.connectedPeripherals objectForKey:
                          peripheral.name]).buttonCharacteristic = characteristic;
            countChars++;
        }
        if([characteristic.UUID.UUIDString isEqualToString:MOTION6D_UUID])
        {
            ((NodDevice*)[self.connectedPeripherals objectForKey:
                          peripheral.name]).motion6DCharacteristic = characteristic;
            countChars++;
        }
    }
    if(countChars == 5)
    {
        if([self.delegate respondsToSelector:@selector(didConnectToNod:)])
        {
            [self.delegate didConnectToNod:peripheral];
        }
        countChars = 0;
    }
}

-(BOOL)isSubscribedToEvent:(NSString *)type forPeripheral:(NSString *)peripheralName
{
    NSArray* keys = [self.connectedPeripherals allKeys];
    /*for(CBPeripheral* p in keys)
    {
        if([p.name isEqualToString:peripheralName])
        {
            if([type isEqualToString:BUTTON])
            {
                return [[((NodDevice*)[self.connectedPeripherals objectForKey:p.name]).subscribedTo
                         objectForKey:BUTTON] boolValue];
            }
            else if([type isEqualToString:POINTER])
            {
                return [[((NodDevice*)[self.connectedPeripherals objectForKey:p.name]).subscribedTo
                         objectForKey:POINTER] boolValue];
            }
            else if([type isEqualToString:ROTATION])
            {
                return [[((NodDevice*)[self.connectedPeripherals objectForKey:p.name]).subscribedTo
                         objectForKey:ROTATION] boolValue];
            }
            else if([type isEqualToString:GESTURE])
            {
                return [[((NodDevice*)[self.connectedPeripherals objectForKey:p.name]).subscribedTo
                         objectForKey:GESTURE] boolValue];
            }
        }
    }*/
    return TRUE;
}

/*
 * Subscribes to rotation events for the given device
 */
-(void)subscribeToRotationEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.pose6DCharacteristic];
        [dev.subscribedTo setValue:@TRUE forKey:ROTATION];
    }
}
-(void)unsubscribeFromRotationEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:NO forCharacteristic:dev.pose6DCharacteristic];
        [dev.subscribedTo setValue:@NO forKey:ROTATION];
    }
}

/*
 * Subscribes to gesture events for the given device
 */
-(void)subscribeToGestureEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.gestureCharacteristic];
        [dev.subscribedTo setValue:@TRUE forKey:GESTURE];
    }
}
-(void)unsubscribeFromGestureEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:NO forCharacteristic:dev.gestureCharacteristic];
        [dev.subscribedTo setValue:@NO forKey:GESTURE];
    }
}

/*
 * Subscribes to button events for the given device
 */
-(void)subscribeToButtonEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.buttonCharacteristic];
        [dev.subscribedTo setValue:@TRUE forKey:BUTTON];
    }
}
-(void)unsubscribeFromButtonEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:NO forCharacteristic:dev.buttonCharacteristic];
        [dev.subscribedTo setValue:@NO forKey:BUTTON];
    }
}

/*
 * Subscribes to pointer events for the given device
 */
-(void)subscribeToPointerEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.pointerCharacteristic];
        [dev.subscribedTo setValue:@TRUE forKey:POINTER];
    }
}
-(void)unsubscribeFromPointerEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:NO forCharacteristic:dev.pointerCharacteristic];
        [dev.subscribedTo setValue:@NO forKey:POINTER];
    }
}

/*
 * Subscribes to motion6D events for the given device
 */
-(void)subscribeToMotion6DEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:YES forCharacteristic:dev.motion6DCharacteristic];
        [dev.subscribedTo setValue:@TRUE forKey:MOTION];
    }
}
-(void)unsubscribeFromMotion6DEvents:(NSString *)peripheralName
{
    NodDevice* dev = [self.connectedPeripherals objectForKey:peripheralName];
    if(dev)
    {
        [dev.BTPeripheral setNotifyValue:NO forCharacteristic:dev.motion6DCharacteristic];
        [dev.subscribedTo setValue:@NO forKey:MOTION];
    }
}

/*
 *  Disconnection handler (currently just tries to reconnect)
 */
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
    
    // Checks if the characteristic is the motion 6d characteristic
    if([characteristic.UUID.UUIDString isEqualToString:MOTION6D_UUID])
    {
        [self motion6DFunction:characteristic peripheral:peripheral];
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
        if([self.delegate respondsToSelector:@selector(pointerEventFired:)])
        {
            [self.delegate pointerEventFired:pEvent];
        }
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
        if([self.delegate respondsToSelector:@selector(rotationEventFired:)])
        {
            [self.delegate rotationEventFired:rEvent];
        }
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
            if([self.delegate respondsToSelector:@selector(buttonEventFired:)])
            {
                [self.delegate buttonEventFired:bEvent];
            }
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
        if([self.delegate respondsToSelector:@selector(gestureEventFired:)])
        {
            [self.delegate gestureEventFired:gEvent];
        }
    }
    // FOR TESTING PURPOSES ONLY
    return gestureEvent;
}

-(void) motion6DFunction: (CBCharacteristic*) characteristic peripheral:(CBPeripheral*) peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeMot6DPointer:bytePtr];
    Motion6DEvent* mEvent = [[Motion6DEvent alloc] init];
    mEvent.xAccel = [[OSData objectForKey:XA] floatValue];
    mEvent.yAccel = [[OSData objectForKey:YA] floatValue];
    mEvent.zAccel = [[OSData objectForKey:ZA] floatValue];
    mEvent.xGyro = [[OSData objectForKey:XG] floatValue];
    mEvent.yGryo = [[OSData objectForKey:YG] floatValue];
    mEvent.zGryo = [[OSData objectForKey:ZG] floatValue];
    
    if([self isSubscribedToEvent:MOTION forPeripheral:peripheral.name])
    {
        if([self.delegate respondsToSelector:@selector(motion6DEventFired:)])
        {
            [self.delegate motion6DEventFired:mEvent];
        }
    }
}


@end
