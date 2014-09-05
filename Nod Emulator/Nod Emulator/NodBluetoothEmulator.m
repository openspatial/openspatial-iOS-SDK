//
//  NodBluetoothEmulator.m
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import "NodBluetoothEmulator.h"
#import "OpenSpatialDecoder.h"

@implementation NodBluetoothEmulator

#pragma mark Singleton Methods

+ (id)sharedEmulator {
    static NodBluetoothEmulator *sharedEmulator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEmulator = [[self alloc] init];
    });
    return sharedEmulator;
}

-(id) init
{
    self = [super init];
    self.periphMan = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    self.services = [[NSMutableArray alloc] init];
    return self;
}


#pragma mark All Other Methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"peripheralStateChange: Powered On");
            // As soon as the peripheral/bluetooth is turned on, start initializing
            // the service.
            [self enableServices];
            break;
        case CBPeripheralManagerStatePoweredOff: {
            NSLog(@"peripheralStateChange: Powered Off");
            [self disableServices];
            break;
        }
        case CBPeripheralManagerStateResetting: {
            NSLog(@"peripheralStateChange: Resetting");
            break;
        }
        case CBPeripheralManagerStateUnauthorized: {
            NSLog(@"peripheralStateChange: Deauthorized");
            [self disableServices];
            break;
        }
        case CBPeripheralManagerStateUnsupported: {
            NSLog(@"peripheralStateChange: Unsupported");
            // TODO: Give user feedback that Bluetooth is not supported.
            break;
        }
        case CBPeripheralManagerStateUnknown:
            NSLog(@"peripheralStateChange: Unknown");
            break;
        default:
            break;
    }
}

-(void) disableServices
{
    for(CBService* serv in self.services)
    {
        [self.periphMan removeService:serv];
    }
    [self.services removeAllObjects];
    [self.periphMan stopAdvertising];
}

