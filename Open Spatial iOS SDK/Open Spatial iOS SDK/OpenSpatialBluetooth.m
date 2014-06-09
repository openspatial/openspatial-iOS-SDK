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
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
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
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData: (NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(![self.foundPeripherals containsObject:peripheral])
    {
        [self.foundPeripherals addObject:peripheral];
        NSLog(@"Found Peripheral: %@",peripheral.name);
        NSLog(@"%@", self.delegate);
        if([self.delegate respondsToSelector:@selector(didFindNewDevice:)])
        {
            NSLog(@"Delegate method called/");

            [self.delegate didFindNewDevice:peripheral];
        }
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
    
    [self.delegate didConnectToNod:peripheral];
    [self getServicesForConnectedDevice: peripheral];
}

/*
 * Returns an Array Containing the names of all the services associated with a device
 */
-(void) getServicesForConnectedDevice:(CBPeripheral *)peripheral
{
    if(peripheral)
    {
        NSLog(@"Discovering Services");
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
        if([[service.UUID UUIDString] isEqualToString:OSUUID])
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
 * Helper Method for discovering characteristics prints all characteristics to log
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)
service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"%@",characteristic.UUID.UUIDString);
        
        if([characteristic.UUID.UUIDString isEqualToString:OS2DUUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if([characteristic.UUID.UUIDString isEqualToString:QUATUUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if([characteristic.UUID.UUIDString isEqualToString:GESTUUID])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
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
    if([characteristic.UUID.UUIDString isEqualToString:OS2DUUID])
    {
        [self openSpatial2DFunction:characteristic peripheral:peripheral];
    }
    
    // Checks if the characteristic is the quaternion characteristic
    if([characteristic.UUID.UUIDString isEqualToString:QUATUUID])
    {
        [self rotationFunction:characteristic peripheral:peripheral];
    }
    
    // Checks if the characteristic is the gesture characteristic
    if([characteristic.UUID.UUIDString isEqualToString:GESTUUID])
    {
        [self gestureFunction:characteristic peripheral:peripheral];
    }
}

/*
 * Method for testing that mimics the above didUpdateValueForCharacteristic method
 */
-(NSArray *)testBluetoothCharacteristic:(CBCharacteristic *)characteristic andPeripheral:(CBPeripheral *)peripheral
{
    // Checks if the characteristic is the open spatial 2d characteristic
    if([characteristic.UUID.UUIDString isEqualToString:OS2DUUID])
    {
        return [self openSpatial2DFunction:characteristic peripheral:peripheral];
    }
    
    // Checks if the characteristic is the quaternion characteristic
    if([characteristic.UUID.UUIDString isEqualToString:QUATUUID])
    {
        return [self rotationFunction:characteristic peripheral:peripheral];
    }
    
    // Checks if the characteristic is the gesture characteristic
    if([characteristic.UUID.UUIDString isEqualToString:GESTUUID])
    {
        return [self gestureFunction:characteristic peripheral:peripheral];
    }
    return nil;
}

uint8_t lastSlideVal = 0;
uint8_t lastTouchVal = 0;
uint8_t lastTactileVal = 0;
short int lastXVal = 0;
short int lastYVal = 0;

/*
 * Method that handles the Open Spatial 2D events
 */
-(NSArray *)openSpatial2DFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeOpenSpatialPointer:bytePtr];
    
    short int x = [[OSData objectForKey:X] shortValue];
    short int y = [[OSData objectForKey:Y] shortValue];
    uint8_t currentTouchVal = [[OSData objectForKey:TOUCH] charValue];
    uint8_t currentSlideVal = [[OSData objectForKey:SLIDE] charValue];
    uint8_t currentTactileVal = [[OSData objectForKey:TACTILE] charValue];
    
    NSMutableArray *openSpatial2DEvents = [[NSMutableArray alloc] init];
    
    // Button Events
    if( [self isSubscribedToEvent:BUTTON forPeripheral:[peripheral name]]  )
    {
        // Touch Values within Button Events
        
        if(currentTouchVal == NOPRESS)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    // Nothing happens in this case.
                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_UP];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case LTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case RTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDLTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case ALL3PRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_UP];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                }
            }
        }
        else if(currentTouchVal == LTOUCHPRESSED)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];

                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case LTOUCHPRESSED:
                {
                    // Nothing in this case
                    break;
                }
                case RTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH1_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH1_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:TOUCH1_DOWN];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                    break;
                }
                case SLIDEHOLDLTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case ALL3PRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                }
            }

        }
        else if(currentTouchVal == RTOUCHPRESSED)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case LTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case RTOUCHPRESSED:
                {
                    // Nothing happens in this case
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDLTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:TOUCH2_DOWN];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                    break;
                }
                case ALL3PRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                }
            }
        }
        else if(currentTouchVal == BOTHTOUCHPRESSED)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    // Nothing happens in this case.
                    break;
                }
                case LTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case RTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH1_DOWN];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:TOUCH2_DOWN];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH1_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDLTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case ALL3PRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
            }
        }
        else if(currentTouchVal == SLIDEHOLDPRESSED)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_UP];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                    break;
                }
                case LTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case RTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    // Nothing happens in this case
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDLTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case ALL3PRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_UP];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
            }
        }
        else if(currentTouchVal == SLIDEHOLDLTOUCH)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case LTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case RTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH1_DOWN];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH1_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDLTOUCH:
                    // Nothing happens in this case
                    break;
                    
                case ALL3PRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
            }
        }
        else if(currentTouchVal == SLIDEHOLDRTOUCH)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case LTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                    break;
                }
                case RTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    // Nothing happens in this case
                    break;
                }
                case SLIDEHOLDLTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case ALL3PRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
            }
        }
        else if(currentTouchVal == ALL3PRESSED)
        {
            switch (lastTouchVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent3 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [bEvent3 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent3.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    [openSpatial2DEvents addObject:bEvent3];
                    break;
                }
                case BOTHTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case LTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case RTOUCHPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:SCROLL_TOUCH_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TOUCH2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case SLIDEHOLDRTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case SLIDEHOLDLTOUCH:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TOUCH2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case ALL3PRESSED:
                {
                    // Nothing happens in this case
                    break;
                }
            }
    }
    
        // Tactile Values within Button Events
        if(currentTactileVal == NOPRESS)
        {
            switch (lastTactileVal)
            {
                case NOPRESS:
                    // Nothing happens in this case
                    break;
                case BOTHTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TACTILE2_UP];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case LTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE1_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case RTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE2_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
            }
        }
        else if(currentTactileVal == LTACTPRESSED)
        {
            switch (lastTactileVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case BOTHTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE2_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case LTACTPRESSED:
                    // Nothing happens in this case
                    break;    
                case RTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE2_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TACTILE1_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
            }
        }
        else if(currentTactileVal == RTACTPRESSED)
        {
            switch (lastTactileVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case BOTHTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE1_UP];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case LTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE1_UP];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TACTILE2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case RTACTPRESSED:
                {
                    // Nothing happens in this case
                    break;
                }
            }
        }
        else if(currentTactileVal == BOTHTACTPRESSED)
        {
            switch (lastTactileVal)
            {
                case NOPRESS:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    ButtonEvent *bEvent2 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [bEvent2 setButtonEventType:TACTILE2_DOWN];
                    bEvent2.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    [openSpatial2DEvents addObject:bEvent2];
                    break;
                }
                case BOTHTACTPRESSED:
                {
                    // Nothing happens in this case
                    break;
                }
                case LTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE2_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
                case RTACTPRESSED:
                {
                    ButtonEvent *bEvent1 = [[ButtonEvent alloc]init];
                    [bEvent1 setButtonEventType:TACTILE1_DOWN];
                    bEvent1.peripheral = peripheral;
                    [openSpatial2DEvents addObject:bEvent1];
                    break;
                }
            }
        }
        
        // Slide Values within Button Events
        if(currentSlideVal == 0 && lastSlideVal == 15)
        {
            ButtonEvent *bEvent1 = [[ButtonEvent alloc] init];
            [bEvent1 setButtonEventType:SCROLL_UP];
            bEvent1.peripheral = peripheral;
            [openSpatial2DEvents addObject:bEvent1];
        }
        else if (currentSlideVal == 15 && lastSlideVal == 0)
        {
            ButtonEvent *bEvent1 = [[ButtonEvent alloc] init];
            [bEvent1 setButtonEventType:SCROLL_DOWN];
            bEvent1.peripheral = peripheral;
            [openSpatial2DEvents addObject:bEvent1];
        } else if(currentSlideVal > lastSlideVal)
        {
            ButtonEvent *bEvent1 = [[ButtonEvent alloc] init];
            [bEvent1 setButtonEventType:SCROLL_UP];
            bEvent1.peripheral = peripheral;
            [openSpatial2DEvents addObject:bEvent1];
        }
        else if (currentSlideVal < lastSlideVal)
        {
            ButtonEvent *bEvent1 = [[ButtonEvent alloc] init];
            [bEvent1 setButtonEventType:SCROLL_DOWN];
            bEvent1.peripheral = peripheral;
            [openSpatial2DEvents addObject:bEvent1];
        }
        else
        {
            // Nothing happens
        }
    }
    
    // Pointer Values
    if([self isSubscribedToEvent:POINTER forPeripheral:[peripheral name]])
    {
        if(lastXVal != x || lastYVal != y)
        {
            PointerEvent *pEvent = [[PointerEvent alloc] init];
            [pEvent setPointerEventCoordinates:x andY:y];
            pEvent.peripheral = peripheral;
            [openSpatial2DEvents addObject:pEvent];
        }
    }
    
    lastTouchVal = currentTouchVal;
    lastSlideVal = currentSlideVal;
    lastTactileVal = currentTactileVal;
    lastXVal = x;
    lastYVal = y;
    
    for (ButtonEvent* bEvent in openSpatial2DEvents) {
        if([bEvent respondsToSelector:@selector(getButtonEventType)])
        {
            [self.delegate buttonEventFired:bEvent];
        }
        else{
            [self.delegate pointerEventFired:(PointerEvent *)bEvent];
        }
    }
    
    // For testing purposes
    return openSpatial2DEvents;
}

