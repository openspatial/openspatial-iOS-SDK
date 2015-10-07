//
//  MainViewController.h
//  Example App
//
//  Copyright (c) 2015 Nod Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenSpatial/OpenSpatialBluetooth.h>
#import <CoreActionSheetPicker/CoreActionSheetPicker.h>

@interface MainViewController : UIViewController <OpenSpatialBluetoothDelegate, UITextFieldDelegate>

@property OpenSpatialBluetooth *HIDServ;
@property CBPeripheral *lastNodPeripheral;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UISwitch *dataSwitch;
- (IBAction)clearLogs:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *nodDevicePicker;
@property (weak, nonatomic) IBOutlet UITextField *dataTypePicker;
@property (nonatomic, assign) NSInteger selectedIndexDevice;
@property (nonatomic, assign) NSInteger selectedIndexDataType;
@property BOOL backspinData;

@property NSMutableArray* peripherals;
@property NSMutableArray* dataTypesRing;
@property NSMutableArray* dataTypesBackspin;

@property NSDictionary* tagsDict;

@end
