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
    CBUUID* osUUID = [CBUUID UUIDWithString:OSUUID];
    CBMutableService* osService = [[CBMutableService alloc] initWithType:osUUID
                                                                 primary:YES];

    CBUUID* os2DUUID = [CBUUID UUIDWithString:OS2DUUID];
    CBUUID* rawQuatUUID = [CBUUID UUIDWithString:QUATUUID];
    CBUUID* gestUUID = [CBUUID UUIDWithString:GESTUUID];



    self.os2dChar = [[CBMutableCharacteristic alloc]
                                         initWithType:os2DUUID
                                         properties:CBCharacteristicPropertyRead|
                                            CBCharacteristicPropertyNotify
                                         value:nil
                                         permissions:CBAttributePermissionsReadable];
    self.rawQuatChar = [[CBMutableCharacteristic alloc]
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

    osService.characteristics = @[self.os2dChar,self.rawQuatChar,self.gestChar];
    [self.services addObject:osService];
    [self.periphMan addService:osService];

    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              TOUCH : @0,
                              SLIDE : @0,
                              TACTILE : @0,
                              };

    NSData* temp = [NSData dataWithBytes:[OpenSpatialDecoder createPointer:retDic]
                                  length:OS2DSIZE];
    self.os2dChar.value = temp;
    retDic = @{ X : @0,
                  Y : @0,
                  Z : @0,
                  W : @0,
                };

    temp = [NSData dataWithBytes:[OpenSpatialDecoder createQuatPointer:retDic]
                                  length:QUATSIZE];
    self.rawQuatChar.value = temp;

    retDic = @{ GEST : @0 };

    temp = [NSData dataWithBytes:[OpenSpatialDecoder createGestPointer:retDic]
                          length:GESTSIZE];
    self.gestChar.value = temp;

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
    NSLog(@"%@",[OpenSpatialDecoder decodeOpenSpatialPointer:data.bytes]);
    self.os2dChar.value = data;
    NSData *updatedValue = self.os2dChar.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:self.os2dChar onSubscribedCentrals:nil];
}

- (void) sendRawQuat: (NSData*) data
{
    NSLog(@"%@",[OpenSpatialDecoder decodeRawQuatPointer:data.bytes]);
    self.rawQuatChar.value = data;
    NSData *updatedValue = self.rawQuatChar.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:self.rawQuatChar onSubscribedCentrals:nil];
}

- (void) sendGesture: (NSData*) data
{
    NSLog(@"%@",[OpenSpatialDecoder decodeGestPointer:data.bytes]);
    self.gestChar.value = data;
    NSData *updatedValue = self.gestChar.value;
    [self.periphMan updateValue:updatedValue
              forCharacteristic:self.gestChar onSubscribedCentrals:nil];
}

@end











