-(NSArray *)rotationFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeRawQuatPointer:bytePtr];
    
    NSMutableArray *rotationEvent = [[NSMutableArray alloc] init];
    
    RotationEvent *rEvent = [[RotationEvent alloc] init];
    
    float x = [[OSData objectForKey:X] floatValue];
    float y = [[OSData objectForKey:Y] floatValue];
    float z = [[OSData objectForKey:Z] floatValue];
    float w = [[OSData objectForKey:W] floatValue];

    CMQuaternion *quaternion = malloc(sizeof(CMQuaternion));
    quaternion->x = x;
    quaternion->y = y;
    quaternion->z = z;
    quaternion->w = w;
    
    [rEvent setQuaternion:*quaternion];
    rEvent.peripheral = peripheral;
    [rotationEvent addObject:rEvent];

    if([self isSubscribedToEvent:ROTATION forPeripheral:[peripheral name]])
    {
        [self.delegate rotationEventFired:rEvent];
    }
    
    // For testing purposes
    return rotationEvent;
}

-(NSArray *)gestureFunction:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral
{
    const uint8_t* bytePtr = [characteristic.value bytes];
    NSDictionary* OSData = [OpenSpatialDecoder decodeGestPointer:bytePtr];
    uint8_t gesture = [[OSData objectForKey:GEST] charValue];
    NSMutableArray *gestureEvent = [[NSMutableArray alloc] init];
    GestureEvent *gEvent = [[GestureEvent alloc] init];
    
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
    else
    {
        NSLog(@"No match found for gesture event.");
    }
    
    /*
    else if(gesture == GTWISTLEFT)
    {
        [gEvent setGestureEventType:TWIST_LEFT];
        gEvent.peripheral = peripheral;
        [gestureEvent addObject:gEvent];
    }
    else if(gesture == GTWISTRIGHT)
    {
        [gEvent setGestureEventType:TWIST_RIGHT];
        gEvent.peripheral = peripheral;
        [gestureEvent addObject:gEvent];
    }
    */
    
    if([self isSubscribedToEvent:GESTURE forPeripheral:[peripheral name]])
    {
        [self.delegate gestureEventFired:gEvent];
    }
    // FOR TESTING PURPOSES ONLY
    return gestureEvent;
}


@end
