//
//  MainViewController.h
//  keyboard
//
//  Copyright (c) 2014 ënimai Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenSpatialV6414/OpenSpatialBluetooth.h>

@interface MainViewController : UIViewController <OpenSpatialBluetoothDelegate>

@property OpenSpatialBluetooth *HIDServ;
@property CBPeripheral *lastNodPeripheral;

@end