-(void) enableServices
{
    CBUUID* osUUID = [CBUUID UUIDWithString:OS_UUID];
    CBUUID* nodUUID = [CBUUID UUIDWithString:NOD_SERVICE_UUID];

    CBMutableService* osService = [[CBMutableService alloc] initWithType:osUUID
                                                                 primary:YES];
    CBMutableService* nodService = [[CBMutableService alloc] initWithType:nodUUID
                                                                  primary:YES];

    CBUUID* os2DUUID = [CBUUID UUIDWithString:POS2D_UUID];
    CBUUID* rawQuatUUID = [CBUUID UUIDWithString:TRANS3D_UUID];
    CBUUID* gestUUID = [CBUUID UUIDWithString:GEST_UUID];
    CBUUID* buttonUUID = [CBUUID UUIDWithString:BUTTON_UUID];
    CBUUID* modeUUID = [CBUUID UUIDWithString:MODE_SWITCH_UUID];



    self.os2dChar = [[CBMutableCharacteristic alloc]
                                         initWithType:os2DUUID
                                         properties:CBCharacteristicPropertyRead|
                                            CBCharacteristicPropertyNotify
                                         value:nil
                                         permissions:CBAttributePermissionsReadable];
    self.trans3DChar = [[CBMutableCharacteristic alloc]
                                            initWithType:rawQuatUUID
                                            properties:CBCharacteristicPropertyRead|
                                                CBCharacteristicPropertyNotify
                                            value:nil
                                            permissions:CBAttributePermissionsReadable];
    self.gestChar = [[CBMutableCharacteristic alloc]
                                            initWithType:gestUUID
                                            properties:CBCharacteristicPropertyRead|
                                            CBCharacteristicPropertyNotify
                                            value:nil
                                            permissions:CBAttributePermissionsReadable];

    self.buttonChar = [[CBMutableCharacteristic alloc]
                                         initWithType:buttonUUID
                                         properties:CBCharacteristicPropertyRead|
                                         CBCharacteristicPropertyNotify
                                         value:nil
                                         permissions:CBAttributePermissionsReadable];

    CBMutableCharacteristic* modeSwitchChar = [[CBMutableCharacteristic alloc]
                                        initWithType:modeUUID
                                        properties:CBCharacteristicPropertyRead|
                                        CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite
                                        value:nil
                                        permissions:CBAttributePermissionsReadable];

    osService.characteristics = @[self.os2dChar,self.trans3DChar,
                                  self.gestChar,self.buttonChar];
    nodService.characteristics = @[modeSwitchChar];
    [self.services addObject:osService];
    [self.periphMan addService:osService];
    [self.services addObject:nodService];
    [self.periphMan addService:nodService];

    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              };
    NSData* temp = [NSData dataWithBytes: [OpenSpatialDecoder createPos2DPointer:retDic]
                                  length:POS2D_SIZE];
    self.os2dChar.value = temp;

    retDic = @{ X : @0,
                Y : @0,
                Z : @0,
                ROLL : @0,
                PITCH : @0,
                YAW : @0,
                };

    temp = [NSData dataWithBytes: [OpenSpatialDecoder create3DTransPointer:retDic]
                                  length:TRANS3D_SIZE];
    self.trans3DChar.value = temp;


    retDic = @{ GEST_OPCODE : @0,
                GEST_DATA : @0,
                };
    temp = [NSData dataWithBytes: [OpenSpatialDecoder createGestPointer:retDic]
                          length:GEST_SIZE];
    self.gestChar.value = temp;


    retDic = @{TOUCH_0 : @0,
               TOUCH_1 : @0,
               TOUCH_2 : @0,
               TACTILE_0 : @0,
               TACTILE_1 : @0,
               };
    temp = [NSData dataWithBytes:[OpenSpatialDecoder createButtonPointer:retDic]
                          length:BUTTON_SIZE];
    self.buttonChar.value = temp;

    uint8_t data = 1;
    temp = [NSData dataWithBytes:&data length:sizeof(data)];
    modeSwitchChar.value = temp;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    NSDictionary* dic = @{CBAdvertisementDataLocalNameKey :
                              [NSString stringWithFormat:@"Nod Emulator - %@",
                               [[UIDevice currentDevice] name]]};
    [self.periphMan startAdvertising:dic];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request
{
    for(CBService* serv in self.services)
    {
        for(CBCharacteristic* chara in serv.characteristics)
        {
            if ([request.characteristic.UUID isEqual:chara.UUID])
            {
                if (request.offset > chara.value.length)
                {
                    [self.periphMan respondToRequest:request
                                          withResult:CBATTErrorInvalidOffset];
                    return;
                }
                else
                {
                    request.value = [chara.value
                                     subdataWithRange:NSMakeRange(request.offset,
                                            chara.value.length - request.offset)];
                    [self.periphMan respondToRequest:request
                                          withResult:CBATTErrorSuccess];
                }
            }
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{

    NSLog(@"Central subscribed to characteristic %@", characteristic);

    NSData *updatedValue = characteristic.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:characteristic
           onSubscribedCentrals:nil];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    for(CBService* serv in self.services)
    {
        for(CBCharacteristic* chara in serv.characteristics)
        {
            NSData *updatedValue = chara.value;
            if(updatedValue != nil)
            {
                [self.periphMan updateValue:updatedValue
                      forCharacteristic:chara onSubscribedCentrals:nil];
            }
        }
    }
}

- (void) sendOS2D: (NSData*) data
{
    NSLog(@"%@",[OpenSpatialDecoder decodePos2DPointer:data.bytes]);
    self.os2dChar.value = data;
    NSData *updatedValue = self.os2dChar.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:self.os2dChar onSubscribedCentrals:nil];
}

- (void) send3DTrans: (NSData*) data
{
    NSLog(@"%@",[OpenSpatialDecoder decode3DTransPointer:data.bytes]);
    self.trans3DChar.value = data;
    NSData *updatedValue = self.trans3DChar.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:self.trans3DChar onSubscribedCentrals:nil];
}

- (void) sendGesture: (NSData*) data
{
    NSLog(@"%@",[OpenSpatialDecoder decodeGestPointer:data.bytes]);
    self.gestChar.value = data;
    NSData *updatedValue = self.gestChar.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:self.gestChar onSubscribedCentrals:nil];
}

- (void) sendButton: (NSData*) data
{
    NSLog(@"%@",[OpenSpatialDecoder decodeButtonPointer:data.bytes]);
    self.buttonChar.value = data;
    NSData *updatedValue = self.buttonChar.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:self.buttonChar onSubscribedCentrals:nil];
}

@end











































